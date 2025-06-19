import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      final remainingTime = state.remainingTime ?? 0;
      final isWarningTime = remainingTime <= 30;

      return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ChronicleSpacing.md),
          decoration: BoxDecoration(
              // color: isWarningTime ? AppColors.errorColor.withOpacity(0.8) : AppColors.primary.withOpacity(0.8),
              color: Color.lerp(
                AppColors.secondary.withOpacity(0.8),
                AppColors.errorColor.withOpacity(0.8),
                (1 - (remainingTime / 30)).clamp(0, 1).toDouble(),
              )!,
              borderRadius:
                  BorderRadius.circular(ChronicleSizes.smallBorderRadius),
              boxShadow: [
                if (isWarningTime)
                  BoxShadow(
                      color: AppColors.errorColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1)
              ]),
          child: Center(
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey<int>(remainingTime),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      color: AppColors.surface,
                    ),
                    SizedBox(width: ChronicleSpacing.sm),
                    Text(
                      GameUtils.formatGamePhaseTime(remainingTime),
                      style: ChronicleTextStyles.bodyLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
          ));
    });
  }
}
