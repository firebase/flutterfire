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

@immutable
class GetMovieMovie {
  final String id;
  final String title;
  GetMovieMovie.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetMovieMovie otherTyped = other as GetMovieMovie;
    return id == otherTyped.id && title == otherTyped.title;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode]);

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

@immutable
class GetMovieData {
  final GetMovieMovie? movie;
  GetMovieData.fromJson(dynamic json)
      : movie = json['movie'] == null
            ? null
            : GetMovieMovie.fromJson(json['movie']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetMovieData otherTyped = other as GetMovieData;
    return movie == otherTyped.movie;
  }

  @override
  int get hashCode => movie.hashCode;

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

@immutable
class GetMovieVariablesKey {
  final String id;
  GetMovieVariablesKey.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetMovieVariablesKey otherTyped = other as GetMovieVariablesKey;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetMovieVariablesKey({
    required this.id,
  });
}

@immutable
class GetMovieVariables {
  final GetMovieVariablesKey key;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetMovieVariables.fromJson(Map<String, dynamic> json)
      : key = GetMovieVariablesKey.fromJson(json['key']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetMovieVariables otherTyped = other as GetMovieVariables;
    return key == otherTyped.key;
  }

  @override
  int get hashCode => key.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['key'] = key.toJson();
    return json;
  }

  GetMovieVariables({
    required this.key,
  });
}
