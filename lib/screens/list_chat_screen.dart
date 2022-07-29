import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/pages/bot_page.dart';
import '../models/chat.dart';
import '../pages/chat_page.dart';
import '../providers.dart';
import '../services/bot.dart';

class ListChatScreen extends ConsumerWidget {
  const ListChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
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
        return Column(children: [
          ListTile(
            title: const Text('Mei'),
            subtitle: const Text('Your virtual assistant'),
            onTap: () async {
              final chatId = await ref
                      .read(databaseProvider)
                      ?.getChatStarted(myUser.uid, bot.uid) ??
                  false;
              // start a chat
              if (chatId == "") {
                await ref
                    .read(databaseProvider)
                    ?.startChat(myUser.uid, bot.uid, bot.name)
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
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const Divider(
            thickness: 4,
            color: Colors.indigo,
          ),
          ListView.builder(
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
        ]);
      },
    );
  }
}
