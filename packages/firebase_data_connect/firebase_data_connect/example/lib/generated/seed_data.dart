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

@immutable
class SeedDataTheMatrix {
  final String id;
  SeedDataTheMatrix.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataTheMatrix otherTyped = other as SeedDataTheMatrix;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedDataTheMatrix({
    required this.id,
  });
}

@immutable
class SeedDataData {
  final SeedDataTheMatrix the_matrix;
  SeedDataData.fromJson(dynamic json)
      : the_matrix = SeedDataTheMatrix.fromJson(json['the_matrix']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataData otherTyped = other as SeedDataData;
    return the_matrix == otherTyped.the_matrix;
  }

  @override
  int get hashCode => the_matrix.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['the_matrix'] = the_matrix.toJson();
    return json;
  }

  SeedDataData({
    required this.the_matrix,
  });
}
