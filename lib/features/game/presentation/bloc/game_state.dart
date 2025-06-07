import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:equatable/equatable.dart';

enum GameStatus {
  initial,
  loading,
  success,
  error,
}

class GameStateUpdatedEvent extends GameEvent {
  final String name;
  final String gameCode;
  final GamePhase phase;
  final String gameId;
  final int currentRound;
  final int rounds;
  final int votingTime;
  final int roundTime;
  final int? remainingTime;
  final int maxParticipants;
  final List<ParticipantModel> participants;
  final List<StoryFragmentModel> history;

  GameStateUpdatedEvent({
    required this.name,
    required this.gameCode,
    required this.phase,
    required this.gameId,
    required this.currentRound,
    required this.rounds,
    required this.votingTime,
    required this.roundTime,
    required this.remainingTime,
    required this.maxParticipants,
    required this.participants,
    required this.history,
  });
}

class GameErrorEvent extends GameEvent {
  final String errorMessage;
  GameErrorEvent({required this.errorMessage});
}

class GameState extends Equatable {
  final GameStatus status;
  final String? title;
  final String? gameCode;
  final String? gameId;
  final GamePhase gamePhase;
  final int currentRound;
  final int rounds;
  final int votingDuration;
  final int roundDuration;
  final int? remainingTime;
  final int maximumParticipants;
  final List<ParticipantModel> participants;
  final List<StoryFragmentModel> history;
  final String? errorMessage;

  const GameState._({
    required this.status,
    this.title,
    this.gameCode,
    this.gameId,
    this.gamePhase = GamePhase.waiting,
    this.currentRound = 1,
    this.rounds = 5,
    this.votingDuration = 60,
    this.roundDuration = 120,
    this.remainingTime,
    this.maximumParticipants = 10,
    this.participants = const [],
    this.history = const [],
    this.errorMessage,
  });

  factory GameState.initial() => GameState._(status: GameStatus.initial);

  GameState copyWith({
    GameStatus? status,
    String? title,
    String? gameCode,
    String? gameId,
    GamePhase? gamePhase,
    int? currentRound,
    int? rounds,
    int? votingDuration,
    int? roundDuration,
    int? remainingTime,
    int? maximumParticipants,
    List<ParticipantModel>? participants,
    List<StoryFragmentModel>? history,
    String? errorMessage,
  }) {
    return GameState._(
      status: status ?? this.status,
      title: title ?? this.title,
      gameCode: gameCode ?? this.gameCode,
      gameId: gameId ?? this.gameId,
      gamePhase: gamePhase ?? this.gamePhase,
      currentRound: currentRound ?? this.currentRound,
      rounds: rounds ?? this.rounds,
      votingDuration: votingDuration ?? this.votingDuration,
      roundDuration: roundDuration ?? this.roundDuration,
      remainingTime: remainingTime ?? this.remainingTime,
      maximumParticipants: maximumParticipants ?? this.maximumParticipants,
      participants: participants ?? this.participants,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        title,
        gameCode,
        gameId,
        gamePhase,
        currentRound,
        rounds,
        votingDuration,
        roundDuration,
        remainingTime,
        maximumParticipants,
        participants,
        history,
        errorMessage,
      ];
}
