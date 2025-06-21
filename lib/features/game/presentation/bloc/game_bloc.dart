import 'dart:async';
import 'dart:developer';

import 'package:chronicle/features/game/domain/game_repository.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;
  StreamSubscription? _gameSubscription;
  bool _disposed = false;

  GameBloc({required this.gameRepository}) : super(GameState.initial()) {
    on<JoinGameEvent>(_onJoinGameEvent);
    on<StartGameEvent>(_onStartGameEvent);
    on<CancelGameEvent>(_onCancelGameEvent);
    on<GameStateUpdatedEvent>(_onGameStateUpdateEvent);
    on<GameErrorEvent>(_onGameErrorEvent);
    on<KickParticipantGameEvent>(_onKickParticipantEvent);
    on<LeaveGameEvent>(_onGameLeaveEvent);
    on<SubmitFragmentEvent>(_onSubmitFragmentEvent);
    on<SubmitVoteEvent>(_onSubmitVoteEvent);
    on<DisposeGameEvent>(_onDisposeGameEvent);
  }

  Future<void> _onJoinGameEvent(
      JoinGameEvent event, Emitter<GameState> emit) async {
    if (_disposed) return;

    emit(state.copyWith(status: GameStatus.loading));

    try {
      await gameRepository.joinGame(
        gameCode: event.gameCode,
        onUpdate: _onGameUpdate,
        onError: _onErrorCallback,
        onKicked: _onKickedCallback,
        onLeft: _onLeftCallback,
      );
    } catch (e) {
      if (!_disposed) {
        emit(state.copyWith(
          status: GameStatus.error,
          errorMessage: 'Failed to join game: $e',
        ));
      }
    }
  }

  Future<void> _onStartGameEvent(
      StartGameEvent event, Emitter<GameState> emit) async {
    if (_disposed) return;

    emit(state.copyWith(status: GameStatus.loading));

    try {
      if (state.gameId != null) {
        emit(state.copyWith(status: GameStatus.loading));
        await gameRepository.startGame(
          state.gameId!,
        );
      }
    } catch (e) {
      if (!_disposed) {
        emit(state.copyWith(
          status: GameStatus.error,
          errorMessage: 'Failed to start game: $e',
        ));
      }
    }
  }

  Future<void> _onCancelGameEvent(
      CancelGameEvent event, Emitter<GameState> emit) async {
    if (_disposed) return;

    try {
      if (state.gameId != null) {
        emit(state.copyWith(status: GameStatus.loading));
        await gameRepository.cancelGame(state.gameId!);
      }
    } catch (e) {
      if (!_disposed) {
        emit(state.copyWith(
          status: GameStatus.error,
          errorMessage: 'Failed to cancel game: $e',
        ));
      }
    }
  }

  void _onGameStateUpdateEvent(
      GameStateUpdatedEvent event, Emitter<GameState> emit) {
    if (_disposed) return; // Check if disposed

    emit(state.copyWith(
      status: GameStatus.success,
      title: event.name,
      gameCode: event.gameCode,
      gameId: event.gameId,
      gamePhase: event.phase,
      currentRound: event.currentRound,
      rounds: event.rounds,
      votingDuration: event.votingTime,
      roundDuration: event.roundTime,
      remainingTime: event.remainingTime,
      maximumParticipants: event.maxParticipants,
      participants: event.participants,
      history: event.history,
      errorMessage: null,
    ));
  }

  void _onGameErrorEvent(GameErrorEvent event, Emitter<GameState> emit) {
    if (_disposed) return;

    emit(state.copyWith(
      status: GameStatus.error,
      errorMessage: event.errorMessage,
    ));
  }

  void _onKickParticipantEvent(
      KickParticipantGameEvent event, Emitter<GameState> emit) {
    if (_disposed) return;

    if (state.gameId != null) {
      gameRepository.kickParticipant(state.gameId!, event.userId);
    }

    emit(state.copyWith(
        status: GameStatus.kicked,
        errorMessage: 'You have been kicked from the game.'));
  }

  void _onGameLeaveEvent(LeaveGameEvent event, Emitter<GameState> emit) {
    if (_disposed) return;

    if (state.gameId != null) {
      gameRepository.leaveGame(state.gameId!);
    }

    emit(state.copyWith(
        status: GameStatus.leftGame, errorMessage: 'You have left the game.'));
  }

  Future<void> _onSubmitFragmentEvent(
      SubmitFragmentEvent event, Emitter<GameState> emit) async {
    if (_disposed) return;

    emit(state.copyWith(status: GameStatus.loading));

    try {
      if (state.gameId != null) {
        await gameRepository.submitFragment(state.gameId!, event.text);
      }
    } catch (e) {
      emit(state.copyWith(
        status: GameStatus.error,
        errorMessage: "Failed to submit fragment: $e",
      ));
    }
  }

  void _onSubmitVoteEvent(SubmitVoteEvent event, Emitter<GameState> emit) {
    if (_disposed) return;

    if (state.gameId != null) {
      gameRepository.submitVote(state.gameId!, event.userId);
    }

    emit(state.copyWith(
      status: GameStatus.success,
      errorMessage: "Text submitted successfully!",
    ));
  }

  void _onDisposeGameEvent(DisposeGameEvent event, Emitter<GameState> emit) {
    _disposed = true;
    _gameSubscription?.cancel();
  }

  void _onGameUpdate({
    required String name,
    required String gameCode,
    required GamePhase phase,
    required String gameId,
    required int currentRound,
    required int rounds,
    required int votingTime,
    required int roundTime,
    required int? remainingTime,
    required int maxParticipants,
    required List<ParticipantModel> participants,
    required List<StoryFragmentModel> history,
  }) {
    if (_disposed) return;

    try {
      add(GameStateUpdatedEvent(
        name: name,
        gameCode: gameCode,
        phase: phase,
        gameId: gameId,
        currentRound: currentRound,
        rounds: rounds,
        votingTime: votingTime,
        roundTime: roundTime,
        remainingTime: remainingTime,
        maxParticipants: maxParticipants,
        participants: participants,
        history: history,
      ));
    } catch (e) {
      log('❌ GameBloc: Error adding game update event: $e');
    }
  }

  void _onErrorCallback(String errorMessage) {
    if (_disposed) return;
    try {
      add(GameErrorEvent(errorMessage: errorMessage));
    } catch (e) {
      log('❌ GameBloc: Error adding error event: $e');
    }
  }

  void _onKickedCallback() {
    if (_disposed) return;
    try {
      if (state.gameId != null) {
        add(KickParticipantGameEvent(userId: state.gameId!));
      }
    } catch (e) {
      log('❌ GameBloc: Error adding kicked event: $e');
    }
  }

  void _onLeftCallback() {
    if (_disposed) return;
    try {
      add(LeaveGameEvent());
    } catch (e) {
      log('❌ GameBloc: Error adding kicked event: $e');
    }
  }

  @override
  Future<void> close() {
    // Add dispose event before closing
    if (!_disposed) {
      add(DisposeGameEvent());
    }
    return super.close();
  }
}

class DisposeGameEvent extends GameEvent {}
