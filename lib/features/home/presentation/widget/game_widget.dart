import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/game/domain/model/game_model.dart';
import 'package:chronicle/features/game/presentation/page/game_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameWidget extends StatelessWidget {
  final GameModel gameModel;
  final bool isCompleted;
  final AppMode currentMode;

  const GameWidget({
    super.key,
    required this.gameModel,
    required this.isCompleted,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ChronicleSizes.cardElevation - 3,
      margin: EdgeInsets.only(bottom: ChronicleSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChronicleSizes.smallBorderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ChronicleSizes.smallBorderRadius),
        onTap: () {
          if (!isCompleted) {
            context.go(GamePage.route(gameModel.gameCode));
          } else {
            // Navigate to game finished page
            context.go(GamePage.route(gameModel.gameCode));
          }
        },
        child: Padding(
          padding: EdgeInsets.all(ChronicleSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gameModel.name ?? "Untitled Game",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ChronicleSpacing.sm,
                      vertical: ChronicleSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.secondary.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted ? "Completed" : "Active",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isCompleted
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
              ChronicleSpacing.verticalXS,
              Text(
                "Code: ${gameModel.gameCode}",
                style: ChronicleTextStyles.bodySmall(context).copyWith(
                  color: AppColors.textColor.withOpacity(0.6),
                ),
              ),
              ChronicleSpacing.verticalSM,
              if (!isCompleted) _buildProgressIndicator(context),
              ChronicleSpacing.verticalSM,
              Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 16,
                    color: AppColors.textColor.withOpacity(0.6),
                  ),
                  ChronicleSpacing.horizontalXS,
                  Text(
                    "${gameModel.participants?.length ?? 0}/${gameModel.maxPlayers}",
                    style: ChronicleTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                  ChronicleSpacing.horizontalMD,
                  Icon(
                    Icons.repeat_outlined,
                    size: 16,
                    color: AppColors.textColor.withOpacity(0.6),
                  ),
                  ChronicleSpacing.horizontalXS,
                  Text(
                    "${gameModel.currentRound}/${gameModel.maxRounds}",
                    style: ChronicleTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return LinearProgressIndicator(
      value: gameModel.currentRound / gameModel.maxRounds,
      backgroundColor: AppColors.background,
      color: AppColors.primary,
      minHeight: 4,
      borderRadius: BorderRadius.circular(2),
    );
  }
}
