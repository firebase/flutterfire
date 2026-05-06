part of 'movies.dart';

class ListMoviesVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListMoviesVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ListMoviesData> dataDeserializer =
      (dynamic json) => ListMoviesData.fromJson(jsonDecode(json));

  Future<QueryResult<ListMoviesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListMoviesData, void> ref() {
    return _dataConnect.query(
        "ListMovies", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMoviesMovies {
  final String id;
  final String title;
  final List<ListMoviesMoviesDirectedBy> directed_by;
  final double? rating;
  ListMoviesMovies.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        title = nativeFromJson<String>(json['title']),
        directed_by = (json['directed_by'] as List<dynamic>)
            .map((e) => ListMoviesMoviesDirectedBy.fromJson(e))
            .toList(),
        rating = json['rating'] == null
            ? null
            : nativeFromJson<double>(json['rating']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListMoviesMovies otherTyped = other as ListMoviesMovies;
    return id == otherTyped.id &&
        title == otherTyped.title &&
        directed_by == otherTyped.directed_by &&
        rating == otherTyped.rating;
  }

  @override
  int get hashCode => Object.hashAll(
      [id.hashCode, title.hashCode, directed_by.hashCode, rating.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['directed_by'] = directed_by.map((e) => e.toJson()).toList();
    if (rating != null) {
      json['rating'] = nativeToJson<double?>(rating);
    }
    return json;
  }

  ListMoviesMovies({
    required this.id,
    required this.title,
    required this.directed_by,
    this.rating,
  });
}

@immutable
class ListMoviesMoviesDirectedBy {
  final String name;
  ListMoviesMoviesDirectedBy.fromJson(dynamic json)
      : name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListMoviesMoviesDirectedBy otherTyped =
        other as ListMoviesMoviesDirectedBy;
    return name == otherTyped.name;
  }

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListMoviesMoviesDirectedBy({
    required this.name,
  });
}

@immutable
class ListMoviesData {
  final List<ListMoviesMovies> movies;
  ListMoviesData.fromJson(dynamic json)
      : movies = (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesMovies.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListMoviesData otherTyped = other as ListMoviesData;
    return movies == otherTyped.movies;
  }

  @override
  int get hashCode => movies.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['movies'] = movies.map((e) => e.toJson()).toList();
    return json;
  }

  ListMoviesData({
    required this.movies,
  });
}
