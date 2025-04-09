import 'package:dio/dio.dart';

class CreateGameRemoteDatasource {
  final Dio dio;

  CreateGameRemoteDatasource({required this.dio});

  Future<String> createGame(
      {required String title,
      required int rounds,
      required int roundDuration,
      required int votingDuration,
      required int maximumParticipants}) async {
    final response = await dio.post(
      '/games/create',
      data: {
        "name": title,
        "maxRounds": rounds,
        "roundTime": roundDuration * 60,
        "voteTime": votingDuration * 60,
        "maxPlayers": maximumParticipants,
      },
    );
    return response.data["gameCode"];
  }
}
