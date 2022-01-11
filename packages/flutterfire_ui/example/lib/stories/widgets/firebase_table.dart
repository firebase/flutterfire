import 'package:flutter/material.dart';
import 'package:flutterfire_ui/database.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';
import 'package:flutterfire_ui_example/stories/widgets/firebase_database_list_view.dart';

class FirebaseDatabaseTableStory extends StoryWidget {
  const FirebaseDatabaseTableStory({Key? key})
      : super(
          key: key,
          category: 'Widgets',
          title: 'FirebaseDatabaseDataTable',
        );

  @override
  Widget build(StoryElement context) {
    return FirebaseDatabaseDataTable(
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
