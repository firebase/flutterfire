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

class SeedMoviesTheMatrix {
  String id;
  SeedMoviesTheMatrix.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedMoviesTheMatrix({
    required this.id,
  });
}

class SeedMoviesJurassicPark {
  String id;
  SeedMoviesJurassicPark.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedMoviesJurassicPark({
    required this.id,
  });
}

class SeedMoviesData {
  SeedMoviesTheMatrix the_matrix;
  SeedMoviesJurassicPark jurassic_park;
  SeedMoviesData.fromJson(dynamic json)
      : the_matrix = SeedMoviesTheMatrix.fromJson(json['the_matrix']),
        jurassic_park = SeedMoviesJurassicPark.fromJson(json['jurassic_park']);

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
