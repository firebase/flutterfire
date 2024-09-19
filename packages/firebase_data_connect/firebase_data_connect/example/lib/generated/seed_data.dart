part of movies;

class SeedData {
  String name = "seedData";
  SeedData({required this.dataConnect});

  Deserializer<SeedDataData> dataDeserializer = (String json) =>
      SeedDataData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  MutationRef<SeedDataData, void> ref() {
    return dataConnect.mutation(
        this.name, dataDeserializer, emptySerializer, null);
  }

  FirebaseDataConnect dataConnect;
}

class SeedDataMovies1 {
  late String id;

  SeedDataMovies1.fromJson(Map<String, dynamic> json) : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  SeedDataMovies1({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class SeedDataData {
  late SeedDataMovies1 movies1;

  SeedDataData.fromJson(Map<String, dynamic> json)
      : movies1 = SeedDataMovies1.fromJson(json['movies1']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['movies1'] = movies1.toJson();

    return json;
  }

  SeedDataData({
    required this.movies1,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
