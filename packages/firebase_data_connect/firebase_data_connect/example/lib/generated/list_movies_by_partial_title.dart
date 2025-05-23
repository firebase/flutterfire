part of 'movies.dart';

class ListMoviesByPartialTitleVariablesBuilder {
  String input;

  final FirebaseDataConnect _dataConnect;
  ListMoviesByPartialTitleVariablesBuilder(
    this._dataConnect, {
    required this.input,
  });
  Deserializer<ListMoviesByPartialTitleData> dataDeserializer =
      (dynamic json) => ListMoviesByPartialTitleData.fromJson(jsonDecode(json));
  Serializer<ListMoviesByPartialTitleVariables> varsSerializer =
      (ListMoviesByPartialTitleVariables vars) => jsonEncode(vars.toJson());
  Future<
      QueryResult<ListMoviesByPartialTitleData,
          ListMoviesByPartialTitleVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListMoviesByPartialTitleData, ListMoviesByPartialTitleVariables>
      ref() {
    ListMoviesByPartialTitleVariables vars = ListMoviesByPartialTitleVariables(
      input: input,
    );
    return _dataConnect.query(
        "ListMoviesByPartialTitle", dataDeserializer, varsSerializer, vars);
  }
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
        rating = json['rating'] == null
            ? null
            : nativeFromJson<double>(json['rating']);

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
  ListMoviesByPartialTitleData.fromJson(dynamic json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesByPartialTitleMovies.fromJson(e))
            .toList();

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
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListMoviesByPartialTitleVariables.fromJson(Map<String, dynamic> json)
      : input = nativeFromJson<String>(json['input']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['input'] = nativeToJson<String>(input);
    return json;
  }

  ListMoviesByPartialTitleVariables({
    required this.input,
  });
}
