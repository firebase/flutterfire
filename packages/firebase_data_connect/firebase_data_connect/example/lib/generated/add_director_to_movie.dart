part of 'movies.dart';

class AddDirectorToMovieVariablesBuilder {
  Optional<AddDirectorToMovieVariablesPersonId> _personId = Optional.optional(
      AddDirectorToMovieVariablesPersonId.fromJson, defaultSerializer);
  Optional<String> _movieId = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;
  AddDirectorToMovieVariablesBuilder personId(
      AddDirectorToMovieVariablesPersonId? t) {
    _personId.value = t;
    return this;
  }

  AddDirectorToMovieVariablesBuilder movieId(String? t) {
    _movieId.value = t;
    return this;
  }

  AddDirectorToMovieVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<AddDirectorToMovieData> dataDeserializer =
      (dynamic json) => AddDirectorToMovieData.fromJson(jsonDecode(json));
  Serializer<AddDirectorToMovieVariables> varsSerializer =
      (AddDirectorToMovieVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddDirectorToMovieData, AddDirectorToMovieVariables>>
      execute() {
    return ref().execute();
  }

  MutationRef<AddDirectorToMovieData, AddDirectorToMovieVariables> ref() {
    AddDirectorToMovieVariables vars = AddDirectorToMovieVariables(
      personId: _personId,
      movieId: _movieId,
    );
    return _dataConnect.mutation(
        "addDirectorToMovie", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddDirectorToMovieDirectedByInsert {
  final String directedbyId;
  final String movieId;
  AddDirectorToMovieDirectedByInsert.fromJson(dynamic json)
      : directedbyId = nativeFromJson<String>(json['directedbyId']),
        movieId = nativeFromJson<String>(json['movieId']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDirectorToMovieDirectedByInsert otherTyped =
        other as AddDirectorToMovieDirectedByInsert;
    return directedbyId == otherTyped.directedbyId &&
        movieId == otherTyped.movieId;
  }

  @override
  int get hashCode => Object.hashAll([directedbyId.hashCode, movieId.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['directedbyId'] = nativeToJson<String>(directedbyId);
    json['movieId'] = nativeToJson<String>(movieId);
    return json;
  }

  AddDirectorToMovieDirectedByInsert({
    required this.directedbyId,
    required this.movieId,
  });
}

@immutable
class AddDirectorToMovieData {
  final AddDirectorToMovieDirectedByInsert directedBy_insert;
  AddDirectorToMovieData.fromJson(dynamic json)
      : directedBy_insert = AddDirectorToMovieDirectedByInsert.fromJson(
            json['directedBy_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDirectorToMovieData otherTyped = other as AddDirectorToMovieData;
    return directedBy_insert == otherTyped.directedBy_insert;
  }

  @override
  int get hashCode => directedBy_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['directedBy_insert'] = directedBy_insert.toJson();
    return json;
  }

  AddDirectorToMovieData({
    required this.directedBy_insert,
  });
}

@immutable
class AddDirectorToMovieVariablesPersonId {
  final String id;
  AddDirectorToMovieVariablesPersonId.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDirectorToMovieVariablesPersonId otherTyped =
        other as AddDirectorToMovieVariablesPersonId;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddDirectorToMovieVariablesPersonId({
    required this.id,
  });
}

@immutable
class AddDirectorToMovieVariables {
  late final Optional<AddDirectorToMovieVariablesPersonId> personId;
  late final Optional<String> movieId;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddDirectorToMovieVariables.fromJson(Map<String, dynamic> json) {
    personId = Optional.optional(
        AddDirectorToMovieVariablesPersonId.fromJson, defaultSerializer);
    personId.value = json['personId'] == null
        ? null
        : AddDirectorToMovieVariablesPersonId.fromJson(json['personId']);

    movieId = Optional.optional(nativeFromJson, nativeToJson);
    movieId.value = json['movieId'] == null
        ? null
        : nativeFromJson<String>(json['movieId']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDirectorToMovieVariables otherTyped =
        other as AddDirectorToMovieVariables;
    return personId == otherTyped.personId && movieId == otherTyped.movieId;
  }

  @override
  int get hashCode => Object.hashAll([personId.hashCode, movieId.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (personId.state == OptionalState.set) {
      json['personId'] = personId.toJson();
    }
    if (movieId.state == OptionalState.set) {
      json['movieId'] = movieId.toJson();
    }
    return json;
  }

  AddDirectorToMovieVariables({
    required this.personId,
    required this.movieId,
  });
}
