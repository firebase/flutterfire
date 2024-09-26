part of movies;

class ListMoviesVariablesBuilder {
  FirebaseDataConnect dataConnect;

  ListMoviesVariablesBuilder(
    this.dataConnect,
  );
  Deserializer<ListMoviesData> dataDeserializer = (String json) =>
      ListMoviesData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListMoviesData, void> build() {
    return dataConnect.query(
        "ListMovies", dataDeserializer, emptySerializer, null);
  }
}

class ListMovies {
  String name = "ListMovies";
  ListMovies({required this.dataConnect});
  ListMoviesVariablesBuilder ref() {
    return ListMoviesVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class ListMoviesMovies {
  String id;

  String title;

  List<ListMoviesMoviesDirectedBy> directed_by;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListMoviesMovies.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        directed_by = (json['directed_by'] as List<dynamic>)
            .map((e) => ListMoviesMoviesDirectedBy.fromJson(e))
            .toList() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    json['title'] = nativeToJson<String>(title);

    json['directed_by'] = directed_by.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesMovies({
    required this.id,
    required this.title,
    required this.directed_by,
  });
}

class ListMoviesMoviesDirectedBy {
  String name;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListMoviesMoviesDirectedBy.fromJson(Map<String, dynamic> json)
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

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListMoviesData.fromJson(Map<String, dynamic> json)
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
