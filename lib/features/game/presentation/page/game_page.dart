import 'dart:developer';

import 'package:chronicle/core/di/get_it.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/page/game_canceled_page.dart';
import 'package:chronicle/features/game/presentation/page/game_waiting_page.dart';
import 'package:chronicle/features/home/presentation/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        body: BlocConsumer<GameBloc, GameState>(
          builder: (context, state) {
            if (state.gamePhase == GamePhase.waiting) {
              return GameWaitingPage();
            }
            if(state.gamePhase == GamePhase.canceled) {
              return GameCanceledPagePage();
            }
            return Center(
              child: Text(
                "${state.title}",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            );
          },
          listener: (context, state) {
            if (state.status == GameStatus.kicked) {
              //  alert dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Kicked from game!"),
                    content: Text("You have been kicked from the game."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.pop();
                          context.pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            } else if (state.status == GameStatus.leftGame) {
              context.pop();
            }
          },
        ),
      ),
    );
  }
}
