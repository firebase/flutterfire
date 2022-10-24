// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/database.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

final usersCollection = FirebaseDatabase.instance.ref('users');

class FirebaseDatabaseListViewStory extends StoryWidget {
  const FirebaseDatabaseListViewStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirebaseDatabaseListView');

  @override
  Widget build(StoryElement context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: FirebaseDatabaseListView(
        query: usersCollection,
        primary: true,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, snapshot) {
          final user = snapshot.value! as Map;

          return Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(user['firstName'][0]),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${user['firstName']} ${user['lastName']}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        user['number'],
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
