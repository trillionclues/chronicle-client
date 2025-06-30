import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/domain/repository/home_repository.dart';
import 'package:chronicle/features/home/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeState.initial()) {
    on<CheckGameByCodeEvent>(_onCheckGameByCodeEvent);
    on<GetAllGamesEvent>(_onGetAllGames);
  }

  Future _onCheckGameByCodeEvent(
      CheckGameByCodeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loadingJoinGame));
    var result = await homeRepository.checkGameByCode(event.gameCode);
    if (result.isRight()) {
      emit(state.copyWith(
          status: HomeStatus.successfullyCheckedGame, gameModel: result.right));
    } else {
      emit(state.copyWith(
          status: HomeStatus.error, errorMessage: result.left.message));
    }
  }

  Future<void> _onGetAllGames(
      GetAllGamesEvent event,
      Emitter<HomeState> emit
      ) async {
    try {
      emit(state.copyWith(
        status: HomeStatus.loadingActiveGames,
        activeGames: const [],
        completedGames: const [],
        errorMessage: null,
      ));

      final activeResult = await homeRepository.getActiveGames();
      if (activeResult.isLeft()) {
        emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: activeResult.left.message,
        ));
        return;
      }

      emit(state.copyWith(
        status: HomeStatus.loadingCompletedGames,
        activeGames: activeResult.right,
      ));

      final completedResult = await homeRepository.getCompletedGames();
      if (completedResult.isLeft()) {
        emit(state.copyWith(
          status: HomeStatus.partialSuccess,
          activeGames: activeResult.right,
          completedGames: const [],
          errorMessage: completedResult.left.message,
        ));
        return;
      }
      emit(state.copyWith(
        status: HomeStatus.success,
        activeGames: activeResult.right,
        completedGames: completedResult.right,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Unexpected error: ${e.toString()}',
        activeGames: const [],
        completedGames: const [],
      ));
    }
  }
}
