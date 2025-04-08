import 'package:chronicle/core/api/api_client.dart';
import 'package:chronicle/features/auth/data/datasource/user_remote_datasource.dart';
import 'package:chronicle/features/auth/data/repository/auth_repository_impl.dart';
import 'package:chronicle/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:chronicle/features/auth/data/repository/user_repository_impl.dart';
import 'package:chronicle/features/auth/domain/repository/auth_repository.dart';
import 'package:chronicle/features/auth/domain/repository/user_repository.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setup() {
  registerApiClient();
  registerDataSource();
  registerRepository();
  registerBloc();
}

void registerApiClient() {
  getIt.registerSingleton(ApiClient());
}

void registerDataSource() {
  var dio = getIt<ApiClient>().getDio();
  var dioWithTokenInterceptor =
      getIt<ApiClient>().getDio(tokenInterceptor: true);

  getIt.registerSingleton(AuthRemoteDataSource(dio: dio));
  getIt.registerSingleton(UserRemoteDataSource(dio: dioWithTokenInterceptor));
}

void registerRepository() {
  getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(authRemoteDataSource: getIt()));

  getIt.registerSingleton<UserRepository>(
      UserRepositoryImpl(userRemoteDataSource: getIt()));
}

void registerBloc() {
  getIt.registerFactory(
      () => UserBloc(authRepository: getIt(), userRepository: getIt()));
}
