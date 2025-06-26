import 'dart:ui';

import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/circle_user_avatar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/app_mode.dart';
import 'package:chronicle/core/utils/app_mode_bloc.dart';
import 'package:chronicle/core/utils/chronicle_appbar.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/core/utils/game_utils.dart';
import 'package:chronicle/core/utils/string_utils.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_event.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/create_game/presentation/page/create_game_page.dart';
import 'package:chronicle/features/game/presentation/page/game_page.dart';
import 'package:chronicle/features/home/presentation/bloc/game_state.dart';
import 'package:chronicle/features/home/presentation/bloc/home_bloc.dart';
import 'package:chronicle/features/home/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const route = "/home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppModeBloc, AppMode>(builder: (context, currentMode) {
      return Scaffold(
        appBar: _buildAppBar(context, currentMode),
        body: _buildBody(context, currentMode),
        backgroundColor: AppColors.background,
      );
    });
  }

  AppBar _buildAppBar(BuildContext context, AppMode currentMode) {
    return ChronicleAppBar.responsiveAppBar(
      context: context,
      titleWidget: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ChronicleSpacing.screenPadding),
            child: Row(
              children: [
                Hero(
                  tag: 'user_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleUserAvatar(
                      width: ChronicleSizes.responsiveAvatarSize(context),
                      height: ChronicleSizes.responsiveAvatarSize(context),
                      url: state.userModel?.photoUrl ?? "",
                    ),
                  ),
                ),
                ChronicleSpacing.horizontalSM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back,',
                        style: ChronicleTextStyles.bodySmall(context).copyWith(
                          color: AppColors.textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        state.userModel?.name ?? "",
                        style: ChronicleTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: ChronicleSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton(
              icon: Icon(
                Icons.apps_rounded,
                color: AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ChronicleSizes.smallBorderRadius),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.15),
              onSelected: (AppMode mode) {
                context.read<AppModeBloc>().add(ChangeAppModeEvent(mode));
              },
              itemBuilder: (BuildContext context) {
                return AppMode.values.map((AppMode mode) {
                  return PopupMenuItem<AppMode>(
                    value: mode,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ChronicleSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            child: Icon(
                              currentMode == mode
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 20,
                              color: currentMode == mode
                                  ? AppColors.primary
                                  : AppColors.textColor.withOpacity(0.5),
                            ),
                          ),
                          ChronicleSpacing.horizontalSM,
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mode.displayName,
                                style: TextStyle(
                                  fontWeight: currentMode == mode
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: currentMode == mode
                                      ? AppColors.primary
                                      : AppColors.textColor,
                                ),
                              ),
                              Text(
                                mode.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                  );
                }).toList();
              }),
        ),
        Container(
          margin: EdgeInsets.only(right: ChronicleSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => onLogoutPressed(context),
            icon: Icon(
              Icons.logout_rounded,
              size: ChronicleSizes.responsiveIconSize(context),
              color: AppColors.errorColor,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBody(BuildContext context, AppMode currentMode) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.status == HomeStatus.successfullyCheckedGame) {
          if (state.gameModel != null) {
            context.go(GamePage.route(state.gameModel!.gameCode));
          }
        }

        if (state.status == HomeStatus.error) {
          ChronicleSnackBar.showError(
            context: context,
            message: state.errorMessage ?? "Failed to join game",
          );
        }

        if (state.status == HomeStatus.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(ChronicleSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator.adaptive(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        SizedBox(height: ChronicleSpacing.md),
                        Text(
                          'Joining game...',
                          style: ChronicleTextStyles.bodyMedium(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state.status != HomeStatus.initial) {
          context.pop();
        }
      },
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(ChronicleSpacing.screenPadding),
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ChronicleSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            ChronicleSizes.smallBorderRadius),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Current Mode: ${currentMode.displayName}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          )
                        ],
                      )),
                  ChronicleSpacing.verticalLG,
                  Text(
                    StringUtils.getJoinButtonText(currentMode),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ChronicleSpacing.verticalMD,
                  DefaultTextField(
                    hintText:
                        "Enter ${currentMode.displayName.toLowerCase()} code",
                    fieldType: "textField",
                    controller: controller,
                    onSubmitted: (text) {
                      joinGameValidator(text);
                    },
                    borderRadius:
                        BorderRadius.circular(ChronicleSizes.smallBorderRadius),
                    actionIcon: IconButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            context.read<HomeBloc>().add(CheckGameByCodeEvent(
                                gameCode: controller.text));
                          }
                        },
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                          size: ChronicleSizes.iconLarge,
                        )),
                  ),
                  ChronicleSpacing.verticalLG,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.dividerColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ChronicleSpacing.md),
                        child: Text(
                          "or",
                          style: ChronicleTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.textColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.dividerColor.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),)
                    ],
                  ),
                  ChronicleSpacing.verticalLG,
                  DefaultButton(
                    text: StringUtils.getCreateButtonText(currentMode),
                    onPressed: () => context.push(CreateGamePage.route),
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.surface,
                    padding: const EdgeInsets.all(ChronicleSpacing.sm),
                  ),
                  ChronicleSpacing.verticalLG,
                  _buildGameHistorySection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget  _buildGameHistorySection(context) {
    return Container(
      padding: EdgeInsets.all(ChronicleSpacing.sm),
      child:  Text(
        "Game History",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  void onLogoutPressed(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel")),
              if (context.read<UserBloc>().state.status == UserStatus.loading)
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      foregroundColor: AppColors.surface),
                  onPressed: () {
                    context.read<UserBloc>().add(LogoutEvent());
                    if (context.mounted) {
                      ChronicleSnackBar.showSuccess(
                        context: context,
                        message: "Logged out successfully",
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Logout"))
            ],
          );
        });
  }

  void joinGameValidator(String rawCode) {
    final gameCode = GameUtils.normalizeGameCode(rawCode);
    final validationError = GameUtils.validateGameCode(rawCode);

    if (validationError != null) {
      ChronicleSnackBar.showError(
        context: context,
        message: validationError,
      );
      return;
    }
    context.read<HomeBloc>().add(CheckGameByCodeEvent(gameCode: gameCode));
  }
}
