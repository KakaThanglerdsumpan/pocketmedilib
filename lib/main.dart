import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/auth/auth_widget.dart';
import 'package:pocketmedi/home.dart';
import 'package:pocketmedi/sign_up_login_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ref) {
    return MaterialApp(
      title: 'PocketMedi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 8, 1, 33)),
      ),
      home: AuthWidget(
        signedInBuilder: (context) => const Home(),
        nonSignedInBuilder: (context) => const SignUpLogIn(),
      ),
    );
  }
}
