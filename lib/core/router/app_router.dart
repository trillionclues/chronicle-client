import 'package:chronicle/features/auth/presentation/pages/auth_page.dart';
import 'package:chronicle/features/create_game/presentation/page/create_game_page.dart';
import 'package:chronicle/features/game/presentation/page/game_page.dart';
import 'package:chronicle/features/home/presentation/page/home_page.dart';
import 'package:chronicle/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class AppRouter {
  static var router = GoRouter(initialLocation: SplashPage.route, routes: [
    GoRoute(
        path: SplashPage.route,
        builder: (context, state) {
          return SplashPage();
        }),
    GoRoute(
        path: AuthPage.route,
        builder: (context, state) {
          return AuthPage();
        }),
    GoRoute(
        path: HomePage.route,
        builder: (context, state) {
          return HomePage();
        },
        routes: [
          GoRoute(
              path: "/game/:id",
              builder: (context, state) {
                final gameCode = state.pathParameters['id'] ?? "";
                return GamePage(gameCode: gameCode);
              }),
        ]),
    GoRoute(
      path: CreateGamePage.route,
      builder: (context, state) {
        return CreateGamePage();
      },
    ),
  ],  observers: [
    routeObserver
  ],);
}
