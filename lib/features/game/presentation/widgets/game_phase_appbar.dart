import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_appbar.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GamePhaseAppbar extends StatelessWidget {
  final String? title;
  final bool showBackButton;
  final String? actionText;

  const GamePhaseAppbar(
      {super.key, this.title, this.showBackButton = true, this.actionText});

  @override
  PreferredSizeWidget build(BuildContext context) {
    return ChronicleAppBar.responsiveAppBar(
      context: context,
      titleWidget: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
        return BlocBuilder<UserBloc, UserState>(builder: (context, userState) {
          final isCreator = userState.userModel != null &&
              state.participants != null &&
              state.participants!.isNotEmpty &&
              GameUtils.isCreator(userState.userModel!, state.participants!);

          return title != null
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Waiting for players...",
                        style: ChronicleTextStyles.bodyLarge(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCreator)
                      TextButton(
                        onPressed: () =>
                            context.read<GameBloc>().add(CancelGameEvent()),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: ChronicleSpacing.md,
                          ),
                          textStyle:
                              ChronicleTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.errorColor,
                          ),
                          foregroundColor: AppColors.errorColor,
                        ),
                        child: const Text("Cancel Game"),
                      ),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ChronicleSpacing.screenPadding,
                  ),
                  child: Text(
                    title ?? "Round ${state.currentRound}/${state.rounds}",
                    style: ChronicleTextStyles.bodyLarge(context),
                  ),
                );
        });
      }),
      actions: title != null
          ? null
          : [
              IconButton(
                icon: Icon(Icons.exit_to_app, size: ChronicleSizes.iconMedium),
                onPressed: () => _showExitConfirmation(context),
              ),
            ],
      showBackButton: showBackButton,
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Leave Game?"),
              content: Text("Are you sure you want to leave this game?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.read<GameBloc>().add(LeaveGameEvent());
                  },
                  child: Text("Leave",
                      style: TextStyle(color: AppColors.errorColor)),
                ),
              ],
            ));
  }
}
