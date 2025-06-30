import 'package:chronicle/features/game/domain/model/game_model.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus {
  initial,
  loadingJoinGame,
  loadingActiveGames,
  loadingCompletedGames,
  success,
  successfullyCheckedGame,
  error,partialSuccess
}

class HomeState extends Equatable {
  final HomeStatus status;
  final String? errorMessage;
  final GameModel? gameModel;
  final List<GameModel> activeGames;
  final List<GameModel> completedGames;

  const HomeState._(
      {required this.status,
      this.errorMessage,
      this.gameModel,
      this.activeGames = const [],
      this.completedGames = const []});

  factory HomeState.initial() {
    return const HomeState._(
      status: HomeStatus.initial,
    );
  }

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    GameModel? gameModel,
    List<GameModel>? activeGames,
    List<GameModel>? completedGames,
  }) =>
      HomeState._(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        gameModel: gameModel ?? this.gameModel,
        activeGames: activeGames ?? this.activeGames,
        completedGames: completedGames ?? this.completedGames,
      );

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        gameModel,
        activeGames,
        completedGames,
      ];
}
