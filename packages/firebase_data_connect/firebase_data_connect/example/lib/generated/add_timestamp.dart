part of 'movies.dart';

class AddTimestampVariablesBuilder {
  Timestamp timestamp;

  final FirebaseDataConnect _dataConnect;
  AddTimestampVariablesBuilder(
    this._dataConnect, {
    required this.timestamp,
  });
  Deserializer<AddTimestampData> dataDeserializer =
      (dynamic json) => AddTimestampData.fromJson(jsonDecode(json));
  Serializer<AddTimestampVariables> varsSerializer =
      (AddTimestampVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddTimestampData, AddTimestampVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddTimestampData, AddTimestampVariables> ref() {
    AddTimestampVariables vars = AddTimestampVariables(
      timestamp: timestamp,
    );
    return _dataConnect.mutation(
        "addTimestamp", dataDeserializer, varsSerializer, vars);
  }
}

class AddTimestampTimestampHolderInsert {
  String id;
  AddTimestampTimestampHolderInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddTimestampTimestampHolderInsert({
    required this.id,
  });
}

class AddTimestampData {
  AddTimestampTimestampHolderInsert timestampHolder_insert;
  AddTimestampData.fromJson(dynamic json)
      : timestampHolder_insert = AddTimestampTimestampHolderInsert.fromJson(
            json['timestampHolder_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestampHolder_insert'] = timestampHolder_insert.toJson();
    return json;
  }

  AddTimestampData({
    required this.timestampHolder_insert,
  });
}

class AddTimestampVariables {
  Timestamp timestamp;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddTimestampVariables.fromJson(Map<String, dynamic> json)
      : timestamp = Timestamp.fromJson(json['timestamp']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestamp'] = timestamp.toJson();
    return json;
  }

  AddTimestampVariables({
    required this.timestamp,
  });
}
