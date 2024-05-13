import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_chat_app/core/widgets/app_bar_widget.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import '../widgets/current_username_widget.dart';
import '../widgets/logged_in_users_widgets.dart';

class InboxScreen extends HookConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarWidget(
        headerTitle: AppStrings.inbox,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CurrentUsernameWidget(),
          LoggedInUsersWidget(),
          const SizedBox.shrink()

          // const ChatRoomsWidget(),
          // if (chatBoxVisible.value) ChatBoxWidget(chatRoomId: chatRoomId.value),
        ],
      ),
    );
  }
}
