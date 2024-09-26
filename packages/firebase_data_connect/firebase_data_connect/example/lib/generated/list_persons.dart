part of movies;

class ListPersonsVariablesBuilder {
  FirebaseDataConnect dataConnect;

  ListPersonsVariablesBuilder(
    this.dataConnect,
  );
  Deserializer<ListPersonsData> dataDeserializer = (String json) =>
      ListPersonsData.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListPersonsData, void> build() {
    return dataConnect.query(
        "ListPersons", dataDeserializer, emptySerializer, null);
  }
}

class ListPersons {
  String name = "ListPersons";
  ListPersons({required this.dataConnect});
  ListPersonsVariablesBuilder ref() {
    return ListPersonsVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class ListPersonsPeople {
  String id;

  String name;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListPersonsPeople.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']),
        name = nativeFromJson<String>(json['name']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    json['name'] = nativeToJson<String>(name);

    return json;
  }

  ListPersonsPeople({
    required this.id,
    required this.name,
  });
}

class ListPersonsData {
  List<ListPersonsPeople> people;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  ListPersonsData.fromJson(Map<String, dynamic> json)
      : people = (json['people'] as List<dynamic>)
            .map((e) => ListPersonsPeople.fromJson(e))
            .toList() {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['people'] = people.map((e) => e.toJson()).toList();

    return json;
  }

  ListPersonsData({
    required this.people,
  });
}
