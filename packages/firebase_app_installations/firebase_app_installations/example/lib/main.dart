// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    init();

    // Listen to changes
    FirebaseInstallations.instance.onIdChange.listen((event) {
      setState(() {
        id = event;
      });

      // Make sure that the Auth Token is updated once the Installation Id is updated
      getAuthToken();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('New Firebase Installations Id generated 🎉'),
        backgroundColor: Colors.green,
      ));
    }).onError((error) {
      log("$error");
    });
  }

  String id = 'None';
  String authToken = 'None';

  init() async {
    await getId();
    await getAuthToken();
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

  Future<void> getAuthToken([forceRefresh = false]) async {
    try {
      final token = await FirebaseInstallations.instance.getToken(forceRefresh);
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  onPressed: () => getAuthToken(true),
                  child: const Text("Force update token"),
                ),
              ),
              const SizedBox(height: 20),
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
        ),
      ),
    );
  }
}
