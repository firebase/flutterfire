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

@immutable
class ListThingThings {
  final AnyValue title;
  ListThingThings.fromJson(dynamic json)
      : title = AnyValue.fromJson(json['title']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListThingThings otherTyped = other as ListThingThings;
    return title == otherTyped.title;
  }

  @override
  int get hashCode => title.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = title.toJson();
    return json;
  }

  ListThingThings({
    required this.title,
  });
}

@immutable
class ListThingData {
  final List<ListThingThings> things;
  ListThingData.fromJson(dynamic json)
      : things = (json['things'] as List<dynamic>)
            .map((e) => ListThingThings.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListThingData otherTyped = other as ListThingData;
    return things == otherTyped.things;
  }

  @override
  int get hashCode => things.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['things'] = things.map((e) => e.toJson()).toList();
    return json;
  }

  ListThingData({
    required this.things,
  });
}

@immutable
class ListThingVariables {
  late final Optional<AnyValue> data;
  @Deprecated(
      'fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListThingVariables.fromJson(Map<String, dynamic> json) {
    data = Optional.optional(AnyValue.fromJson, defaultSerializer);
    data.value = json['data'] == null ? null : AnyValue.fromJson(json['data']);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListThingVariables otherTyped = other as ListThingVariables;
    return data == otherTyped.data;
  }

  @override
  int get hashCode => data.hashCode;

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
