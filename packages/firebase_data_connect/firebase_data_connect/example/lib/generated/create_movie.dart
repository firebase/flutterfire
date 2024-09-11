// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;

class CreateMovie {
  String name = "createMovie";
  CreateMovie({required this.dataConnect});

  Deserializer<CreateMovieResponse> dataDeserializer = (String json) =>
      CreateMovieResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<CreateMovieVariables> varsSerializer =
      (CreateMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<CreateMovieResponse, CreateMovieVariables> ref(
      {required String title,
      required int releaseYear,
      required String genre,
      double? rating,
      String? description,
      CreateMovieVariables? createMovieVariables}) {
    CreateMovieVariables vars1 = CreateMovieVariables(
      title: title,
      releaseYear: releaseYear,
      genre: genre,
      rating: rating,
      description: description,
    );
    CreateMovieVariables vars = createMovieVariables ?? vars1;
    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class CreateMovieMovieInsert {
  late String id;

  CreateMovieMovieInsert.fromJson(Map<String, dynamic> json)
      : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  CreateMovieMovieInsert({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class CreateMovieResponse {
  late CreateMovieMovieInsert movie_insert;

  CreateMovieResponse.fromJson(Map<String, dynamic> json)
      : movie_insert = CreateMovieMovieInsert.fromJson(json['movie_insert']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movie_insert'] = movie_insert.toJson();

    return json;
  }

  CreateMovieResponse({
    required this.movie_insert,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class CreateMovieVariables {
  late String title;

  late int releaseYear;

  late String genre;

  late double? rating;

  late String? description;

  CreateMovieVariables.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        releaseYear = json['releaseYear'],
        genre = json['genre'],
        rating = json['rating'],
        description = json['description'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['title'] = title;

    json['releaseYear'] = releaseYear;

    json['genre'] = genre;

    if (rating != null) {
      json['rating'] = rating;
    }

    if (description != null) {
      json['description'] = description;
    }

    return json;
  }

  CreateMovieVariables({
    required this.title,
    required this.releaseYear,
    required this.genre,
    this.rating,
    this.description,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
