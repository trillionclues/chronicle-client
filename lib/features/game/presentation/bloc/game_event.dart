abstract class GameEvent {}

class JoinGameEvent extends GameEvent {
  final String gameCode;

  JoinGameEvent({
    required this.gameCode,
  });
}

class StartGameEvent extends GameEvent {}
