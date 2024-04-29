import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:firebase_chat_app/utils/AppConstants.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:intl/intl.dart';

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
        .collection('chats')
        .doc(AppConstants.chatGroupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('Received new messages: ${snapshot.docs.length}');
      // Update your state here
    });

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
                          DateFormat('HH:mm, MM/dd/yyyy').format(timestamp);

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
