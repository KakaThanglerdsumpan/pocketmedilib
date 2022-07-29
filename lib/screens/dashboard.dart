import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pocketmedi/models/analysis.dart';
import 'package:pocketmedi/models/chat.dart';
import 'package:pocketmedi/providers.dart';
import 'package:pocketmedi/services/bot.dart';
import 'package:pocketmedi/services/dashbaord_service.dart';
import 'package:provider/provider.dart';

import '../models/local.dart';

class Dashboard extends ConsumerWidget {
  Dashboard({Key? key}) : super(key: key);

  final Map<String, double> datamap = {
    'PTSD': sum.labelsCount[0],
    'Unpredictable': sum.labelsCount[1],
    'No PTSD': sum.labelsCount[2],
  };

  @override
  Widget build(BuildContext context, ref) {
    List<String> docIDs = [];
    dynamic chatId;
    Future getDocId() async {
      chatId = await ref.read(databaseProvider)?.getChatStarted(
              ref.read(firebaseAuthProvider).currentUser!.uid, bot.uid) ??
          false;
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId.toString())
          .collection('messages')
          .where('myUid',
              isEqualTo: ref.read(firebaseAuthProvider).currentUser!.uid)
          .get()
          .then((snapshot) => snapshot.docs.forEach((element) {
                log(element.reference.id.toString());
                docIDs.add(element.reference.id);
              }));
    }

    return Scaffold(
      body: Column(children: [
        Container(
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
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Text(
                'Labeling of Chat Messages by ML Model',
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 30),
              PieChart(
                dataMap: datamap,
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: false,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: true,
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
        ),
        Expanded(
          child: FutureBuilder(
            future: getDocId(),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: docIDs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: GetPtsdVal(
                      chatId: chatId,
                      documentId: docIDs[index],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
