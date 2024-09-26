part of movies;

class DeleteMovieVariablesBuilder {
  String id;

  FirebaseDataConnect dataConnect;

  DeleteMovieVariablesBuilder(
    this.dataConnect, {
    required String this.id,
  });
  Deserializer<DeleteMovieData> dataDeserializer = (String json) =>
      DeleteMovieData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<DeleteMovieVariables> varsSerializer =
      (DeleteMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<DeleteMovieData, DeleteMovieVariables> build() {
    DeleteMovieVariables vars = DeleteMovieVariables(
      id: id,
    );

    return dataConnect.mutation(
        "deleteMovie", dataDeserializer, varsSerializer, vars);
  }
}

class DeleteMovie {
  String name = "deleteMovie";
  DeleteMovie({required this.dataConnect});
  DeleteMovieVariablesBuilder ref({
    required String id,
  }) {
    return DeleteMovieVariablesBuilder(
      dataConnect,
      id: id,
    );
  }

  FirebaseDataConnect dataConnect;
}

class DeleteMovieMovieDelete {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  DeleteMovieMovieDelete.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  DeleteMovieMovieDelete({
    required this.id,
  });
}

class DeleteMovieData {
  DeleteMovieMovieDelete? movie_delete;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  DeleteMovieData.fromJson(Map<String, dynamic> json) {
    movie_delete = json['movie_delete'] == null
        ? null
        : DeleteMovieMovieDelete.fromJson(json['movie_delete']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (movie_delete != null) {
      json['movie_delete'] = movie_delete!.toJson();
    }

    return json;
  }

  DeleteMovieData({
    this.movie_delete,
  });
}

class DeleteMovieVariables {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  DeleteMovieVariables.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  DeleteMovieVariables({
    required this.id,
  });
}
