import 'package:flutter/material.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  static const String route = '/create-game';

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context){
    return AppBar(
      automaticallyImplyLeading: false,
      title: (
      Row()
      ),
    );
  }
}
