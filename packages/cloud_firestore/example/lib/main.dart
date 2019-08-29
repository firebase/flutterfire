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

  CollectionReference get messages => firestore.collection('messages');

  Future<void> _updateMessage(DocumentSnapshot document) async {
    firestore.runTransaction((Transaction tx) async {
      await tx.update(document.reference, <String, dynamic>{
        'message': 'Message updated at' + DateTime.now().toIso8601String(),
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }
  Future<void> _transactionWithMultipleOperations(DocumentSnapshot document) async {
    firestore.runTransaction((Transaction tx) async {
     // these operations make no particular sense.
      // They are here just to test this case in the plugin.
      await tx.update(document.reference, <String, dynamic>{
        'message': 'Message updated at' + DateTime.now().toIso8601String(),
        'created_at': FieldValue.serverTimestamp(),
      });
      await tx.get(document.reference);
      await tx.delete(document.reference);
    });
  }

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
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'UPDATE',
                      child: const Text('Update with local timestamp'),
                    ),
                    PopupMenuItem<String>(
                      value: 'DELETE',
                      child: const Text('Delete'),
                    ),
                    PopupMenuItem<String>(
                      value: 'BATCH',
                      child: const Text('Get, update and delete in a single transaction'),
                    ),
                  ];
                },
                onSelected: (String entry) async {
                  if (entry == 'UPDATE') {
                    await _updateMessage(document);
                  } else if (entry == 'DELETE') {
                    await messages.document(document.documentID).delete();
                  } else if (entry == 'BATCH') {
                    _transactionWithMultipleOperations(document);
                  }
                },
              ),
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
    firestore.runTransaction((Transaction tx) async {
      await tx.set(messages.document(), <String, dynamic>{
        'message': 'Hello world!',
        'created_at': FieldValue.serverTimestamp(),
      });
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
