import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        headerTitle: AppStrings.joinRoom,
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              String? currentUserName = FirebaseSettings().currentUserName;

              print('current user name');
              print(currentUserName);

              if (currentUserName!.isEmpty) {
                _showUsernameDialog(context);
              } else {
                context.goNamed(RouteNames.chat);
              }
            },
            child: const Text(
              AppStrings.joinChatRoom,
              style: TextStyle(
                color: AppColors.blue,
              ),
            )),
      ),
    );
  }

  Future<void> _showUsernameDialog(BuildContext context) async {
    final TextEditingController usernameController = TextEditingController();

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
              child: const Text(AppStrings.join),
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
                Navigator.of(context).pop();
                context.goNamed(RouteNames.chat);
              },
            ),
          ],
        );
      },
    );
  }
}
