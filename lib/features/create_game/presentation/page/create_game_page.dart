import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/create_game/presentation/bloc/create_game_bloc.dart';
import 'package:chronicle/features/create_game/presentation/bloc/create_game_event.dart';
import 'package:chronicle/features/create_game/presentation/bloc/create_game_state.dart';
import 'package:chronicle/features/create_game/presentation/widgets/number_picker.dart';
import 'package:chronicle/features/game/presentation/page/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  static const route = "/create_game";

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  String title = "";
  int rounds = 3;
  int roundDuration = 2;
  int votingDuration = 2;
  int maximumParticipants = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(
                Icons.chevron_left,
                size: ChronicleSizes.iconLarge,
              )),
          Text(
            "Create Game",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      titleSpacing: 0,
      toolbarHeight: ChronicleSizes.appBarHeight,
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<CreateGameBloc, CreateGameState>(
      builder: (context, state) {
        return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ChronicleSpacing.screenPadding,
                          vertical: ChronicleSpacing.md),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Title",
                              style: ChronicleTextStyles.bodyMedium(context)
                                  .copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ChronicleSpacing.verticalSM,
                            DefaultTextField(
                              hintText: "Enter story line",
                              borderRadius: BorderRadius.circular(
                                  ChronicleSizes.smallBorderRadius),
                              minLines: 1,
                              maxLines: 1,
                              onChanged: (value) =>
                                  setState(() => title = value),
                            ),
                            ChronicleSpacing.verticalMD,
                            Text(
                              "Rounds",
                              style: ChronicleTextStyles.bodyMedium(context)
                                  .copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]),
                    ),
                    ChronicleSpacing.verticalSM,
                    NumberPicker(
                      from: 3,
                      to: 10,
                      onNumberChanged: (value) =>
                          setState(() => rounds = value),
                    ),
                    ChronicleSpacing.verticalLG,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ChronicleSpacing.screenPadding,
                          vertical: ChronicleSpacing.md),
                      child: Text(
                        "Round duration (minutes)",
                        style: ChronicleTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ChronicleSpacing.verticalSM,
                    NumberPicker(
                      from: 3,
                      to: 10,
                      onNumberChanged: (value) =>
                          setState(() => roundDuration = value),
                    ),
                    ChronicleSpacing.verticalLG,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ChronicleSpacing.screenPadding,
                          vertical: ChronicleSpacing.md),
                      child: Text(
                        "Voting duration (minutes)",
                        style: ChronicleTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ChronicleSpacing.verticalSM,
                    NumberPicker(
                      from: 2,
                      to: 10,
                      onNumberChanged: (value) =>
                          setState(() => votingDuration = value),
                    ),
                    ChronicleSpacing.verticalLG,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: ChronicleSpacing.screenPadding,
                          vertical: ChronicleSpacing.md),
                      child: Text(
                        "Maximum participants",
                        style: ChronicleTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ChronicleSpacing.verticalSM,
                    NumberPicker(
                      from: 3,
                      to: 10,
                      onNumberChanged: (value) =>
                          setState(() => maximumParticipants = value),
                    ),
                    ChronicleSpacing.verticalLG,
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: DefaultButton(
                          text: "Create",
                          loading: state.status == CreateGameStatus.loading,
                          onPressed: title.isEmpty
                              ? () {
                                  ChronicleSnackBar.showError(
                                    context: context,
                                    message: "Game title cannot be empty.",
                                  );
                                }
                              : () {
                                  context.read<CreateGameBloc>().add(
                                      CreateGameEvent(
                                          title: title,
                                          rounds: rounds,
                                          roundDuration: roundDuration,
                                          votingDuration: votingDuration,
                                          maximumParticipants:
                                              maximumParticipants));
                                },
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(
                              vertical: ChronicleSpacing.md,
                              horizontal: ChronicleSpacing.sm)),
                    ),
                  ],
                ),
              ),
            ));
      },
      listener: (context, state) {
        if (state.status == CreateGameStatus.success) {
          if (state.createdGameCode != null) {
            ChronicleSnackBar.showSuccess(
              context: context,
              message: "Game created successfully!",
            );
            // delay before navigating
            Future.delayed(
                const Duration(
                  milliseconds: 500,
                ), () {
              if (context.mounted) {
                context.go(GamePage.route(state.createdGameCode!));
              }
            });
          }
        } else if (state.status == CreateGameStatus.error) {
          ChronicleSnackBar.showError(
            context: context,
            message: "Error creating game!",
          );
        }
      },
    );
  }
}
