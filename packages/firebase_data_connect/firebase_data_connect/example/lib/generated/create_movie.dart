// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;

class CreateMovie {
  String name = "createMovie";
  CreateMovie({required this.dataConnect});

  Deserializer<CreateMovieResponse> dataDeserializer = (String json) =>
      CreateMovieResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<CreateMovieVariables> varsSerializer = jsonEncode;
  MutationRef<CreateMovieResponse, CreateMovieVariables> ref(
      CreateMovieVariables vars) {
    return dataConnect.mutation(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class CreateMovieMovieInsert {
  String id;

  CreateMovieMovieInsert.fromJson(Map<String, dynamic> json)
      : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  CreateMovieMovieInsert(
    this.id,
  );
}

class CreateMovieResponse {
  CreateMovieMovieInsert movie_insert;

  CreateMovieResponse.fromJson(Map<String, dynamic> json)
      : movie_insert = CreateMovieMovieInsert.fromJson(json['movie_insert']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movie_insert'] = movie_insert.toJson();

    return json;
  }

  CreateMovieResponse(
    this.movie_insert,
  );
}

class CreateMovieVariables {
  String title;

  int releaseYear;

  String genre;

  double? rating;

  String? description;

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

  CreateMovieVariables(
    this.title,
    this.releaseYear,
    this.genre,
    this.rating,
    this.description,
  );
}
