part of movies;

class AddDateAndTimestampVariablesBuilder {
  DateTime date;
  Timestamp timestamp;

  FirebaseDataConnect dataConnect;

  AddDateAndTimestampVariablesBuilder(
    this.dataConnect, {
    required DateTime this.date,
    required Timestamp this.timestamp,
  });
  Deserializer<AddDateAndTimestampData> dataDeserializer = (String json) =>
      AddDateAndTimestampData.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddDateAndTimestampVariables> varsSerializer =
      (AddDateAndTimestampVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddDateAndTimestampData, AddDateAndTimestampVariables> build() {
    AddDateAndTimestampVariables vars = AddDateAndTimestampVariables(
      date: date,
      timestamp: timestamp,
    );

    return dataConnect.mutation(
        "addDateAndTimestamp", dataDeserializer, varsSerializer, vars);
  }
}

class AddDateAndTimestamp {
  String name = "addDateAndTimestamp";
  AddDateAndTimestamp({required this.dataConnect});
  AddDateAndTimestampVariablesBuilder ref({
    required DateTime date,
    required Timestamp timestamp,
  }) {
    return AddDateAndTimestampVariablesBuilder(
      dataConnect,
      date: date,
      timestamp: timestamp,
    );
  }

  FirebaseDataConnect dataConnect;
}

class AddDateAndTimestampTimestampHolderInsert {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddDateAndTimestampTimestampHolderInsert.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  AddDateAndTimestampTimestampHolderInsert({
    required this.id,
  });
}

class AddDateAndTimestampData {
  AddDateAndTimestampTimestampHolderInsert timestampHolder_insert;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddDateAndTimestampData.fromJson(Map<String, dynamic> json)
      : timestampHolder_insert =
            AddDateAndTimestampTimestampHolderInsert.fromJson(
                json['timestampHolder_insert']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['timestampHolder_insert'] = timestampHolder_insert.toJson();

    return json;
  }

  AddDateAndTimestampData({
    required this.timestampHolder_insert,
  });
}

class AddDateAndTimestampVariables {
  DateTime date;

  Timestamp timestamp;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddDateAndTimestampVariables.fromJson(Map<String, dynamic> json)
      : date = nativeFromJson<DateTime>(json['date']),
        timestamp = Timestamp.fromJson(json['timestamp']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['date'] = nativeToJson<DateTime>(date);

    json['timestamp'] = timestamp.toJson();

    return json;
  }

  AddDateAndTimestampVariables({
    required this.date,
    required this.timestamp,
  });
}
