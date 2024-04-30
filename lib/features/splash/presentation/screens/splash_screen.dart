import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:go_router/go_router.dart';
import 'package:firebase_chat_app/core/config/firebase/FirebaseSettings.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authData = useStream(
      FirebaseAuth.instance.authStateChanges(),
      initialData: null,
    );

    useEffect(() {
      _handleAuthState(authData.data, context);
      // Clean up effect
      return () {};
    }, [authData]); // Trigger effect only when authData changes

    return const Scaffold(
      body: Center(
        child: SizedBox.shrink(), // Show a Sized box to minimize content
      ),
    );
  }

  void _handleAuthState(User? user, BuildContext context) {
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
  }
}
