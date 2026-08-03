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

@immutable
class ListMoviesByPartialTitleMovies {
  final String id;
  final String title;
  final String genre;
  final double? rating;
  ListMoviesByPartialTitleMovies.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        genre = nativeFromJson<String>(json['genre']),
        rating = json['rating'] == null
            ? null
            : nativeFromJson<double>(json['rating']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListMoviesByPartialTitleMovies otherTyped =
        other as ListMoviesByPartialTitleMovies;
    return id == otherTyped.id &&
        title == otherTyped.title &&
        genre == otherTyped.genre &&
        rating == otherTyped.rating;
  }

  @override
  int get hashCode => Object.hashAll(
      [id.hashCode, title.hashCode, genre.hashCode, rating.hashCode]);

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

@immutable
class ListMoviesByPartialTitleData {
  final List<ListMoviesByPartialTitleMovies> movies;
  ListMoviesByPartialTitleData.fromJson(dynamic json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesByPartialTitleMovies.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListMoviesByPartialTitleData otherTyped =
        other as ListMoviesByPartialTitleData;
    return movies == otherTyped.movies;
  }

  @override
  int get hashCode => movies.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['movies'] = movies.map((e) => e.toJson()).toList();
    return json;
  }

  ListMoviesByPartialTitleData({
    required this.movies,
  });
}

@immutable
class ListMoviesByPartialTitleVariables {
  final String input;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListMoviesByPartialTitleVariables.fromJson(Map<String, dynamic> json)
      : input = nativeFromJson<String>(json['input']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListMoviesByPartialTitleVariables otherTyped =
        other as ListMoviesByPartialTitleVariables;
    return input == otherTyped.input;
  }

  @override
  int get hashCode => input.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['input'] = nativeToJson<String>(input);
    return json;
  }

  ListMoviesByPartialTitleVariables({
    required this.input,
  });
}
