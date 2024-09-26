part of movies;

class AddTimestampVariablesBuilder {
  Timestamp timestamp;

  FirebaseDataConnect dataConnect;

  AddTimestampVariablesBuilder(
    this.dataConnect, {
    required Timestamp this.timestamp,
  });
  Deserializer<AddTimestampData> dataDeserializer = (String json) =>
      AddTimestampData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddTimestampVariables> varsSerializer =
      (AddTimestampVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddTimestampData, AddTimestampVariables> build() {
    AddTimestampVariables vars = AddTimestampVariables(
      timestamp: timestamp,
    );

    return dataConnect.mutation(
        "addTimestamp", dataDeserializer, varsSerializer, vars);
  }
}

class AddTimestamp {
  String name = "addTimestamp";
  AddTimestamp({required this.dataConnect});
  AddTimestampVariablesBuilder ref({
    required Timestamp timestamp,
  }) {
    return AddTimestampVariablesBuilder(
      dataConnect,
      timestamp: timestamp,
    );
  }

  FirebaseDataConnect dataConnect;
}

class AddTimestampTimestampHolderInsert {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddTimestampTimestampHolderInsert.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

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

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddTimestampData.fromJson(Map<String, dynamic> json)
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

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
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
