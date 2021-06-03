---
title: Testing
sidebar_label: Testing
---

## Overview

There are several ways to test apps that use Firebase:

- use fakes for unit and widget tests.
- use the actual Firebase service for integration tests. Alternatively, you can use the Firestore emulator.

As explained at https://flutter.dev/docs/testing, unit and widget tests are easier to maintain and run quickly. On the other hand, integration tests, while more thorough, run slower and require more configuration.

## Unit tests using fakes

The Firebase libraries need to run on an actual device or emulator. So if you want to run unit tests, you'll have to use Fakes instead. A Fake is a library that implements the API of a given Firebase library and simulates its behavior. A few Fakes are available:

- https://pub.dev/packages/fake_cloud_firestore
- https://pub.dev/packages/firebase_storage_mocks
- https://pub.dev/packages/firebase_auth_mocks
- https://pub.dev/packages/google_sign_in_mocks

Note: despite the name, these libraries are Fakes, not Mocks.

When initializing your app, instead of passing the actual instance of a Firebase library (e.g. `FirebaseFirestore.instance` if using Firestore), you pass an instance of a fake (e.g. `FakeFirebaseFirestore()`). Then the rest of your application will run as if it were talking to Firebase.

### Testing a Firestore app

Let's take a look at an old version of the Firestore sample app:

```dart
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:79601577497:ios:5f2bcc6ba8cecddd',
      gcmSenderID: '79601577497',
      apiKey: 'AIzaSyArgmRGfB5kiQT6CunAOmKRVKEsxKmy6YI-G72PVU',
      projectID: 'flutter-firestore',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  runApp(MaterialApp(
      title: 'Firestore Example', home: MyHomePage(firestore: firestore)));
}

class MessageList extends StatelessWidget {
  MessageList({this.firestore});

  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('messages').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            final dynamic message = document['message'];
            return ListTile(
              title: Text(
                message != null ? message.toString() : '<No message retrieved>',
              ),
              subtitle: Text('Message ${index + 1} of $messageCount'),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({this.firestore});

  final Firestore firestore;

  CollectionReference get messages => firestore.collection('messages');

  Future<void> _addMessage() async {
    await messages.add(<String, dynamic>{
      'message': 'Hello world!',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
      ),
      body: MessageList(firestore: firestore),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

`main()` instantiates a `MyHomePage` and passes an instance of Firestore to it. The UI is organized like so:

* MyHomePage
  * MessageList
    * ListTile
    * ListTile
    *  ...
  * FloatingActionButton

`MessageList` displays the messages stored in `firestore.collection("messages")`, and each tap to the `ActionButton` adds one "Hello world!" message to that same collection.

There are two things we can test:

1. `MessageList` does render messages.
1. Tapping the `ActionButton` adds a "Hello world!" message to the database, and is also rendered.

In the tests, we pass a `FakeFirebaseFirestore` to `MyHomePage`. Since the fake instance is initially empty, we add some data so that `MessageList` has something to display.

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestore_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const MessagesCollection = 'messages';

void main() {
  testWidgets('shows messages', (WidgetTester tester) async {
    // Populate the fake database.
    final firestore = FakeFirebaseFirestore();
    await firestore.collection(MessagesCollection).add({
      'message': 'Hello world!',
      'created_at': FieldValue.serverTimestamp(),
    });

    // Render the widget.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example', home: MyHomePage(firestore: firestore)));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();
    // // Verify the output.
    expect(find.text('Hello world!'), findsOneWidget);
    expect(find.text('Message 1 of 1'), findsOneWidget);
  });

  testWidgets('adds messages', (WidgetTester tester) async {
    // Instantiate the mock database.
    final firestore = FakeFirebaseFirestore();

    // Render the widget.
    await tester.pumpWidget(MaterialApp(
        title: 'Firestore Example', home: MyHomePage(firestore: firestore)));
    // Verify that there is no data.
    expect(find.text('Hello world!'), findsNothing);

    // Tap the Add button.
    await tester.tap(find.byType(FloatingActionButton));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();

    // Verify the output.
    expect(find.text('Hello world!'), findsOneWidget);
  });
}
```

To run the tests, run `flutter test`:

```
example % flutter test 
00:02 +2: All tests passed!                                                                                                    
example % 
```

## Integration tests using the Firestore Emulator

1. Set up the Firestore Emulator according to [the docs](https://firebase.google.com/docs/rules/emulator-setup).
1. Run the emulator: `firebase emulators:start --only firestore`
1. Set up your integration test to connect to your the emulator ([sample code](https://github.com/FirebaseExtended/flutterfire/blob/f8831a3e2728a471e49c1e60e79efa02827f6909/packages/cloud_firestore/cloud_firestore/example/lib/main.dart#L19)):

```dart
/// Requires that a Firestore emulator is running locally.
/// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
bool USE_FIRESTORE_EMULATOR = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = const Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  runApp(FirestoreExampleApp());
}
```
