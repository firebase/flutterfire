import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class Movie {
  Movie({required this.title, required this.genre});
  Movie.fromJson(Map<String, Object?> json)
      : this(
          title: json['title']! as String,
          genre: (json['genre']! as List).cast<String>(),
        );

  final String title;
  final List<String> genre;

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'genre': genre,
    };
  }
}

final moviesCollection = FirebaseFirestore.instance
    .collection('firestore-example-app')
    .withConverter<Movie>(
      fromFirestore: (snapshot, _) => Movie.fromJson(snapshot.data()!),
      toFirestore: (movie, _) => movie.toJson(),
    );

class FirestoreListViewStory extends StoryWidget {
  const FirestoreListViewStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreListView');

  @override
  Widget build(StoryElement context) {
    return FirestoreListView<Movie>(
      query: moviesCollection.orderBy('title'),
      itemBuilder: (context, snapshot) {
        Movie movie = snapshot.data();
        return Text(movie.title);
      },
    );
  }
}
