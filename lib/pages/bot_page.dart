import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/models/analysis.dart';
import 'package:pocketmedi/models/chat.dart';
import 'package:pocketmedi/models/message.dart';
import 'package:pocketmedi/providers.dart';
import 'package:pocketmedi/services/bot.dart';
import 'package:http/http.dart' as http;
import 'package:pocketmedi/services/bot_service.dart';

class BotPage extends ConsumerStatefulWidget {
  final Chat chat;
  const BotPage({required this.chat, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BotPageState();
}

class _BotPageState extends ConsumerState<BotPage>
    with SingleTickerProviderStateMixin {
  final _textMessageController = TextEditingController();
  final BotService _botService = BotService();

  void _addMessage(String message) async {
    log("USER: $message");
    var data = await _botService.callBot(message);
    log("LEX: ${data['reply']}");

    await ref.read(databaseProvider)!.sendMessage(
          widget.chat.chatId,
          Message(
            text: data['reply'],
            myUid: bot.uid,
            time: DateTime.now().toString(),
          ),
        );
  }

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
    final myUid = ref.read(firebaseAuthProvider).currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.myUid == myUid
            ? widget.chat.otherName
            : widget.chat.myName),
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
                        itemCount: messages.length,
                        itemBuilder: (_, index) {
                          if (index == (messages.length - 1)) {
                            return Align(
                                alignment: Alignment.centerLeft,
                                child: otherChatBubble(Message(
                                    text:
                                        "Hi! I'm Mei, your virtual assistant. \n\nFeel free to chat with me whenever you'd like. Always happy to listen :)",
                                    myUid: bot.uid,
                                    time: DateTime.now().toString())));
                          }
                          final message = messages[index];
                          final isMe = message.myUid ==
                              ref.read(firebaseAuthProvider).currentUser!.uid;
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
        padding: const EdgeInsets.all(10),
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
          children: [
            const SizedBox(
              width: 10,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 60,
                ),
                child: Scrollbar(
                  child: TextField(
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    controller: _textMessageController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message",
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            InkWell(
              onTap: () async {
                if (_textMessageController.text.isNotEmpty) {
                  String message = _textMessageController.text;
                  String timeOnSent = DateTime.now().toString();

                  // adds message (without analysis) to a new document in firestore
                  DocumentReference docid = await ref
                      .read(databaseProvider)!
                      .sendMessage(
                          widget.chat.chatId,
                          Message(
                              text: message,
                              myUid: ref
                                  .read(firebaseAuthProvider)
                                  .currentUser!
                                  .uid,
                              time: timeOnSent));

                  // sends message to bot api and gets response from bot
                  _addMessage(message);

                  _textMessageController.clear();

                  // calls api method to send message to api for analysis
                  http.Response djangoResponses = await getSentiment(message);
                  log(djangoResponses.body);

                  // processes output from api
                  Analysis result =
                      Analysis.fromJson(json.decode(djangoResponses.body));
                  String stringValues = result.ptsdValues.toString();
                  var splitted = stringValues.split('[');
                  var splitted2 = splitted[2].split(']');
                  var splitted3 = splitted2[0].split(', ');
                  List<double> ptsdValues = [
                    double.parse(splitted3[0]),
                    double.parse(splitted3[1]),
                    double.parse(splitted3[2]),
                  ];

                  // adds analyses to message document in firestore
                  await docid.update({
                    'valueSentiment': result.valueSentiment,
                    'sentiment': result.sentiment,
                    'ptsdScore': ptsdValues[0],
                    'unpredScore': ptsdValues[1],
                    'noScore': ptsdValues[2],
                  });

                  // gets DocumentReference of chatt
                  final doc = await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chat.chatId)
                      .get();

                  // maps chat info from json
                  Chat chat = Chat.fromJson(doc.data()!);

                  // updates user status depending on ratio of ptsd messages to total messages
                  if (result.valueSentiment == 0) {
                    if (((chat.ptsdCount + 1) / (chat.totalCount + 1)) >=
                        0.65) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(ref.read(firebaseAuthProvider).currentUser!.uid)
                          .update(
                              {'status': 'concerning', 'hasTextedBot': true});
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(ref.read(firebaseAuthProvider).currentUser!.uid)
                          .update({'status': 'normal', 'hasTextedBot': true});
                    }
                  } else {
                    if (chat.ptsdCount / (chat.totalCount + 1) >= 0.65) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(ref.read(firebaseAuthProvider).currentUser!.uid)
                          .update(
                              {'status': 'concerning', 'hasTextedBot': true});
                    } else {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(ref.read(firebaseAuthProvider).currentUser!.uid)
                          .update({'status': 'normal', 'hasTextedBot': true});
                    }
                  }

                  // increases the total count of messages sent by the user by one
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chat.chatId)
                      .update({'totalCount': chat.totalCount + 1});

                  // update the count of labels according to analysis output of latest message
                  if (result.valueSentiment == 0) {
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chat.chatId)
                        .update({'ptsdCount': chat.ptsdCount + 1});
                  } else if (result.valueSentiment == 1) {
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chat.chatId)
                        .update({'unpredCount': chat.unpredCount + 1});
                  } else if (result.valueSentiment == 2) {
                    await FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chat.chatId)
                        .update({'noCount': chat.noCount + 1});
                  }

                  // await FirebaseFirestore.instance
                  //     .collection('users')
                  //     .doc(
                  //       ref.read(firebaseAuthProvider).currentUser!.uid,
                  //     )
                  //     .update({'hasTextedBot': true});
                }
              },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
