part of movies;

class SeedMoviesVariablesBuilder {
  FirebaseDataConnect dataConnect;

  SeedMoviesVariablesBuilder(
    this.dataConnect,
  );
  Deserializer<SeedMoviesData> dataDeserializer = (String json) =>
      SeedMoviesData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  MutationRef<SeedMoviesData, void> build() {
    return dataConnect.mutation(
        "seedMovies", dataDeserializer, emptySerializer, null);
  }
}

class SeedMovies {
  String name = "seedMovies";
  SeedMovies({required this.dataConnect});
  SeedMoviesVariablesBuilder ref() {
    return SeedMoviesVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class SeedMoviesTheMatrix {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  SeedMoviesTheMatrix.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

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

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  SeedMoviesJurassicPark.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

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

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  SeedMoviesData.fromJson(Map<String, dynamic> json)
      : the_matrix = SeedMoviesTheMatrix.fromJson(json['the_matrix']),
        jurassic_park =
            SeedMoviesJurassicPark.fromJson(json['jurassic_park']) {}

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
