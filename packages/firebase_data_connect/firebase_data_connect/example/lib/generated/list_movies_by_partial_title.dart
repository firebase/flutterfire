part of movies;

class ListMoviesByPartialTitleVariablesBuilder {
  String input;

  FirebaseDataConnect dataConnect;

  ListMoviesByPartialTitleVariablesBuilder(
    this.dataConnect, {
    required String this.input,
  });
  Deserializer<ListMoviesByPartialTitleData> dataDeserializer =
      (dynamic json) => ListMoviesByPartialTitleData.fromJson(jsonDecode(json));
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

  ListMoviesByPartialTitleMovies.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        genre = nativeFromJson<String>(json['genre']),
        rating = nativeFromJson<double>(json['rating']) {}

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
    required this.rating,
  });
}

class ListMoviesByPartialTitleData {
  List<ListMoviesByPartialTitleMovies> movies;

  ListMoviesByPartialTitleData.fromJson(dynamic json)
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
