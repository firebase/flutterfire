// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';

@JsonSerializable(explicitToJson: true)
class Fruits {
  /// The generated code assumes these values exist in JSON.
  final Fruit apple;

  Fruits({
    required this.apple,
  });

  factory Fruits.fromJson(Map<String, dynamic> json) => _$FruitsFromJson(json);

  Map<String, dynamic> toJson() => _$FruitsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Fruit {
  final String color;
  final String size;

  Fruit({
    required this.color,
    required this.size,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) => _$FruitFromJson(json);

  Map<String, dynamic> toJson() => _$FruitToJson(this);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You should have the Functions Emulator running locally to use it
  // https://firebase.google.com/docs/functions/local-emulator
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List fruit = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Functions Example'),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: fruit.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${fruit[index]}'),
              );
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () async {
              // See index.js in .github/workflows/scripts for the example function we
              // are using for this example
              HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
                'nestedFruit',
                options: HttpsCallableOptions(
                  timeout: const Duration(seconds: 5),
                ),
              );

              try {
                final result = await callable();
                print(result.data);
                final data = Fruits.fromJson(result.data['fruits']);
                print(data.toJson());
                setState(() {
                  fruit.clear();
                  result.data.forEach((f) {
                    fruit.add(f);
                  });
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ERROR: $e'),
                  ),
                );
              }
            },
            label: const Text('Call Function'),
            icon: const Icon(Icons.cloud),
            backgroundColor: Colors.deepOrange,
          ),
        ),
      ),
    );
  }
}
