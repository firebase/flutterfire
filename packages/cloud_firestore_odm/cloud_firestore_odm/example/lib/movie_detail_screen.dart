// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:flutter/material.dart';

import 'movie.dart';
import 'movie_item.dart';

class MovieDetail extends StatelessWidget {
  const MovieDetail({
    Key? key,
    required this.movieID,
  }) : super(key: key);

  final String movieID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie $movieID'),
      ),
      body: Column(
        children: [
          FirestoreBuilder<MovieDocumentSnapshot>(
            ref: moviesRef.doc(movieID),
            builder: (context, asyncSnapshot, _) {
              if (asyncSnapshot.hasError) return const Text('error');
              if (!asyncSnapshot.hasData) return const Text('loading');

              final snapshot = asyncSnapshot.data!;

              return MovieItem(snapshot.data!, snapshot.reference);
            },
          ),
          Expanded(
            child: FirestoreBuilder<CommentQuerySnapshot>(
              ref: moviesRef.doc(movieID).comments,
              builder: (context, asyncSnapshot, _) {
                if (asyncSnapshot.hasError) return const Text('error');
                if (!asyncSnapshot.hasData) return const Text('loading');

                final snapshot = asyncSnapshot.data!;

                if (snapshot.docs.isEmpty) return Container();

                return Column(
                  children: [
                    Text('Comments (${snapshot.docs.length}):'),
                    ListView.builder(
                      itemCount: snapshot.docs.length,
                      itemBuilder: (context, index) {
                        return Text(snapshot.docs[index].data.message);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
