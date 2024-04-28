import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/core/config/storage/app_storage.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final storageProvider = Provider<AppStorage>((ref) => AppStorage());
final authTokenProvider = FutureProvider<String>(
  (ref) => ref.read(storageProvider).getAuthToken(),
);

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenData = ref.watch(authTokenProvider);

    return Scaffold(
      body: Center(
        child: tokenData.when(
          data: (token) => _handleToken(token, context),
          loading: () {
            return const Text(AppStrings.checkingUserInfo);
          },
          error: (error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed(RouteNames.login);
            });
            return const Placeholder();
          },
        ),
      ),
    );
  }

  Widget _handleToken(String token, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (token.isEmpty) {
        context.goNamed(RouteNames.login);
      } else {
        context.goNamed(RouteNames.chat);
      }
    });

    return const SizedBox();
  }
}
