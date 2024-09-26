part of movies;

class CreateMovieVariablesBuilder {
  String title;
  int releaseYear;
  String genre;
  double? rating;
  String? description;

  FirebaseDataConnect dataConnect;

  CreateMovieVariablesBuilder(
    this.dataConnect, {
    required String this.title,
    required int this.releaseYear,
    required String this.genre,
    double? this.rating,
    String? this.description,
  });
  Deserializer<CreateMovieData> dataDeserializer = (String json) =>
      CreateMovieData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<CreateMovieVariables> varsSerializer =
      (CreateMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<CreateMovieData, CreateMovieVariables> build() {
    CreateMovieVariables vars = CreateMovieVariables(
      title: title,
      releaseYear: releaseYear,
      genre: genre,
      rating: rating,
      description: description,
    );

    return dataConnect.mutation(
        "createMovie", dataDeserializer, varsSerializer, vars);
  }
}

class CreateMovie {
  String name = "createMovie";
  CreateMovie({required this.dataConnect});
  CreateMovieVariablesBuilder ref({
    required String title,
    required int releaseYear,
    required String genre,
    double? rating,
    String? description,
  }) {
    return CreateMovieVariablesBuilder(
      dataConnect,
      title: title,
      releaseYear: releaseYear,
      genre: genre,
      rating: rating,
      description: description,
    );
  }

  FirebaseDataConnect dataConnect;
}

class CreateMovieMovieInsert {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  CreateMovieMovieInsert.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  CreateMovieMovieInsert({
    required this.id,
  });
}

class CreateMovieData {
  CreateMovieMovieInsert movie_insert;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  CreateMovieData.fromJson(Map<String, dynamic> json)
      : movie_insert = CreateMovieMovieInsert.fromJson(json['movie_insert']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movie_insert'] = movie_insert.toJson();

    return json;
  }

  CreateMovieData({
    required this.movie_insert,
  });
}

class CreateMovieVariables {
  String title;

  int releaseYear;

  String genre;

  double? rating;

  String? description;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  CreateMovieVariables.fromJson(Map<String, dynamic> json)
      : title = nativeFromJson<String>(json['title']),
        releaseYear = nativeFromJson<int>(json['releaseYear']),
        genre = nativeFromJson<String>(json['genre']) {
    rating =
        json['rating'] == null ? null : nativeFromJson<double>(json['rating']);

    description = json['description'] == null
        ? null
        : nativeFromJson<String>(json['description']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['title'] = nativeToJson<String>(title);

    json['releaseYear'] = nativeToJson<int>(releaseYear);

    json['genre'] = nativeToJson<String>(genre);

    if (rating != null) {
      json['rating'] = nativeToJson<double?>(rating);
    }

    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }

    return json;
  }

  CreateMovieVariables({
    required this.title,
    required this.releaseYear,
    required this.genre,
    this.rating,
    this.description,
  });
}
