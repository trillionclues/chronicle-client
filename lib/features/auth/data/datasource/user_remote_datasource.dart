import 'package:chronicle/features/auth/domain/model/user_model.dart';
import 'package:dio/dio.dart';

class UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSource({required this.dio});

  Future<UserModel> getUser() async {
    var request = await dio.get("users/profile");
    return UserModel.fromJson(request.data);
  }
}
