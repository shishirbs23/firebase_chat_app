import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomsProvider = FutureProvider.autoDispose<List<QueryDocumentSnapshot>>((ref) {
  final firebaseSettings = FirebaseSettings();
  return firebaseSettings.getChatRoomsForUser(FirebaseSettings().currentUser!.uid);
});
