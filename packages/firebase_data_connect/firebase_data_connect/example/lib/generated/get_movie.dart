part of 'movies.dart';

class GetMovieVariablesBuilder {
  GetMovieVariablesKey key;

  final FirebaseDataConnect _dataConnect;
  GetMovieVariablesBuilder(
    this._dataConnect, {
    required this.key,
  });
  Deserializer<GetMovieData> dataDeserializer =
      (dynamic json) => GetMovieData.fromJson(jsonDecode(json));
  Serializer<GetMovieVariables> varsSerializer =
      (GetMovieVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetMovieData, GetMovieVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetMovieData, GetMovieVariables> ref() {
    GetMovieVariables vars = GetMovieVariables(
      key: key,
    );
    return _dataConnect.query(
        "GetMovie", dataDeserializer, varsSerializer, vars);
  }
}

class GetMovieMovie {
  String id;
  String title;
  GetMovieMovie.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    return json;
  }

  GetMovieMovie({
    required this.id,
    required this.title,
  });
}

class GetMovieData {
  GetMovieMovie? movie;
  GetMovieData.fromJson(dynamic json)
      : movie = json['movie'] == null
            ? null
            : GetMovieMovie.fromJson(json['movie']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (movie != null) {
      json['movie'] = movie!.toJson();
    }
    return json;
  }

  GetMovieData({
    this.movie,
  });
}

class GetMovieVariablesKey {
  String id;
  GetMovieVariablesKey.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetMovieVariablesKey({
    required this.id,
  });
}

class GetMovieVariables {
  GetMovieVariablesKey key;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetMovieVariables.fromJson(Map<String, dynamic> json)
      : key = GetMovieVariablesKey.fromJson(json['key']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['key'] = key.toJson();
    return json;
  }

  GetMovieVariables({
    required this.key,
  });
}
