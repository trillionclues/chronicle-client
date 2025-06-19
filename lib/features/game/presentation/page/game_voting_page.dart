import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:chronicle/features/game/presentation/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameVotingPage extends StatefulWidget {
  const GameVotingPage({super.key});

  @override
  State<GameVotingPage> createState() => _GameVotingPageState();
}

class _GameVotingPageState extends State<GameVotingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GamePhaseAppbar(
        showBackButton: false,
      ).build(context),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(builder: (context, state) {
      final socketManager = SocketManager();
      final bool isLoading =
          state.status == GameStatus.loading || !socketManager.isConnected;

      return isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Column(
              children: [
                Container(
                    padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
                    child: Column(
                      children: [
                        TimerWidget(),
                        ChronicleSpacing.verticalMD,
                        _buildPhaseInfo(state),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(
                              ChronicleSpacing.screenPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Vote for your favorite fragment to continue the story.",
                                  style:
                                      ChronicleTextStyles.bodyMedium(context),
                                ),
                                ChronicleSpacing.verticalSM,
                                Text(
                                  "You cannot vote for your own submission.",
                                  style: ChronicleTextStyles.bodySmall(context)
                                      .copyWith(
                                    color:
                                        AppColors.errorColor.withOpacity(0.8),
                                  ),
                                ),
                                ChronicleSpacing.verticalXL,
                                ..._buildFragmentOptions(context, state),
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
              ],
            );
    });
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
            Text("Writing Fragment",
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

  List<Widget> _buildFragmentOptions(BuildContext context, GameState state) {
    return state.history.map((fragment) {
      final isCurrentUser =
          fragment.author.id == context.read<UserBloc>().state.userModel?.id;

      return Card(
        margin: EdgeInsets.only(bottom: ChronicleSpacing.md),
        child: Padding(
          padding: EdgeInsets.all(ChronicleSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fragment.text,
                style: ChronicleTextStyles.bodyMedium(context),
              ),
              ChronicleSpacing.verticalMD,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Fragment ${fragment.author}",
                    style: ChronicleTextStyles.bodySmall(context).copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (isCurrentUser)
                    Text(
                      "Your Submission",
                      style: ChronicleTextStyles.bodySmall(context).copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  else if (fragment.votes > 0)
                    Text(
                      "✓ Voted",
                      style: ChronicleTextStyles.bodySmall(context).copyWith(
                        color: AppColors.secondary,
                      ),
                    )
                  else
                    DefaultButton(
                      onPressed: () => _showVoteConfirmation(
                          context, isCurrentUser ? fragment.author.id : ""),
                      text: "Vote",
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      textColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: ChronicleSpacing.md,
                        vertical: ChronicleSpacing.xs,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showVoteConfirmation(BuildContext context, String fragmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Vote"),
        content: Text("Are you sure you want to vote for this fragment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              // context.read<GameBloc>().add(SubmitVoteEvent(userId: fragmentId));
            },
            child: Text("Vote", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
