part of movies;

class ListMovies {
  String name = "ListMovies";
  ListMovies({required this.dataConnect});

  Deserializer<ListMoviesResponse> dataDeserializer = (String json) =>
      ListMoviesResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListMoviesResponse, void> ref() {
    return dataConnect.query(this.name, dataDeserializer, null, null);
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
