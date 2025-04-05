import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const route = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Chronicle", style: Theme.of(context).textTheme.headlineLarge,),
      ),
    );
  }
}
