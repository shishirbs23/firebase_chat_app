import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/core/config/firebase/FirebaseSettings.dart';
import 'package:firebase_chat_app/core/config/networking/Endpoints.dart';
import 'package:firebase_chat_app/utils/AppConstants.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/networking/ApiService.dart';

final messagesProvider = StreamProvider.autoDispose
    .family<QuerySnapshot, String>((ref, chatGroupId) {
  return FirebaseFirestore.instance
      .collection(AppStrings.chats)
      .doc(chatGroupId)
      .collection(AppStrings.messages)
      .orderBy(AppStrings.timestamp, descending: true)
      .snapshots();
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final User? currentUser = FirebaseSettings().currentUser;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection(AppStrings.chats)
        .doc(AppConstants.chatGroupId)
        .collection(AppStrings.messages)
        .orderBy(AppStrings.timestamp, descending: true)
        .snapshots()
        .listen(
      (event) async {
        String? fcmToken = await FirebaseSettings().fcmToken;

        if (fcmToken!.isNotEmpty) {
          Map<String, dynamic> lastMessage = event.docs.first.data();
          String lastMessageUserName = lastMessage["userName"];
          String lastMessageText = lastMessage["text"];

          print(event.docs.first.data());

          if (lastMessageUserName != FirebaseSettings().currentUserName) {
            print("mile nai, so push jabe");

            final apiService = ApiService();

            const path = '${ApiService.baseUrl}/${Endpoints.sendFcm}';
            final requestBody = {
              "notification": {
                "title": "$lastMessageUserName sends you a message...",
                "body": lastMessageText
              },
              "to": fcmToken
            };

            try {
              final response = await apiService.post(path, requestBody);
              print('Response: $response');
            } catch (e) {
              print('Error: $e');
            }
          }
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        headerTitle:
            '${AppStrings.currentUser}: ${FirebaseSettings().currentUser?.displayName}',
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, watch, child) {
                final messagesAsyncValue =
                    ref.watch(messagesProvider(AppConstants.chatGroupId));

                return messagesAsyncValue.when(
                  data: (messages) => ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: messages.docs.length,
                    itemBuilder: (context, index) {
                      final message = messages.docs[index];
                      final Map<String, dynamic> messageData =
                          message.data() as Map<String, dynamic>;
                      final userName =
                          messageData.containsKey(AppStrings.userName)
                              ? messageData[AppStrings.userName]
                              : AppStrings.anonymous;
                      final timestamp =
                          messageData[AppStrings.timestamp].toDate();
                      final formattedTimestamp =
                          DateFormat(AppConstants.dateFormat).format(timestamp);

                      return ListTile(
                        title: Text(message[AppStrings.text]),
                        subtitle: Text(
                          userName,
                        ),
                        trailing: Text(formattedTimestamp),
                      );
                    },
                  ),
                  loading: () => const Center(
                    child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: AppStrings.enterYourMessage,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection(AppStrings.chats)
                          .doc(AppConstants.chatGroupId)
                          .collection(AppStrings.messages)
                          .add({
                        AppStrings.id: currentUser?.uid,
                        AppStrings.userName: currentUser?.displayName,
                        AppStrings.text: _controller.text,
                        AppStrings.timestamp: DateTime.now(),
                      });

                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
