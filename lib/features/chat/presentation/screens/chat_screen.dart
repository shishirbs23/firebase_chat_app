import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/core/config/firebase/FirebaseSettings.dart';
import 'package:firebase_chat_app/core/config/networking/Endpoints.dart';
import 'package:firebase_chat_app/utils/AppConstants.dart';
import 'package:firebase_chat_app/utils/AppStrings.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_chat_app/core/config/networking/ApiService.dart';

final messagesProvider = StreamProvider.autoDispose
    .family<QuerySnapshot, String>((ref, chatGroupId) {
  return FirebaseFirestore.instance
      .collection(AppStrings.chats)
      .doc(chatGroupId)
      .collection(AppStrings.messages)
      .orderBy(AppStrings.timestamp, descending: true)
      .snapshots();
});

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final currentUser = FirebaseSettings().currentUser;

    useEffect(() {
      final subscription = FirebaseFirestore.instance
          .collection(AppStrings.chats)
          .doc(AppConstants.chatGroupId)
          .collection(AppStrings.messages)
          .orderBy(AppStrings.timestamp, descending: true)
          .snapshots()
          .listen((event) async {
        String? fcmToken = await FirebaseSettings().fcmToken;

        if (fcmToken!.isNotEmpty) {
          Map<String, dynamic> lastMessage = event.docs.first.data();
          String lastMessageUserName = lastMessage[AppStrings.userName];
          String lastMessageText = lastMessage[AppStrings.text];

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
                          .doc(AppConstants.chatGroupId)
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
