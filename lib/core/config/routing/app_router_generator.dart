import 'package:firebase_chat_app/features/login/presentation/screens/login_screen.dart';
import 'package:firebase_chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:firebase_chat_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const chat = 'chat';
}

class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const chat = '/chat';
}

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      name: RouteNames.splash,
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: RouteNames.login,
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: RouteNames.chat,
      path: RoutePaths.chat,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);
