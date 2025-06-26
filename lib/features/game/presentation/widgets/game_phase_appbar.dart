import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/utils/app_mode.dart';
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

class GamePhaseAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final String? actionText;
  final AppMode currentMode;

  const GamePhaseAppbar(
      {super.key,
      this.title,
      this.showBackButton = true,
      this.actionText,
      required this.currentMode});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, gameState) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            if (userState.userModel == null || gameState.participants.isEmpty) {
              return ChronicleAppBar.responsiveAppBar(
                context: context,
                titleWidget: _buildTitleWidget(context, false, gameState),
                actions: _buildActions(context),
                showBackButton: showBackButton,
              );
            }

            final isCreator = GameUtils.isCreator(
              userState.userModel!,
              gameState.participants,
            );

            return ChronicleAppBar.responsiveAppBar(
              context: context,
              titleWidget: _buildTitleWidget(context, isCreator, gameState),
              actions: _buildActions(context),
              showBackButton: showBackButton,
            );
          },
        );
      },
    );
  }

  Widget _buildTitleWidget(
      BuildContext context, bool isCreator, GameState gameState) {
    if (title != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              title!,
              style: ChronicleTextStyles.bodyMedium(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCreator && actionText != null)
            TextButton(
              onPressed: () => _showCancelConfirmation(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: ChronicleSpacing.md,
                ),
                textStyle: ChronicleTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.errorColor,
                ),
                foregroundColor: AppColors.errorColor,
              ),
              child: Text(actionText!),
            ),
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ChronicleSpacing.screenPadding,
        ),
        child: Text(
          "Round ${gameState.currentRound}/${gameState.rounds}",
          style: ChronicleTextStyles.bodyLarge(context),
        ),
      );
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    // Only show exit action when there's no title (during game phases != waiting)
    if (title == null && actionText == "Writing Fragment") {
      return [
        IconButton(
          icon: Icon(Icons.exit_to_app, size: ChronicleSizes.iconLarge),
          onPressed: () => _showExitConfirmation(context),
        ),
      ];
    }
    return null;
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Leave ${currentMode.displayName}?"),
        content: Text(
            "Are you sure you want to leave this ${currentMode.displayName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GameBloc>().add(LeaveGameEvent());
              ChronicleSnackBar.showSuccess(
                context: context,
                message: "You have left the ${currentMode.displayName}.",
              );
            },
            child: const Text(
              "Leave",
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Cancel ${currentMode.displayName}?"),
        content: Text(
          "Are you sure you want to cancel this ${currentMode.displayName?.toLowerCase()}? This will end the ${currentMode.displayName?.toLowerCase()} for all players.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GameBloc>().add(CancelGameEvent());
              ChronicleSnackBar.showSuccess(
                context: context,
                message: "${currentMode.displayName} has been cancelled.",
              );
            },
            child: Text(
              "Cancel ${currentMode.displayName}",
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
