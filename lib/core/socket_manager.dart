import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  IO.Socket? _socket;
  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  bool _isDisposed = false;
  String? _currentGameId;
  String? _baseUrl;

  StreamController<bool>? _connectionController;
  Stream<bool> get connectionStream =>
      _connectionController?.stream ?? const Stream.empty();

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({
    required String baseUrl,
    required Function(Map<String, dynamic>) onGameStateUpdate,
    required Function(String) onError,
    required Function(String) onJoined,
    required Function() onKicked,
    required Function() onLeft,
  }) async {
    if (_isConnecting || _isDisposed) {
      log('⚠️ Already connecting or disposed, skipping...');
      return;
    }
    _isConnecting = true;
    _baseUrl = baseUrl;

    try {
      // Initialize connection controller if not exists or closed
      if (_connectionController == null || _connectionController!.isClosed) {
        _connectionController = StreamController<bool>.broadcast();
      }

      await _disconnect();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isConnecting = false;
        onError('User not authenticated');
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        onError('Failed to get authentication token');
        return;
      }

      // Create socket with comprehensive options
      final socketOptions = IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .setTimeout(15000)
          .enableReconnection()
          .setReconnectionAttempts(3)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          })
          .build();

      _socket = IO.io(baseUrl, socketOptions);

      log('🚀 Socket instance created, setting up listeners...');
      _setupEventListeners(
          onGameStateUpdate, onError, onJoined, onKicked, onLeft);

      // Enhanced connection handling with detailed logging
      final completer = Completer<bool>();
      Timer? timeoutTimer;
      bool connectionAttempted = false;

      // Connection success handler
      _socket!.onConnect((_) {
        connectionAttempted = true;
        if (!completer.isCompleted) {
          completer.complete(true);
          timeoutTimer?.cancel();
        }
      });

      // Connection error handler
      _socket!.onConnectError((error) {
        log('❌ Socket connection error: $error');
        connectionAttempted = true;
        if (!completer.isCompleted) {
          completer.complete(false);
          timeoutTimer?.cancel();
        }
      });

      // Disconnect handler (for immediate disconnections)
      _socket!.onDisconnect((reason) {
        log('🔌 Socket disconnected during connection: $reason');
        if (!connectionAttempted && !completer.isCompleted) {
          completer.complete(false);
          timeoutTimer?.cancel();
        }
      });

      // Timeout handler
      timeoutTimer = Timer(const Duration(seconds: 20), () {
        log('⏰ Socket connection timeout after 20 seconds');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      log('🔄 Initiating socket connection...');
      _socket!.connect();

      // Wait for connection result
      final connected = await completer.future;
      _isConnecting = false;

      if (connected && !_isDisposed) {
        log('🎉 Socket connection established successfully');
        _startKeepAlive();
      } else if (!_isDisposed) {
        log('💥 Socket connection failed');
        onError(
            'Failed to connect to game server. Please check your internet connection and try again.');
        await _disconnect();
      }
    } catch (e, stackTrace) {
      log('🚨 Socket connection exception: $e');
      log('📍 Stack trace: $stackTrace');
      if (!_isDisposed) {
        onError('Connection error: $e');
      }
      _isConnecting = false;
    }
  }

  void _setupEventListeners(
    Function(Map<String, dynamic>) onGameStateUpdate,
    Function(String) onError,
    Function(String) onJoined,
    Function() onKicked,
    Function() onLeft,
  ) {
    if (_socket == null) return;

    log('🎧 Setting up socket event listeners...');

    _socket!.onConnect((_) {
      log('✅ Socket connected - setting up streams');
      _isConnecting = false;
      _isReconnecting = false;
      _reconnectTimer?.cancel();
      _safeAddToStream(_connectionController, true);
      _startKeepAlive();
    });

    _socket!.onDisconnect((reason) {
      log('❌ Socket disconnected: $reason');
      _safeAddToStream(_connectionController, false);
      _keepAliveTimer?.cancel();

      // Only attempt reconnection for unexpected disconnections
      if (!_isReconnecting &&
          !_isDisposed &&
          reason != 'io client disconnect') {
        log('🔄 Scheduling reconnection due to: $reason');
        _attemptReconnect(
            onGameStateUpdate, onError, onJoined, onKicked, onLeft);
      }
    });

    _socket!.onConnectError((error) {
      log('❌ Socket connection error in listener: $error');
      _safeAddToStream(_connectionController, false);
      if (!_isDisposed) {
        onError('Connection error: $error');
      }
    });

    _socket!.onError((error) {
      log('❌ Socket error: $error');
      if (!_isDisposed) {
        onError('Socket error: $error');
      }
    });

    // Game-specific event handlers
    _socket!.on('gameStateUpdate', (data) {
      if (_isDisposed) return;
      try {
        log('📡 Received gameStateUpdate');
        if (data is Map<String, dynamic>) {
          onGameStateUpdate(data);
        } else {
          log('⚠️ Invalid gameStateUpdate format: ${data.runtimeType}');
        }
      } catch (e) {
        log('Error handling gameStateUpdate: $e');
      }
    });

    _socket!.on('joined', (data) {
      if (_isDisposed) return;
      try {
        log('✅ Received joined event: $data');
        if (data is Map<String, dynamic>) {
          if (data['gameId'] != null) {
            _currentGameId = data['gameId'].toString();
          }
          onJoined(data['message'] ?? 'Joined successfully');
        } else if (data is String) {
          onJoined(data);
        }
      } catch (e) {
        log('Error handling joined event: $e');
      }
    });

    _socket!.on('error', (data) {
      if (_isDisposed) return;
      try {
        log('❌ Received error event: $data');
        String errorMessage = 'Unknown error';
        if (data is Map<String, dynamic> && data['message'] != null) {
          errorMessage = data['message'];
        } else if (data is String) {
          errorMessage = data;
        }
        onError(errorMessage);
      } catch (e) {
        log('Error handling error event: $e');
      }
    });

    _socket!.on('kicked', (data) {
      if (_isDisposed) return;
      try {
        log('👢 Received kicked event: $data');
        onKicked.call();
      } catch (e) {
        log('Error handling kicked event: $e');
      }
    });

    _socket!.on('leftGame', (data) {
      if (_isDisposed) return;
      try {
        log('🏁 Received gameEnded event: $data');
        onLeft.call();
      } catch (e) {
        log('Error handling gameEnded event: $e');
      }
    });

    log('✅ All event listeners set up');
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_socket?.connected == true && !_isDisposed) {
        _socket?.emit('ping');
        log('📡 Keep-alive ping sent');
      }
    });
  }

  void _safeAddToStream<T>(StreamController<T>? controller, T data) {
    if (controller != null && !controller.isClosed && !_isDisposed) {
      try {
        controller.add(data);
      } catch (e) {
        log('Error adding to stream: $e');
      }
    }
  }

  void _attemptReconnect(
    Function(Map<String, dynamic>) onGameStateUpdate,
    Function(String) onError,
    Function(String) onJoined,
    Function() onKicked,
    Function() onLeft,
  ) {
    if (_isReconnecting || _isDisposed) return;
    _isReconnecting = true;

    log('🔄 Starting reconnection attempts...');

    int attempts = 0;
    _reconnectTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      attempts++;
      log('🔄 Reconnection attempt $attempts/5');

      if (_socket?.connected == true) {
        log('✅ Reconnection successful');
        timer.cancel();
        _isReconnecting = false;

        if (_currentGameId != null) {
          log('🎮 Rejoining game: $_currentGameId');
          joinGame(_currentGameId!);
        }
      } else if (attempts <= 5) {
        try {
          // Create a completely new connection
          await connect(
            baseUrl: _baseUrl!,
            onGameStateUpdate: onGameStateUpdate,
            onError: onError,
            onJoined: onJoined,
            onKicked: onKicked,
            onLeft: onLeft,
          );

          if (_socket?.connected == true) {
            timer.cancel();
            _isReconnecting = false;
          }
        } catch (e) {
          log('Failed reconnection attempt $attempts: $e');
        }
      } else {
        timer.cancel();
        _isReconnecting = false;
        if (!_isDisposed) {
          onError('Failed to reconnect after 5 attempts');
        }
      }
    });
  }

  void joinGame(String gameId) {
    if (!isConnected || _isDisposed) {
      log('❌ Cannot join game: Socket not connected or disposed');
      return;
    }

    log('🎮 Joining game: $gameId');
    _currentGameId = gameId;
    _socket?.emit('joinGame', gameId);
  }

  void joinGameByCode(String gameCode) {
    if (!isConnected || _isDisposed) {
      log('❌ Cannot join game by code: Socket not connected or disposed');
      return;
    }
    log('🎮 Joining game by code: $gameCode');
    _socket?.emit('joinGameByCode', gameCode);
  }

  void startGame(String gameId) {
    if (!isConnected || _isDisposed) return;
    log('▶️ Starting game: $gameId');
    _socket?.emit('startGame', gameId);
  }

  void cancelGame(String gameId) {
    if (!isConnected || _isDisposed) return;
    log('❌ Canceling game: $gameId');
    _socket?.emit('cancelGame', gameId);
  }

  void leaveGame(String gameId) {
    if (!isConnected || _isDisposed) return;
    log('🚪 Leaving game: $gameId');
    _socket?.emit('leaveGame', gameId);
    _currentGameId = null;
  }

  void kickParticipant(String gameId, String userId) {
    if (!isConnected || _isDisposed) return;
    log('👢 Kicking participant: $userId from game: $gameId');
    _socket
        ?.emit('kickParticipant', {'gameId': gameId, 'participantId': userId});
  }

  void submitFragment(String gameId, String text) {
    if (!isConnected || _isDisposed) return;
    log('📝 Submitting text for game: $gameId');
    _socket?.emit('submitText', {'gameId': gameId, 'text': text});
  }

  void submitVote(String gameId, String userId) {
    if (!isConnected || _isDisposed) return;
    log('🗳️ Submitting vote for game: $gameId');
    _socket?.emit('submitVote', {'gameId': gameId, 'votedFor': userId});
  }

  Future<void> _disconnect() async {
    try {
      _reconnectTimer?.cancel();
      _keepAliveTimer?.cancel();
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _currentGameId = null;
      _safeAddToStream(_connectionController, false);
      log('🔌 Socket disconnected and cleaned up');
    } catch (e) {
      log('Error disconnecting socket: $e');
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;

    log('🗑️ Disposing SocketManager');
    _isDisposed = true;

    await _disconnect();

    try {
      await _connectionController?.close();
      _connectionController = null;
    } catch (e) {
      log('Error closing connection controller: $e');
    }
  }
}
