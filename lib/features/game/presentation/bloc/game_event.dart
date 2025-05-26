abstract class GameEvent{}

class JoinGameEvent extends GameEvent {
  final String gameCode;

  JoinGameEvent({
    required this.gameCode,
  });
}