part of movies;

class AddDateAndTimestamp {
  String name = "addDateAndTimestamp";
  AddDateAndTimestamp({required this.dataConnect});

  Deserializer<AddDateAndTimestampData> dataDeserializer = (String json) =>
      AddDateAndTimestampData.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddDateAndTimestampVariables> varsSerializer =
      (AddDateAndTimestampVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddDateAndTimestampData, AddDateAndTimestampVariables> ref({
    required DateTime date,
    required Timestamp timestamp,
  }) {
    AddDateAndTimestampVariables vars = AddDateAndTimestampVariables(
      date: date,
      timestamp: timestamp,
    );

    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class AddDateAndTimestampTimestampHolderInsert {
  String id;

  AddDateAndTimestampTimestampHolderInsert.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  AddDateAndTimestampTimestampHolderInsert({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddDateAndTimestampData {
  AddDateAndTimestampTimestampHolderInsert timestampHolder_insert;

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
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddDateAndTimestampVariables {
  DateTime date;

  Timestamp timestamp;

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
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
