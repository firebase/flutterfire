// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;

class ListMovies {
  String name = "ListMovies";
  ListMovies({required this.dataConnect});

  Deserializer<ListMoviesResponse> dataDeserializer = (String json) =>
      ListMoviesResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<ListMoviesVariables> varsSerializer = jsonEncode;
  QueryRef<ListMoviesResponse, ListMoviesVariables> ref(
      {String? title, ListMoviesVariables? listMoviesVariables}) {
    ListMoviesVariables vars1 = ListMoviesVariables(
      title: title,
    );
    ListMoviesVariables vars = listMoviesVariables ?? vars1;
    return dataConnect.query(this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class ListMoviesMovies {
  late String id;

  late String title;

  late List<ListMoviesMoviesDirectedBy> directed_by;

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

  ListMoviesMovies({
    required this.id,
    required this.title,
    required this.directed_by,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListMoviesMoviesDirectedBy {
  late String name;

  ListMoviesMoviesDirectedBy.fromJson(Map<String, dynamic> json)
      : name = json['name'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['name'] = name;

    return json;
  }

  ListMoviesMoviesDirectedBy({
    required this.name,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListMoviesResponse {
  late List<ListMoviesMovies> movies;

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

  ListMoviesResponse({
    required this.movies,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListMoviesVariables {
  late Optional<String> _title = Optional.optional(
      nativeFromJson as Deserializer<String>,
      nativeToJson as Serializer<String>);

  set title(String t) {
    this._title.value = t;
  }

  String get title => this._title.value!;

  ListMoviesVariables.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('title')) {
      _title.value = json['title'];
    }
  }

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (title != null) {
      json['title'] = title;
    }

    return json;
  }

  ListMoviesVariables({
    String? title,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.

    this._title = Optional.optional(nativeFromJson, nativeToJson);
  }
}
