import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/snackbar_extensions.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameCodeCardWidget extends StatelessWidget {
  final GameState state;
  final String mode;

  const GameCodeCardWidget({super.key, required this.state, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: ChronicleSpacing.md),
      padding: EdgeInsets.all(ChronicleSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface, // Solid white
        borderRadius: BorderRadius.circular(ChronicleSizes.largeBorderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "$mode Code",
            style: ChronicleTextStyles.bodyMedium(context).copyWith(
              color: Color(0xFF8B5A00),
              fontWeight: FontWeight.w500,
            ),
          ),
          ChronicleSpacing.verticalSM,
          Text(
            state.gameCode ?? "LOADING",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Color(0xFF6B4100),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  fontSize: 32,
                ),
          ),
          ChronicleSpacing.verticalMD,
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "${state.gameCode}"));
              context.showGameSnackBar("$mode code copied!");
            },
            icon: Icon(
              Icons.copy,
              size: 18,
              color: Color(0xFF8B5A00),
            ),
            label: Text(
              "Copy Code",
              style: ChronicleTextStyles.bodyMedium(context).copyWith(
                color: Color(0xFF8B5A00),
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(
                horizontal: ChronicleSpacing.md,
                vertical: ChronicleSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ChronicleSizes.smallBorderRadius),
                side: BorderSide(
                  color: Color(0xFFFFCC02).withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
