import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/models/chat.dart';
import 'package:pocketmedi/models/message.dart';
import 'package:pocketmedi/providers.dart';
import 'package:pocketmedi/services/bot.dart';
import 'package:http/http.dart' as http;

class UsersChat extends ConsumerStatefulWidget {
  final Chat chat;
  const UsersChat({required this.chat, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersChatState();
}

class _UsersChatState extends ConsumerState<UsersChat>
    with SingleTickerProviderStateMixin {
  // call api method
  Future<http.Response> getSentiment(String text) async {
    return await http.post(
      Uri.parse('https://ml.api.pocketmedi.live/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'Sentence': text}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${widget.chat.myName}'s chat with ${widget.chat.otherName}"),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
              child: StreamBuilder<List<Message>>(
                  stream: ref
                      .read(databaseProvider)!
                      .getMessages(widget.chat.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active &&
                        snapshot.hasData) {
                      final messages = snapshot.data ?? [];
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length + 2,
                        itemBuilder: (_, index) {
                          if (index == (messages.length + 1)) {
                            return Align(
                                alignment: Alignment.centerLeft,
                                child: otherChatBubble(Message(
                                    text:
                                        "Hi! I'm Mei, your virtual assistant. \n\nFeel free to chat with me whenever you'd like. Always happy to listen :)",
                                    myUid: bot.uid,
                                    time: DateTime.now().toString())));
                          }
                          if (index == messages.length) {
                            return Align(
                                alignment: Alignment.centerLeft,
                                child: otherChatBubble(Message(
                                    text: "How are you doing?",
                                    myUid: bot.uid,
                                    time: DateTime.now().toString())));
                          }
                          final message = messages[index];
                          final isMe = message.myUid == widget.chat.myUid;
                          if (isMe) {
                            return Align(
                                alignment: Alignment.centerRight,
                                child: myChatBubble(message));
                          } else {
                            return Align(
                                alignment: Alignment.centerLeft,
                                child: otherChatBubble(message));
                          }
                        },
                      );
                    }
                    return Container();
                  })),
          sendMessageField(),
        ]),
      ),
    );
  }

  Widget myChatBubble(Message message) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 50.0, right: 15.0, top: 7.0, bottom: 7.0),
      child: PopupMenuButton(
        offset: const Offset(-15, -5),
        color: Colors.indigoAccent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        position: PopupMenuPosition.under,
        itemBuilder: ((BuildContext context) {
          return [
            PopupMenuItem(
                child: RichText(
                    text: TextSpan(children: [
              TextSpan(
                text: message.sentiment == null
                    ? 'Fetching analysis...\n'
                    : '${message.sentiment}\n',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
              const TextSpan(
                text: 'Confidence:\n',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: message.sentiment == null
                    ? '\t\tFetching analysis...'
                    : '\t\t${(message.ptsdScore * 1000).round() / 10}% PTSD\n\t\t${(message.unpredScore * 1000).round() / 10}% Unpredictable\n\t\t${(message.noScore * 1000).round() / 10}% No PTSD',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ]))),
          ];
        }),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 222, 255),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 5),
                color: Colors.grey.withOpacity(.1),
                blurRadius: 5.0,
                spreadRadius: 1.0,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Text(message.text),
        ),
      ),
    );
  }

  Widget otherChatBubble(Message message) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin:
          const EdgeInsets.only(left: 15.0, right: 50.0, top: 7.0, bottom: 7.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.grey.withOpacity(.1),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
          topLeft: Radius.circular(10.0),
        ),
      ),
      child: Text(message.text),
    );
  }

  Widget sendMessageField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, left: 10, right: 10, top: 15),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(80)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.2),
                  offset: const Offset(0.0, 0.50),
                  spreadRadius: 1,
                  blurRadius: 1),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '^Mei',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.chat.myName}^',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
