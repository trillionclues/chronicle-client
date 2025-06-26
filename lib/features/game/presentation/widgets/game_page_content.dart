import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/page/game_canceled_page.dart';
import 'package:chronicle/features/game/presentation/page/game_finished_page.dart';
import 'package:chronicle/features/game/presentation/page/game_voting_page.dart';
import 'package:chronicle/features/game/presentation/page/game_waiting_page.dart';
import 'package:chronicle/features/game/presentation/page/game_writing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/game_phase_model.dart';

class GamePageContent extends StatelessWidget {
  const GamePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GameBloc, GameState>(
        builder: (context, state) {
          switch (state.gamePhase) {
            case GamePhase.waiting:
              return const GameWaitingPage();
            case GamePhase.writing:
              return const GameWritingPage();
            case GamePhase.voting:
              return const GameVotingPage();
            case GamePhase.canceled:
              return const GameCanceledPagePage();
              case GamePhase.finished:
                return const GameFinishedPage();
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
        listener: (context, state) {
          _handleGameStateChanges(context, state);
        },
      ),
    );
  }

  void _handleGameStateChanges(BuildContext context, GameState state) {
    if (state.status == GameStatus.kicked) {
      _showKickedDialog(context);
    }
    if (state.status == GameStatus.leftGame) {
      context.pop();
    }
  }

  void _showKickedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Kicked from game!"),
        content: const Text("You have been kicked from the game."),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
