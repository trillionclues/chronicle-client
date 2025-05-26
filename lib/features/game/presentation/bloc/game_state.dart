import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';

enum GameStatus {
  initial,
  loading,
  success,
  error,
}

class GameState {
  final GameStatus status;
  final String? errorMessage;
  final String? gameCode;
  final String? gameId;
  final GamePhase? gamePhase;
  final String? title;
  final int? roundDuration;
  final int? votingDuration;
  final int? rounds;
  final int? remainingTime;
  final int? currentRound;
  final int? maximumParticipants;
  final List<ParticipantModel>? participants;
  final List<StoryFragmentModel>? history;

  GameState._({
    required this.status,
    this.errorMessage,
    this.gameCode,
    this.gameId,
    this.gamePhase,
    this.title,
    this.roundDuration,
    this.votingDuration,
    this.rounds,
    this.remainingTime,
    this.currentRound,
    this.maximumParticipants,
    this.participants,
    this.history,
  });

  factory GameState.initial() => GameState._(status: GameStatus.initial);

  GameState copyWith({
    GameStatus? status,
    String? errorMessage,
    String? gameCode,
    String? gameId,
    GamePhase? gamePhase,
    String? title,
    int? roundDuration,
    int? votingDuration,
    int? rounds,
    int? remainingTime,
    int? currentRound,
    int? maximumParticipants,
    List<ParticipantModel>? participants,
    List<StoryFragmentModel>? history,
  }) {
    return GameState._(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      gameCode: gameCode ?? this.gameCode,
      gameId: gameId ?? this.gameId,
      gamePhase: gamePhase ?? this.gamePhase,
      title: title ?? this.title,
      roundDuration: roundDuration ?? this.roundDuration,
      votingDuration: votingDuration ?? this.votingDuration,
      rounds: rounds ?? this.rounds,
      remainingTime: remainingTime ?? this.remainingTime,
      currentRound: currentRound ?? this.currentRound,
      maximumParticipants: maximumParticipants ?? this.maximumParticipants,
      participants: participants ?? this.participants,
      history: history ?? this.history,
    );
  }
}
