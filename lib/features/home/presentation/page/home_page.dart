import 'package:chronicle/core/ui/widgets/circle_user_avatar.dart';
import 'package:chronicle/core/ui/widgets/default_text_field.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                width: 50, height: 50, url: state.userModel?.photoUrl ?? ""),
            SizedBox(
              width: 10,
            ),
            Text(
              state.userModel?.name ?? "",
              style: Theme.of(context).textTheme.headlineMedium,
            )
          ],
        );
      }),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.logout)),
      ],
    );
  }

  Widget _buildJoinGame(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Text(
          "Join via code",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(
          height: 15,
        ),
        DefaultTextField(
          hintText: "Enter game code",
          actionIcon: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_circle_right_outlined,
                size: 30,
              )),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          "or",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(
          height: 15,
        ),
        DefaultTextField(
          hintText: "Enter game code",
          actionIcon: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_circle_right_outlined,
                size: 30,
              )),
        ),
      ],
    );
  }
}
