part of movies;

class DeleteMovie {
  String name = "deleteMovie";
  DeleteMovie({required this.dataConnect});

  Deserializer<DeleteMovieResponse> dataDeserializer = (String json) =>
      DeleteMovieResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<DeleteMovieVariables> varsSerializer =
      (DeleteMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<DeleteMovieResponse, DeleteMovieVariables> ref(
      {required String id, DeleteMovieVariables? deleteMovieVariables}) {
    DeleteMovieVariables vars1 = DeleteMovieVariables(
      id: id,
    );
    DeleteMovieVariables vars = deleteMovieVariables ?? vars1;
    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class DeleteMovieMovieDelete {
  late String id;

  DeleteMovieMovieDelete.fromJson(Map<String, dynamic> json)
      : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  DeleteMovieMovieDelete({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class DeleteMovieResponse {
  late DeleteMovieMovieDelete? movie_delete;

  DeleteMovieResponse.fromJson(Map<String, dynamic> json)
      : movie_delete = DeleteMovieMovieDelete.fromJson(json['movie_delete']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (movie_delete != null) {
      json['movie_delete'] = movie_delete!.toJson();
    }

    return json;
  }

  DeleteMovieResponse({
    DeleteMovieMovieDelete? movie_delete,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class DeleteMovieVariables {
  late String id;

  DeleteMovieVariables.fromJson(Map<String, dynamic> json) : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  DeleteMovieVariables({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
