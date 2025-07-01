import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/app_mode_bloc.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:chronicle/features/game/presentation/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameVotingPage extends StatefulWidget {
  const GameVotingPage({super.key});

  @override
  State<GameVotingPage> createState() => _GameVotingPageState();
}

class _GameVotingPageState extends State<GameVotingPage> {
  String? selectedFragmentId;
  bool hasVoted = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppModeBloc, AppMode>(builder: (context, currentMode) {
      return Scaffold(
        appBar: GamePhaseAppbar(showBackButton: false, currentMode: currentMode,),
        body: _buildBody(context),
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final currentUserId = context.read<UserBloc>().state.userModel?.id;

        final isLoading = state.status == GameStatus.loading;
        if (isLoading) {
          return const Center(
              child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ));
        }

        final currentRoundFragments =
            state.history.where((f) => f.round == state.currentRound).toList();

        // Filter votable fragments (excluding current user's own)
        final votableFragments = currentRoundFragments
            .where((f) => f.author.id != currentUserId)
            .toList();

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
              child: Column(
                children: [
                  const TimerWidget(),
                  ChronicleSpacing.verticalMD,
                  _buildPhaseInfo(state),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
                child: _buildVotingContent(context, votableFragments, state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVotingContent(
    BuildContext context,
    List<StoryFragmentModel> votableFragments,
    GameState state,
  ) {
    if (votableFragments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: ChronicleSizes.iconXLarge,
              color: Colors.grey,
            ),
            SizedBox(height: ChronicleSpacing.md),
            Text(
              "Waiting for submissions",
              style: ChronicleTextStyles.bodyMedium(context),
            ),
            SizedBox(height: ChronicleSpacing.sm),
            Text(
              "No fragments available to vote for yet",
              style: ChronicleTextStyles.bodySmall(context)
                  .copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ChronicleSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(ChronicleSizes.smallBorderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vote for your favorite fragment:",
                style: ChronicleTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: ChronicleSpacing.xs),
              Text("You cannot vote for your own submission.",
                  style: ChronicleTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primary,
                  )),
            ],
          ),
        ),
        SizedBox(height: ChronicleSpacing.lg),
        Text(
          "Choose the best fragment:",
          style: ChronicleTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ChronicleSpacing.md),
        Expanded(
          child: ListView.builder(
            itemCount: votableFragments.length,
            itemBuilder: (context, index) => _buildFragmentCard(
              context,
              votableFragments[index],
              index,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFragmentCard(
    BuildContext context,
    StoryFragmentModel fragment,
    int index,
  ) {
    final isSelected = selectedFragmentId == fragment.author.id;
    final fragmentLabel = String.fromCharCode(65 + index);

    return Container(
      margin: EdgeInsets.only(bottom: ChronicleSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ChronicleSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fragment.text,
              style: ChronicleTextStyles.bodyMedium(context),
            ),
            SizedBox(height: ChronicleSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ChronicleSpacing.sm,
                        vertical: ChronicleSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Fragment $fragmentLabel",
                        style: ChronicleTextStyles.bodySmall(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasVoted && isSelected)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ChronicleSpacing.md,
                      vertical: ChronicleSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: ChronicleSpacing.xs),
                        Text(
                          "Voted",
                          style:
                              ChronicleTextStyles.bodySmall(context).copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DefaultButton(
                    fullWidth: false,
                    onPressed: hasVoted ? null : () => _handleVote(fragment),
                    text: "Vote",
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    textColor: isSelected ? Colors.white : AppColors.primary,
                    padding: const EdgeInsets.all(ChronicleSpacing.sm),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseInfo(GameState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Current Phase",
              style: ChronicleTextStyles.bodyMedium(context),
            ),
            Text("Voting Phase",
                style: ChronicleTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )),
          ],
        ),
        ChronicleSpacing.verticalSM,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Players Online",
              style: ChronicleTextStyles.bodyMedium(context),
            ),
            Text(
              "${state.participants.length}/${state.maximumParticipants}",
              style: ChronicleTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleVote(StoryFragmentModel fragment) {
    setState(() {
      selectedFragmentId = fragment.author.id;
    });

    _showVoteConfirmation(context, fragment);
  }

  void _showVoteConfirmation(
      BuildContext context, StoryFragmentModel fragment) {
    final gameBloc = context.read<GameBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Vote"),
        content: Text("Are you sure you want to vote for this fragment?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedFragmentId = null;
              });
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameBloc.add(SubmitVoteEvent(userId: fragment.author.id ?? ''));
              setState(() {
                hasVoted = true;
              });
            },
            child: Text("Vote", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
