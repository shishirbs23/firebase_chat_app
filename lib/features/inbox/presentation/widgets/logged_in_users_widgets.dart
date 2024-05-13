import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import '../providers/logged_in_users_provider.dart';

class LoggedInUsersWidget extends HookConsumerWidget {
  LoggedInUsersWidget({
    super.key,
  });

  final currentUserName = FirebaseSettings().currentUser?.displayName;

  String checkUserName(Map<String, dynamic> user) {
    if (user[AppStrings.userName] == currentUserName) {
      return AppStrings.you;
    }
    return user[AppStrings.userName] ?? AppStrings.anonymous;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseSettings().currentUser;
    final chatBoxVisible = useState(false);
    final chatRoomId = useState('');
    final isClicked = useState(false);

    final loggedInUsersFuture =
        useFuture(ref.watch(loggedInUsersProvider.future));

    Future<void> openChatRoom(BuildContext context, Map<String, dynamic> user,
        String chatRoomId) async {
      print(user);

      // Check if the chat room already exists
      final chatRoomSnapshot = await FirebaseFirestore.instance
          .collection(AppStrings.chatRooms)
          .doc(chatRoomId)
          .get();

      print(chatRoomSnapshot.exists);

      if (chatRoomSnapshot.exists) {
        // Chat room exists, navigate to it
        context.pushNamed(RouteNames.inboxMessages, pathParameters: {
          AppStrings.chatRoomId: chatRoomId,
        }, queryParameters: {
          AppStrings.userId: user[AppStrings.userId],
          AppStrings.email: user[AppStrings.email],
          AppStrings.userName: user[AppStrings.userName],
        });
        isClicked.value = false;
      } else {
        // Chat room does not exist, create it
        await FirebaseSettings().createChatRoom(chatRoomId, currentUser, user);
        // Then navigate to it
        context.pushNamed(RouteNames.inboxMessages,
            pathParameters: {'chatRoomId': chatRoomId});
        isClicked.value = false;
      }
    }

    Future<void> openChat(Map<String, dynamic> user) async {
      if ((currentUser?.uid != user[AppStrings.userId]) && !isClicked.value) {
        chatBoxVisible.value = true;
        isClicked.value = true;

        final sortedUIds = [currentUser!.uid, user[AppStrings.userId]];
        sortedUIds.sort();
        chatRoomId.value = sortedUIds.join('_');

        openChatRoom(context, user, chatRoomId.value);
      }
    }

    return loggedInUsersFuture.connectionState == ConnectionState.waiting
        ? const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: SizedBox(
              height: 25.0,
              width: 25.0,
              child: CircularProgressIndicator(),
            ),
          )
        : loggedInUsersFuture.hasError
            ? Text('Error: ${loggedInUsersFuture.error}')
            : loggedInUsersFuture.hasData
                ? Column(
                    children: [
                      const Text(
                        AppStrings.currLoggedInUsers,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: loggedInUsersFuture.data!.docs.length,
                            itemBuilder: (context, index) {
                              final user =
                                  loggedInUsersFuture.data!.docs[index].data();

                              return InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () => openChat(user),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 24.0,
                                          child: Text(
                                            user[AppStrings.userName][0]
                                                .toString()
                                                .toUpperCase(),
                                            style:
                                                const TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        Text(
                                          checkUserName(user),
                                          style:
                                              const TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (isClicked.value)
                        const Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.openingChat,
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              SizedBox(
                                height: 28.0,
                                width: 28.0,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                : const Text(AppStrings.noLoggedInUsers);
  }
}
