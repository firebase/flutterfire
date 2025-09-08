part of 'movies.dart';

class ListThingVariablesBuilder {
  Optional<AnyValue> _data =
      Optional.optional(AnyValue.fromJson, defaultSerializer);

  final FirebaseDataConnect _dataConnect;
  ListThingVariablesBuilder data(AnyValue? t) {
    _data.value = t;
    return this;
  }

  ListThingVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ListThingData> dataDeserializer =
      (dynamic json) => ListThingData.fromJson(jsonDecode(json));
  Serializer<ListThingVariables> varsSerializer =
      (ListThingVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListThingData, ListThingVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListThingData, ListThingVariables> ref() {
    ListThingVariables vars = ListThingVariables(
      data: _data,
    );
    return _dataConnect.query(
        "ListThing", dataDeserializer, varsSerializer, vars);
  }
}

class ListThingThings {
  AnyValue title;
  ListThingThings.fromJson(dynamic json)
      : title = AnyValue.fromJson(json['title']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = title.toJson();
    return json;
  }

  ListThingThings({
    required this.title,
  });
}

class ListThingData {
  List<ListThingThings> things;
  ListThingData.fromJson(dynamic json)
      : things = (json['things'] as List<dynamic>)
            .map((e) => ListThingThings.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['things'] = things.map((e) => e.toJson()).toList();
    return json;
  }

  ListThingData({
    required this.things,
  });
}

class ListThingVariables {
  late Optional<AnyValue> data;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListThingVariables.fromJson(Map<String, dynamic> json) {
    data = Optional.optional(AnyValue.fromJson, defaultSerializer);
    data.value = json['data'] == null ? null : AnyValue.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (data.state == OptionalState.set) {
      json['data'] = data.toJson();
    }
    return json;
  }

  ListThingVariables({
    required this.data,
  });
}
