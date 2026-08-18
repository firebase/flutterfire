part of 'movies.dart';

class AddPersonVariablesBuilder {
  Optional<String> _name = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;
  AddPersonVariablesBuilder name(String? t) {
    _name.value = t;
    return this;
  }

  AddPersonVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<AddPersonData> dataDeserializer =
      (dynamic json) => AddPersonData.fromJson(jsonDecode(json));
  Serializer<AddPersonVariables> varsSerializer =
      (AddPersonVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddPersonData, AddPersonVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddPersonData, AddPersonVariables> ref() {
    AddPersonVariables vars = AddPersonVariables(
      name: _name,
    );
    return _dataConnect.mutation(
        "addPerson", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddPersonPersonInsert {
  final String id;
  AddPersonPersonInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddPersonPersonInsert otherTyped = other as AddPersonPersonInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddPersonPersonInsert({
    required this.id,
  });
}

@immutable
class AddPersonData {
  final AddPersonPersonInsert person_insert;
  AddPersonData.fromJson(dynamic json)
      : person_insert = AddPersonPersonInsert.fromJson(json['person_insert']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddPersonData otherTyped = other as AddPersonData;
    return person_insert == otherTyped.person_insert;
  }

  @override
  int get hashCode => person_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['person_insert'] = person_insert.toJson();
    return json;
  }

  AddPersonData({
    required this.person_insert,
  });
}

@immutable
class AddPersonVariables {
  late final Optional<String> name;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddPersonVariables.fromJson(Map<String, dynamic> json) {
    name = Optional.optional(nativeFromJson, nativeToJson);
    name.value =
        json['name'] == null ? null : nativeFromJson<String>(json['name']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AddPersonVariables otherTyped = other as AddPersonVariables;
    return name == otherTyped.name;
  }

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (name.state == OptionalState.set) {
      json['name'] = name.toJson();
    }
    return json;
  }

  AddPersonVariables({
    required this.name,
  });
}
