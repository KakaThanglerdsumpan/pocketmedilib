import 'dart:convert';
import 'dart:developer';

import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sigv4/sigv4.dart';

class BotService {
  late Map<String, dynamic> result;
  String botName = "OrderFlowers";
  String kAccessKeyId = 'AKIATH7PC3THRQL2HCAU';
  String kSecretAccessKey = '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';
  String botAlias = "OrderFlowerPocketMedi";
  String botAWSRegion = "ap-southeast-1";

  /*
  String botName = "PTSDDoctorVisit";
  String kAccessKeyId = 'AKIATH7PC3THRQL2HCAU';
  String kSecretAccessKey = '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';
  String botAlias = "TestBotAlias";
  String botAWSRegion = "us-west-2";
  */
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
    // Django ML API URL:
    // https://api.pocketmedi.live/api - POST
    /*
    {
	    "Sentence": message_here
    }

    outputs:
    {
	    "PtsdValues": [
	    	[
		    	0.9680765867233276,
		    	0.027727315202355385,
		    	0.004196105059236288
		    ]
	    ],
	    "ValueSentiment": 0,
	    "Sentiment": "PTSD"
    }
    */

    Future<http.Response> getSentiment(String text) async {
      return await http.post(
        Uri.parse('https://api.pocketmedi.live/api'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'Sentence': text}),
      );
    }

    http.Response responses = await getSentiment(message);
    log(responses.body);

    response = await http.post(request.url,
        headers: request.headers, body: request.body);
    result = jsonDecode(response.body);
    return result;
  }
}
