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
  String id;

  String title;

  String genre;

  double? rating;

  ListMoviesByPartialTitleMovies.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        genre = nativeFromJson<String>(json['genre']) {
    rating =
        json['rating'] == null ? null : nativeFromJson<double>(json['rating']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    json['title'] = nativeToJson<String>(title);

    json['genre'] = nativeToJson<String>(genre);

    if (rating != null) {
      json['rating'] = nativeToJson<double?>(rating);
    }

    return json;
  }

  ListMoviesByPartialTitleMovies({
    required this.id,
    required this.title,
    required this.genre,
    this.rating,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class ListMoviesByPartialTitleData {
  List<ListMoviesByPartialTitleMovies> movies;

  ListMoviesByPartialTitleData.fromJson(Map<String, dynamic> json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesByPartialTitleMovies.fromJson(e))
            .toList() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movies'] = movies.map((e) => e.toJson()).toList();

    return json;
  }

  ListMoviesByPartialTitleData({
    required this.movies,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class ListMoviesByPartialTitleVariables {
  String input;

  ListMoviesByPartialTitleVariables.fromJson(Map<String, dynamic> json)
      : input = nativeFromJson<String>(json['input']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['input'] = nativeToJson<String>(input);

    return json;
  }

  ListMoviesByPartialTitleVariables({
    required this.input,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}
