import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/chronicle_snackbar.dart';
import 'package:chronicle/core/ui/widgets/circle_user_avatar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildJoinGame(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
        return Row(
          children: [
            CircleUserAvatar(
                width: ChronicleSizes.avatarMedium,
                height: ChronicleSizes.avatarMedium,
                url: state.userModel?.photoUrl ?? ""),
            ChronicleSpacing.horizontalSM,
            Text(
              state.userModel?.name ?? "",
              style: ChronicleTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ChronicleTextStyles.lg,
              ),
            )
          ],
        );
      }),
      actions: [
        IconButton(
            onPressed: () {
              onLogoutPressed(context);
            },
            icon: Icon(
              Icons.logout,
              size: ChronicleSizes.iconMedium,
            )),
      ],
    );
  }

  Widget _buildJoinGame(BuildContext context) {
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
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(ChronicleSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(ChronicleSizes.smallBorderRadius),
                  ),
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            },
          );
        } else if (state.status != HomeStatus.initial) {
          context.pop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(ChronicleSpacing.screenPadding),
        child: Column(
          children: [
            ChronicleSpacing.verticalLG,
            Text(
              "Join via code",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ChronicleSpacing.verticalMD,
            DefaultTextField(
              hintText: "Enter game code",
              fieldType: "textField",
              controller: controller,
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  context
                      .read<HomeBloc>()
                      .add(CheckGameByCodeEvent(gameCode: text));
                } else {
                  ChronicleSnackBar.showError(
                    context: context,
                    message: "Game code cannot be empty",
                  );
                }
              },
              borderRadius:
                  BorderRadius.circular(ChronicleSizes.smallBorderRadius),
              actionIcon: IconButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      context
                          .read<HomeBloc>()
                          .add(CheckGameByCodeEvent(gameCode: controller.text));
                    }
                  },
                  icon: Icon(
                    Icons.arrow_circle_right_outlined,
                    size: ChronicleSizes.iconLarge,
                  )),
            ),
            ChronicleSpacing.verticalLG,
            Text(
              "or",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ChronicleSpacing.verticalLG,
            DefaultButton(
              text: "Create new game",
              onPressed: () => context.push(CreateGamePage.route),
              backgroundColor: AppColors.primary,
              textColor: AppColors.textColor,
              padding: const EdgeInsets.symmetric(
                  vertical: ChronicleSpacing.md,
                  horizontal: ChronicleSpacing.sm),
            )
          ],
        ),
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
              // if logout is loading
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
}
