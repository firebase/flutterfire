// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:firebase_ui_firestore_example/firebase_options.dart';
import 'package:flutter/material.dart';

late CollectionReference<User> collection;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final collectionRef = FirebaseFirestore.instance.collection('users');

  collection = collectionRef.withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );

  runApp(const FirebaseUIFirestoreExample());
}

class FirebaseUIFirestoreExample extends StatelessWidget {
  const FirebaseUIFirestoreExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Contacts')),
        body: FirestoreListView<User>(
          query: collection,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, snapshot) {
            final user = snapshot.data();
            return Column(
              children: [
                UserTile(user: user),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  const UserTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          child: Text(user.firstName[0]),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${user.firstName} ${user.lastName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              user.number,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class User {
  User({
    required this.city,
    required this.country,
    required this.streetName,
    required this.zipCode,
    required this.prefix,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.number,
  });
  User.fromJson(Map<String, Object?> json)
      : this(
          city: json['city'].toString(),
          country: json['country'].toString(),
          streetName: json['streetName'].toString(),
          zipCode: json['zipCode'].toString(),
          prefix: json['prefix'].toString(),
          firstName: json['firstName'].toString(),
          lastName: json['lastName'].toString(),
          email: json['email'].toString(),
          userName: json['userName'].toString(),
          number: json['number'].toString(),
        );

  final String city;
  final String country;
  final String streetName;
  final String zipCode;

  final String prefix;
  final String firstName;
  final String lastName;

  final String email;
  final String userName;
  final String number;

  Map<String, Object?> toJson() {
    return {
      'city': city,
      'country': country,
      'streetName': streetName,
      'zipCode': zipCode,
      'prefix': prefix,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userName': userName,
      'number': number,
    };
  }
}
