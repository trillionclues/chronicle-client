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
  bool _isConnecting = false;
  bool _isReconnecting = false;
  bool _isDisposed = false;
  String? _currentGameId;

  StreamController<bool>? _connectionController;
  Stream<bool> get connectionStream =>
      _connectionController?.stream ?? const Stream.empty();

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({
    required String baseUrl,
    required Function(Map<String, dynamic>) onGameStateUpdate,
    required Function(String) onError,
    required Function(String) onJoined,
  }) async {
    if (_isConnecting || _isDisposed) {
      log('⚠️ Already connecting or disposed, skipping...');
      return;
    }
    _isConnecting = true;

    try {
      // Initialize connection controller if not exists or closed
      if (_connectionController == null || _connectionController!.isClosed) {
        _connectionController = StreamController<bool>.broadcast();
      }

      await _disconnect();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        onError('User not authenticated');
        _isConnecting = false;
        return;
      }

      final token = await user.getIdToken(true);
      if (token!.isEmpty) {
        onError('Failed to get authentication token');
        _isConnecting = false;
        return;
      }

      log('Connecting to socket with URL: $baseUrl');
      log('Token length: ${token.length}');
      log('User ID: ${user.uid}');

      final socketOptions = IO.OptionBuilder()
          .setExtraHeaders({'authorization': token})
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .setTimeout(15000)
          .enableReconnection()
          .setReconnectionAttempts(3)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(5000)
          .build();

      _socket = IO.io(baseUrl, socketOptions);
      _setupEventListeners(onGameStateUpdate, onError, onJoined);

      // Use a completer to properly handle connection timeout
      final completer = Completer<bool>();
      Timer? timeoutTimer;

      late StreamSubscription connectSub;
      late StreamSubscription errorSub;

      connectSub = _socket!.onConnect((_) {
        if (!completer.isCompleted) {
          completer.complete(true);
          timeoutTimer?.cancel();
          connectSub.cancel();
          errorSub.cancel();
        }
      }) as StreamSubscription;

      errorSub = _socket!.onConnectError((error) {
        if (!completer.isCompleted) {
          completer.complete(false);
          timeoutTimer?.cancel();
          connectSub.cancel();
          errorSub.cancel();
        }
      }) as StreamSubscription;

      timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          completer.complete(false);
          connectSub.cancel();
          errorSub.cancel();
        }
      });

      _socket!.connect();
      final connected = await completer.future;
      _isConnecting = false;

      if (!connected && !_isDisposed) {
        log('❌ Connection failed after timeout');
        onError('Connection timeout');
        await _disconnect();
      }
    } catch (e) {
      log('Socket connection error: $e');
      if (!_isDisposed) {
        onError('Failed to connect: $e');
      }
      _isConnecting = false;
    }
  }

  void _setupEventListeners(
      Function(Map<String, dynamic>) onGameStateUpdate,
      Function(String) onError,
      Function(String) onJoined,
      ) {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      log('✅ Socket connected successfully');
      _isConnecting = false;
      _isReconnecting = false;
      _reconnectTimer?.cancel();
      _safeAddToStream(_connectionController, true);
    });

    _socket!.onDisconnect((reason) {
      log('❌ Socket disconnected: $reason');
      _safeAddToStream(_connectionController, false);
      if (!_isReconnecting && !_isDisposed && reason != 'io client disconnect') {
        _attemptReconnect(onGameStateUpdate, onError, onJoined);
      }
    });

    _socket!.onConnectError((error) {
      log('❌ Socket connection error: $error');
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

    _socket!.on('gameStateUpdate', (data) {
      if (_isDisposed) return;
      try {
        log('📡 Received gameStateUpdate: $data');
        if (data is Map<String, dynamic>) {
          onGameStateUpdate(data);
        } else {
          log('⚠️ Invalid gameStateUpdate data format: $data');
        }
      } catch (e) {
        log('Error handling gameStateUpdate: $e');
      }
    });

    _socket!.on('joined', (data) {
      if (_isDisposed) return;
      try {
        log('✅ Joined game: $data');
        if (data is Map<String, dynamic> && data['gameId'] != null) {
          _currentGameId = data['gameId'].toString();
          onJoined(data['message'] ?? 'Joined successfully');
        }
      } catch (e) {
        log('Error handling joined event: $e');
      }
    });

    _socket!.on('error', (data) {
      if (_isDisposed) return;
      try {
        log('❌ Game error: $data');
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
        log('👢 Kicked from game: $data');
        onError('You have been kicked from the game');
      } catch (e) {
        log('Error handling kicked event: $e');
      }
    });

    _socket!.on('gameEnded', (data) {
      if (_isDisposed) return;
      try {
        log('🏁 Game ended: $data');
        onError('Game has ended');
      } catch (e) {
        log('Error handling gameEnded event: $e');
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
      ) {
    if (_isReconnecting || _isDisposed) return;
    _isReconnecting = true;

    log('🔄 Starting reconnection attempts...');

    int attempts = 0;
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      attempts++;

      if (_socket?.connected == true) {
        log('✅ Reconnection successful');
        timer.cancel();
        _isReconnecting = false;

        if (_currentGameId != null) {
          joinGame(_currentGameId!);
        }
      } else if (attempts <= 3) {
        log('🔄 Reconnection attempt $attempts');

        try {
          final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
          if (token != null && !_isDisposed) {
            _socket?.io.options?['extraHeaders'] = {'authorization': token};
            _socket?.connect();
          }
        } catch (e) {
          log('Failed to refresh token for reconnection: $e');
        }
      } else {
        timer.cancel();
        _isReconnecting = false;
        if (!_isDisposed) {
          onError('Failed to reconnect after multiple attempts');
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
      log('❌ Cannot join game: Socket not connected or disposed');
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

  void submitText(String gameId, String text) {
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
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _currentGameId = null;
      _safeAddToStream(_connectionController, false);
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