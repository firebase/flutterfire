part of 'movies.dart';

class AddDateAndTimestampVariablesBuilder {
  DateTime date;
  Timestamp timestamp;

  final FirebaseDataConnect _dataConnect;
  AddDateAndTimestampVariablesBuilder(
    this._dataConnect, {
    required this.date,
    required this.timestamp,
  });
  Deserializer<AddDateAndTimestampData> dataDeserializer =
      (dynamic json) => AddDateAndTimestampData.fromJson(jsonDecode(json));
  Serializer<AddDateAndTimestampVariables> varsSerializer =
      (AddDateAndTimestampVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddDateAndTimestampData, AddDateAndTimestampVariables>>
      execute() {
    return ref().execute();
  }

  MutationRef<AddDateAndTimestampData, AddDateAndTimestampVariables> ref() {
    AddDateAndTimestampVariables vars = AddDateAndTimestampVariables(
      date: date,
      timestamp: timestamp,
    );
    return _dataConnect.mutation(
        "addDateAndTimestamp", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddDateAndTimestampTimestampHolderInsert {
  final String id;
  AddDateAndTimestampTimestampHolderInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDateAndTimestampTimestampHolderInsert otherTyped =
        other as AddDateAndTimestampTimestampHolderInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddDateAndTimestampTimestampHolderInsert({
    required this.id,
  });
}

@immutable
class AddDateAndTimestampData {
  final AddDateAndTimestampTimestampHolderInsert timestampHolder_insert;
  AddDateAndTimestampData.fromJson(dynamic json)
      : timestampHolder_insert =
            AddDateAndTimestampTimestampHolderInsert.fromJson(
                json['timestampHolder_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDateAndTimestampData otherTyped = other as AddDateAndTimestampData;
    return timestampHolder_insert == otherTyped.timestampHolder_insert;
  }

  @override
  int get hashCode => timestampHolder_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestampHolder_insert'] = timestampHolder_insert.toJson();
    return json;
  }

  AddDateAndTimestampData({
    required this.timestampHolder_insert,
  });
}

@immutable
class AddDateAndTimestampVariables {
  final DateTime date;
  final Timestamp timestamp;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddDateAndTimestampVariables.fromJson(Map<String, dynamic> json)
      : date = nativeFromJson<DateTime>(json['date']),
        timestamp = Timestamp.fromJson(json['timestamp']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddDateAndTimestampVariables otherTyped =
        other as AddDateAndTimestampVariables;
    return date == otherTyped.date && timestamp == otherTyped.timestamp;
  }

  @override
  int get hashCode => Object.hashAll([date.hashCode, timestamp.hashCode]);

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
