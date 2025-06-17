import 'dart:developer';

import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/chronicle_appbar.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/gamecode_card_widget.dart';
import 'package:chronicle/features/game/presentation/widgets/participants_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameWritingPagePagePage extends StatelessWidget {
  const GameWritingPagePagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return ChronicleAppBar.responsiveAppBar(
      context: context,
      titleWidget: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
        return BlocBuilder<UserBloc, UserState>(builder: (context, userState) {
          final isCreator = userState.userModel != null &&
              state.participants != null &&
              state.participants!.isNotEmpty &&
              GameUtils.isCreator(userState.userModel!, state.participants!);

          return Row(
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
                "Round ${state.currentRound}/${state.rounds}",
                style: ChronicleTextStyles.bodyLarge(context),
              ),
              const Spacer(),
              if (isCreator)
                TextButton(
                  onPressed: () {
                    context.read<GameBloc>().add(CancelGameEvent());
                  },
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: ChronicleSpacing.md),
                    textStyle: ChronicleTextStyles.bodyLarge(context).copyWith(
                      color: AppColors.errorColor,
                    ),
                    foregroundColor: AppColors.errorColor,
                    alignment: Alignment.center,
                  ),
                  child: Text(
                    "Cancel Game",
                  ),
                ),
            ],
          );
        });
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      final socketManager = SocketManager();
      final bool isLoading =
          state.status == GameStatus.loading || !socketManager.isConnected;

      return Padding(
        padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameCodeCardWidget(state: state),
                  ChronicleSpacing.verticalLG,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${state.title}",
                        style: ChronicleTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      )
                    ],
                  ),
                  ChronicleSpacing.verticalXS,
                  RichText(
                      text: TextSpan(
                          style: ChronicleTextStyles.bodySmall(context),
                          children: [
                        TextSpan(text: "Round Duration: "),
                        TextSpan(
                            text: "${state.roundDuration ~/ 60} minutes",
                            style: ChronicleTextStyles.bodySmall(context)
                                .copyWith(fontWeight: FontWeight.w500)),
                      ])),
                  ChronicleSpacing.verticalXS,
                  RichText(
                      text: TextSpan(
                          style: ChronicleTextStyles.bodySmall(context),
                          children: [
                        TextSpan(text: "Voting Duration: "),
                        TextSpan(
                            text: "${state.votingDuration ~/ 60} minutes",
                            style: ChronicleTextStyles.bodySmall(context)
                                .copyWith(fontWeight: FontWeight.w500)),
                      ])),
                  ChronicleSpacing.verticalXS,
                  RichText(
                      text: TextSpan(
                          style: ChronicleTextStyles.bodySmall(context),
                          children: [
                        TextSpan(text: "Rounds: "),
                        TextSpan(
                            text: "${state.rounds}",
                            style: ChronicleTextStyles.bodySmall(context)
                                .copyWith(fontWeight: FontWeight.w500)),
                      ])),
                  ChronicleSpacing.verticalLG,
                  ParticipantsWidget(),
                ],
              ),
      );
    });
  }
}
