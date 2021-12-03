import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

final countriesCollection =
    FirebaseFirestore.instance.collection('firestore-example-app');

class FirestoreTableStory extends StoryWidget {
  const FirestoreTableStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreDataTable');

  @override
  Widget build(StoryElement context) {
    return FirestoreDataTable(
      query: countriesCollection,
      columnLabels: const {
        'title': Text('Title'),
        'runtime': Text('Run time'),
        'rated': Text('Rated'),
        'year': Text('Creation date (year)'),
        'poster': Text('Poster URL'),
        'likes': Text('Likes'),
      },
    );
  }
}
