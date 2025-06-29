import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/game/domain/model/game_model.dart';
import 'package:chronicle/features/game/presentation/page/game_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameWidget extends StatelessWidget {
  final GameModel gameModel;


  const GameWidget({super.key, required this.gameModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: ChronicleSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChronicleSizes.smallBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(ChronicleSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameModel.name ?? "Untitled Game",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ChronicleSpacing.sm,
                    vertical: ChronicleSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    // color: gameModel.isActive
                    //     ? AppColors.primary.withOpacity(0.1)
                    //     : AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Completed",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        // color: gameModel.isActive
                        //     ? AppColors.primary
                        //     : AppColors.secondary,
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
            if (!gameModel.isFinished)
              ElevatedButton(
                onPressed: () {
                  context.go(GamePage.route(gameModel.gameCode));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  "Continue Game",
                  style: TextStyle(color: AppColors.surface),
                ),
              )
            else
              OutlinedButton(
                onPressed: () {
                  // Navigate to game summary or replay
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Text(
                  "View Summary",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
