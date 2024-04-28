import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_chat_app/features/chat/presentation/widgets/app_bar_widget.dart';

final messagesProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots();
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, watch, child) {
                final messagesAsyncValue = ref.watch(messagesProvider);
                return messagesAsyncValue.when(
                  data: (messages) => ListView.builder(
                    reverse: true,
                    itemCount: messages.docs.length,
                    itemBuilder: (context, index) {
                      final message = messages.docs[index];
                      return ListTile(
                        title: Text(message['text']),
                        subtitle: Text(message['timestamp'].toString()),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _messagesCollection.add({
                        'text': _controller.text,
                        'timestamp': DateTime.now(),
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
