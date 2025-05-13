part of 'movies.dart';

class ListTimestampsVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListTimestampsVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ListTimestampsData> dataDeserializer =
      (dynamic json) => ListTimestampsData.fromJson(jsonDecode(json));

  Future<QueryResult<ListTimestampsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListTimestampsData, void> ref() {
    return _dataConnect.query(
        "ListTimestamps", dataDeserializer, emptySerializer, null);
  }
}

class ListTimestampsTimestampHolders {
  Timestamp timestamp;
  DateTime? date;
  ListTimestampsTimestampHolders.fromJson(dynamic json)
      : timestamp = Timestamp.fromJson(json['timestamp']),
        date = json['date'] == null
            ? null
            : nativeFromJson<DateTime>(json['date']);

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
  ListTimestampsData.fromJson(dynamic json)
      : timestampHolders = (json['timestampHolders'] as List<dynamic>)
            .map((e) => ListTimestampsTimestampHolders.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestampHolders'] = timestampHolders.map((e) => e.toJson()).toList();
    return json;
  }

  ListTimestampsData({
    required this.timestampHolders,
  });
}
