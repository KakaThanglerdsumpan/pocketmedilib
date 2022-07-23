import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sigv4/sigv4.dart';

class BotService {
  late Map<String, dynamic> result;
  String botName = "Medi";
  String kAccessKeyId = 'AKIAVUTPU5EDAFL4Z7UU';
  String kSecretAccessKey = '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';
  String botAlias = "TestBotAlias";
  String botAWSRegion = "ap-southeast-1";

  Future<Map<String, dynamic>> callBot(String message) async {
    var response;

    String requestUrl = "https://runtime.lex." +
        botAWSRegion +
        ".amazonaws.com/bot/" +
        botName +
        "/alias/" +
        botAlias +
        "/user/1234/text";

    Sigv4Client client = Sigv4Client(
      region: botAWSRegion,
      serviceName: 'lex',
      defaultContentType: 'application/json; charset=utf-8',
      keyId: kAccessKeyId,
      accessKey: kSecretAccessKey,
    );

    final request = client.request(
      requestUrl,
      method: 'POST',
      body: jsonEncode({'inputText': message}),
    );

    response = await http.post(request.url,
        headers: request.headers, body: request.body);
    result = jsonDecode(response.body);
    return result;
  }
}
