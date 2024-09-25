part of movies;

class ListTimestamps {
  String name = "ListTimestamps";
  ListTimestamps({required this.dataConnect});

  Deserializer<ListTimestampsData> dataDeserializer = (String json) =>
      ListTimestampsData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListTimestampsData, void> ref() {
    return dataConnect.query(
        this.name, dataDeserializer, emptySerializer, null);
  }

  FirebaseDataConnect dataConnect;
}

class ListTimestampsTimestampHolders {
  Timestamp timestamp;

  DateTime? date;

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
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class ListTimestampsData {
  List<ListTimestampsTimestampHolders> timestampHolders;

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
  }) {
    // TODO: Only show this if there are optional fields.
  }
}
