part of movies;

class ListTimestampsVariablesBuilder {
  FirebaseDataConnect dataConnect;

  ListTimestampsVariablesBuilder(
    this.dataConnect,
  );
  Deserializer<ListTimestampsData> dataDeserializer = (String json) =>
      ListTimestampsData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListTimestampsData, void> build() {
    return dataConnect.query(
        "ListTimestamps", dataDeserializer, emptySerializer, null);
  }
}

class ListTimestamps {
  String name = "ListTimestamps";
  ListTimestamps({required this.dataConnect});
  ListTimestampsVariablesBuilder ref() {
    return ListTimestampsVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class ListTimestampsTimestampHolders {
  Timestamp timestamp;

  DateTime? date;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListTimestampsTimestampHolders.fromJson(Map<String, dynamic> json)
      : timestamp = Timestamp.fromJson(json['timestamp']) {
    date = json['date'] == null ? null : nativeFromJson<DateTime>(json['date']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['timestamp'] = timestamp.toJson();

    if (date != null) {
      json['date'] = nativeToJson<DateTime?>(date);
    }

    return json;
  }

  ListTimestampsTimestampHolders({
    required this.timestamp,
    this.date,
  });
}

class ListTimestampsData {
  List<ListTimestampsTimestampHolders> timestampHolders;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListTimestampsData.fromJson(Map<String, dynamic> json)
      : timestampHolders = (json['timestampHolders'] as List<dynamic>)
            .map((e) => ListTimestampsTimestampHolders.fromJson(e))
            .toList() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['timestampHolders'] = timestampHolders.map((e) => e.toJson()).toList();

    return json;
  }

  ListTimestampsData({
    required this.timestampHolders,
  });
}
