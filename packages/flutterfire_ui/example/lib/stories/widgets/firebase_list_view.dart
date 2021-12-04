import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/firebase.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

final messagesCollection =
    FirebaseDatabase.instance.reference().child('list-values').child('list');

class FirebaseListViewStory extends StoryWidget {
  const FirebaseListViewStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirebaseListView');

  @override
  Widget build(StoryElement context) {
    return FirebaseListView(
      query: messagesCollection,
      itemBuilder: (context, id, snapshot) {
        return Text('$id: $snapshot');
      },
    );
  }
}
