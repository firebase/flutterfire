// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

/// Requires that a Firestore emulator is running locally.
/// See https://firebase.google.com/docs/firestore/quickstart#optional_prototype_and_test_with
bool shouldUseFirestoreEmulator = true;

Future<Uint8List> loadBundleSetup(int number) async {
  // endpoint serves a bundle with 3 documents each containing
  // a 'number' property that increments in value 1-3.
  final url =
      Uri.https('api.rnfirebase.io', '/firestore/e2e-tests/bundle-$number');
  final response = await http.get(url);
  String string = response.body;
  return Uint8List.fromList(string.codeUnits);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(FirestoreExampleApp());
}

/// A reference to the list of movies.
/// We are using `withConverter` to ensure that interactions with the collection
/// are type-safe.
final moviesRef = FirebaseFirestore.instance
    .collection('firestore-example-app')
    .withConverter<Movie>(
      fromFirestore: (snapshots, _) => Movie.fromJson(snapshots.data()!),
      toFirestore: (movie, _) => movie.toJson(),
    );

/// The different ways that we can filter/sort movies.
enum MovieQuery {
  year,
  likesAsc,
  likesDesc,
  rated,
  sciFi,
  fantasy,
}

extension on Query<Movie> {
  /// Create a firebase query from a [MovieQuery]
  Query<Movie> queryBy(MovieQuery query) {
    return switch (query) {
      MovieQuery.fantasy => where('genre', arrayContainsAny: ['fantasy']),
      MovieQuery.sciFi => where('genre', arrayContainsAny: ['sci-fi']),
      MovieQuery.likesAsc ||
      MovieQuery.likesDesc =>
        orderBy('likes', descending: query == MovieQuery.likesDesc),
      MovieQuery.year => orderBy('year', descending: true),
      MovieQuery.rated => orderBy('rated', descending: true)
    };
  }
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class FirestoreExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Example App',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: FilmList()),
      ),
    );
  }
}

/// Holds all example app films
class FilmList extends StatefulWidget {
  const FilmList({Key? key}) : super(key: key);

  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  MovieQuery query = MovieQuery.year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Firestore Example: Movies'),

            // This is a example use for 'snapshots in sync'.
            // The view reflects the time of the last Firestore sync; which happens any time a field is updated.
            StreamBuilder(
              stream: FirebaseFirestore.instance.snapshotsInSync(),
              builder: (context, _) {
                return Text(
                  'Latest Snapshot: ${DateTime.now()}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<MovieQuery>(
            onSelected: (value) => setState(() => query = value),
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: MovieQuery.year,
                  child: Text('Sort by Year'),
                ),
                const PopupMenuItem(
                  value: MovieQuery.rated,
                  child: Text('Sort by Rated'),
                ),
                const PopupMenuItem(
                  value: MovieQuery.likesAsc,
                  child: Text('Sort by Likes ascending'),
                ),
                const PopupMenuItem(
                  value: MovieQuery.likesDesc,
                  child: Text('Sort by Likes descending'),
                ),
                const PopupMenuItem(
                  value: MovieQuery.fantasy,
                  child: Text('Filter genre fantasy'),
                ),
                const PopupMenuItem(
                  value: MovieQuery.sciFi,
                  child: Text('Filter genre sci-fi'),
                ),
              ];
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'reset_likes':
                  return _resetLikes();
                case 'aggregate':
                  // Count the number of movies
                  final _count = await FirebaseFirestore.instance
                      .collection('firestore-example-app')
                      .count()
                      .get();

                  print('Count: ${_count.count}');

                  // Average the number of likes
                  final _average = await FirebaseFirestore.instance
                      .collection('firestore-example-app')
                      .aggregate(average('likes'))
                      .get();

                  print('Average: ${_average.getAverage('likes')}');

                  // Sum the number of likes
                  final _sum = await FirebaseFirestore.instance
                      .collection('firestore-example-app')
                      .aggregate(sum('likes'))
                      .get();

                  print('Sum: ${_sum.getSum('likes')}');

                  // In one query
                  final _all = await FirebaseFirestore.instance
                      .collection('firestore-example-app')
                      .aggregate(
                        average('likes'),
                        sum('likes'),
                        count(),
                      )
                      .get();

                  print('Average: ${_all.getAverage('likes')} '
                      'Sum: ${_all.getSum('likes')} '
                      'Count: ${_all.count}');

                  return;
                case 'load_bundle':
                  Uint8List buffer = await loadBundleSetup(2);
                  LoadBundleTask task =
                      FirebaseFirestore.instance.loadBundle(buffer);

                  final list = await task.stream.toList();

                  print(
                    list.map((e) => e.totalDocuments),
                  );
                  print(
                    list.map((e) => e.bytesLoaded),
                  );
                  print(
                    list.map((e) => e.documentsLoaded),
                  );
                  print(
                    list.map((e) => e.totalBytes),
                  );
                  print(
                    list,
                  );

                  LoadBundleTaskSnapshot lastSnapshot = list.removeLast();
                  print(lastSnapshot.taskState);

                  print(
                    list.map((e) => e.taskState),
                  );
                  return;
                case 'vectorValue':
                  const vectorValue = VectorValue([1.0, 2.0, 3.0]);
                  final vectorValueDoc = await FirebaseFirestore.instance
                      .collection('firestore-example-app')
                      .add({'vectorValue': vectorValue});

                  final snapshot = await vectorValueDoc.get();
                  print(snapshot.data());
                  return;
                default:
                  return;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'reset_likes',
                  child: Text('Reset like counts (WriteBatch)'),
                ),
                const PopupMenuItem(
                  value: 'aggregate',
                  child: Text('Get aggregate data'),
                ),
                const PopupMenuItem(
                  value: 'load_bundle',
                  child: Text('Load bundle'),
                ),
                const PopupMenuItem(
                  value: 'vectorValue',
                  child: Text('Test Vector Value'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Movie>>(
        stream: moviesRef.queryBy(query).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return _MovieItem(
                data.docs[index].data(),
                data.docs[index].reference,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _resetLikes() async {
    final movies = await moviesRef.get(
      const GetOptions(
        serverTimestampBehavior: ServerTimestampBehavior.previous,
      ),
    );

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (final movie in movies.docs) {
      batch.update(movie.reference, {'likes': 0});
    }
    await batch.commit();
  }
}

/// A single movie row.
class _MovieItem extends StatelessWidget {
  _MovieItem(this.movie, this.reference);

  final Movie movie;
  final DocumentReference<Movie> reference;

  /// Returns the movie poster.
  Widget get poster {
    return SizedBox(
      width: 100,
      child: Image.network(movie.poster),
    );
  }

  /// Returns movie details.
  Widget get details {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          metadata,
          genres,
          Likes(
            reference: reference,
            currentLikes: movie.likes,
          ),
        ],
      ),
    );
  }

  /// Return the movie title.
  Widget get title {
    return Text(
      '${movie.title} (${movie.year})',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// Returns metadata about the movie.
  Widget get metadata {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Rated: ${movie.rated}'),
          ),
          Text('Runtime: ${movie.runtime}'),
        ],
      ),
    );
  }

  /// Returns a list of genre movie tags.
  List<Widget> get genreItems {
    return [
      for (final genre in movie.genre)
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Chip(
            backgroundColor: Colors.lightBlue,
            label: Text(
              genre,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
    ];
  }

  /// Returns all genres.
  Widget get genres {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        children: genreItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          poster,
          Flexible(child: details),
        ],
      ),
    );
  }
}

/// Displays and manages the movie 'like' count.
class Likes extends StatefulWidget {
  /// Constructs a new [Likes] instance with a given [DocumentReference] and
  /// current like count.
  Likes({
    Key? key,
    required this.reference,
    required this.currentLikes,
  }) : super(key: key);

  /// The reference relating to the counter.
  final DocumentReference<Movie> reference;

  /// The number of current likes (before manipulation).
  final int currentLikes;

  @override
  _LikesState createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  /// A local cache of the current likes, used to immediately render the updated
  /// likes count after an update, even while the request isn't completed yet.
  late int _likes = widget.currentLikes;

  Future<void> _onLike() async {
    final currentLikes = _likes;

    // Increment the 'like' count straight away to show feedback to the user.
    setState(() {
      _likes = currentLikes + 1;
    });

    try {
      // Update the likes using a transaction.
      // We use a transaction because multiple users could update the likes count
      // simultaneously. As such, our likes count may be different from the likes
      // count on the server.
      int newLikes = await FirebaseFirestore.instance
          .runTransaction<int>((transaction) async {
        DocumentSnapshot<Movie> movie =
            await transaction.get<Movie>(widget.reference);

        if (!movie.exists) {
          throw Exception('Document does not exist!');
        }

        int updatedLikes = movie.data()!.likes + 1;
        transaction.update(widget.reference, {'likes': updatedLikes});
        return updatedLikes;
      });

      // Update with the real count once the transaction has completed.
      setState(() => _likes = newLikes);
    } catch (e, s) {
      print(s);
      print('Failed to update likes for document! $e');

      // If the transaction fails, revert back to the old count
      setState(() => _likes = currentLikes);
    }
  }

  @override
  void didUpdateWidget(Likes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The likes on the server changed, so we need to update our local cache to
    // keep things in sync. Otherwise if another user updates the likes,
    // we won't see the update.
    if (widget.currentLikes != oldWidget.currentLikes) {
      _likes = widget.currentLikes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          iconSize: 20,
          onPressed: _onLike,
          icon: const Icon(Icons.favorite),
        ),
        Text('$_likes likes'),
      ],
    );
  }
}

@immutable
class Movie {
  Movie({
    required this.genre,
    required this.likes,
    required this.poster,
    required this.rated,
    required this.runtime,
    required this.title,
    required this.year,
  });

  Movie.fromJson(Map<String, Object?> json)
      : this(
          genre: (json['genre']! as List).cast<String>(),
          likes: json['likes']! as int,
          poster: json['poster']! as String,
          rated: json['rated']! as String,
          runtime: json['runtime']! as String,
          title: json['title']! as String,
          year: json['year']! as int,
        );

  final String poster;
  final int likes;
  final String title;
  final int year;
  final String runtime;
  final String rated;
  final List<String> genre;

  Map<String, Object?> toJson() {
    return {
      'genre': genre,
      'likes': likes,
      'poster': poster,
      'rated': rated,
      'runtime': runtime,
      'title': title,
      'year': year,
    };
  }
}
