import 'package:firebase_chat_app/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
  static showToast(String toastMessage, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: toastMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? AppColors.red : AppColors.white,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
