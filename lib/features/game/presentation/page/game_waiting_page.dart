import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/snackbar_extensions.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameWaitingPage extends StatelessWidget {
  const GameWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(
                Icons.chevron_left,
                size: ChronicleSizes.iconLarge,
              )),
          ChronicleSpacing.horizontalSM,
          Text(
            "Waiting for players...",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: ChronicleSpacing.sm),
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.errorColor,
                  ),
              foregroundColor: AppColors.errorColor,
              alignment: Alignment.center,
            ),
            child: Text(
              "Cancel Game",
            ),
          )
        ],
      ),
      titleSpacing: 0,
      toolbarHeight: ChronicleSizes.appBarHeight,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ChronicleSpacing.verticalXL,
            Text("Join via code",
                style: Theme.of(context).textTheme.bodyMedium),
            ChronicleSpacing.verticalMD,
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${state.gameCode}"));
                  context.showGameSnackBar(
                    "Game code copied!",
                  );
                },
                child: (Text(
                  state.gameCode ?? "No game code",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.primary, letterSpacing: 6),
                ))),
          ],
        ),
      );
    });
  }
}
