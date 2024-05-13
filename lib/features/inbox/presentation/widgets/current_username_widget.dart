import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';

class CurrentUsernameWidget extends HookWidget {
  const CurrentUsernameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserName = FirebaseSettings().currentUser?.displayName;

    return Container(
      width: double.infinity,
      color: AppColors.greenAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${AppStrings.loggedInAs} $currentUserName',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.black),
        ),
      ),
    );
  }
}
