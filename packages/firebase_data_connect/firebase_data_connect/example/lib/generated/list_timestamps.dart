part of movies;

class ListTimestampsVariablesBuilder {
  FirebaseDataConnect dataConnect;

  ListTimestampsVariablesBuilder(
    this.dataConnect,
  );
  Deserializer<ListTimestampsData> dataDeserializer =
      (dynamic json) => ListTimestampsData.fromJson(jsonDecode(json));

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

  ListTimestampsTimestampHolders.fromJson(dynamic json)
      : timestamp = Timestamp.fromJson(json['timestamp']),
        date = nativeFromJson<DateTime>(json['date']) {}

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
    required this.date,
  });
}

class ListTimestampsData {
  List<ListTimestampsTimestampHolders> timestampHolders;

  ListTimestampsData.fromJson(dynamic json)
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
