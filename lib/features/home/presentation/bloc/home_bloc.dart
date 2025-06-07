import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/domain/repository/home_repository.dart';
import 'package:chronicle/features/home/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeState.initial()) {
    on<CheckGameByCodeEvent>(_onCheckGameByCodeEvent);
  }

  Future _onCheckGameByCodeEvent(
      CheckGameByCodeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    var result = await homeRepository.checkGameByCode(event.gameCode);
    if (result.isRight()) {
      emit(state.copyWith(
          status: HomeStatus.successfullyCheckedGame, gameModel: result.right));
    } else {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: result.left.message));
    }
  }
}
