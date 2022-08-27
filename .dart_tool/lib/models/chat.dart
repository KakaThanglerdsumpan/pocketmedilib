class Chat {
  final String myUid;
  final String myName;
  final String otherUid;
  final String otherName;
  final String chatId;
  dynamic totalCount = 0;
  dynamic ptsdCount = 0;
  dynamic unpredCount = 0;
  dynamic noCount = 0;

  Chat({
    required this.chatId,
    required this.myUid,
    required this.otherUid,
    required this.myName,
    required this.otherName,
    this.totalCount,
    this.ptsdCount,
    this.unpredCount,
    this.noCount,
  });

  // from JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'],
      myUid: json['myUid'],
      myName: json['myName'],
      otherUid: json['otherUid'],
      otherName: json['otherName'],
      totalCount: json['totalCount'],
      ptsdCount: json['ptsdCount'],
      unpredCount: json['unpredCount'],
      noCount: json['noCount'],
    );
  }
  // to JSON
  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'myUid': myUid,
        'otherUid': otherUid,
        'myName': myName,
        'otherName': otherName,
        'totalCount': totalCount,
        'ptsdCount': ptsdCount,
        'unpredCount': unpredCount,
        'noCount': noCount,
      };
}
