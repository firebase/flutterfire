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

class ThingAbc {
  String id;
  ThingAbc.fromJson(dynamic json) : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ThingAbc({
    required this.id,
  });
}

class ThingDef {
  String id;
  ThingDef.fromJson(dynamic json) : id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ThingDef({
    required this.id,
  });
}

class ThingData {
  ThingAbc abc;
  ThingDef def;
  ThingData.fromJson(dynamic json)
      : abc = ThingAbc.fromJson(json['abc']),
        def = ThingDef.fromJson(json['def']);

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

class ThingVariables {
  late Optional<AnyValue> title;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ThingVariables.fromJson(Map<String, dynamic> json) {
    title = Optional.optional(AnyValue.fromJson, defaultSerializer);
    title.value =
        json['title'] == null ? null : AnyValue.fromJson(json['title']);
  }

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
