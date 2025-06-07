import 'package:chronicle/core/failure/failure.dart';
import 'package:chronicle/core/model/either.dart';
import 'package:chronicle/features/game/data/datasource/game_remote_datasource.dart';
import 'package:chronicle/features/game/domain/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDatasource gameRemoteDatasource;

  GameRepositoryImpl({required this.gameRemoteDatasource});

  @override
  Future<Either<Failure, void>> joinGame(
      {required String gameCode,
      required GameUpdateCallback onUpdate,
      required ErrorCallback onError}) async {
    try {
      return Either.right(gameRemoteDatasource.joinGame(
          gameCode: gameCode, onUpdate: onUpdate, onError: onError));
    } catch (e) {
      return Either.left(GameFailure(message: "Join game error!"));
    }
  }

  @override
  Future<Either<Failure, void>> startGame(String gameId) async {
    try {
      return Either.right(gameRemoteDatasource.startGame(gameId));
    } catch (e) {
      return Either.left(GameFailure(message: "Start game error!"));
    }
  }

  @override
  Future<Either<Failure, void>> cancelGame(String gameId) async {
    try {
      return Either.right(gameRemoteDatasource.cancelGame(gameId));
    } catch (e) {
      return Either.left(GameFailure(message: "Cancel game error!"));
    }
  }
}
