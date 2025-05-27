import 'package:chronicle/features/game/domain/game_repository.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;

  GameBloc({required this.gameRepository}) : super(GameState.initial()) {
   on<JoinGameEvent>(onJoinGameEvent);
  }

  Future onJoinGameEvent(JoinGameEvent event, Emitter emit) async {
    emit(state.copyWith(status: GameStatus.initial));
    gameRepository.joinGame(gameCode: event.gameCode, onUpdate: onGameUpdate, onError: onErrorCallback);
  }



  void onGameUpdate({
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
    emit(state.copyWith(
      gamePhase: phase,
      gameCode: gameCode,
      gameId: gameId,
      currentRound: currentRound,
      rounds: rounds,
      votingDuration: votingTime,
      participants: participants,
      history: history,
      maximumParticipants: maxParticipants,
      remainingTime: remainingTime,
      roundDuration: roundTime,
      title: name,
    ));
  }

  void onErrorCallback(String errorMessage) {
    emit(state.copyWith(
      status: GameStatus.error,
      errorMessage: errorMessage,
    ));

  }
}
