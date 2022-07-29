class MessageWBot {
  String text;
  String myUid;
  String time;
  int valueSentiment;
  String sentiment;
  double ptsdScore;
  double unpredScore;
  double noScore;

  MessageWBot(
      {required this.text,
      required this.myUid,
      required this.time,
      required this.valueSentiment,
      required this.sentiment,
      required this.ptsdScore,
      required this.unpredScore,
      required this.noScore});

  // to json
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'myUid': myUid,
      'time': time,
      'valueSentiment': valueSentiment,
      'sentiment': sentiment,
      'ptsdScore': ptsdScore,
      'unpredScore': unpredScore,
      'noScore': noScore,
    };
  }

  // from json
  factory MessageWBot.fromJson(Map<String, dynamic> json) {
    return MessageWBot(
      text: json['text'],
      myUid: json['myUid'],
      time: json['time'],
      valueSentiment: json['valueSentiment'],
      sentiment: json['sentiment'],
      ptsdScore: json['ptsdScore'],
      unpredScore: json['unpredScore'],
      noScore: json['noScore'],
    );
  }
}
