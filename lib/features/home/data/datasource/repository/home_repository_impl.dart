import 'package:chronicle/core/failure/failure.dart';
import 'package:chronicle/core/model/either.dart';
import 'package:chronicle/features/game/domain/model/game_model.dart';
import 'package:chronicle/features/home/data/datasource/home_remote_datasource.dart';
import 'package:chronicle/features/home/domain/repository/home_repository.dart';
import 'package:dio/dio.dart';

class HomeRepositoryImpl extends HomeRepository {
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepositoryImpl({
    required this.homeRemoteDataSource,
  });

  @override
  Future<Either<Failure, GameModel>> checkGameByCode(String gameCode) async {
    try {
      var result = await homeRemoteDataSource.checkGameByCode(gameCode);
      return Either.right(result);
    } on DioException catch (e) {
      return Either.left(GameFailure(message: e.response?.data['error']));
    } catch (e) {
      return Either.left(GameFailure(message: 'Join game failed!'));
    }
  }

  @override
  Future<Either<Failure, List<GameModel>>> getCompletedGames() async {
    try {
      var games = await homeRemoteDataSource.getCompletedGames();
      final completedGames = games.where((game) => game.isFinished).toList();
      return Either.right(completedGames);
    } on DioException catch (e) {
      return Either.left(GameFailure(
          message: e.response?.data['error'] ?? 'Failed to fetch completed games'
      ));
    } catch (e) {
      return Either.left(GameFailure(
        message: 'Failed to load completed games: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<GameModel>>> getActiveGames() async {
    try {
      var games = await homeRemoteDataSource.getActiveGames();
      final activeGames = games.where((game) => !game.isFinished).toList();
      return Either.right(activeGames);

    } on DioException catch (e) {
      return Either.left(GameFailure(
          message: e.response?.data['error'] ?? 'Failed to fetch active games'
      ));
    } catch (e) {
      return Either.left(GameFailure(
        message: 'Failed to load active games: ${e.toString()}',
      ));
    }
  }
}
