import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_strings.dart';

enum SignInError {
  userNotFound,
  invalidEmail,
  invalidCredential,
  wrongPassword,
  common,
}

class SignInResult {
  final UserCredential? userCredential;
  final SignInError? error;

  SignInResult.success(this.userCredential) : error = null;
  SignInResult.failure(this.error) : userCredential = null;
}

class FirebaseSettings {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _firebaseStore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  String? get currentUserName => _firebaseAuth.currentUser!.displayName ?? "";

  Future<void> initNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _firebaseMessaging.setAutoInitEnabled(true);
      final fcmToken = await _firebaseMessaging.getToken();
      log(fcmToken ?? "");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<SignInResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return SignInResult.success(userCredential);
    } on FirebaseAuthException catch (e) {
      log(e.code);
      if (e.code == 'user-not-found') {
        return SignInResult.failure(SignInError.userNotFound);
      } else if (e.code == 'invalid-email') {
        return SignInResult.failure(SignInError.invalidEmail);
      } else if (e.code == 'invalid-credential') {
        return SignInResult.failure(SignInError.invalidCredential);
      } else if (e.code == 'wrong-password') {
        return SignInResult.failure(SignInError.wrongPassword);
      } else {
        return SignInResult.failure(SignInError.common);
      }
    } catch (e) {
      return SignInResult.failure(SignInError.common);
    }
  }

  Future<void> updateUsername(String userName) async {
    try {
      // Update the username in Firebase Authentication
      await _firebaseAuth.currentUser!.updateDisplayName(userName);

      // Update the username in Firestore
      await _firebaseStore
          .collection('users')
          .doc(
            _firebaseAuth.currentUser!.uid,
          )
          .update({
        'username': userName,
      });

      print(userName);

      // Show a success message
      Fluttertoast.showToast(
        msg: AppStrings.updateUserNameSuccessMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.greenAccent,
        textColor: AppColors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Show an error message
      Fluttertoast.showToast(
        msg: '${AppStrings.updateUserNameErrorMessage} $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.redAccent,
        textColor: AppColors.white,
        fontSize: 16.0,
      );
    }
  }
}
