// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

enum LanguageType { english, french, spanish, chinese, korean }

enum GenreType {
  @JsonValue('action')
  action,
  @JsonValue('adventure')
  adventure,
  @JsonValue('comedy')
  comedy,
  @JsonValue('crime')
  crime,
  @JsonValue('drame')
  drame,
  @JsonValue('fantasy')
  fantasy,
  @JsonValue('mystery')
  mystery,
  @JsonValue('sciFi')
  sciFi,
  @JsonValue('thriler')
  thriler,
}

enum CertificationType {
  @JsonValue('none')
  none,
  @JsonValue('g')
  g,
  @JsonValue('pg')
  pg,
  @JsonValue('pg13')
  pg13,
  @JsonValue('R')
  R,
  @JsonValue('tvpg')
  tvpg,
  @JsonValue('tvma')
  tvma,
}

enum CastType {
  @JsonValue('background')
  background,
  @JsonValue('cameo')
  cameo,
  @JsonValue('recurring')
  recurring,
  @JsonValue('side')
  side,
  @JsonValue('star')
  star,
  @JsonValue('coStar')
  coStar,
  @JsonValue('guestStar')
  guestStar,
}

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
    required this.language,
    required this.certification,
    required this.cast,
    required this.majorCast,
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
  final List<LanguageType>? language;
  final CertificationType certification;
  final List<Map<CastType, String>> cast;
  final Map<CastType, String> majorCast;
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
