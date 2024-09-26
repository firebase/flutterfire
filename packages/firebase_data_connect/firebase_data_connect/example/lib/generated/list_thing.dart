part of movies;

class ListThingVariablesBuilder {
  AnyValue? data;

  FirebaseDataConnect dataConnect;

  ListThingVariablesBuilder(
    this.dataConnect, {
    AnyValue? this.data,
  });
  Deserializer<ListThingData> dataDeserializer = (String json) =>
      ListThingData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<ListThingVariables> varsSerializer =
      (ListThingVariables vars) => jsonEncode(vars.toJson());
  QueryRef<ListThingData, ListThingVariables> build() {
    ListThingVariables vars = ListThingVariables(
      data: data,
    );

    return dataConnect.query(
        "ListThing", dataDeserializer, varsSerializer, vars);
  }
}

class ListThing {
  String name = "ListThing";
  ListThing({required this.dataConnect});
  ListThingVariablesBuilder ref({
    dynamic? data,
  }) {
    return ListThingVariablesBuilder(
      dataConnect,
      data: data,
    );
  }

  FirebaseDataConnect dataConnect;
}

class ListThingThings {
  AnyValue title;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListThingThings.fromJson(Map<String, dynamic> json)
      : title = AnyValue.fromJson(json['title']) {}

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

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListThingData.fromJson(Map<String, dynamic> json)
      : things = (json['things'] as List<dynamic>)
            .map((e) => ListThingThings.fromJson(e))
            .toList() {}

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
  AnyValue? data;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListThingVariables.fromJson(Map<String, dynamic> json) {
    data = json['data'] == null ? null : AnyValue.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (data != null) {
      json['data'] = data!.toJson();
    }

    return json;
  }

  ListThingVariables({
    this.data,
  });
}
