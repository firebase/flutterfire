part of 'movies.dart';

class AddTimestampVariablesBuilder {
  Timestamp timestamp;

  final FirebaseDataConnect _dataConnect;
  AddTimestampVariablesBuilder(
    this._dataConnect, {
    required this.timestamp,
  });
  Deserializer<AddTimestampData> dataDeserializer =
      (dynamic json) => AddTimestampData.fromJson(jsonDecode(json));
  Serializer<AddTimestampVariables> varsSerializer =
      (AddTimestampVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddTimestampData, AddTimestampVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddTimestampData, AddTimestampVariables> ref() {
    AddTimestampVariables vars = AddTimestampVariables(
      timestamp: timestamp,
    );
    return _dataConnect.mutation(
        "addTimestamp", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddTimestampTimestampHolderInsert {
  final String id;
  AddTimestampTimestampHolderInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddTimestampTimestampHolderInsert otherTyped =
        other as AddTimestampTimestampHolderInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddTimestampTimestampHolderInsert({
    required this.id,
  });
}

@immutable
class AddTimestampData {
  final AddTimestampTimestampHolderInsert timestampHolder_insert;
  AddTimestampData.fromJson(dynamic json)
      : timestampHolder_insert = AddTimestampTimestampHolderInsert.fromJson(
            json['timestampHolder_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddTimestampData otherTyped = other as AddTimestampData;
    return timestampHolder_insert == otherTyped.timestampHolder_insert;
  }

  @override
  int get hashCode => timestampHolder_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestampHolder_insert'] = timestampHolder_insert.toJson();
    return json;
  }

  AddTimestampData({
    required this.timestampHolder_insert,
  });
}

@immutable
class AddTimestampVariables {
  final Timestamp timestamp;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddTimestampVariables.fromJson(Map<String, dynamic> json)
      : timestamp = Timestamp.fromJson(json['timestamp']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddTimestampVariables otherTyped = other as AddTimestampVariables;
    return timestamp == otherTyped.timestamp;
  }

  @override
  int get hashCode => timestamp.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestamp'] = timestamp.toJson();
    return json;
  }

  AddTimestampVariables({
    required this.timestamp,
  });
}
