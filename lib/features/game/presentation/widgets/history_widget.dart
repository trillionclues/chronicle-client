import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryWidget extends StatelessWidget {
  final bool showOnlyWinningFragments;
  final bool showAuthors;
  final bool showRoundNumbers;
  final TextStyle? textStyle;

  const HistoryWidget(
      {super.key,
      required this.showOnlyWinningFragments,
      required this.showAuthors,
      this.showRoundNumbers = false,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      final fragments = showOnlyWinningFragments
          ? GameUtils.extractWinningFragments(state)
          : state.history;

      if (fragments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(ChronicleSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(ChronicleSizes.smallBorderRadius),
              border:
                  Border.all(color: AppColors.dividerColor.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(fragments.length, (index) {
                final fragment = fragments[index];

                return Container(
                  padding: EdgeInsets.only(
                      bottom: index == fragments.length - 1
                          ? 0
                          : ChronicleSpacing.md),
                  decoration: BoxDecoration(
                    border: index < fragments.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: AppColors.dividerColor.withOpacity(0.2),
                              width: 1,
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showAuthors) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: ChronicleSizes.avatarSmall / 2,
                              backgroundImage:
                                  NetworkImage(fragment.author.photoUrl ?? ''),
                            ),
                            ChronicleSpacing.horizontalSM,
                            Text(
                              fragment.author.name ?? 'Anonymous',
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        ChronicleSpacing.verticalSM,
                      ],
                      if (showRoundNumbers) ...[
                        Text(
                          'Round ${fragment.round}',
                          style:
                              ChronicleTextStyles.bodySmall(context).copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        ChronicleSpacing.verticalXS,
                      ],
                      Text(
                        fragment.text,
                        style: textStyle ??
                            TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                              height: 1.5,
                            ),
                      ),
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
