import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sigv4/sigv4.dart';

class BotService {
  late Map<String, dynamic> result;
  String botName = "PTSDMediBot";
  String kAccessKeyId = 'AKIATH7PC3THRQL2HCAU';
  String kSecretAccessKey = '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';
  String botAlias = "PocketMediChatBot";
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
