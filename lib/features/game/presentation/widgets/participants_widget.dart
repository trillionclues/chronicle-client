import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/domain/model/game_phase_model.dart';
import 'package:chronicle/features/game/domain/model/participant_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantsWidget extends StatelessWidget {
  const ParticipantsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Players (${state.participants.length}/${state.maximumParticipants})",
            style: ChronicleTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: ChronicleTextStyles.lg,
            ),
          ),
          ChronicleSpacing.verticalSM,
          SizedBox(
              height: 350,
              width: double.infinity,
              child: Scrollbar(
                  child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ChronicleSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(ChronicleSizes.smallBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ...state.participants.asMap().entries.map((entry) {
                        int index = entry.key;
                        ParticipantModel participant = entry.value;
                        bool isLast = index == state.participants.length - 1;

                        return Column(
                          children: [
                            _buildPlayerTile(context, participant),
                            if (!isLast)
                              Divider(
                                height: ChronicleSpacing.md * 2,
                                thickness: 1,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.3),
                              ),
                          ],
                        );
                      }),
                      if (state.participants.length < state.maximumParticipants)
                        _buildEmptySlots(context, state),
                    ],
                  ),
                ),
              ))),
        ],
        // padding: EdgeInsets.all(ChronicleSpacing.cardPadding),
      );
    });
  }

  Widget _buildPlayerTile(BuildContext context, ParticipantModel participant) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      return BlocBuilder<GameBloc, GameState>(builder: (context, gameState) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ChronicleSpacing.xs),
          child: Row(
            children: [
              Container(
                width: ChronicleSizes.avatarMedium,
                height: ChronicleSizes.avatarMedium,
                decoration: BoxDecoration(
                  color: getAvatarColor(participant.name ?? "Player"),
                  shape: BoxShape.circle,
                  image: participant.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(participant.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: getAvatarColor(participant.photoUrl ?? 'Player')
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: participant.photoUrl == null
                    ? Center(
                        child: Text(
                          GameUtils.getInitials(participant.name ?? 'Player'),
                          style: TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: ChronicleSizes.iconSmall,
                          ),
                        ),
                      )
                    : null,
              ),
              ChronicleSpacing.horizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name ?? 'Unknown Player',
                      style: ChronicleTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    // ChronicleSpacing.verticalSM,
                    Row(
                      children: [
                        if (participant.isCreator) ...[
                          Icon(
                            Icons.kayaking,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          ChronicleSpacing.horizontalXS,
                        ],
                        Text(
                          participant.isCreator ? 'Host' : 'Player',
                          style:
                              ChronicleTextStyles.bodySmall(context).copyWith(
                            color: participant.isCreator
                                ? Color(0xFFB8860B)
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(context, participant),
              ChronicleSpacing.horizontalSM,
              if (GameUtils.isCreator(
                      state.userModel!, gameState.participants ?? []) &&
                  !participant.isCreator &&
                  (gameState.gamePhase == GamePhase.canceled ||
                      gameState.gamePhase == GamePhase.finished))
                IconButton(
                  onPressed: () {
                    context.read<GameBloc>().add(KickParticipantGameEvent(
                          userId: participant.id,
                        ));
                  },
                  icon: Icon(Icons.remove_circle_outline),
                  color: AppColors.errorColor,
                ),
            ],
          ),
        );
      });
    });
  }

  Widget _buildEmptySlots(BuildContext context, GameState state) {
    int emptySlots = state.maximumParticipants - state.participants.length;

    return Column(
      children: [
        if (state.participants.isNotEmpty)
          Divider(
            height: ChronicleSpacing.md * 2,
            thickness: 0.8,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ...List.generate(emptySlots, (index) => _buildEmptySlot(context))
            .take(3),
        if (emptySlots > 3)
          Padding(
            padding: EdgeInsets.symmetric(vertical: ChronicleSpacing.sm),
            child: Text(
              "... and ${emptySlots - 3} more slots",
              style: ChronicleTextStyles.bodySmall(context).copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySlot(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: ChronicleSpacing.xs),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: ChronicleSpacing.xs,
          ),
          child: Row(
            children: [
              Container(
                width: ChronicleSizes.iconXLarge,
                height: ChronicleSizes.iconXLarge,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    width: ChronicleSpacing.xs - 3,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.4),
                  size: ChronicleSizes.iconMedium,
                ),
              ),
              ChronicleSpacing.horizontalMD,

              // Waiting text
              Expanded(
                child: Text(
                  "Waiting for player...",
                  style: ChronicleTextStyles.bodyMedium(context).copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatusIndicator(
      BuildContext context, ParticipantModel participant) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      if ([
        GamePhase.writing,
        GamePhase.voting,
        GamePhase.finished,
        GamePhase.canceled
      ].contains(state.gamePhase)) {
        return Container();
      }
      return Icon(participant.hasSubmitted ? Icons.done : Icons.timer_outlined);
    });
  }
}
