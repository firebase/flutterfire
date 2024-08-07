// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;

class ListMovies {
  String name = "ListMove";
  ListMovies({required this.dataConnect});

  Deserializer<ListMoviesResponse> dataDeserializer = (String json) =>
      ListMoviesResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListMoviesResponse, void> ref() {
    return dataConnect.query(name, dataDeserializer, null, null);
  }

  FirebaseDataConnect dataConnect;
}

class ListMoviesMovies {
  String id;

  String title;

  List<ListMoviesMoviesDirectedBy> directed_by;

  ListMoviesMovies.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        directed_by = (json['directed_by'] as List<dynamic>)
            .map((e) => ListMoviesMoviesDirectedBy.fromJson(e))
            .toList() {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    json['title'] = title;

    json['directed_by'] = directed_by.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesMovies(
    this.id,
    this.title,
    this.directed_by,
  );
}

class ListMoviesMoviesDirectedBy {
  String name;

  ListMoviesMoviesDirectedBy.fromJson(Map<String, dynamic> json)
      : name = json['name'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['name'] = name;

    return json;
  }

  ListMoviesMoviesDirectedBy(
    this.name,
  );
}

class ListMoviesResponse {
  List<ListMoviesMovies> movies;

  ListMoviesResponse.fromJson(Map<String, dynamic> json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesMovies.fromJson(e))
            .toList() {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movies'] = movies.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesResponse(
    this.movies,
  );
}
