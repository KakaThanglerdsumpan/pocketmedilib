import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/screens/dashboard.dart';
import 'package:pocketmedi/pages/select_person_to_chat_page.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 2);
  }

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
          const Icon(Icons.search),
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
        children: <Widget>[
          const ListChatScreen(),
          Dashboard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SelectPersonToChat()),
        ),
      ),
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
