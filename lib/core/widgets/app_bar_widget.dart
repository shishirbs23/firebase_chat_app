import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_chat_app/core/config/firebase/FirebaseSettings.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/features/chat/presentation/widgets/signout_dialog_widget.dart';
import 'package:firebase_chat_app/utils/AppColors.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class AppBarWidget extends HookWidget implements PreferredSizeWidget {
  final String headerTitle;

  const AppBarWidget({super.key, required this.headerTitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: AppColors.appBarColor),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: AppColors.white,
                ),
              ),
              InkWell(
                child: const Text(
                  AppStrings.signOut,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: AppColors.white,
                  ),
                ),
                onTap: () {
                  _showSignOutDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SignOutDialogWidget(
          onConfirm: () async {
            await FirebaseSettings().signOut();
            context.goNamed(RouteNames.login);
            Fluttertoast.showToast(
              msg: AppStrings.successfullySignedOut,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: AppColors.greenAccent,
              textColor: AppColors.white,
              fontSize: 16.0,
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
