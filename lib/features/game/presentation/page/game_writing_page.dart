import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:chronicle/features/game/presentation/widgets/participants_widget.dart';
import 'package:chronicle/features/game/presentation/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameWritingPage extends StatefulWidget {
  const GameWritingPage({super.key});

  @override
  State<GameWritingPage> createState() => _GameWritingPageState();
}

class _GameWritingPageState extends State<GameWritingPage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GamePhaseAppbar(
        showBackButton: false,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocListener<GameBloc, GameState>(listener: (context, state) {
      if (state.status == GameStatus.error && state.errorMessage != null) {
        ChronicleSnackBar.showError(
          context: context,
          message: state.errorMessage ?? "An error occurred",
        );
      }
      if (state.participants.any((p) => p.hasSubmitted == true)) {
        _controller.clear();
        setState(() => _charCount = 0);
        ChronicleSnackBar.showSuccess(
          context: context,
          message: "Fragment submitted successfully!",
        );
      }
    }, child: BlocBuilder<GameBloc, GameState>(builder: (context, state) {
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
                      ],
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      ChronicleSpacing.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStorySection(context, state),
                        ChronicleSpacing.verticalXL,
                        _buildWritingSection(context, state),
                        ChronicleSpacing.verticalXL,
                        const ParticipantsWidget(),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(context, state),
              ],
            );
    }));
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

  Widget _buildSubmitButton(BuildContext context, GameState state) {
    return Container(
      padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
      child: SizedBox(
        width: double.infinity,
        height: ChronicleSizes.buttonHeight,
        child: DefaultButton(
          onPressed: _charCount >= 50 ? () => _submitFragment(context) : null,
          loading: state.status == GameStatus.loading,
          backgroundColor: AppColors.primary,
          text: "Submit Fragment",
          textColor: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Story so far:",
          style: ChronicleTextStyles.bodyLarge(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ChronicleSpacing.verticalMD,
        Container(
          padding: EdgeInsets.all(ChronicleSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(ChronicleSizes.smallBorderRadius),
            border: Border.all(color: AppColors.diverColor.withOpacity(0.2)),
          ),
          child: Text(
            state.history.isNotEmpty
                ? "Current Story"
                : "No story yet - be the first to contribute!",
            style: ChronicleTextStyles.bodyMedium(context),
          ),
        )
      ],
    );
  }

  Widget _buildWritingSection(BuildContext context, GameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Write your fragment:",
          style: ChronicleTextStyles.bodyLarge(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ChronicleSpacing.verticalMD,
        DefaultTextField(
          controller: _controller,
          maxLines: 5,
          minLines: 4,
          maxLength: 255,
          hintText:
              "${state.history.isNotEmpty ? "Start the story!" : "Continue the story"} Be the first to add a twist...",
          borderRadius: BorderRadius.circular(ChronicleSizes.smallBorderRadius),
          onChanged: (value) {
            setState(() => _charCount = value.length);
            // context.read<GameBloc>().add(UpdateFragmentEvent(fragment: value));
          },
        ),
      ],
    );
  }

  void _submitFragment(BuildContext context) {
    if (_controller.text.length < 50) {
      ChronicleSnackBar.showError(
        context: context,
        message: "Fragment must be at least 50 characters",
      );
      return;
    }

    context.read<GameBloc>().add(
          SubmitFragmentEvent(text: _controller.text.trim()),
        );
    // ChronicleSnackBar.showSuccess(
    //   context: context,
    //   message: "Fragment submitted successfully!",
    // );
    // _controller.clear();
    setState(() => _charCount = 0);
  }
}
