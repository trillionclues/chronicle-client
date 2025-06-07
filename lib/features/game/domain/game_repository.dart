import 'package:chronicle/core/failure/failure.dart';
import 'package:chronicle/core/model/either.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';

typedef GameUpdateCallback = Function({
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
});

typedef ErrorCallback = Function(String errorMessage);

abstract class GameRepository {
  Future<Either<Failure, void>> joinGame({
    required String gameCode,required GameUpdateCallback onUpdate,required ErrorCallback onError,
  });

  Future<Either<Failure, void>> startGame(String gameId);
}