import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:chronicle/features/game/presentation/widgets/gamecode_card_widget.dart';
import 'package:chronicle/features/game/presentation/widgets/participants_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameWaitingPage extends StatelessWidget {
  const GameWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamePhaseAppbar(
        title: "Waiting for players...",
        showBackButton: true,
        actionText: "Cancel Game",
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final socketManager = SocketManager();
        final bool isLoading =
            state.status == GameStatus.loading || !socketManager.isConnected;

        return isLoading
            ? const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        )
            : Column(
          children: [
            Container(
              padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
              child: GameCodeCardWidget(state: state),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ChronicleSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChronicleSpacing.verticalLG,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${state.title}",
                          style: ChronicleTextStyles.bodyLarge(context)
                              .copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        ChronicleSpacing.verticalXS,
                        RichText(
                          text: TextSpan(
                            style: ChronicleTextStyles.bodySmall(context),
                            children: [
                              const TextSpan(text: "Round Duration: "),
                              TextSpan(
                                text:
                                "${state.roundDuration ~/ 60} minutes",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        ChronicleSpacing.verticalXS,
                        RichText(
                          text: TextSpan(
                            style: ChronicleTextStyles.bodySmall(context),
                            children: [
                              const TextSpan(text: "Voting Duration: "),
                              TextSpan(
                                text:
                                "${state.votingDuration ~/ 60} minutes",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        ChronicleSpacing.verticalXS,
                        RichText(
                          text: TextSpan(
                            style: ChronicleTextStyles.bodySmall(context),
                            children: [
                              const TextSpan(text: "Rounds: "),
                              TextSpan(
                                text: "${state.rounds}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ChronicleSpacing.verticalLG,
                    const ParticipantsWidget(),
                    ChronicleSpacing.verticalXL,
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
              child: _buildStartGameButton(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartGameButton(BuildContext context, GameState gameState) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Safety check to prevent crashes
        if (userState.userModel == null || gameState.participants.isEmpty) {
          return const SizedBox.shrink();
        }

        final isCreator = GameUtils.isCreator(
          userState.userModel!,
          gameState.participants,
        );

        if (!isCreator) return const SizedBox.shrink();

        final canStartGame = gameState.participants.length >= 2;

        return SizedBox(
          width: double.infinity,
          height: ChronicleSizes.buttonHeight,
          child: DefaultButton(
            onPressed: canStartGame
                ? () => context.read<GameBloc>().add(StartGameEvent())
                : () {
              ChronicleSnackBar.showError(
                context: context,
                message: "At least 2 players required to start game.",
              );
            },
            loading: gameState.status == GameStatus.loading,
            backgroundColor: AppColors.primary,
            text: "Start Game",
            textColor: AppColors.surface,
          ),
        );
      },
    );
  }
}