class Message {
  String text;
  String myUid;
  String time;
  dynamic valueSentiment;
  dynamic sentiment;
  dynamic ptsdScore;
  dynamic unpredScore;
  dynamic noScore;

  Message(
      {required this.text,
      required this.myUid,
      required this.time,
      this.valueSentiment,
      this.sentiment,
      this.ptsdScore,
      this.unpredScore,
      this.noScore});

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
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
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
