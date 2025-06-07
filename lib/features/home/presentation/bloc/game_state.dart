import 'package:chronicle/features/game/domain/model/game_model.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  successfullyCheckedGame,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final String? errorMessage;
  final GameModel? gameModel;

  const HomeState._({
    required this.status,
    this.errorMessage,
    this.gameModel,
  });

  factory HomeState.initial() {
    return const HomeState._(
      status: HomeStatus.initial,
    );
  }

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    GameModel? gameModel,
  }) =>
      HomeState._(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        gameModel: gameModel ?? this.gameModel,
      );

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        gameModel,
      ];
}
