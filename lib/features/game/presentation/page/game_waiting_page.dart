import 'package:chronicle/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameWaitingPage extends StatelessWidget {
  const GameWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Text(
          "Waiting for players to join...",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
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
              icon: Icon(Icons.chevron_left)),
          Text(
            "Waiting for players...",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16),
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.errorColor,
                  ),
              foregroundColor: AppColors.errorColor,
              alignment: Alignment.center,
            ),
            child: Text(
              "Cancel Game",
            ),
          )
        ],
      ),
    );
  }
}
