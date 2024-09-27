part of movies;

class DeleteMovieVariablesBuilder {
  String id;

  FirebaseDataConnect _dataConnect;

  DeleteMovieVariablesBuilder(
    this._dataConnect, {
    required String this.id,
  });
  Deserializer<DeleteMovieData> dataDeserializer =
      (dynamic json) => DeleteMovieData.fromJson(jsonDecode(json));
  Serializer<DeleteMovieVariables> varsSerializer =
      (DeleteMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<DeleteMovieData, DeleteMovieVariables> build() {
    DeleteMovieVariables vars = DeleteMovieVariables(
      id: id,
    );

    return _dataConnect.mutation(
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

  DeleteMovieMovieDelete.fromJson(dynamic json)
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

  DeleteMovieData.fromJson(dynamic json)
      : movie_delete = DeleteMovieMovieDelete.fromJson(json['movie_delete']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (movie_delete != null) {
      json['movie_delete'] = movie_delete!.toJson();
    }

    return json;
  }

  DeleteMovieData({
    required this.movie_delete,
  });
}

class DeleteMovieVariables {
  String id;

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
