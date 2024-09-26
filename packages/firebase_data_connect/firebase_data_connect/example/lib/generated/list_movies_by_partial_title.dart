part of movies;

class ListMoviesByPartialTitleVariablesBuilder {
  String input;

  FirebaseDataConnect dataConnect;

  ListMoviesByPartialTitleVariablesBuilder(
    this.dataConnect, {
    required String this.input,
  });
  Deserializer<ListMoviesByPartialTitleData> dataDeserializer = (String json) =>
      ListMoviesByPartialTitleData.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
  Serializer<ListMoviesByPartialTitleVariables> varsSerializer =
      (ListMoviesByPartialTitleVariables vars) => jsonEncode(vars.toJson());
  QueryRef<ListMoviesByPartialTitleData, ListMoviesByPartialTitleVariables>
      build() {
    ListMoviesByPartialTitleVariables vars = ListMoviesByPartialTitleVariables(
      input: input,
    );

    return dataConnect.query(
        "ListMoviesByPartialTitle", dataDeserializer, varsSerializer, vars);
  }
}

class ListMoviesByPartialTitle {
  String name = "ListMoviesByPartialTitle";
  ListMoviesByPartialTitle({required this.dataConnect});
  ListMoviesByPartialTitleVariablesBuilder ref({
    required String input,
  }) {
    return ListMoviesByPartialTitleVariablesBuilder(
      dataConnect,
      input: input,
    );
  }

  FirebaseDataConnect dataConnect;
}

class ListMoviesByPartialTitleMovies {
  String id;

  String title;

  String genre;

  double? rating;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
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
  });
}

class ListMoviesByPartialTitleData {
  List<ListMoviesByPartialTitleMovies> movies;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
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
  });
}

class ListMoviesByPartialTitleVariables {
  String input;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListMoviesByPartialTitleVariables.fromJson(Map<String, dynamic> json)
      : input = nativeFromJson<String>(json['input']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['input'] = nativeToJson<String>(input);

    return json;
  }

  ListMoviesByPartialTitleVariables({
    required this.input,
  });
}
