import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/game/domain/model/story_fragment_model.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VotingResultsPage extends StatefulWidget {
  const VotingResultsPage({super.key});

  @override
  State<VotingResultsPage> createState() => _VotingResultsPageState();
}

class _VotingResultsPageState extends State<VotingResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GamePhaseAppbar(
        showBackButton: false,
      ),
      body: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
        final currentRoundFragments =
            state.history.where((f) => f.round == state.currentRound).toList();

        currentRoundFragments.sort((a, b) => b.votes.compareTo(a.votes));

        final winner = currentRoundFragments.isNotEmpty
            ? currentRoundFragments.first
            : null;

        return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildContent(
                    context,
                    state,
                    winner,
                    currentRoundFragments,
                  ),
                ),
              );
            });
      }),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GameState state,
    StoryFragmentModel? winner,
    List<StoryFragmentModel> currentRoundFragments,
  ) {
    return Padding(
        padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (winner != null) ...[
              Container(
                padding: EdgeInsets.all(ChronicleSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(ChronicleSizes.largeBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, value, child) {
                          return Transform.scale(
                              scale: value,
                              child: Container(
                                padding: EdgeInsets.all(ChronicleSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ));
                        }),
                    SizedBox(height: ChronicleSpacing.md),
                    Container(
                      padding: EdgeInsets.all(ChronicleSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        winner.text,
                        style: ChronicleTextStyles.bodyMedium(context).copyWith(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: ChronicleSpacing.md),
                    Text(
                      "Written by ${winner.author?.name ?? 'Anonymous'} • ${winner.votes} ${winner.votes == 1 ? 'vote' : 'votes'}",
                      style: ChronicleTextStyles.bodySmall(context).copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ChronicleSpacing.xl),
            ],
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: ChronicleSpacing.sm),
                Text(
                  "Vote Results:",
                  style: ChronicleTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ChronicleSpacing.lg),
            Expanded(
                child: ListView.builder(
                    itemCount: currentRoundFragments.length,
                    itemBuilder: (context, index) {
                      final fragment = currentRoundFragments[index];
                      final maxVotes = currentRoundFragments.isNotEmpty
                          ? currentRoundFragments.first.votes
                          : 1;
                      final votePercentage =
                          maxVotes > 0 ? (fragment.votes / maxVotes) : 0.0;

                      return TweenAnimationBuilder(
                          tween: Tween(begin: 0.0, end: votePercentage),
                          duration: Duration(milliseconds: 800 + (index * 200)),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedPercentage, child) {
                            return Container(
                              margin:
                                  EdgeInsets.only(bottom: ChronicleSpacing.lg),
                              padding: EdgeInsets.all(ChronicleSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                    ChronicleSizes.smallBorderRadius),
                                border: Border.all(
                                  color: index == 0
                                      ? AppColors.primary.withOpacity(0.5)
                                      : Colors.grey.withOpacity(0.2),
                                  width: index == 0 ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: ChronicleSpacing.sm,
                                              vertical: ChronicleSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: index == 0
                                                  ? AppColors.primary
                                                      .withOpacity(0.1)
                                                  : Colors.grey
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Fragment ${String.fromCharCode(65 + index)}",
                                              style:
                                                  ChronicleTextStyles.bodySmall(
                                                          context)
                                                      .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: index == 0
                                                    ? AppColors.primary
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          if (index == 0) ...[
                                            SizedBox(
                                                width: ChronicleSpacing.sm),
                                            Icon(
                                              Icons.emoji_events,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        "${fragment.votes} ${fragment.votes == 1 ? 'vote' : 'votes'}",
                                        style: ChronicleTextStyles.bodySmall(
                                                context)
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: index == 0
                                              ? AppColors.primary
                                              : Colors.grey[700],
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: ChronicleSpacing.md),
                                  Text(
                                    fragment.author?.name ?? 'Anonymous',
                                    style:
                                        ChronicleTextStyles.bodySmall(context)
                                            .copyWith(color: Colors.grey),
                                  ),
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: animatedPercentage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: index == 0
                                                ? [
                                                    AppColors.primary,
                                                    AppColors.primary
                                                        .withOpacity(0.7)
                                                  ]
                                                : [
                                                    Colors.grey[400]!,
                                                    Colors.grey[300]!
                                                  ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: ChronicleSpacing.md),
                                  Text(
                                    fragment.author?.name ?? 'Anonymous',
                                    style:
                                        ChronicleTextStyles.bodySmall(context)
                                            .copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    })),
            SizedBox(height: ChronicleSpacing.lg),
            DefaultButton(
              text: state.currentRound < state.rounds
                  ? "Continue to Round ${state.currentRound + 1}"
                  : "View Final Story",
              onPressed: () {
                // context.read<GameBloc>().add(ProceedToNextPhaseEvent());
              },
              padding: const EdgeInsets.all(ChronicleSpacing.sm),
            ),
            SizedBox(height: ChronicleSpacing.md),
            Text(
              "${state.rounds - state.currentRound} rounds remaining",
              style: ChronicleTextStyles.bodySmall(context).copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }
}
