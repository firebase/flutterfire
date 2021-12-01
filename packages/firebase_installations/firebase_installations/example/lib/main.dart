import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_installations/firebase_installations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.amber),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Installations'),
        ),
        body: const InstallationsCard(),
      ),
    );
  }
}

class InstallationsCard extends StatefulWidget {
  const InstallationsCard({Key? key}) : super(key: key);

  @override
  _InstallationsCardState createState() => _InstallationsCardState();
}

class _InstallationsCardState extends State<InstallationsCard> {
  @override
  void initState() {
    super.initState();
    logResults();

    FirebaseInstallations.instance.idTokenChanges.listen((event) {
      setState(() {
        authToken = event;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Auth token updated!')));
    }).onError((error) {
      log("$error");
    });
  }

  String id = 'None';
  String authToken = 'None';

  Future<void> logResults() async {
    final id = await FirebaseInstallations.instance.getId();

    setState(() {
      this.id = id;
    });
  }

  Future<void> deleteId() async {
    try {
      await FirebaseInstallations.instance.delete();

      setState(() {
        id = 'None';
      });
    } catch (e) {
      log('$e');
    }
  }

  Future<void> getId() async {
    try {
      final _newid = await FirebaseInstallations.instance.getId();

      setState(() {
        id = _newid;
      });
    } catch (e) {
      log('$e');
    }
  }

  Future<void> getAuthToken() async {
    try {
      final token = await FirebaseInstallations.instance.getToken(true);
      setState(() {
        authToken = token;
      });
    } catch (e) {
      log('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text("Installation Id: "),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(id),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text("Auth Token: "),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(authToken),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: getAuthToken,
              child: const Text("Force update token"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteId,
                  child: const Text("Delete ID"),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: getId,
                  child: const Text("Get ID"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
