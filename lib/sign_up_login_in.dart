import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketmedi/providers.dart';

class SignUpLogIn extends ConsumerWidget {
  const SignUpLogIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final docIDController = TextEditingController();
    final pwdController = TextEditingController();

    return Center(
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // sign in announymsly with firebase
                const Text("Sign in/Sign Up"),
                ElevatedButton(
                  child: const Text("Sign up"),
                  onPressed: () async {
                    await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          "Sign Up as a",
                          textAlign: TextAlign.center,
                        ),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              child: const Text("User"),
                              onPressed: () async {
                                // pop up asking for name
                                await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Sign Up"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          autofocus: true,
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: "Name",
                                          ),
                                        ),
                                        TextField(
                                          autofocus: true,
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                            labelText: "Email",
                                          ),
                                        ),
                                        TextField(
                                          autofocus: true,
                                          controller: pwdController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: "Password",
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        child: const Text("OK"),
                                        onPressed: () async {
                                          if (nameController.text != "" &&
                                              emailController.text != "") {
                                            try {
                                              ref
                                                  .read(nameProvider)
                                                  .setName(nameController.text);
                                              await ref
                                                  .read(firebaseAuthProvider)
                                                  .createUserWithEmailAndPassword(
                                                      email:
                                                          emailController.text,
                                                      password:
                                                          pwdController.text);

                                              await ref
                                                  .read(databaseProvider)
                                                  ?.initializeUser(
                                                    ref
                                                        .read(
                                                            firebaseAuthProvider)
                                                        .currentUser!
                                                        .uid,
                                                    nameController.text,
                                                    'user',
                                                  );
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            } catch (e) {
                                              print(e);
                                              String error = e.toString();
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Error Signing Up'),
                                                  content: Text(
                                                      error.split('] ')[1]),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Dismiss'))
                                                  ],
                                                ),
                                              );
                                            }
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Error Signing Up'),
                                                content: const Text(
                                                    'Name and Email fields cannot be empty.'),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Dismiss'))
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              child: const Text("Doctor"),
                              onPressed: () async {
                                // pop up asking for name
                                await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Sign Up"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          autofocus: true,
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: "Name",
                                          ),
                                        ),
                                        TextField(
                                          autofocus: true,
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                            labelText: "Email",
                                          ),
                                        ),
                                        TextField(
                                          autofocus: true,
                                          controller: docIDController,
                                          decoration: const InputDecoration(
                                            labelText: "Doctor ID",
                                          ),
                                        ),
                                        TextField(
                                          autofocus: true,
                                          controller: pwdController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: "Password",
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        child: const Text("OK"),
                                        onPressed: () async {
                                          if (nameController.text != "" &&
                                              docIDController.text != "" &&
                                              emailController.text != "") {
                                            try {
                                              ref
                                                  .read(nameProvider)
                                                  .setName(nameController.text);
                                              await ref
                                                  .read(firebaseAuthProvider)
                                                  .createUserWithEmailAndPassword(
                                                      email:
                                                          emailController.text,
                                                      password:
                                                          pwdController.text);
                                              await ref
                                                  .read(databaseProvider)
                                                  ?.initializeUser(
                                                    ref
                                                        .read(
                                                            firebaseAuthProvider)
                                                        .currentUser!
                                                        .uid,
                                                    nameController.text,
                                                    'doctor',
                                                  );
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            } catch (e) {
                                              print(e);
                                              String error = e.toString();
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Error Signing Up'),
                                                  content: Text(
                                                      error.split('] ')[1]),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Dismiss'))
                                                  ],
                                                ),
                                              );
                                            }
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Error Signing Up'),
                                                content: const Text(
                                                    'Name, Email, and Doctor ID fields cannot be empty.'),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Dismiss'))
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                //testt
                ElevatedButton(
                  child: const Text("Log In"),
                  onPressed: () async {
                    // pop up asking for name
                    await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Log In"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              autofocus: true,
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                              ),
                            ),
                            TextField(
                              autofocus: true,
                              controller: pwdController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text("OK"),
                            onPressed: () async {
                              if (emailController.text != "") {
                                try {
                                  await ref
                                      .read(firebaseAuthProvider)
                                      .signInWithEmailAndPassword(
                                          email: emailController.text,
                                          password: pwdController.text);
                                  Navigator.pop(context);
                                } catch (e) {
                                  print(e);
                                  String error = e.toString();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error Logging In'),
                                      content: Text(error.split('] ')[1]),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Dismiss'))
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error Logging In'),
                                    content: const Text(
                                        'Email field cannot be empty.'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Dismiss'))
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
