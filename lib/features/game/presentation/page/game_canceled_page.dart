
import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/app_mode_bloc.dart';
import 'package:chronicle/core/utils/chronicle_appbar.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/gamecode_card_widget.dart';
import 'package:chronicle/features/game/presentation/widgets/participants_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameCanceledPagePage extends StatelessWidget {
  const GameCanceledPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppModeBloc, AppMode>(builder: (context, currentMode) {
      return Scaffold(
        appBar: _buildAppBar(context, currentMode),
        body: _buildBody(context, currentMode),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context, AppMode currentMode) {
    return ChronicleAppBar.responsiveAppBar(
      context: context,
      titleWidget: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
        return BlocBuilder<UserBloc, UserState>(builder: (context, userState) {

          return Row(
            children: [
              ChronicleSpacing.horizontalSM,
              Text(
                "Game Canceled",
                style: ChronicleTextStyles.bodyLarge(context),
              ),
            ],
          );
        });
      }),
      showBackButton: true,
    );
  }

  Widget _buildBody(BuildContext context, AppMode currentMode) {
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
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameCodeCardWidget(state: state, mode: currentMode.displayName),
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
        ),
      );
    });
  }
}
