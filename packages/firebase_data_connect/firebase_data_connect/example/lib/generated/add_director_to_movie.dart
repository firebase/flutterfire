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

class AddDirectorToMovieDirectedByInsert {
  String directedbyId;
  String movieId;
  AddDirectorToMovieDirectedByInsert.fromJson(dynamic json)
      : directedbyId = nativeFromJson<String>(json['directedbyId']),
        movieId = nativeFromJson<String>(json['movieId']);

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

class AddDirectorToMovieData {
  AddDirectorToMovieDirectedByInsert directedBy_insert;
  AddDirectorToMovieData.fromJson(dynamic json)
      : directedBy_insert = AddDirectorToMovieDirectedByInsert.fromJson(
            json['directedBy_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['directedBy_insert'] = directedBy_insert.toJson();
    return json;
  }

  AddDirectorToMovieData({
    required this.directedBy_insert,
  });
}

class AddDirectorToMovieVariablesPersonId {
  String id;
  AddDirectorToMovieVariablesPersonId.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddDirectorToMovieVariablesPersonId({
    required this.id,
  });
}

class AddDirectorToMovieVariables {
  late Optional<AddDirectorToMovieVariablesPersonId> personId;
  late Optional<String> movieId;
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
