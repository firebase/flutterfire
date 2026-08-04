part of 'movies.dart';

class CreateMovieVariablesBuilder {
  String title;
  int releaseYear;
  String genre;
  Optional<double> _rating = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _description =
      Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;
  CreateMovieVariablesBuilder rating(double? t) {
    _rating.value = t;
    return this;
  }

  CreateMovieVariablesBuilder description(String? t) {
    _description.value = t;
    return this;
  }

  CreateMovieVariablesBuilder(
    this._dataConnect, {
    required this.title,
    required this.releaseYear,
    required this.genre,
  });
  Deserializer<CreateMovieData> dataDeserializer =
      (dynamic json) => CreateMovieData.fromJson(jsonDecode(json));
  Serializer<CreateMovieVariables> varsSerializer =
      (CreateMovieVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateMovieData, CreateMovieVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateMovieData, CreateMovieVariables> ref() {
    CreateMovieVariables vars = CreateMovieVariables(
      title: title,
      releaseYear: releaseYear,
      genre: genre,
      rating: _rating,
      description: _description,
    );
    return _dataConnect.mutation(
        "createMovie", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateMovieMovieInsert {
  final String id;
  CreateMovieMovieInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateMovieMovieInsert otherTyped = other as CreateMovieMovieInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateMovieMovieInsert({
    required this.id,
  });
}

@immutable
class CreateMovieData {
  final CreateMovieMovieInsert movie_insert;
  CreateMovieData.fromJson(dynamic json)
      : movie_insert = CreateMovieMovieInsert.fromJson(json['movie_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateMovieData otherTyped = other as CreateMovieData;
    return movie_insert == otherTyped.movie_insert;
  }

  @override
  int get hashCode => movie_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['movie_insert'] = movie_insert.toJson();
    return json;
  }

  CreateMovieData({
    required this.movie_insert,
  });
}

@immutable
class CreateMovieVariables {
  final String title;
  final int releaseYear;
  final String genre;
  late final Optional<double> rating;
  late final Optional<String> description;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateMovieVariables.fromJson(Map<String, dynamic> json)
      : title = nativeFromJson<String>(json['title']),
        releaseYear = nativeFromJson<int>(json['releaseYear']),
        genre = nativeFromJson<String>(json['genre']) {
    rating = Optional.optional(nativeFromJson, nativeToJson);
    rating.value =
        json['rating'] == null ? null : nativeFromJson<double>(json['rating']);

    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null
        ? null
        : nativeFromJson<String>(json['description']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final CreateMovieVariables otherTyped = other as CreateMovieVariables;
    return title == otherTyped.title &&
        releaseYear == otherTyped.releaseYear &&
        genre == otherTyped.genre &&
        rating == otherTyped.rating &&
        description == otherTyped.description;
  }

  @override
  int get hashCode => Object.hashAll([
        title.hashCode,
        releaseYear.hashCode,
        genre.hashCode,
        rating.hashCode,
        description.hashCode
      ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['releaseYear'] = nativeToJson<int>(releaseYear);
    json['genre'] = nativeToJson<String>(genre);
    if (rating.state == OptionalState.set) {
      json['rating'] = rating.toJson();
    }
    if (description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    return json;
  }

  CreateMovieVariables({
    required this.title,
    required this.releaseYear,
    required this.genre,
    required this.rating,
    required this.description,
  });
}
