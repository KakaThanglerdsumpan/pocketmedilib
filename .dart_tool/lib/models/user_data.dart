class UserData {
  String uid;
  String name;
  dynamic hasTextedBot;
  dynamic role;
  dynamic status;
  dynamic hasTextedDoctor;

  UserData({
    required this.name,
    required this.uid,
    this.hasTextedBot = false,
    this.role,
    this.status,
    this.hasTextedDoctor = false,
  });

  UserData.fromMap(Map<dynamic, dynamic> map)
      : name = map['name'] ?? "",
        uid = map['uid'] ?? "",
        hasTextedBot = map['hasTextedBot'] ?? "",
        role = map['role'] ?? "",
        status = map['status'] ?? "",
        hasTextedDoctor = map['hasTextedDoctor'];

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'hasTextedBot': hasTextedBot,
      'role': role,
      'status': status,
      'hasTextedDoctor': hasTextedBot,
    };
  }
}
