import 'package:chronicle/core/di/get_it.dart';
import 'package:chronicle/core/router/app_router.dart';
import 'package:chronicle/core/theme/app_theme.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setup();
  runApp(BlocProvider(
    create: (context) => getIt<UserBloc>(),
    child: MaterialApp.router(
      routerConfig: AppRouter.router,
      theme: AppTheme.getThemeData(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}
