import 'package:chronicle/features/auth/presentation/pages/auth_page.dart';
import 'package:chronicle/splash_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static var router = GoRouter(initialLocation: AuthPage.route, routes: [
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
  ]);
}
