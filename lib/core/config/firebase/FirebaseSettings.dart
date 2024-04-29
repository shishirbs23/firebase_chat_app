import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_chat_app/utils/AppColors.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';

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

  Future<String?> get fcmToken async => await _firebaseMessaging.getToken();

  Future<void> initNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _firebaseMessaging.setAutoInitEnabled(true);

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification?.title,
            notification?.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: 'launch_background',
              ),
            ));
      });
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
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

  void subscribeToChatGroup(String chatGroupId) {
    _firebaseMessaging.subscribeToTopic(chatGroupId);
  }
}
