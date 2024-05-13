import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';

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

  Future<void> handleBackgroundMessage(RemoteMessage message) async {}

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

  Future<void> updateUsernameInFireStore(String uid, String userName) async {
    await _firebaseStore
        .collection(AppStrings.loggedInUsers)
        .where(AppStrings.userId, isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update(
          {
            AppStrings.userName: userName,
          },
        );
      }
    });
  }

  void subscribeToChatGroup(String chatGroupId) {
    _firebaseMessaging.subscribeToTopic(chatGroupId);
  }

  Future<void> deleteUserDocument(String userId) async {
    await _firebaseStore
        .collection(AppStrings.loggedInUsers)
        .where(AppStrings.userId, isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> createChatRoom(String chatRoomId, User? currentUser,
      Map<String, dynamic> otherUser) async {
    final chatRoomRef = FirebaseFirestore.instance
        .collection(AppStrings.chatRooms)
        .doc(chatRoomId);

    await chatRoomRef.set({
      AppStrings.id: chatRoomId,
      AppStrings.name:
          "${currentUser?.displayName}-${otherUser[AppStrings.userName]}",
      AppStrings.users: {
        currentUser?.uid: true,
        otherUser[AppStrings.userId]: true,
      },
      AppStrings.createdAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Future<void> sendMessage(
  //     String chatRoomId, String senderId, String messageText) async {
  //   final messagesRef = FirebaseFirestore.instance
  //       .collection(AppStrings.chatRooms)
  //       .doc(chatRoomId)
  //       .collection(AppStrings.messages);
  //
  //   await messagesRef.add({
  //     AppStrings.senderId: senderId,
  //     AppStrings.message: messageText,
  //     AppStrings.timestamp: FieldValue.serverTimestamp(),
  //   });
  // }

  Future<List<Map<String, dynamic>>?> getAllMessages(String chatRoomId) async {
    // Reference to the chat room document
    DocumentReference chatRoomRef = FirebaseFirestore.instance
        .collection(AppStrings.chatRooms)
        .doc(chatRoomId);

    // Fetch the chat room document
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    Map<String, dynamic>? chatRoomData =
        chatRoomSnapshot.data() as Map<String, dynamic>?;

    // Check if the document exists and contains the 'messages' field
    if (chatRoomData != null && chatRoomData.containsKey(AppStrings.messages)) {
      // Return the messages as a list of maps
      return chatRoomData[AppStrings.messages] as List<Map<String, dynamic>>?;
    } else {
      // If the document does not exist or does not contain the 'messages' field, return null
      return [];
    }
  }

  Future<void> sendMessage(
      String chatRoomId,
      String senderId,
      String senderEmail,
      String senderUserName,
      String receiverId,
      String receiverEmail,
      String receiverUserName,
      String messageText) async {
    // Create a new message object
    Map<String, dynamic> message = {
      AppStrings.senderId: senderId,
      AppStrings.senderEmail: senderEmail,
      AppStrings.senderUserName: senderUserName,
      AppStrings.receiverId: receiverId,
      AppStrings.receiverEmail: receiverEmail,
      AppStrings.receiverUserName: receiverUserName,
      AppStrings.createdAt: FieldValue.serverTimestamp(),
      AppStrings.message: messageText,
    };

    // Reference to the chat room document
    DocumentReference chatRoomRef = FirebaseFirestore.instance
        .collection(AppStrings.chatRooms)
        .doc(chatRoomId);

    // Check if the messages field exists
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
    Map<String, dynamic>? chatRoomData =
        chatRoomSnapshot.data() as Map<String, dynamic>?;

    if (chatRoomData != null && chatRoomData.containsKey(AppStrings.messages)) {
      // If messages field exists, add the new message
      await chatRoomRef.update({
        AppStrings.messages: FieldValue.arrayUnion([message]),
      });
    } else {
      // If messages field does not exist, create it with the new message as the first element
      await chatRoomRef.update({
        AppStrings.messages: [message],
      });
    }
  }

  Future<List<QueryDocumentSnapshot>> getChatRoomsForUser(String userId) async {
    final chatRoomsRef =
        FirebaseFirestore.instance.collection(AppStrings.chatRooms);
    final querySnapshot = await chatRoomsRef.get();

    // Filter the documents to only include those where the 'users' field contains the userId
    final filteredDocs = querySnapshot.docs.where((doc) {
      final users = doc.data()[AppStrings.users] as Map<String, dynamic>?;
      return users != null && users.containsKey(userId);
    }).toList();

    print(filteredDocs);

    return filteredDocs;
  }
}
