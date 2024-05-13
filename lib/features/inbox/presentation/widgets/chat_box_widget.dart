import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:firebase_chat_app/core/config/networking/endpoints.dart';
import 'package:firebase_chat_app/utils/app_constants.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_chat_app/core/config/networking/api_service.dart';

final messagesProvider = StreamProvider.autoDispose
    .family<QuerySnapshot, String>((ref, chatRoomId) {
  return FirebaseFirestore.instance
      .collection(AppStrings.chats)
      .doc(chatRoomId)
      .collection(AppStrings.messages)
      .orderBy(AppStrings.timestamp, descending: true)
      .snapshots();
});

class ChatBoxWidget extends HookConsumerWidget {
  final String chatRoomId;

  const ChatBoxWidget({super.key, required this.chatRoomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final currentUser = FirebaseSettings().currentUser;

    useEffect(() {
      final subscription = FirebaseFirestore.instance
          .collection(AppStrings.chats)
          .doc(chatRoomId)
          .collection(AppStrings.messages)
          .orderBy(AppStrings.timestamp, descending: true)
          .snapshots()
          .listen((event) async {
        String? fcmToken = await FirebaseSettings().fcmToken;

        if (fcmToken!.isNotEmpty) {
          var lastMessage = event.docs.first;
          Map<String, dynamic>? lastMessageData = lastMessage.data();
          String lastMessageUserName = lastMessageData[AppStrings.userName];
          String lastMessageText = lastMessageData[AppStrings.text];

          if (lastMessageUserName != FirebaseSettings().currentUserName) {
            final apiService = ApiService();

            const path = '${ApiService.baseUrl}/${Endpoints.sendFcm}';
            final requestBody = {
              "notification": {
                "title": "$lastMessageUserName sends you a message...",
                "body": lastMessageText
              },
              "to": fcmToken
            };
            await apiService.post(path, requestBody);
          }
        }
      });

      return subscription.cancel;
    }, const []);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, watch, child) {
                final messagesAsyncValue =
                ref.watch(messagesProvider(chatRoomId));

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
                    controller: controller,
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
                    if (controller.text.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection(AppStrings.chats)
                          .doc(chatRoomId)
                          .collection(AppStrings.messages)
                          .add({
                        AppStrings.id: currentUser?.uid,
                        AppStrings.userName: currentUser?.displayName,
                        AppStrings.text: controller.text,
                        AppStrings.timestamp: DateTime.now(),
                      });

                      controller.clear();
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
