part of movies;

class SeedMovies {
  String name = "seedMovies";
  SeedMovies({required this.dataConnect});

  Deserializer<SeedMoviesResponse> dataDeserializer = (String json) =>
      SeedMoviesResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);

  MutationRef<SeedMoviesResponse, void> ref() {
    return dataConnect.mutation(
        this.name, dataDeserializer, emptySerializer, null);
  }

  FirebaseDataConnect dataConnect;
}

class SeedMoviesTheMatrix {
  late String id;

  SeedMoviesTheMatrix.fromJson(Map<String, dynamic> json) : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  SeedMoviesTheMatrix({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class SeedMoviesJurassicPark {
  late String id;

  SeedMoviesJurassicPark.fromJson(Map<String, dynamic> json)
      : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  SeedMoviesJurassicPark({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class SeedMoviesResponse {
  late SeedMoviesTheMatrix the_matrix;

  late SeedMoviesJurassicPark jurassic_park;

  SeedMoviesResponse.fromJson(Map<String, dynamic> json)
      : the_matrix = SeedMoviesTheMatrix.fromJson(json['the_matrix']),
        jurassic_park =
            SeedMoviesJurassicPark.fromJson(json['jurassic_park']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['the_matrix'] = the_matrix.toJson();

    json['jurassic_park'] = jurassic_park.toJson();

    return json;
  }

  SeedMoviesResponse({
    required this.the_matrix,
    required this.jurassic_park,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
