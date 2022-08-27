import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pocketmedi/models/user_data.dart';
import 'package:pocketmedi/pages/user_detail_page.dart';
import 'package:pocketmedi/providers.dart';
import 'package:pocketmedi/services/bot.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double ptsdCount = 0;
    double unpredCount = 0;
    double noCount = 0;

    List<String> docIDs = [];
    List<String> ptsdDocIDs = [];
    List<String> unpredDocIDs = [];
    List<String> noDocIDs = [];
    dynamic chatId;

    dynamic role;
    Future getRole() async {
      DocumentReference user = FirebaseFirestore.instance
          .collection('users')
          .doc(ref.read(firebaseAuthProvider).currentUser!.uid);
      dynamic data;

      await user.get().then((doc) => {data = doc.data()});

      role = data["role"];
    }

    bool doneLoading = false; // changes to true when getDocId completes

    Map<String, double> datamap;
    Future getDocId() async {
      chatId = await ref.read(databaseProvider)?.getChatStarted(
              ref.read(firebaseAuthProvider).currentUser!.uid, bot.uid) ??
          false;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference messages = firestore
          .collection('chats')
          .doc(chatId.toString())
          .collection('messages');

      // queries database for messages labeled as PTSD
      await messages
          .where('myUid',
              isEqualTo: ref.read(firebaseAuthProvider).currentUser!.uid)
          .where('valueSentiment', isEqualTo: 0)
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                docIDs.add(element.reference.id);
                ptsdDocIDs.add(element.reference.id);
              }));

      // queries database for messages labeled as Unpredictable
      await messages
          .where('myUid',
              isEqualTo: ref.read(firebaseAuthProvider).currentUser!.uid)
          .where('valueSentiment', isEqualTo: 1)
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                docIDs.add(element.reference.id);
                unpredDocIDs.add(element.reference.id);
              }));

      // queries database for messages labeled as No PTSD
      await messages
          .where('myUid',
              isEqualTo: ref.read(firebaseAuthProvider).currentUser!.uid)
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

      doneLoading = true;
    }

    // dynamic chat;
    // Future getLabelCounts() async {
    //   String chatID;
    //   await FirebaseFirestore.instance
    //       .collection("chats")
    //       .where('myUid',
    //           isEqualTo: ref.read(firebaseAuthProvider).currentUser!.uid)
    //       .where('otherUid')
    //       .get()
    //       .then((snapshot) => snapshot.docs.forEach((element) {
    //             chatID = element.reference.id;
    //           }));
    //   final doc = await FirebaseFirestore.instance
    //       .collection("chats")
    //       .doc(chatId)
    //       .get();
    //   chat = Chat.fromJson(doc.data()!);
    //   doneLoading = true;
    //   log(chat);
    // }

    return FutureBuilder(
        future: getRole(),
        builder: (context, snapshot) {
          return role == null
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : role == 'doctor'
                  ? Scaffold(
                      body: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StreamBuilder<List<UserData>>(
                                stream: ref
                                    .read(databaseProvider)!
                                    .getConcerningUsers(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                          "Something went wrong! ${snapshot.error}"),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final users = snapshot.data ?? [];
                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      final user =
                                          users[index]; // type UserData
                                      final myUser = ref
                                          .read(firebaseAuthProvider)
                                          .currentUser!; // type User
                                      // if the user is the same as the current user, don't show it
                                      if (user.uid == myUser.uid ||
                                          user.uid == bot.uid) {
                                        return Container();
                                      }
                                      return Column(
                                        children: [
                                          ListTile(
                                              title: Text(
                                                user.name,
                                              ),
                                              subtitle: Text('${user.role}'),
                                              trailing: Text(
                                                'Status: ${user.status}',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 226, 86, 86),
                                                ),
                                              ),
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserDetail(
                                                              user: user)),
                                                );
                                              }),
                                          const Divider(
                                            thickness: 4,
                                            color: Color.fromARGB(
                                                255, 226, 86, 86),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              StreamBuilder<List<UserData>>(
                                stream: ref
                                    .read(databaseProvider)!
                                    .getNormalUsers(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                          "Something went wrong! ${snapshot.error}"),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final users = snapshot.data ?? [];
                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      final user =
                                          users[index]; // type UserData
                                      final myUser = ref
                                          .read(firebaseAuthProvider)
                                          .currentUser!; // type User
                                      // if the user is the same as the current user, don't show it
                                      if (user.uid == myUser.uid ||
                                          user.uid == bot.uid) {
                                        return Container();
                                      }
                                      return Column(
                                        children: [
                                          ListTile(
                                              title: Text(user.name),
                                              subtitle: Text('${user.role}'),
                                              trailing: Text(
                                                  'Status: ${user.status}'),
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserDetail(
                                                              user: user)),
                                                );
                                              }),
                                          const Divider(),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ]),
                      ),
                    )
                  : Scaffold(
                      body: Column(children: [
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
                                      blurRadius: 5,
                                      spreadRadius: 5,
                                      color: Colors.black.withOpacity(0.15))
                                ],
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Column(
                                children: [
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
                                            ? 'No data yet. \nStart talking to Mei!'
                                            : ''
                                        : 'Fetching data...',
                                    centerTextStyle: const TextStyle(
                                        fontWeight: FontWeight.normal),
                                    chartValuesOptions:
                                        const ChartValuesOptions(
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
                      ]),
                    );
        });
  }
}
