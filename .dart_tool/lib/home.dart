import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/models/chat.dart';
import 'package:pocketmedi/models/doctor.dart';
import 'package:pocketmedi/pages/chat_page.dart';
import 'package:pocketmedi/screens/dashboard.dart';
import 'package:pocketmedi/providers.dart';
import 'package:pocketmedi/screens/list_chat_screen.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Doctor> doctors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 1, length: 2);
  }

  dynamic role;
  dynamic hasTextedDoctor = true;
  Future getRole() async {
    DocumentReference user = FirebaseFirestore.instance
        .collection('users')
        .doc(ref.read(firebaseAuthProvider).currentUser!.uid);
    dynamic data;

    await user.get().then((doc) => {data = doc.data()});

    hasTextedDoctor = data['hasTextedDoctor'];
    role = data["role"];
  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .snapshots(includeMetadataChanges: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'PocketMedi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const <Widget>[
            Tab(text: "CHATS"),
            Tab(text: "DASHBOARD"),
          ],
        ),
        actions: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // sign out popup
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Sign out?"),
                  actions: [
                    ElevatedButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text("Sign out"),
                      onPressed: () async {
                        await ref
                            .read(firebaseAuthProvider)
                            .signOut()
                            .then((value) => Navigator.pop(context));
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          ListChatScreen(),
          Dashboard(),
        ],
      ),
      floatingActionButton: StreamBuilder<Object>(
          stream: _usersStream,
          builder: (context, snapshot) {
            return FutureBuilder(
                future: getRole(),
                builder: (context, snapshot) {
                  return role == 'doctor'
                      ? Container()
                      : hasTextedDoctor
                          ? Container()
                          : FloatingActionButton(
                              backgroundColor: Colors.black,
                              child: const Icon(
                                Icons.people,
                                color: Colors.white,
                              ),
                              onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Do you want to request a chat with a doctor?'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              hasTextedDoctor = true;
                                              doctors = await ref
                                                  .read(databaseProvider)!
                                                  .requestDoc();
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(
                                                    ref
                                                        .read(
                                                            firebaseAuthProvider)
                                                        .currentUser!
                                                        .uid,
                                                  )
                                                  .update({
                                                'hasTextedDoctor': true
                                              });

                                              await FirebaseFirestore.instance
                                                  .collection('doctors')
                                                  .doc(doctors[0].uid)
                                                  .update({
                                                'patientCount':
                                                    doctors[0].patientCount + 1
                                              });
                                              await ref
                                                  .read(databaseProvider)
                                                  ?.startChat(
                                                      ref
                                                          .read(
                                                              firebaseAuthProvider)
                                                          .currentUser!
                                                          .uid,
                                                      doctors[0].uid,
                                                      doctors[0].name)
                                                  .then((value) {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                            chat: Chat(
                                                      myUid: ref
                                                          .read(
                                                              firebaseAuthProvider)
                                                          .currentUser!
                                                          .uid,
                                                      myName: "",
                                                      otherUid: doctors[0].uid,
                                                      otherName:
                                                          doctors[0].name,
                                                      chatId: value,
                                                    )),
                                                  ),
                                                );
                                              });
                                            },
                                            child: const Text('Yes')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('No'))
                                      ],
                                    ),
                                  ));
                });
          }),
    );
  }
}

class OtherTab extends StatelessWidget {
  final String tabName;
  const OtherTab({required this.tabName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(tabName),
    );
  }
}
