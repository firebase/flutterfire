part of movies;

class ThingVariablesBuilder {
  Optional<AnyValue> _title =
      Optional.optional(AnyValue.fromJson, defaultSerializer);

  FirebaseDataConnect _dataConnect;
  ThingVariablesBuilder title(AnyValue t) {
    this._title.value = t;
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
    return this.ref().execute();
  }

  MutationRef<ThingData, ThingVariables> ref() {
    ThingVariables vars = ThingVariables(
      title: _title,
    );

    return _dataConnect.mutation(
        "thing", dataDeserializer, varsSerializer, vars);
  }
}

class ThingThingInsert {
  String id;

  ThingThingInsert.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  ThingThingInsert({
    required this.id,
  });
}

class ThingData {
  ThingThingInsert thing_insert;

  ThingData.fromJson(dynamic json)
      : thing_insert = ThingThingInsert.fromJson(json['thing_insert']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['thing_insert'] = thing_insert.toJson();

    return json;
  }

  ThingData({
    required this.thing_insert,
  });
}

class ThingVariables {
  late Optional<AnyValue> title;

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
