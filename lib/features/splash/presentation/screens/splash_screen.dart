import 'package:firebase_chat_app/core/config/firebase/FirebaseSettings.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:go_router/go_router.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authData = ref.watch(authStateProvider);

    return Scaffold(
      body: Center(
        child: authData.when(
          data: (user) => _handleToken(user, context),
          loading: () {
            return const Text(AppStrings.checkingUserInfo);
          },
          error: (error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed(RouteNames.login);
            });

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _handleToken(User? user, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        context.goNamed(RouteNames.login);
      } else {
        if (FirebaseSettings().currentUserName!.isEmpty) {
          context.goNamed(RouteNames.joinRoom);
        } else {
          context.goNamed(RouteNames.chat);
        }
      }
    });

    return const SizedBox.shrink();
  }
}
