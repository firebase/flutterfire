part of movies;

class AddDirectorToMovie {
  String name = "addDirectorToMovie";
  AddDirectorToMovie({required this.dataConnect});

  Deserializer<AddDirectorToMovieData> dataDeserializer = (String json) =>
      AddDirectorToMovieData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddDirectorToMovieVariables> varsSerializer =
      (AddDirectorToMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddDirectorToMovieData, AddDirectorToMovieVariables> ref({
    AddDirectorToMovieVariablesPersonId? personId,
    String? movieId,
  }) {
    AddDirectorToMovieVariables vars = AddDirectorToMovieVariables(
      personId: personId,
      movieId: movieId,
    );

    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class AddDirectorToMovieDirectedByInsert {
  String directedbyId;

  String movieId;

  AddDirectorToMovieDirectedByInsert.fromJson(Map<String, dynamic> json)
      : directedbyId = nativeFromJson<String>(json['directedbyId']),
        movieId = nativeFromJson<String>(json['movieId']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['directedbyId'] = nativeToJson<String>(directedbyId);

    json['movieId'] = nativeToJson<String>(movieId);

    return json;
  }

  AddDirectorToMovieDirectedByInsert({
    required this.directedbyId,
    required this.movieId,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class AddDirectorToMovieData {
  AddDirectorToMovieDirectedByInsert directedBy_insert;

  AddDirectorToMovieData.fromJson(Map<String, dynamic> json)
      : directedBy_insert = AddDirectorToMovieDirectedByInsert.fromJson(
            json['directedBy_insert']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['directedBy_insert'] = directedBy_insert.toJson();

    return json;
  }

  AddDirectorToMovieData({
    required this.directedBy_insert,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class AddDirectorToMovieVariablesPersonId {
  String id;

  AddDirectorToMovieVariablesPersonId.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  AddDirectorToMovieVariablesPersonId({
    required this.id,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class AddDirectorToMovieVariables {
  AddDirectorToMovieVariablesPersonId? personId;

  String? movieId;

  AddDirectorToMovieVariables.fromJson(Map<String, dynamic> json) {
    personId = json['personId'] == null
        ? null
        : AddDirectorToMovieVariablesPersonId.fromJson(json['personId']);

    movieId = json['movieId'] == null
        ? null
        : nativeFromJson<String>(json['movieId']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (personId != null) {
      json['personId'] = personId!.toJson();
    }

    if (movieId != null) {
      json['movieId'] = nativeToJson<String?>(movieId);
    }

    return json;
  }

  AddDirectorToMovieVariables({
    this.personId,
    this.movieId,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}
