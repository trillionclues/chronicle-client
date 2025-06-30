import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/app_mode_bloc.dart';
import 'package:chronicle/core/utils/chronicle_appbar.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/string_utils.dart';
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
  int roundDuration = 1;
  int votingDuration = 1;
  int maximumParticipants = 3;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppModeBloc, AppMode>(builder: (context, currentMode) {
      return Scaffold(
        appBar: _buildAppBar(context, currentMode),
        body: _buildBody(context, currentMode),
      );
    });
  }

  AppBar _buildAppBar(BuildContext context, AppMode currentMode) {
    return ChronicleAppBar.responsiveAppBar(
      context: context,
      title: "Create ${currentMode.displayName}",
      showBackButton: true,
    );
  }

  Widget _buildBody(BuildContext context, AppMode currentMode) {
    return BlocConsumer<CreateGameBloc, CreateGameState>(
      builder: (context, state) {
        return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(context, currentMode),
                    ChronicleSpacing.verticalSM,
                    _buildRoundsSection(),
                    ChronicleSpacing.verticalLG,
                    _buildSubmitButton(context, state, currentMode)
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
              message: "${currentMode.displayName} created successfully!",
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

  Widget _buildTitleSection(BuildContext context, AppMode currentMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ChronicleSpacing.screenPadding,
          vertical: ChronicleSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Title",
          style: ChronicleTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        ChronicleSpacing.verticalSM,
        DefaultTextField(
          hintText: "Enter ${currentMode.displayName.toLowerCase()} title",
          borderRadius: BorderRadius.circular(ChronicleSizes.smallBorderRadius),
          minLines: 1,
          maxLines: 1,
          onChanged: (value) => setState(() => title = value),
        ),
        ChronicleSpacing.verticalMD,
        Text(
          "Rounds",
          style: ChronicleTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ]),
    );
  }

  Widget _buildRoundsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumberPicker(
          from: 3,
          to: 10,
          onNumberChanged: (value) => setState(() => rounds = value),
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
          onNumberChanged: (value) => setState(() => roundDuration = value),
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
          onNumberChanged: (value) => setState(() => votingDuration = value),
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
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, CreateGameState state, AppMode currentMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: DefaultButton(
          text: StringUtils.getCreateButtonText(currentMode),
          loading: state.status == CreateGameStatus.loading,
          onPressed: title.isEmpty
              ? () {
                  ChronicleSnackBar.showError(
                    context: context,
                    message: "${currentMode.displayName} title cannot be empty.",
                  );
                }
              : () {
                  context.read<CreateGameBloc>().add(CreateGameEvent(
                      title: title,
                      rounds: rounds,
                      roundDuration: roundDuration,
                      votingDuration: votingDuration,
                      maximumParticipants: maximumParticipants));
                },
          backgroundColor: AppColors.primary,
          textColor: AppColors.surface,
          padding: const EdgeInsets.all(ChronicleSpacing.sm)),
    );
  }
}
