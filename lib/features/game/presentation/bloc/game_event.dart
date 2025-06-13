abstract class GameEvent {}

class JoinGameEvent extends GameEvent {
  final String gameCode;

  JoinGameEvent({
    required this.gameCode,
  });
}

class StartGameEvent extends GameEvent {}

class CancelGameEvent extends GameEvent {}

class KickParticipantGameEvent extends GameEvent {
  final String userId;

  KickParticipantGameEvent({required this.userId});
}

class LeaveGameEvent extends GameEvent {}
