import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/models/analysis.dart';
import 'package:pocketmedi/models/chat.dart';
import 'package:pocketmedi/models/message.dart';
import 'package:pocketmedi/models/message_with_bot.dart';
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
    log("LEX: ${data['message']}");

    await ref.read(databaseProvider)!.sendMessage(
          widget.chat.chatId,
          Message(
            text: data['message'],
            myUid: bot.uid,
            time: DateTime.now().toString(),
          ),
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
        actions: const <Widget>[
          Icon(Icons.video_call),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
          ),
          Icon(Icons.call),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
          ),
          Icon(Icons.more_vert),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SafeArea(
          bottom: false,
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
                                      text: "How are you doing today?",
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
      ),
    );
  }

  Widget myChatBubble(Message message) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin:
          const EdgeInsets.only(left: 50.0, right: 15.0, top: 7.0, bottom: 7.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 216, 222, 255),
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
      margin: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
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
            Icon(
              Icons.insert_emoticon,
              color: Colors.grey[500],
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
                  // call api method
                  Future<http.Response> getSentiment(String text) async {
                    return await http.post(
                      Uri.parse('https://api.pocketmedi.live/'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{'Sentence': text}),
                    );
                  }

                  // sends message to api for analysis
                  http.Response djangoResponses =
                      await getSentiment(_textMessageController.text);
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

                  // stores message along with analysis inside firestore
                  await ref.read(databaseProvider)!.sendMessageWBot(
                        widget.chat.chatId,
                        MessageWBot(
                          text: _textMessageController.text,
                          myUid:
                              ref.read(firebaseAuthProvider).currentUser!.uid,
                          time: DateTime.now().toString(),
                          valueSentiment: result.valueSentiment,
                          sentiment: result.sentiment,
                          ptsdScore: ptsdValues[0],
                          unpredScore: ptsdValues[1],
                          noScore: ptsdValues[2],
                        ),
                      );

                  _addMessage(_textMessageController.text);
                  _textMessageController.clear();
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
