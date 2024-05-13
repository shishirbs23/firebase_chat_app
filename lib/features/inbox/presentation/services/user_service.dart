import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';

class UserService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getLoggedInUsers(
      String excludedUserId) {
    return _fireStore
        .collection(AppStrings.loggedInUsers)
        .where(FieldPath.documentId, isNotEqualTo: excludedUserId)
        .get();
  }
}
