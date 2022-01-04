import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutterfire_ui_example/stories/widgets/firestore_list_view.dart';

class FirestoreTableStory extends StoryWidget {
  const FirestoreTableStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreDataTable');

  @override
  Widget build(StoryElement context) {
    return FirestoreDataTable(
      query: usersCollection,
      columnLabels: const {
        'firstName': Text('First name'),
        'lastName': Text('Last name'),
        'prefix': Text('Prefix'),
        'userName': Text('User name'),
        'email': Text('Email'),
        'number': Text('Phone number'),
        'streetName': Text('Street name'),
        'city': Text('City'),
        'zipCode': Text('Zip code'),
        'country': Text('Country'),
      },
    );
  }
}
