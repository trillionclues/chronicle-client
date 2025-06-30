import 'dart:math';

import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/app_mode_bloc.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/features/create_game/presentation/page/create_game_page.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:chronicle/features/game/presentation/widgets/history_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

class GameFinishedPage extends StatefulWidget {
  const GameFinishedPage({super.key});

  @override
  State<GameFinishedPage> createState() => _GameFinishedPageState();
}

class _GameFinishedPageState extends State<GameFinishedPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<AppModeBloc, AppMode>(builder: (context, currentMode) {
          return Scaffold(
            appBar: GamePhaseAppbar(
              showBackButton: false,
              actionText: "Play Again",
              currentMode: currentMode,
            ),
            body: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
              final participants = state.participants;
              final winningFragments = GameUtils.extractWinningFragments(state);
              final wordCount = winningFragments.fold(
                  0, (sum, fragment) => sum + fragment.text.split(' ').length);

              return SingleChildScrollView(
                padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ChronicleSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_stories,
                            size: ChronicleSizes.largeBorderRadius * 2,
                            color: AppColors.primary,
                          ),
                        ),
                        ChronicleSpacing.verticalXS,
                        Text(
                          '${currentMode.displayName} Complete!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    )),
                    ChronicleSpacing.verticalSM,
                    Center(
                      child: Text(
                        'Created by ${participants.length} amazing storyteller${participants.length > 1 ? 's' : ''}.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColor.withOpacity(0.6),
                            ),
                      ),
                    ),
                    ChronicleSpacing.verticalLG,
                    HistoryWidget(
                        showOnlyWinningFragments: true,
                        showAuthors: false,
                        textStyle: TextStyle(
                          fontSize: ChronicleSizes.largeBorderRadius,
                          color: AppColors.textColor,
                          height: 1.6,
                        )),
                    ChronicleSpacing.verticalXL,
                    Container(
                      padding: EdgeInsets.all(ChronicleSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.dividerColor.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(
                            ChronicleSizes.smallBorderRadius),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(children: [
                            Center(
                                child: Text('Players',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold))),
                            Center(
                                child: Text('Rounds',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold))),
                            Center(
                                child: Text('Words',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold))),
                          ]),
                          TableRow(
                            children: [
                              Center(
                                  child: Text(participants.length.toString())),
                              Center(child: Text(state.rounds.toString())),
                              Center(child: Text(wordCount.toString())),
                            ],
                          )
                        ],
                      ),
                    ),
                    ChronicleSpacing.verticalLG,
                    Center(
                      child: DefaultButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            context.push(CreateGamePage.route);
                          },
                          text: "Play Again",
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.surface,
                          padding: const EdgeInsets.all(ChronicleSpacing.sm)),
                    )
                  ],
                ),
              );
            }),
          );
        }),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: drawStar,
          ),
        ),
      ],
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
