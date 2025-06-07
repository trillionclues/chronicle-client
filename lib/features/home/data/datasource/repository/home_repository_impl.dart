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
    var result = await homeRemoteDataSource.checkGameByCode(gameCode);
    return Either.right(result);
    try {

    } on DioException catch (e) {
      return Either.left(GameFailure(message: e.response?.data['error']));
    } catch (e) {
      return Either.left(GameFailure(message: 'Join game failed!'));
    }
  }
}
