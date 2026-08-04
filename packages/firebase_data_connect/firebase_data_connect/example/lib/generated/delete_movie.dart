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

@immutable
class DeleteMovieMovieDelete {
  final String id;
  DeleteMovieMovieDelete.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMovieMovieDelete otherTyped = other as DeleteMovieMovieDelete;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteMovieMovieDelete({
    required this.id,
  });
}

@immutable
class DeleteMovieData {
  final DeleteMovieMovieDelete? movie_delete;
  DeleteMovieData.fromJson(dynamic json)
      : movie_delete = json['movie_delete'] == null
            ? null
            : DeleteMovieMovieDelete.fromJson(json['movie_delete']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMovieData otherTyped = other as DeleteMovieData;
    return movie_delete == otherTyped.movie_delete;
  }

  @override
  int get hashCode => movie_delete.hashCode;

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

@immutable
class DeleteMovieVariables {
  final String id;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteMovieVariables.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteMovieVariables otherTyped = other as DeleteMovieVariables;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  DeleteMovieVariables({
    required this.id,
  });
}
