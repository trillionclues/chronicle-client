import 'package:chronicle/core/api/api_client.dart';
import 'package:chronicle/features/auth/data/datasource/user_remote_datasource.dart';
import 'package:chronicle/features/auth/data/repository/auth_repository_impl.dart';
import 'package:chronicle/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:chronicle/features/auth/data/repository/user_repository_impl.dart';
import 'package:chronicle/features/auth/domain/repository/auth_repository.dart';
import 'package:chronicle/features/auth/domain/repository/user_repository.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/create_game/data/datasource/create_game_remote_datasource.dart';
import 'package:chronicle/features/create_game/data/repository/create_game_repository.impl.dart';
import 'package:chronicle/features/create_game/domain/repository/create_game_repository.dart';
import 'package:chronicle/features/create_game/presentation/bloc/create_game_bloc.dart';
import 'package:chronicle/features/game/data/datasource/game_remote_datasource.dart';
import 'package:chronicle/features/game/data/repository/game_repository_impl.dart';
import 'package:chronicle/features/game/domain/game_repository.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
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
  getIt.registerSingleton(
      CreateGameRemoteDatasource(dio: dioWithTokenInterceptor));

  getIt.registerSingleton(GameRemoteDatasource());
}

void registerRepository() {
  getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(authRemoteDataSource: getIt()));

  getIt.registerSingleton<UserRepository>(
      UserRepositoryImpl(userRemoteDataSource: getIt()));

  getIt.registerSingleton<CreateGameRepository>(
      CreateGameRepositoryImpl(createGameRemoteDataSource: getIt()));

  getIt.registerSingleton<GameRepository>(
      GameRepositoryImpl(gameRemoteDatasource: getIt()));
}

void registerBloc() {
  getIt.registerFactory(
      () => UserBloc(authRepository: getIt(), userRepository: getIt()));

  getIt.registerFactory(() => CreateGameBloc(createGameRepository: getIt()));

  getIt.registerFactory(() => GameBloc(gameRepository: getIt()));
}
