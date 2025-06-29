import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/domain/repository/home_repository.dart';
import 'package:chronicle/features/home/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeState.initial()) {
    on<CheckGameByCodeEvent>(_onCheckGameByCodeEvent);
    on<GetActiveGamesEvent>(_onGetActiveGames);
    on<GetCompletedGamesEvent>(_onGetCompletedGames);
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

  Future _onGetActiveGames(
      GetActiveGamesEvent event, Emitter<HomeState> emit) async {
    emit(
        state.copyWith(status: HomeStatus.loadingActiveGames, activeGames: []));

    var result = await homeRepository.getActiveGames();
    if (result.isRight()) {
      emit(state.copyWith(
          status: HomeStatus.success,
          activeGames: result.right,
          errorMessage: null));
    } else {
      emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: result.left.message,
          activeGames: []));
    }
  }

  Future _onGetCompletedGames(
      GetCompletedGamesEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      status: HomeStatus.loadingCompletedGames,
      completedGames: [],
    ));

    var result = await homeRepository.getCompletedGames();
    if (result.isRight()) {
      emit(state.copyWith(
        status: HomeStatus.success,
        completedGames: result.right,
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: result.left.message,
        completedGames: [],
      ));
    }
  }
}
