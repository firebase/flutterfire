part of 'movies.dart';

class DeleteMovieVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteMovieVariablesBuilder(
    this._dataConnect, {
    required this.id,
  });
  Deserializer<DeleteMovieData> dataDeserializer =
      (dynamic json) => DeleteMovieData.fromJson(jsonDecode(json));
  Serializer<DeleteMovieVariables> varsSerializer =
      (DeleteMovieVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteMovieData, DeleteMovieVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteMovieData, DeleteMovieVariables> ref() {
    DeleteMovieVariables vars = DeleteMovieVariables(
      id: id,
    );
    return _dataConnect.mutation(
        "deleteMovie", dataDeserializer, varsSerializer, vars);
  }
}

class DeleteMovieMovieDelete {
  String id;
  DeleteMovieMovieDelete.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

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
      : movie_delete = json['movie_delete'] == null
            ? null
            : DeleteMovieMovieDelete.fromJson(json['movie_delete']);

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
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteMovieVariables.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteMovieVariables({
    required this.id,
  });
}
