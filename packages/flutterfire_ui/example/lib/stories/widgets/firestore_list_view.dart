// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

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

final usersCollection =
    FirebaseFirestore.instance.collection('users').withConverter<User>(
          fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        );

class FirestoreListViewStory extends StoryWidget {
  const FirestoreListViewStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreListView');

  @override
  Widget build(StoryElement context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: FirestoreListView<User>(
        query: usersCollection,
        primary: true,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, snapshot) {
          final user = snapshot.data();

          return Column(
            children: [
              Row(
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
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        user.number,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
