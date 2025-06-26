import 'package:chronicle/core/socket_manager.dart';
import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/app_mode_bloc.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/string_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/game/presentation/bloc/game_bloc.dart';
import 'package:chronicle/features/game/presentation/bloc/game_event.dart';
import 'package:chronicle/features/game/presentation/bloc/game_state.dart';
import 'package:chronicle/features/game/presentation/widgets/game_phase_appbar.dart';
import 'package:chronicle/features/game/presentation/widgets/history_widget.dart';
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
  bool _hasSubmitted = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = context.read<UserBloc>().state.userModel?.id;
    _checkInitialSubmissionStatus();
  }

  void _checkInitialSubmissionStatus() {
    final gameState = context.read<GameBloc>().state;

    if (_userId != null) {
      final participant = gameState.participants.firstWhere(
        (p) => p.id == _userId,
        orElse: () => throw Exception("User not found in participants"),
      );

      setState(() {
        _hasSubmitted = participant.hasSubmitted ?? false;
        if (_hasSubmitted) {
          _controller.clear();
          _charCount = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppModeBloc, AppMode>(builder: (context, currentMode) {
      return Scaffold(
        appBar: GamePhaseAppbar(
          showBackButton: false,
          actionText: "Writing Fragment",
          currentMode: currentMode,
        ),
        body: _buildBody(context, currentMode),
        floatingActionButton: _buildManualNextPhaseButton(context),
      );
    });
  }

  Widget _buildBody(BuildContext context, AppMode currentMode) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<GameBloc, GameState>(
            listener: (context, state) {
              if (state.status == GameStatus.error &&
                  state.errorMessage != null) {
                ChronicleSnackBar.showError(
                  context: context,
                  message: state.errorMessage!,
                );
              }

              if (_userId != null) {
                final participant = state.participants.firstWhere(
                  (p) => p.id == _userId,
                  orElse: () =>
                      throw Exception("User not found in participants"),
                );

                if (participant?.hasSubmitted != _hasSubmitted) {
                  setState(() {
                    _hasSubmitted = participant?.hasSubmitted ?? false;
                    if (_hasSubmitted) {
                      _controller.clear();
                      _charCount = 0;
                    }
                  });
                }
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state.userModel?.id != _userId) {
                setState(() {
                  _userId = state.userModel?.id;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            final socketManager = SocketManager();
            final bool isLoading = state.status == GameStatus.loading ||
                !socketManager.isConnected;

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
                            const TimerWidget(),
                            ChronicleSpacing.verticalMD,
                            _buildPhaseInfo(state),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding:
                              EdgeInsets.all(ChronicleSpacing.screenPadding),
                          children: [
                            _buildStorySection(context, state, currentMode),
                            ChronicleSpacing.verticalXL,
                            if (!_hasSubmitted)
                              _buildWritingSection(context, state, currentMode),
                            ChronicleSpacing.verticalXL,
                            const ParticipantsWidget(),
                          ],
                        ),
                      ),
                      if (!_hasSubmitted)
                        _buildSubmitButton(context, state, currentMode),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildManualNextPhaseButton(BuildContext context) {
    return BlocSelector<GameBloc, GameState, bool>(
      selector: (state) {
        if (_userId == null) return false;
        return state.participants.any(
          (p) => p.id == _userId && p.isCreator == true,
        );
      },
      builder: (context, isCreator) {
        if (!isCreator) return SizedBox.shrink();

        return BlocSelector<GameBloc, GameState, GameStatus>(
          selector: (state) => state.status,
          builder: (context, status) {
            if (status == GameStatus.loading) {
              return SizedBox.shrink();
            }

            return FloatingActionButton(
              onPressed: () {
                // context.read<GameBloc>().add(ManualNextPhaseEvent());
              },
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ChronicleSizes.smallBorderRadius),
              ),
              heroTag: 'nextPhaseButton',
              tooltip: 'Advance to next phase',
              child: const Icon(Icons.done, color: AppColors.surface),
            );
          },
        );
      },
    );
  }

  Widget _buildStorySection(
      BuildContext context, GameState state, AppMode currentMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${currentMode.displayName} so far:",
            style: ChronicleTextStyles.bodyLarge(context)
                .copyWith(fontWeight: FontWeight.bold)),
        ChronicleSpacing.verticalMD,
        if (state.history.isEmpty)
          Text(
              "No ${currentMode.displayName} yet - be the first to contribute!",
              style: ChronicleTextStyles.bodyMedium(context))
        else
          const HistoryWidget(
              showOnlyWinningFragments: true,
              showAuthors: false,
              showRoundNumbers: true),
      ],
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

  Widget _buildSubmitButton(
      BuildContext context, GameState state, AppMode currentMode) {
    return Container(
      padding: EdgeInsets.all(ChronicleSpacing.screenPadding),
      child: SizedBox(
        width: double.infinity,
        height: ChronicleSizes.buttonHeight,
        child: DefaultButton(
          onPressed: _charCount >= 50
              ? () => _submitFragment(context)
              : () {
                  ChronicleSnackBar.showError(
                    context: context,
                    message: "Fragment must be at least 50 characters",
                  );
                },
          loading: state.status == GameStatus.loading,
          backgroundColor: AppColors.primary,
          text: StringUtils.getSubmitButtonText(currentMode),
          textColor: AppColors.surface,
          padding: const EdgeInsets.all(ChronicleSpacing.sm),
        ),
      ),
    );
  }

  Widget _buildWritingSection(
      BuildContext context, GameState state, AppMode currentMode) {
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
              "${state.history.isEmpty ? "Start the ${currentMode.displayName}!" : "Continue the ${currentMode.displayName}"} Be the first to add a twist...",
          borderRadius: BorderRadius.circular(ChronicleSizes.smallBorderRadius),
          onChanged: (value) {
            setState(() => _charCount = value.length);
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
    setState(() => _charCount = 0);
    ChronicleSnackBar.showSuccess(
      context: context,
      message: "Fragment submitted successfully!",
    );
  }
}
