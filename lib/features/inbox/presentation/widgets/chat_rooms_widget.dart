import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/chat_rooms_provider.dart';

class ChatRoomsWidget extends HookConsumerWidget {
  const ChatRoomsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsFuture = useFuture(ref.watch(chatRoomsProvider.future));

    return chatRoomsFuture.connectionState == ConnectionState.waiting
        ? const Center(child: CircularProgressIndicator())
        : chatRoomsFuture.hasError
            ? Center(child: Text('Error: ${chatRoomsFuture.error}'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: chatRoomsFuture.data!.length,
                itemBuilder: (context, index) {
                  final chatRoom = chatRoomsFuture.data![index];
                  // Assuming the chat room document has a 'name' field
                  final chatRoomName =
                      chatRoom.get('name') ?? 'Unnamed Chat Room';
                  return ListTile(
                    title: Text(chatRoomName),
                    // Add more details about the chat room here
                  );
                },
              );
  }
}
