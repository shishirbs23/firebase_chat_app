import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
}
