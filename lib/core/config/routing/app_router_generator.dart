import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_chat_app/features/login/presentation/screens/login_screen.dart';
import 'package:firebase_chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:firebase_chat_app/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:firebase_chat_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:firebase_chat_app/features/start-chat/presentation/pages/start_chat_screen.dart';
import 'package:firebase_chat_app/features/inbox-messages/presentation/screens/inbox_messages_screen.dart';

class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const startChat = 'start-chat';
  static const chat = 'chat';
  static const inbox = 'inbox';
  static const inboxMessages = 'inbox-messages';
}

class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const startChat = '/start-chat';
  static const chat = '/chat';
  static const inbox = '/inbox';
  static const inboxMessages = '/inbox-messages';
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
      name: RouteNames.startChat,
      path: RoutePaths.startChat,
      builder: (context, state) => const StartChatScreen(),
    ),
    GoRoute(
      name: RouteNames.chat,
      path: RoutePaths.chat,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      name: RouteNames.inbox,
      path: RoutePaths.inbox,
      builder: (context, state) => const InboxScreen(),
    ),
    GoRoute(
      name: RouteNames.inboxMessages,
      path: '${RoutePaths.inboxMessages}/:${AppStrings.chatRoomId}',
      builder: (context, state) {
        final chatRoomId = state.pathParameters[AppStrings.chatRoomId];

        return InboxMessagesScreen(
          chatRoomId: chatRoomId!,
          userId: state.uri.queryParameters[AppStrings.userId]!,
          email: state.uri.queryParameters[AppStrings.email]!,
          userName: state.uri.queryParameters[AppStrings.userName]!,
        );
      },
    ),
  ],
);
