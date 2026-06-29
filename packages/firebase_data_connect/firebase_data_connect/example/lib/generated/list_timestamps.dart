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

@immutable
class ListTimestampsTimestampHolders {
  final Timestamp timestamp;
  final DateTime? date;
  ListTimestampsTimestampHolders.fromJson(dynamic json)
      : timestamp = Timestamp.fromJson(json['timestamp']),
        date = json['date'] == null
            ? null
            : nativeFromJson<DateTime>(json['date']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListTimestampsTimestampHolders otherTyped =
        other as ListTimestampsTimestampHolders;
    return timestamp == otherTyped.timestamp && date == otherTyped.date;
  }

  @override
  int get hashCode => Object.hashAll([timestamp.hashCode, date.hashCode]);

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

@immutable
class ListTimestampsData {
  final List<ListTimestampsTimestampHolders> timestampHolders;
  ListTimestampsData.fromJson(dynamic json)
      : timestampHolders = (json['timestampHolders'] as List<dynamic>)
            .map((e) => ListTimestampsTimestampHolders.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListTimestampsData otherTyped = other as ListTimestampsData;
    return timestampHolders == otherTyped.timestampHolders;
  }

  @override
  int get hashCode => timestampHolders.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestampHolders'] = timestampHolders.map((e) => e.toJson()).toList();
    return json;
  }

  ListTimestampsData({
    required this.timestampHolders,
  });
}
