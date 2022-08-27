import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pocketmedi/models/chat.dart';
import 'package:pocketmedi/models/user_data.dart';
import 'package:pocketmedi/pages/chat_page.dart';
import 'package:pocketmedi/pages/dr_bot_chat.dart';
import 'package:pocketmedi/providers.dart';
import 'package:pocketmedi/services/bot.dart';

class UserDetail extends ConsumerStatefulWidget {
  final UserData user;
  const UserDetail({required this.user, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserDetailState();
}

class _UserDetailState extends ConsumerState<UserDetail>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final myUser = ref.read(firebaseAuthProvider).currentUser!;
    double ptsdCount = 0;
    double unpredCount = 0;
    double noCount = 0;

    List<String> docIDs = [];
    List<String> ptsdDocIDs = [];
    List<String> unpredDocIDs = [];
    List<String> noDocIDs = [];
    dynamic chatId;

    bool doneLoading = false; // changes to true when getDocId completes
    Future<int> getPatientCount() async {
      DocumentReference user =
          FirebaseFirestore.instance.collection('doctors').doc(myUser.uid);
      int patientCount;
      dynamic data;

      await user.get().then((doc) => {data = doc.data()});

      patientCount = data["patientCount"];
      return patientCount;
    }

    Map<String, double> datamap;
    Future getDocId() async {
      chatId = await ref
              .read(databaseProvider)
              ?.getChatStarted(widget.user.uid, bot.uid) ??
          false;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference messages = firestore
          .collection('chats')
          .doc(chatId.toString())
          .collection('messages');

      // queries database for messages labeled as PTSD
      await messages
          .where('myUid', isEqualTo: widget.user.uid)
          .where('valueSentiment', isEqualTo: 0)
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                docIDs.add(element.reference.id);
                ptsdDocIDs.add(element.reference.id);
              }));

      // queries database for messages labeled as Unpredictable
      await messages
          .where('myUid', isEqualTo: widget.user.uid)
          .where('valueSentiment', isEqualTo: 1)
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                docIDs.add(element.reference.id);
                unpredDocIDs.add(element.reference.id);
              }));

      // queries database for messages labeled as No PTSD
      await messages
          .where('myUid', isEqualTo: widget.user.uid)
          .where('valueSentiment', isEqualTo: 2)
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                docIDs.add(element.reference.id);
                noDocIDs.add(element.reference.id);
              }));

      // gets the length of each list holding the IDs of messages to see how many messages are under each label
      ptsdCount = ptsdDocIDs.length.toDouble();
      unpredCount = unpredDocIDs.length.toDouble();
      noCount = noDocIDs.length.toDouble();

      log('PTSD: \t\t$ptsdCount');
      log('UNPREDICTABLE: \t$unpredCount');
      log('NO PTSD: \t\t$noCount');

      doneLoading = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Detail'),
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        UserDetail(user: widget.user),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FutureBuilder(
            future: getDocId(),
            builder: (context, snapshot) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.15),
                      blurRadius: 5.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        "Name: \n${widget.user.name}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.indigo),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ptsdCount / (ptsdCount + noCount + unpredCount) >= 0.65
                          ? 'Status: \nConcerning'
                          : 'Status: \nNormal',
                      style: TextStyle(
                        fontSize: 17,
                        color:
                            ptsdCount / (ptsdCount + noCount + unpredCount) >=
                                    0.65
                                ? Color.fromARGB(255, 226, 86, 86)
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),
        FutureBuilder(
          future: getDocId(),
          builder: (context, snapshot) {
            return Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.15),
                    blurRadius: 5.0,
                    spreadRadius: 5.0,
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    'Labeling of Chat Messages by ML Model',
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 30),
                  PieChart(
                    dataMap: datamap = {
                      'PTSD': ptsdCount,
                      'Unpredictable': unpredCount,
                      'No PTSD': noCount,
                    },
                    centerText: doneLoading
                        ? docIDs.isEmpty
                            ? 'No data yet.'
                            : ''
                        : 'Fetching data...',
                    centerTextStyle:
                        const TextStyle(fontWeight: FontWeight.normal),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                    colorList: const [
                      Color.fromARGB(255, 201, 71, 71),
                      Color.fromARGB(255, 219, 219, 219),
                      Color.fromARGB(255, 96, 118, 241),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () async {
            final chatId = await ref
                    .read(databaseProvider)
                    ?.getChatStarted(widget.user.uid, bot.uid) ??
                false;
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersChat(
                      chat: Chat(
                    myUid: widget.user.uid,
                    myName: widget.user.name,
                    otherUid: bot.uid,
                    otherName: bot.name,
                    chatId: chatId.toString(),
                  )),
                ));
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.15),
                  blurRadius: 5.0,
                  spreadRadius: 5.0,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.user.name.length > 21
                      ? "View ${widget.user.name.substring(0, 21)}...'s chat with Mei"
                      : "View ${widget.user.name}'s chat with Mei",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final chatId = await ref
                    .read(databaseProvider)
                    ?.getChatStarted(myUser.uid, widget.user.uid) ??
                false;

            // start a chat
            if (chatId == "") {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.uid)
                  .update({'hasTextedDoctor': true});

              int patientCount = await getPatientCount();

              await FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(myUser.uid)
                  .update({'patientCount': patientCount + 1});

              await ref
                  .read(databaseProvider)
                  ?.startChat(myUser.uid, widget.user.uid, widget.user.name)
                  .then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                        chat: Chat(
                      myUid: myUser.uid,
                      myName: "",
                      otherUid: widget.user.uid,
                      otherName: widget.user.name,
                      chatId: value,
                    )),
                  ),
                );
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                      chat: Chat(
                    myUid: myUser.uid,
                    myName: "",
                    otherUid: widget.user.uid,
                    otherName: widget.user.name,
                    chatId: chatId.toString(),
                  )),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.15),
                  blurRadius: 5.0,
                  spreadRadius: 5.0,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.user.name.length > 21
                      ? "Text ${widget.user.name.substring(0, 21)}..."
                      : "Text ${widget.user.name}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
