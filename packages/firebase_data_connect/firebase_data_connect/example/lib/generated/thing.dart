part of 'movies.dart';

class ThingVariablesBuilder {
  Optional<AnyValue> _title =
      Optional.optional(AnyValue.fromJson, defaultSerializer);

  final FirebaseDataConnect _dataConnect;
  ThingVariablesBuilder title(AnyValue t) {
    _title.value = t;
    return this;
  }

  ThingVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ThingData> dataDeserializer =
      (dynamic json) => ThingData.fromJson(jsonDecode(json));
  Serializer<ThingVariables> varsSerializer =
      (ThingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<ThingData, ThingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<ThingData, ThingVariables> ref() {
    ThingVariables vars = ThingVariables(
      title: _title,
    );
    return _dataConnect.mutation(
        "thing", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ThingAbc {
  final String id;
  ThingAbc.fromJson(dynamic json) : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ThingAbc otherTyped = other as ThingAbc;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ThingAbc({
    required this.id,
  });
}

@immutable
class ThingDef {
  final String id;
  ThingDef.fromJson(dynamic json) : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ThingDef otherTyped = other as ThingDef;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ThingDef({
    required this.id,
  });
}

@immutable
class ThingData {
  final ThingAbc abc;
  final ThingDef def;
  ThingData.fromJson(dynamic json)
      : abc = ThingAbc.fromJson(json['abc']),
        def = ThingDef.fromJson(json['def']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ThingData otherTyped = other as ThingData;
    return abc == otherTyped.abc && def == otherTyped.def;
  }

  @override
  int get hashCode => Object.hashAll([abc.hashCode, def.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['abc'] = abc.toJson();
    json['def'] = def.toJson();
    return json;
  }

  ThingData({
    required this.abc,
    required this.def,
  });
}

@immutable
class ThingVariables {
  late final Optional<AnyValue> title;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ThingVariables.fromJson(Map<String, dynamic> json) {
    title = Optional.optional(AnyValue.fromJson, defaultSerializer);
    title.value =
        json['title'] == null ? null : AnyValue.fromJson(json['title']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ThingVariables otherTyped = other as ThingVariables;
    return title == otherTyped.title;
  }

  @override
  int get hashCode => title.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (title.state == OptionalState.set) {
      json['title'] = title.toJson();
    }
    return json;
  }

  ThingVariables({
    required this.title,
  });
}
