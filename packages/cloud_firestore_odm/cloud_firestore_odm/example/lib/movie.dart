// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  Movie({
    this.genre,
    required this.likes,
    required this.poster,
    required this.rated,
    required this.runtime,
    required this.title,
    required this.year,
    required this.id,
  }) {
    _$assertMovie(this);
  }

  @Id()
  final String id;
  final String poster;
  @Min(0)
  final int likes;
  final String title;
  @Min(0)
  final int year;
  final String runtime;
  final String rated;
  final List<String>? genre;
}

@Collection<Movie>('firestore-example-app')
@Collection<Comment>('firestore-example-app/*/comments', name: 'comments')
final moviesRef = MovieCollectionReference();

@JsonSerializable()
class Comment {
  Comment({
    required this.authorName,
    required this.message,
  });

  final String authorName;
  final String message;
}
