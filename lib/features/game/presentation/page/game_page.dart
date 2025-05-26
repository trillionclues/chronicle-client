import 'package:chronicle/core/di/get_it.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/page/game_waiting_page.dart';
import 'package:chronicle/features/home/presentation/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamePage extends StatelessWidget {
  final String gameCode;

  const GamePage({super.key, required this.gameCode});

  static String route(String gameCode) {
    return '${HomePage.route}/game/$gameCode';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<GameBloc>()..add(JoinGameEvent(gameCode: gameCode)),
      child: Scaffold(
        body: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
          if(state.gamePhase == GamePhase.waiting) {
            return GameWaitingPage();
          }
          return Center(
            child: Text("${state.title}", style: Theme.of(context).textTheme.headlineLarge,),
        );
        }),
      ),
    );
  }
}
