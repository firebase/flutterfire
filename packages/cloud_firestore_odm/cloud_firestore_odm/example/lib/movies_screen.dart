// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:flutter/material.dart';

import 'movie.dart';
import 'movie_item.dart';

/// The different ways that we can filter/sort movies.
enum MovieQueryType {
  year,
  likesAsc,
  likesDesc,
  score,
  sciFi,
  family,
}

extension on MovieQuery {
  /// Create a firebase query from a [MovieQuery]
  MovieQuery queryBy(MovieQueryType query) {
    switch (query) {
      case MovieQueryType.family:
        return whereGenre(arrayContainsAny: ['family']);

      case MovieQueryType.sciFi:
        return whereGenre(arrayContainsAny: ['sci-Fi']);

      case MovieQueryType.likesAsc:
      case MovieQueryType.likesDesc:
        return orderByLikes(descending: query == MovieQueryType.likesDesc);

      case MovieQueryType.year:
        return orderByYear(descending: true);

      case MovieQueryType.score:
        return orderByRated(descending: true);
    }
  }
}

/// Holds all example app films
class FilmList extends StatefulWidget {
  const FilmList({Key? key}) : super(key: key);

  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  var _query = MovieQueryType.year;

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
            )
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<MovieQueryType>(
            onSelected: (newQuery) {
              setState(() {
                _query = newQuery;
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: MovieQueryType.year,
                  child: Text('Sort by Year'),
                ),
                const PopupMenuItem(
                  value: MovieQueryType.score,
                  child: Text('Sort by Score'),
                ),
                const PopupMenuItem(
                  value: MovieQueryType.likesAsc,
                  child: Text('Sort by Likes ascending'),
                ),
                const PopupMenuItem(
                  value: MovieQueryType.likesDesc,
                  child: Text('Sort by Likes descending'),
                ),
                const PopupMenuItem(
                  value: MovieQueryType.family,
                  child: Text('Filter genre Family'),
                ),
                const PopupMenuItem(
                  value: MovieQueryType.sciFi,
                  child: Text('Filter genre Sci-Fi'),
                ),
              ];
            },
          ),
          PopupMenuButton<String>(
            onSelected: (_) => _resetLikes(),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'reset_likes',
                  child: Text('Reset like counts (WriteBatch)'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FirestoreBuilder<MovieQuerySnapshot>(
        ref: moviesRef.queryBy(_query),
        builder: (context, snapshot, _) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/movies/${data.docs[index].id}',
                ),
                child: MovieItem(
                  data.docs[index].data,
                  data.docs[index].reference,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _resetLikes() async {
    final movies = await moviesRef.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final movie in movies.docs) {
      batch.update(movie.reference.reference, <String, Object?>{'likes': 0});
    }
    await batch.commit();
  }
}
