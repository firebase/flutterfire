import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class Country {
  Country();
  Country.fromJson(Map<String, Object?> json) : this();

  Map<String, Object?> toJson() {
    return {};
  }
}

final countriesCollection =
    FirebaseFirestore.instance.collection('firebasePerfTest');
// .withConverter<Country>(
//   fromFirestore: (snapshot, _) => Country.fromJson(snapshot.data()!),
//   toFirestore: (country, _) => country.toJson(),
// );

class FirestoreListViewStory extends StoryWidget {
  const FirestoreListViewStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreListView');

  @override
  Widget build(StoryElement context) {
    return FirestoreListView<Map>(
      primary: true,
      itemExtent: 200,
      query: countriesCollection,
      itemBuilder: (context, snapshot) {
        return Text(snapshot.data().toString());
      },
    );
  }
}
