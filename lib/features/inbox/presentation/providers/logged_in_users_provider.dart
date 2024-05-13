import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

final loggedInUsersProvider =
    FutureProvider.autoDispose<QuerySnapshot<Map<String, dynamic>>>((ref) {
  final userService = UserService();
  return userService.getLoggedInUsers(FirebaseSettings().currentUser!.uid);
});
