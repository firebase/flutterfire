import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_installations/firebase_installations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    logResults();

    FirebaseInstallations.instance.idTokenChanges.listen((event) {
      log(event);
    }).onError((error) {
      log("$error");
    });
  }

  String id = '';
  String oldToken = '';

  Future<void> logResults() async {
    final id = await FirebaseInstallations.instance.getId();

    setState(() {
      this.id = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text("Id: $id"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseInstallations.instance.getToken(true);
              },
              child: const Text("Force update token"),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.delete),
            onPressed: () async {
              await FirebaseInstallations.instance.delete();
              final _newid = await FirebaseInstallations.instance.getId();

              setState(() {
                id = _newid;
              });
            }),
      ),
    );
  }
}
