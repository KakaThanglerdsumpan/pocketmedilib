class Doctor {
  String uid;
  String name;
  int patientCount;

  Doctor({
    required this.name,
    required this.uid,
    required this.patientCount,
  });

  Doctor.fromMap(Map<dynamic, dynamic> map)
      : name = map['name'] ?? "",
        uid = map['uid'] ?? "",
        patientCount = map['patientCount'] ?? "";

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'patientCount': patientCount,
    };
  }
}
