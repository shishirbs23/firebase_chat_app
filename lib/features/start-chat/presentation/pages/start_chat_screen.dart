import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:firebase_chat_app/utils/app_constants.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';

class StartChatScreen extends HookWidget {
  const StartChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = useTextEditingController();

    return Scaffold(
      appBar: AppBarWidget(
        headerTitle: AppStrings.startChat,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String? currentUserName = FirebaseSettings().currentUserName;

            if (currentUserName!.isEmpty) {
              await _showUsernameDialog(context, usernameController);
            } else {
              await FirebaseSettings().updateUsernameInFireStore(
                  FirebaseSettings().currentUser?.uid ?? "",
                  FirebaseSettings().currentUserName ?? "");
              FirebaseSettings().subscribeToChatGroup(AppConstants.chatGroupId);
              context.goNamed(RouteNames.inbox);
            }
          },
          child: const Text(
            AppStrings.startChatting,
            style: TextStyle(
              color: AppColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showUsernameDialog(
      BuildContext context, TextEditingController usernameController) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.addUserName),
          content: TextField(
            controller: usernameController,
            decoration:
                const InputDecoration(hintText: AppStrings.enterUserName),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(AppStrings.start),
              onPressed: () async {
                if (usernameController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: AppStrings.emptyUsernameNotAllowed,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: AppColors.redAccent,
                    textColor: AppColors.white,
                    fontSize: 16.0,
                  );

                  return;
                }

                await FirebaseSettings()
                    .updateUsername(usernameController.text);
                await FirebaseSettings().updateUsernameInFireStore(
                    FirebaseSettings().currentUser?.email ?? "",
                    usernameController.text);
                Navigator.of(context).pop();
                FirebaseSettings()
                    .subscribeToChatGroup(AppConstants.chatGroupId);
                context.goNamed(RouteNames.inbox);
              },
            ),
          ],
        );
      },
    );
  }
}
