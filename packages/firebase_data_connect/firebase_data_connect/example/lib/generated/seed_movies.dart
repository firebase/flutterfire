part of 'movies.dart';

class SeedMoviesVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  SeedMoviesVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<SeedMoviesData> dataDeserializer =
      (dynamic json) => SeedMoviesData.fromJson(jsonDecode(json));

  Future<OperationResult<SeedMoviesData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedMoviesData, void> ref() {
    return _dataConnect.mutation(
        "seedMovies", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class SeedMoviesTheMatrix {
  final String id;
  SeedMoviesTheMatrix.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedMoviesTheMatrix otherTyped = other as SeedMoviesTheMatrix;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedMoviesTheMatrix({
    required this.id,
  });
}

@immutable
class SeedMoviesJurassicPark {
  final String id;
  SeedMoviesJurassicPark.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedMoviesJurassicPark otherTyped = other as SeedMoviesJurassicPark;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedMoviesJurassicPark({
    required this.id,
  });
}

@immutable
class SeedMoviesData {
  final SeedMoviesTheMatrix the_matrix;
  final SeedMoviesJurassicPark jurassic_park;
  SeedMoviesData.fromJson(dynamic json)
      : the_matrix = SeedMoviesTheMatrix.fromJson(json['the_matrix']),
        jurassic_park = SeedMoviesJurassicPark.fromJson(json['jurassic_park']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedMoviesData otherTyped = other as SeedMoviesData;
    return the_matrix == otherTyped.the_matrix &&
        jurassic_park == otherTyped.jurassic_park;
  }

  @override
  int get hashCode =>
      Object.hashAll([the_matrix.hashCode, jurassic_park.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['the_matrix'] = the_matrix.toJson();
    json['jurassic_park'] = jurassic_park.toJson();
    return json;
  }

  SeedMoviesData({
    required this.the_matrix,
    required this.jurassic_park,
  });
}
