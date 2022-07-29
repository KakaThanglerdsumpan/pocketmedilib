class SumOfLabels {
  final List<double> labelsCount;
  final List<double> labelsLength;

  SumOfLabels({required this.labelsCount, required this.labelsLength});

  // from JSON
  factory SumOfLabels.fromJson(Map<String, dynamic> json) {
    return SumOfLabels(
      labelsCount: json['labelsCount'],
      labelsLength: json['labelsLength'],
    );
  }

  // to JSON
  Map<String, dynamic> toJson() => {
        'labelsCount': labelsCount,
        'labelsLength': labelsLength,
      };
}
