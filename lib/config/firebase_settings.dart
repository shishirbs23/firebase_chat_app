import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseSettings {
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
}
