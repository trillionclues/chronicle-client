import 'package:chronicle/core/theme/app_colors.dart';
import 'package:chronicle/core/ui/widgets/circle_user_avatar.dart';
import 'package:chronicle/core/ui/widgets/default_button.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/core/utils/chronicle_spacing.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_event.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/create_game/presentation/page/create_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = "/home";

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
              style: Theme.of(context).textTheme.headlineMedium,
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
    return Padding(
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
            borderRadius:
                BorderRadius.circular(ChronicleSizes.smallBorderRadius),
            actionIcon: IconButton(
                onPressed: () {},
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
            backgroundColor: AppColors.secondary,
            textColor: AppColors.textColor,
            padding: const EdgeInsets.symmetric(
                vertical: ChronicleSpacing.md, horizontal: ChronicleSpacing.sm),
          )
        ],
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
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(LogoutEvent());
                    Navigator.pop(context);
                  },
                  child: Text("Logout"))
            ],
          );
        });
  }
}
