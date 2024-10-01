part of movies;

class SeedDataVariablesBuilder {
  FirebaseDataConnect dataConnect;

  SeedDataVariablesBuilder(
    this.dataConnect,
  );
  Deserializer<SeedDataData> dataDeserializer = (String json) =>
      SeedDataData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  MutationRef<SeedDataData, void> build() {
    return dataConnect.mutation(
        "seedData", dataDeserializer, emptySerializer, null);
  }
}

class SeedData {
  String name = "seedData";
  SeedData({required this.dataConnect});
  SeedDataVariablesBuilder ref() {
    return SeedDataVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class SeedDataTheMatrix {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  SeedDataTheMatrix.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  SeedDataTheMatrix({
    required this.id,
  });
}

class SeedDataData {
  SeedDataTheMatrix the_matrix;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  SeedDataData.fromJson(Map<String, dynamic> json)
      : the_matrix = SeedDataTheMatrix.fromJson(json['the_matrix']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['the_matrix'] = the_matrix.toJson();

    return json;
  }

  SeedDataData({
    required this.the_matrix,
  });
}
