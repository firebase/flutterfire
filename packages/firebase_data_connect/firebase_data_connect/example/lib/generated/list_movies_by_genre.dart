part of movies;

class ListMoviesByGenreVariablesBuilder {
  Optional<String> _genre = Optional.optional(nativeFromJson, nativeToJson);

  FirebaseDataConnect _dataConnect;
  ListMoviesByGenreVariablesBuilder genre(String t) {
    this._genre.value = t;
    return this;
  }

  ListMoviesByGenreVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ListMoviesByGenreData> dataDeserializer =
      (dynamic json) => ListMoviesByGenreData.fromJson(jsonDecode(json));
  Serializer<ListMoviesByGenreVariables> varsSerializer =
      (ListMoviesByGenreVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListMoviesByGenreData, ListMoviesByGenreVariables>>
      execute() {
    return this.ref().execute();
  }

  QueryRef<ListMoviesByGenreData, ListMoviesByGenreVariables> ref() {
    ListMoviesByGenreVariables vars = ListMoviesByGenreVariables(
      genre: _genre,
    );

    return _dataConnect.query(
        "ListMoviesByGenre", dataDeserializer, varsSerializer, vars);
  }
}

class ListMoviesByGenreMostPopular {
  String id;

  String title;

  double? rating;

  ListMoviesByGenreMostPopular.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        rating = json['rating'] == null
            ? null
            : nativeFromJson<double>(json['rating']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    json['title'] = nativeToJson<String>(title);

    if (rating != null) {
      json['rating'] = nativeToJson<double?>(rating);
    }

    return json;
  }

  ListMoviesByGenreMostPopular({
    required this.id,
    required this.title,
    this.rating,
  });
}

class ListMoviesByGenreMostRecent {
  String id;

  String title;

  double? rating;

  ListMoviesByGenreMostRecent.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        rating = json['rating'] == null
            ? null
            : nativeFromJson<double>(json['rating']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    json['title'] = nativeToJson<String>(title);

    if (rating != null) {
      json['rating'] = nativeToJson<double?>(rating);
    }

    return json;
  }

  ListMoviesByGenreMostRecent({
    required this.id,
    required this.title,
    this.rating,
  });
}

class ListMoviesByGenreData {
  List<ListMoviesByGenreMostPopular> mostPopular;

  List<ListMoviesByGenreMostRecent> mostRecent;

  ListMoviesByGenreData.fromJson(dynamic json)
      : mostPopular = (json['mostPopular'] as List<dynamic>)
            .map((e) => ListMoviesByGenreMostPopular.fromJson(e))
            .toList(),
        mostRecent = (json['mostRecent'] as List<dynamic>)
            .map((e) => ListMoviesByGenreMostRecent.fromJson(e))
            .toList() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['mostPopular'] = mostPopular.map((e) => e.toJson()).toList();

    json['mostRecent'] = mostRecent.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesByGenreData({
    required this.mostPopular,
    required this.mostRecent,
  });
}

class ListMoviesByGenreVariables {
  late Optional<String> genre;

  ListMoviesByGenreVariables.fromJson(Map<String, dynamic> json) {
    genre = Optional.optional(nativeFromJson, nativeToJson);
    genre.value =
        json['genre'] == null ? null : nativeFromJson<String>(json['genre']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (genre.state == OptionalState.set) {
      json['genre'] = genre.toJson();
    }

    return json;
  }

  ListMoviesByGenreVariables({
    required this.genre,
  });
}
