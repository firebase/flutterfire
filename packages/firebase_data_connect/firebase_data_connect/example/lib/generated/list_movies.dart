part of movies;

class ListMoviesVariablesBuilder {
  FirebaseDataConnect _dataConnect;

  ListMoviesVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ListMoviesData> dataDeserializer =
      (dynamic json) => ListMoviesData.fromJson(jsonDecode(json));

  Future<QueryResult<ListMoviesData, void>> execute() {
    return this.ref().execute();
  }

  QueryRef<ListMoviesData, void> ref() {
    return _dataConnect.query(
        "ListMovies", dataDeserializer, emptySerializer, null);
  }
}

class ListMoviesMovies {
  String id;

  String title;

  String genre;

  int? releaseYear;

  List<ListMoviesMoviesDirectedBy> directed_by;

  double? rating;

  ListMoviesMovies.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        genre = nativeFromJson<String>(json['genre']),
        releaseYear = json['releaseYear'] == null
            ? null
            : nativeFromJson<int>(json['releaseYear']),
        directed_by = (json['directed_by'] as List<dynamic>)
            .map((e) => ListMoviesMoviesDirectedBy.fromJson(e))
            .toList(),
        rating = json['rating'] == null
            ? null
            : nativeFromJson<double>(json['rating']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    json['title'] = nativeToJson<String>(title);

    json['genre'] = nativeToJson<String>(genre);

    if (releaseYear != null) {
      json['releaseYear'] = nativeToJson<int?>(releaseYear);
    }

    json['directed_by'] = directed_by.map((e) => e.toJson()).toList();

    if (rating != null) {
      json['rating'] = nativeToJson<double?>(rating);
    }

    return json;
  }

  ListMoviesMovies({
    required this.id,
    required this.title,
    required this.genre,
    this.releaseYear,
    required this.directed_by,
    this.rating,
  });
}

class ListMoviesMoviesDirectedBy {
  String name;

  ListMoviesMoviesDirectedBy.fromJson(dynamic json)
      : name = nativeFromJson<String>(json['name']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['name'] = nativeToJson<String>(name);

    return json;
  }

  ListMoviesMoviesDirectedBy({
    required this.name,
  });
}

class ListMoviesData {
  List<ListMoviesMovies> movies;

  ListMoviesData.fromJson(dynamic json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesMovies.fromJson(e))
            .toList() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movies'] = movies.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesData({
    required this.movies,
  });
}
