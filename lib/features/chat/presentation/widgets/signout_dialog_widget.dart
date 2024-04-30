import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';

class SignOutDialogWidget extends HookWidget {
  final Function onConfirm;

  const SignOutDialogWidget({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        AppStrings.confirmSignOut,
        style: TextStyle(fontSize: 20.0),
      ),
      content: const Text(
        AppStrings.areYouSureToSignOut,
        style: TextStyle(fontSize: 18.0),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            AppStrings.cancel,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text(
            AppStrings.signOut,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
