part of movies;

class ListThing {
  String name = "ListThing";
  ListThing({required this.dataConnect});

  Deserializer<ListThingData> dataDeserializer = (String json) =>
      ListThingData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<ListThingVariables> varsSerializer =
      (ListThingVariables vars) => jsonEncode(vars.toJson());
  QueryRef<ListThingData, ListThingVariables> ref({
    dynamic? data,
  }) {
    ListThingVariables vars = ListThingVariables(
      data: AnyValue(data),
    );

    return dataConnect.query(this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class ListThingThings {
  late AnyValue title;

  ListThingThings.fromJson(Map<String, dynamic> json)
      : title = AnyValue.fromJson(json['title']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['title'] = title.toJson();

    return json;
  }

  ListThingThings({
    required this.title,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListThingData {
  late List<ListThingThings> things;

  ListThingData.fromJson(Map<String, dynamic> json)
      : things = (json['things'] as List<dynamic>)
            .map((e) => ListThingThings.fromJson(e))
            .toList() {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['things'] = things.map((e) => e.toJson()).toList();

    return json;
  }

  ListThingData({
    required this.things,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListThingVariables {
  late AnyValue? data;

  ListThingVariables.fromJson(Map<String, dynamic> json)
      : data = AnyValue.fromJson(json['data']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (data != null) {
      json['data'] = data!.toJson();
    }

    return json;
  }

  ListThingVariables({
    this.data,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
