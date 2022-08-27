import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/models/message.dart';
import 'package:pocketmedi/pages/bot_page.dart';
import '../models/chat.dart';
import '../pages/chat_page.dart';
import '../providers.dart';
import '../services/bot.dart';

class ListChatScreen extends ConsumerWidget {
  const ListChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    dynamic role;
    Future getRole(String uid) async {
      DocumentReference user =
          FirebaseFirestore.instance.collection('users').doc(uid);
      dynamic data;

      await user.get().then((doc) => {data = doc.data()});

      role = data["role"];
      log('$role');
    }

    dynamic otherRole;
    Future getOtherRole(String uid) async {
      DocumentReference user =
          FirebaseFirestore.instance.collection('users').doc(uid);
      dynamic data;

      await user.get().then((doc) => {data = doc.data()});

      otherRole = data["role"];
      log('$otherRole');
    }

    return StreamBuilder<List<Chat?>>(
      stream: ref.read(databaseProvider)!.getChats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong!"),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chats = snapshot.data ?? [];
        final myUser = ref.read(firebaseAuthProvider).currentUser!;
        return SingleChildScrollView(
          child: Column(children: [
            FutureBuilder(
                future: getRole(myUser.uid),
                builder: (context, snapshot) {
                  log('$role');
                  return role == 'doctor'
                      ? Container()
                      : role == null
                          ? Container()
                          : Column(
                              children: [
                                ListTile(
                                  title: const Text('Mei'),
                                  subtitle:
                                      const Text('Your virtual assistant'),
                                  onTap: () async {
                                    final chatId = await ref
                                            .read(databaseProvider)
                                            ?.getChatStarted(
                                                myUser.uid, bot.uid) ??
                                        false;

                                    final doc = await FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(chatId.toString())
                                        .get();
                                    Chat chat = Chat.fromJson(doc.data()!);

                                    // start a chat
                                    if (chatId == "") {
                                      await ref
                                          .read(databaseProvider)
                                          ?.startChat(
                                              myUser.uid, bot.uid, bot.name)
                                          .then((value) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BotPage(
                                              chat: Chat(
                                                myUid: myUser.uid,
                                                myName: "",
                                                otherUid: bot.uid,
                                                otherName: bot.name,
                                                chatId: value,
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BotPage(
                                            chat: Chat(
                                              myUid: myUser.uid,
                                              myName: "",
                                              otherUid: bot.uid,
                                              otherName: bot.name,
                                              chatId: chatId.toString(),
                                              totalCount: chat.totalCount,
                                              ptsdCount: chat.ptsdCount,
                                            ),
                                          ),
                                        ),
                                      );
                                      await Future.delayed(
                                          const Duration(milliseconds: 500));

                                      await ref
                                          .read(databaseProvider)!
                                          .sendMessage(
                                            chatId.toString(),
                                            Message(
                                              text: "Hello!",
                                              myUid: bot.uid,
                                              time: DateTime.now().toString(),
                                            ),
                                          );
                                      await Future.delayed(
                                          const Duration(milliseconds: 500));

                                      await ref
                                          .read(databaseProvider)!
                                          .sendMessage(
                                            chatId.toString(),
                                            Message(
                                              text: "How are you doing?",
                                              myUid: bot.uid,
                                              time: DateTime.now().toString(),
                                            ),
                                          );
                                    }
                                  },
                                ),
                                const Divider(
                                  thickness: 4,
                                  color: Colors.indigo,
                                ),
                              ],
                            );
                }),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index]; // type Chat
                final myUser =
                    ref.read(firebaseAuthProvider).currentUser!; // type User
                if (chat == null) {
                  return Container();
                }
                if (chat.otherUid == bot.uid || chat.myUid == bot.uid) {
                  return Container();
                }
                return Column(
                  children: [
                    ListTile(
                      title: Text(myUser.uid == chat.myUid
                          ? chat.otherName
                          : chat.myName),
                      subtitle: FutureBuilder(
                        future: getOtherRole(myUser.uid == chat.myUid
                            ? chat.otherUid
                            : chat.myUid),
                        builder: (context, snapshot) {
                          return otherRole == null
                              ? Container()
                              : Text('$otherRole');
                        },
                      ),
                      onTap: () async {
                        // start a chat
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => ChatScreen(chat: chat),
                            builder: (context) => ChatPage(
                              chat: chat,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ]),
        );
      },
    );
  }
}
