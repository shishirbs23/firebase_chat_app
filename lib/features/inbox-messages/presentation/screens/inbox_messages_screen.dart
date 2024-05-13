import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:intl/intl.dart';
import 'package:firebase_chat_app/utils/app_constants.dart';
import '../providers/chat_room_messages_provider.dart';

class InboxMessagesScreen extends HookConsumerWidget {
  final String chatRoomId;
  final String userId;
  final String email;
  final String userName;

  const InboxMessagesScreen({
    super.key,
    required this.chatRoomId,
    required this.userId,
    required this.email,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final currentUser = FirebaseSettings().currentUser!;

    return Scaffold(
      appBar: AppBarWidget(headerTitle: 'Inbox'),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Consumer(
              builder: (context, watch, child) {
                final messagesAsyncValue =
                    ref.watch(chatRoomMessagesProvider(chatRoomId));

                return messagesAsyncValue.when(
                  data: (messages) => messages.docs.isEmpty
                      ? const Center(
                          child: Text(
                            AppStrings.noMessages,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                        )
                      : ListView.builder(
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
                                DateFormat(AppConstants.dateFormat)
                                    .format(timestamp);

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
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
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
                  color: controller.text.isEmpty ? Colors.grey : AppColors.blue,
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      FirebaseSettings().sendMessage(
                          chatRoomId,
                          currentUser.uid,
                          currentUser.email ?? "",
                          currentUser.displayName ?? "",
                          userId,
                          email,
                          userName,
                          controller.text);

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
