import 'package:chronicle/core/di/get_it.dart';
import 'package:chronicle/core/router/app_router.dart';
import 'package:chronicle/core/theme/app_theme.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_bloc.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_event.dart';
import 'package:chronicle/features/auth/presentation/bloc/user_state.dart';
import 'package:chronicle/features/auth/presentation/pages/auth_page.dart';
import 'package:chronicle/features/home/presentation/page/home_page.dart';
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
    create: (context) => getIt<UserBloc>()..add(GetUserEvent()),
    child: MaterialApp.router(
      routerConfig: AppRouter.router,
      theme: AppTheme.getThemeData(),
      debugShowCheckedModeBanner: false,
      builder: (context, router) {
        return BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state.status == UserStatus.success) {
              AppRouter.router.go(HomePage.route);
            } else if (state.status == UserStatus.error) {
              AppRouter.router.go(AuthPage.route);
            }
          },
          child: router,
        );
      },
    ),
  ));
}
