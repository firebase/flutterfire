part of movies;

class ListMoviesByPartialTitle {
  String name = "ListMoviesByPartialTitle";
  ListMoviesByPartialTitle({required this.dataConnect});

  Deserializer<ListMoviesByPartialTitleData> dataDeserializer = (String json) =>
      ListMoviesByPartialTitleData.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
  Serializer<ListMoviesByPartialTitleVariables> varsSerializer =
      (ListMoviesByPartialTitleVariables vars) => jsonEncode(vars.toJson());
  QueryRef<ListMoviesByPartialTitleData, ListMoviesByPartialTitleVariables>
      ref({
    required String input,
  }) {
    ListMoviesByPartialTitleVariables vars = ListMoviesByPartialTitleVariables(
      input: input,
    );

    return dataConnect.query(this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class ListMoviesByPartialTitleMovies {
  late String id;

  late String title;

  late String genre;

  late double? rating;

  ListMoviesByPartialTitleMovies.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        genre = json['genre'],
        rating = json['rating'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    json['title'] = title;

    json['genre'] = genre;

    if (rating != null) {
      json['rating'] = rating;
    }

    return json;
  }

  ListMoviesByPartialTitleMovies({
    required this.id,
    required this.title,
    required this.genre,
    this.rating,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListMoviesByPartialTitleData {
  late List<ListMoviesByPartialTitleMovies> movies;

  ListMoviesByPartialTitleData.fromJson(Map<String, dynamic> json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesByPartialTitleMovies.fromJson(e))
            .toList() {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movies'] = movies.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesByPartialTitleData({
    required this.movies,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListMoviesByPartialTitleVariables {
  late String input;

  ListMoviesByPartialTitleVariables.fromJson(Map<String, dynamic> json)
      : input = json['input'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['input'] = input;

    return json;
  }

  ListMoviesByPartialTitleVariables({
    required this.input,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
