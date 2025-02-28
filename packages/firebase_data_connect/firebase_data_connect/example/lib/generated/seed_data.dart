part of 'movies.dart';

class SeedDataVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  SeedDataVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<SeedDataData> dataDeserializer =
      (dynamic json) => SeedDataData.fromJson(jsonDecode(json));

  Future<OperationResult<SeedDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedDataData, void> ref() {
    return _dataConnect.mutation(
        "seedData", dataDeserializer, emptySerializer, null);
  }
}

class SeedDataTheMatrix {
  String id;
  SeedDataTheMatrix.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

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
  SeedDataData.fromJson(dynamic json)
      : the_matrix = SeedDataTheMatrix.fromJson(json['the_matrix']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['the_matrix'] = the_matrix.toJson();
    return json;
  }

  SeedDataData({
    required this.the_matrix,
  });
}
