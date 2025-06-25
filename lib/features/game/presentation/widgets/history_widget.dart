import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryWidget extends StatelessWidget {
  const HistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      if (state.history.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(ChronicleSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(ChronicleSizes.smallBorderRadius),
              border: Border.all(color: AppColors.diverColor.withOpacity(0.2)),
            ),
            child: Column(
              children: List.generate(state.history.length, (index) {
                final fragment = state.history[index];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == state.history.length - 1
                          ? 0
                          : ChronicleSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                NetworkImage(fragment.author.photoUrl),
                          ),
                          ChronicleSpacing.horizontalSM,
                          Text(fragment.author.name,
                              style: ChronicleTextStyles.bodyMedium(context)),
                        ],
                      ),
                      ChronicleSpacing.verticalSM,
                      Text(fragment.text,
                          style: ChronicleTextStyles.bodyMedium(context)),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      );
    });
  }
}
