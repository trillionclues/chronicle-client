import 'dart:async';
import 'dart:developer';

import 'package:chronicle/core/api/api_config.dart';
import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/features/game/domain/game_repository.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';

class GameRemoteDatasource {
  final SocketManager _socketManager = SocketManager();
  bool _isDisposed = false;

  // Stream controllers for real time updates
  StreamController<Map<String, dynamic>>? _gameStateController;
  StreamController<String>? _errorController;
  StreamController<String>? _joinedController;

  Stream<Map<String, dynamic>> get gameStateStream =>
      _gameStateController?.stream ?? const Stream.empty();
  Stream<String> get errorStream =>
      _errorController?.stream ?? const Stream.empty();
  Stream<String> get joinedStream =>
      _joinedController?.stream ?? const Stream.empty();
  Stream<bool> get connectionStream => _socketManager.connectionStream;

  void _initializeControllers() {
    if (_isDisposed) return;

    _gameStateController?.close();
    _errorController?.close();
    _joinedController?.close();

    _gameStateController = StreamController<Map<String, dynamic>>.broadcast();
    _errorController = StreamController<String>.broadcast();
    _joinedController = StreamController<String>.broadcast();
  }

  Future<void> joinGame({
    required String gameCode,
    required GameUpdateCallback onUpdate,
    required ErrorCallback onError,
  }) async {
    if (_isDisposed) {
      onError('Datasource has been disposed');
      return;
    }

    log('🎮 Starting game join process for code: $gameCode');

    // Initialize fresh controllers
    _initializeControllers();

    // Setup stream listeners
    _setupStreamListeners(onUpdate, onError);

    // Don't dispose socket manager, just connect
    await _socketManager.connect(
      baseUrl: ApiConfig.BASE_URL,
      onGameStateUpdate: _handleGameStateUpdate,
      onError: _handleError,
      onJoined: _handleJoined,
    );

    // Wait for connection
    await Future.delayed(const Duration(milliseconds: 1000));

    if (_socketManager.isConnected && !_isDisposed) {
      log('🎮 Socket connected, joining game by code: $gameCode');
      _socketManager.joinGameByCode(gameCode);
    } else if (!_isDisposed) {
      onError('Failed to connect to game server');
    }
  }

  void _setupStreamListeners(
    GameUpdateCallback onUpdate,
    ErrorCallback onError,
  ) {
    if (_isDisposed) return;

    // Game state stream
    gameStateStream.listen(
      (data) {
        if (_isDisposed) return;
        try {
          _processGameStateUpdate(data, onUpdate, onError);
        } catch (e) {
          log('Error processing game state: $e');
          if (!_isDisposed) {
            onError('Error processing game update');
          }
        }
      },
      onError: (error) {
        log('Game state stream error: $error');
        if (!_isDisposed) {
          onError('Game state stream error');
        }
      },
    );

    // Error stream
    errorStream.listen(
      (error) {
        if (!_isDisposed) {
          onError(error);
        }
      },
      onError: (error) {
        log('Error stream error: $error');
      },
    );

    // Connection status stream
    connectionStream.listen(
      (isConnected) {
        log('Connection status changed: $isConnected');
        if (!isConnected && !_isDisposed) {
          onError('Connection lost');
        }
      },
      onError: (error) {
        log('Connection stream error: $error');
      },
    );

    // Joined events stream
    joinedStream.listen(
      (message) {
        log('✅ Successfully joined game: $message');
      },
      onError: (error) {
        log('Joined stream error: $error');
      },
    );
  }

  void _handleGameStateUpdate(Map<String, dynamic> data) {
    if (_isDisposed) return;
    log('📡 Raw game state data: $data');
    _safeAddToStream(_gameStateController, data);
  }

  void _handleError(String error) {
    if (_isDisposed) return;
    log('❌ Socket error: $error');
    _safeAddToStream(_errorController, error);
  }

  void _handleJoined(String message) {
    if (_isDisposed) return;
    log('✅ Joined: $message');
    _safeAddToStream(_joinedController, message);
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

  void _processGameStateUpdate(
    Map<String, dynamic> data,
    GameUpdateCallback onUpdate,
    ErrorCallback onError,
  ) {
    if (_isDisposed) return;

    try {
      log('🔄 Processing game state update: $data');

      if (!_validateGameStateData(data)) {
        log('❌ Invalid game state data structure');
        if (!_isDisposed) {
          onError('Invalid game data received');
        }
        return;
      }

      // Parse game phase, participants and history
      final phaseString = data['phase']?.toString() ?? 'waiting';
      final phase = _parseGamePhase(phaseString);

      final participantsList = data['participants'] as List? ?? [];
      final participants = participantsList
          .map((e) => _parseParticipant(e))
          .where((p) => p != null)
          .cast<ParticipantModel>()
          .toList();

      final historyList = data['history'] as List? ?? [];
      final history = historyList
          .map((e) => _parseStoryFragment(e))
          .where((f) => f != null)
          .cast<StoryFragmentModel>()
          .toList();

      // Update callback with parsed data
      if (!_isDisposed) {
        onUpdate(
          name: data['name']?.toString() ?? 'Unknown Game',
          gameCode: data['gameCode']?.toString() ?? '',
          phase: phase,
          currentRound: _parseInt(data['currentRound']) ?? 1,
          rounds: _parseInt(data['maxRounds']) ?? 5,
          roundTime: _parseInt(data['roundTime']) ?? 120,
          votingTime: _parseInt(data['voteTime']) ?? 60,
          remainingTime: _parseInt(data['remainingTime']),
          gameId: data['id']?.toString() ?? data['_id']?.toString() ?? '',
          participants: participants,
          history: history,
          maxParticipants: _parseInt(data['maxPlayers']) ?? 10,
        );
      }

      log('✅ Game state processed successfully');
    } catch (e, stackTrace) {
      log('❌ Error processing game state: $e\n$stackTrace');
      if (!_isDisposed) {
        onError('Error processing game update: $e');
      }
    }
  }

  bool _validateGameStateData(Map<String, dynamic> data) {
    final requiredFields = ['name', 'gameCode', 'phase'];
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        log('❌ Missing required field: $field');
        return false;
      }
    }
    return true;
  }

  GamePhase _parseGamePhase(String phaseString) {
    try {
      return GamePhase.values.firstWhere(
        (e) => e.name.toLowerCase() == phaseString.toLowerCase(),
        orElse: () => GamePhase.waiting,
      );
    } catch (e) {
      log('⚠️ Unknown game phase: $phaseString, defaulting to waiting');
      return GamePhase.waiting;
    }
  }

  ParticipantModel? _parseParticipant(dynamic participantData) {
    try {
      if (participantData is Map<String, dynamic>) {
        return ParticipantModel.fromJson(participantData);
      }
      return null;
    } catch (e) {
      log('⚠️ Error parsing participant: $e');
      return null;
    }
  }

  StoryFragmentModel? _parseStoryFragment(dynamic fragmentData) {
    try {
      if (fragmentData is Map<String, dynamic>) {
        return StoryFragmentModel.fromJson(fragmentData);
      }
      return null;
    } catch (e) {
      log('⚠️ Error parsing story fragment: $e');
      return null;
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // Delegate methods to socket manager
  Future<void> startGame(String gameId) async {
    if (!_isDisposed) {
      _socketManager.startGame(gameId);
    }
  }

  Future<void> cancelGame(String gameId) async {
    if (!_isDisposed) {
      _socketManager.cancelGame(gameId);
    }
  }

  Future<void> leaveGame(String gameId) async {
    if (!_isDisposed) {
      _socketManager.leaveGame(gameId);
    }
  }

  Future<void> submitText(String gameId, String text) async {
    if (!_isDisposed) {
      _socketManager.submitText(gameId, text);
    }
  }

  Future<void> submitVote(String gameId, String userId) async {
    if (!_isDisposed) {
      _socketManager.submitVote(gameId, userId);
    }
  }

  void dispose() {
    if (_isDisposed) return;

    log('🗑️ Disposing GameRemoteDatasource');
    _isDisposed = true;

    try {
      _gameStateController?.close();
      _errorController?.close();
      _joinedController?.close();
    } catch (e) {
      log('Error closing stream controllers: $e');
    }

    // Don't dispose socket manager here as it's a singleton
    // _socketManager.dispose();
  }
}
