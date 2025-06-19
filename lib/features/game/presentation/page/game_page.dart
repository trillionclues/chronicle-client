import 'package:chronicle/core/di/get_it.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/widgets/game_page_content.dart';
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
      child: const GamePageContent(),
    );
  }
}
