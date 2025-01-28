part of movies;

class AddTimestampVariablesBuilder {
  Timestamp timestamp;

  FirebaseDataConnect _dataConnect;

  AddTimestampVariablesBuilder(
    this._dataConnect, {
    required Timestamp this.timestamp,
  });
  Deserializer<AddTimestampData> dataDeserializer =
      (dynamic json) => AddTimestampData.fromJson(jsonDecode(json));
  Serializer<AddTimestampVariables> varsSerializer =
      (AddTimestampVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddTimestampData, AddTimestampVariables>> execute() {
    return this.ref().execute();
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
  Timestamp timestamp;

  AddTimestampTimestampHolderInsert.fromJson(dynamic json)
      : timestamp = Timestamp.fromJson(json['timestamp']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['timestamp'] = timestamp.toJson();

    return json;
  }

  AddTimestampTimestampHolderInsert({
    required this.timestamp,
  });
}

class AddTimestampData {
  AddTimestampTimestampHolderInsert timestampHolder_insert;

  AddTimestampData.fromJson(dynamic json)
      : timestampHolder_insert = AddTimestampTimestampHolderInsert.fromJson(
            json['timestampHolder_insert']) {}

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

  AddTimestampVariables.fromJson(Map<String, dynamic> json)
      : timestamp = Timestamp.fromJson(json['timestamp']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['timestamp'] = timestamp.toJson();

    return json;
  }

  AddTimestampVariables({
    required this.timestamp,
  });
}
