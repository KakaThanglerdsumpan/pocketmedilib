class Analysis {
  String sentence;
  List<dynamic> ptsdValues;
  int valueSentiment;
  String sentiment;

  Analysis({
    required this.sentence,
    required this.ptsdValues,
    required this.valueSentiment,
    required this.sentiment,
  });

  // from JSON
  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      sentence: json['Sentence'],
      ptsdValues: json['PtsdValues'],
      // json['PtsdValues'][0] = PTSD
      // json['PtsdValues'][1] = Unpredictable
      // json['PtsdValues'][2] = No PTSD
      valueSentiment: json['ValueSentiment'],
      sentiment: json['Sentiment'],
    );
  }

  // to JSON
  Map<String, dynamic> toJson() => {
        'Sentence': sentence,
        'PtsdValues': ptsdValues,
        'ValueSentiment': valueSentiment,
        'Sentiment': sentiment,
      };
}
