import 'dart:convert';

import 'package:http/http.dart' as http;

class BotService {
  late Map<String, dynamic> result;

  Future<Map<String, dynamic>> callBot(String message) async {
    // call api method
    Future<http.Response> getSentiment(String text) async {
      return await http.post(
        Uri.parse('https://bot.api.pocketmedi.live/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'message': text}),
      );
    }

    // calls api method to send message to api for analysis
    http.Response djangoResponses = await getSentiment(message);
    result = jsonDecode(djangoResponses.body);
    return result;
  }
}
