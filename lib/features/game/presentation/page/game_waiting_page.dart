import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_event.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/gamecode_card_widget.dart';
import 'package:chronicle/features/game/presentation/widgets/participants_widget.dart';
import 'package:flutter/material.dart';
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
            style: ChronicleTextStyles.bodyLarge(context),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: ChronicleSpacing.sm),
              textStyle: ChronicleTextStyles.bodyLarge(context).copyWith(
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
      return Padding(
        padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GameCodeCardWidget(state: state),
            ChronicleSpacing.verticalXL,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${state.title}",
                  style: ChronicleTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                )
              ],
            ),
            ChronicleSpacing.verticalXS,
            RichText(
                text: TextSpan(
                    style: ChronicleTextStyles.bodyMedium(context),
                    children: [
                  TextSpan(text: "Round Duration: "),
                  TextSpan(
                      text: "${state.roundDuration ~/ 60} minutes",
                      style: ChronicleTextStyles.bodyMedium(context)
                          .copyWith(fontWeight: FontWeight.w500)),
                ])),
            ChronicleSpacing.verticalXS,
            RichText(
                text: TextSpan(
                    style: ChronicleTextStyles.bodyMedium(context),
                    children: [
                  TextSpan(text: "Voting Duration: "),
                  TextSpan(
                      text: "${state.votingDuration ~/ 60} minutes",
                      style: ChronicleTextStyles.bodyMedium(context)
                          .copyWith(fontWeight: FontWeight.w500)),
                ])),
            ChronicleSpacing.verticalXS,
            RichText(
                text: TextSpan(
                    style: ChronicleTextStyles.bodyMedium(context),
                    children: [
                  TextSpan(text: "Rounds: "),
                  TextSpan(
                      text: "${state.rounds}",
                      style: ChronicleTextStyles.bodyMedium(context)
                          .copyWith(fontWeight: FontWeight.w500)),
                ])),
            ChronicleSpacing.verticalLG,
            ParticipantsWidget(),
            const Spacer(),
            _buildStartGameButton(context, state),
          ],
        ),
      );
    });
  }

  Widget _buildStartGameButton(BuildContext context, GameState state) {
    final canStartGame = state.participants.length >= 2;

    return BlocBuilder<UserBloc, UserState>(builder: (context, userState) {
      return SizedBox(
        width: double.infinity,
        height: ChronicleSizes.buttonHeight,
        child: DefaultButton(
          onPressed: canStartGame &&
                  GameUtils.isCreator(
                      userState.userModel!, state.participants ?? [])
              ? () {
                  // context.read<GameBloc>().add(StartGameEvent());
                }
              : !GameUtils.isCreator(
                      userState.userModel!, state.participants ?? [])
                  ? () {
                      ChronicleSnackBar.showError(
                        context: context,
                        message: "Only the game creator can start the game.",
                      );
                    }
                  : () {
                      ChronicleSnackBar.showError(
                        context: context,
                        message: "At least 2 players required to start game.",
                      );
                    },
          backgroundColor: AppColors.primary,
          text: "Start Game",
          textColor: AppColors.textColor,
          padding: EdgeInsets.symmetric(
            vertical: ChronicleSpacing.sm,
            horizontal: ChronicleSpacing.screenPadding,
          ),
        ),
      );
    });
  }
}
