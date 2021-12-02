import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

final countriesCollection = FirebaseFirestore.instance.collection('firestore');

class FirestoreTableStory extends StoryWidget {
  const FirestoreTableStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreTable');

  @override
  Widget build(StoryElement context) {
    return FirestoreTable(
      query: countriesCollection,
      onError: (err, stack) {},
      columnLabels: const {
        'bool': Text('is developed'),
        'foo': Text('Total population'),
        'geo': Text('Country UID'),
        'name': Text('Independence date'),
        'null': Text('Towns'),
        'ref': Text('ref'),
      },
    );
  }
}
