import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketmedi/models/doctor.dart';
import 'package:pocketmedi/models/message.dart';

import 'package:pocketmedi/services/bot.dart';

import '../models/chat.dart';
import '../models/user_data.dart';

class FirestoreService {
  FirestoreService({required this.uid});
  final String uid;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Save the user in a user collection
  Future<void> addUser(
    UserData user,
  ) async {
    await firestore.collection("users").doc(user.uid).set(user.toMap());
  }

  Future<UserData?> getUser(String uid) async {
    final doc = await firestore.collection("users").doc(uid).get();
    return doc.exists ? UserData.fromMap(doc.data()!) : null;
  }

  // get all users
  Stream<List<UserData>> getUsers() {
    return firestore
        .collection("users")
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              final u = UserData.fromMap(d);
              return u;
            }).toList());
  }

  Stream<List<UserData>> getConcerningUsers() {
    return firestore
        .collection("users")
        .where('role', isEqualTo: 'user')
        .where('status', isEqualTo: 'concerning')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              final u = UserData.fromMap(d);
              return u;
            }).toList());
  }

  Stream<List<UserData>> getNormalUsers() {
    return firestore
        .collection("users")
        .where('role', isEqualTo: 'user')
        .where('status', isEqualTo: 'normal')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              final u = UserData.fromMap(d);
              return u;
            }).toList());
  }

  Stream<List<UserData>> getDoctors() {
    return firestore
        .collection("users")
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              final u = UserData.fromMap(d);
              return u;
            }).toList());
  }

  Future<bool> checkIfTextedBot(String uid) async {
    DocumentReference user =
        FirebaseFirestore.instance.collection('users').doc(uid);
    bool hasTextedbot;
    dynamic data;

    await user.get().then((doc) => {data = doc.data()});

    hasTextedbot = data["hasTextedBot"];
    return hasTextedbot;
  }

  // start a chat with 2 users
  Future<String> startChat(
      String uid1, String otherUid, String otherName) async {
    final myUser = await getUser(uid1);
    final docId = firestore.collection("chats").doc().id;
    await firestore.collection("chats").doc(docId).set(Chat(
          chatId: docId,
          myUid: uid1,
          otherUid: otherUid,
          myName: myUser?.name ?? "",
          otherName: otherName,
        ).toJson());
    return docId;
  }

  // initalizes user with UserData on firestore upon sign up
  Future<void> initializeUser(
    String uid,
    String name,
    String role,
  ) async {
    role == 'user'
        ? await firestore.collection('users').doc(uid).set(UserData(
                name: name,
                uid: uid,
                role: role,
                status: 'normal',
                hasTextedDoctor: false)
            .toMap())
        : await firestore
            .collection('users')
            .doc(uid)
            .set(UserData(name: name, uid: uid, role: role).toMap());
    final myUser = await getUser(uid);
    final docId = firestore.collection("chats").doc().id;
    if (role == 'user') {
      await firestore.collection("chats").doc(docId).set(Chat(
              chatId: docId,
              myUid: uid,
              otherUid: bot.uid,
              myName: myUser?.name ?? "",
              otherName: bot.name,
              totalCount: 0,
              ptsdCount: 0,
              unpredCount: 0,
              noCount: 0)
          .toJson());
    } else if (role == 'doctor') {
      await firestore
          .collection("doctors")
          .doc(uid)
          .set({'uid': uid, 'name': name, 'patientCount': 0});
    }
    log('initialized');
  }

  // query the chat collection to get all the chats of that the user with uid is part of
  Stream<List<Chat?>> getChats() {
    return firestore
        .collection("chats")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              final c = Chat.fromJson(d);
              if (c.myUid == uid || c.otherUid == uid) {
                return c;
              }
              return null;
            }).toList());
  }

  // stores a chat message inside firebase
  Future<DocumentReference> sendMessage(String chatId, Message message) async {
    DocumentReference doc = await firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add(message.toJson());
    return doc;
  }

  // read the msgs of a chat
  Stream<List<Message>> getMessages(String chatId) {
    final a = firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              final u = Message.fromJson(d);
              return u;
            }).toList());
    return a;
  }

  Future<List<Doctor>> requestDoc() async {
    List<Doctor> doctors = [];
    await firestore
        .collection("doctors")
        .orderBy('patientCount')
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doctors.add(Doctor(
            name: doc['name'],
            uid: doc['uid'],
            patientCount: doc['patientCount']));
      });
    });
    return doctors;
  }

  // check if there is already a chat started
  Future<String> getChatStarted(String uid1, String uid2) async {
    final doc1 = await firestore
        .collection("chats")
        .where('myUid', isEqualTo: uid1)
        .where('otherUid', isEqualTo: uid2)
        .get();
    if (doc1.docs.isNotEmpty) {
      return doc1.docs[0].id;
    }
    final doc2 = await firestore
        .collection("chats")
        .where('otherUid', isEqualTo: uid1)
        .where('myUid', isEqualTo: uid2)
        .get();
    if (doc2.docs.isNotEmpty) {
      return doc2.docs[0].id;
    }
    return "";
  }
}
