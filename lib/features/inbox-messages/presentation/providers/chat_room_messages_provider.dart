import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final chatRoomMessagesProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, chatRoomId) {
  return FirebaseFirestore.instance
      .collection(AppStrings.chatRooms)
      .doc(chatRoomId)
      .collection(AppStrings.messages)
      .snapshots();
});
