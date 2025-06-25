import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/circle_user_avatar.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VotingWidget extends StatefulWidget {
  const VotingWidget({super.key});

  @override
  State<VotingWidget> createState() => _VotingWidgetState();
}

class _VotingWidgetState extends State<VotingWidget> {
  String? selectedFragmentAuthorId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        return BlocBuilder<GameBloc, GameState>(builder: (context, gameState) {
          // cannot vote for self
          var participants = gameState.participants
                  .where((p) => p.id != userState.userModel?.id)
                  .toList() ??
              [];
          return ListView.builder(
            itemBuilder: (context, index) {
              var participant = (gameState.participants ?? [])[index];
              return Row(
                children: [
                  CircleUserAvatar(
                      width: ChronicleSizes.avatarSmall,
                      height: ChronicleSizes.avatarSmall,
                      url: participant.photoUrl),
                  ChronicleSpacing.horizontalSM,
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(participant.name,
                          style: ChronicleTextStyles.bodySmall(context)
                              .copyWith(fontWeight: FontWeight.w600)),
                      ChronicleSpacing.verticalXS,
                      Material(
                        color: selectedFragmentAuthorId == participant.id
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedFragmentAuthorId = participant.id;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(ChronicleSpacing.xs),
                            child: Text(participant.text ?? "",
                                style: ChronicleTextStyles.bodySmall(context)
                                    .copyWith(
                                        color: selectedFragmentAuthorId ==
                                                participant.id
                                            ? AppColors.surface
                                            : AppColors.textColor)),
                          ),
                        ),
                      )
                    ],
                  ))
                ],
              );
            },
            itemCount: participants.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          );
        });
      },
    );
  }
}
