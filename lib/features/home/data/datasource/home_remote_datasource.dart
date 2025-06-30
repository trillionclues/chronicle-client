import 'package:chronicle/features/game/domain/model/game_model.dart';
import 'package:dio/dio.dart';

class HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSource({required this.dio});

  Future<GameModel> checkGameByCode(String gameCode) async {
    try {
      var result = await dio.get(
        '/games/check/$gameCode',
      );
      return GameModel.fromJson(result.data);
    } catch (e) {
      throw Exception('Failed to parse game data');
    }
  }

  Future<List<GameModel>> getActiveGames({bool? isActive}) async {
    try {
      var games = await dio.get('/games/user-games', queryParameters: {
        'isActive': isActive,
      });

      return (games.data as List)
          .map((game) => GameModel.fromJson(game))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active games');
    }
  }
}
