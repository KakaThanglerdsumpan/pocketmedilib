import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import '../services/bot_service.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({Key? key}) : super(key: key);

  @override
  _BotScreenState createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  List<types.Message> messages = [];
  final _user = const types.User(id: '1234556');
  final _bot = const types.User(id: "123");

  BotService _botService = BotService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) async {
    setState(() {
      messages.insert(0, message);
    });
    log("USER: ${message.toJson()["text"]}");
    var data = await _botService.callBot(message.toJson()["text"]);
    log("LEX: ${data['message']}");
    setState(() {
      messages.insert(0, botMessageReply(data['message']));
    });
  }

  types.Message botMessageReply(String message) {
    return types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message,
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage);
  }

  void _loadMessages() async {
    List<types.Message> messagesList = [];
    Future.delayed(Duration(milliseconds: 300), () {
      messagesList.add(types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "Hello. My name is Medi - your bot. How can I help you?",
      ));

      setState(() {
        messages = messagesList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
          //automaticallyImplyLeading: false,
          title: const Text("Medi"),
          backgroundColor: Colors.indigo),
      body: Chat(
        theme: DefaultChatTheme(
          primaryColor: Color.fromARGB(255, 106, 118, 186),
          sentMessageDocumentIconColor: Colors.black,
          inputTextCursorColor: Colors.indigo,
          inputBorderRadius: BorderRadius.circular(40),
          inputTextColor: Colors.black,
          inputMargin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          inputContainerDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: MediaQuery.of(context).viewInsets.bottom == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                offset: Offset.zero,
                color: Colors.black.withOpacity(.15),
                blurRadius: 10.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
        ),
        messages: messages,
        showUserNames: true,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}
