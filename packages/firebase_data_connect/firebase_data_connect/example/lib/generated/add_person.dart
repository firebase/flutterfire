part of movies;

class AddPersonVariablesBuilder {
  String? name;

  FirebaseDataConnect dataConnect;

  AddPersonVariablesBuilder(
    this.dataConnect, {
    String? this.name,
  });
  Deserializer<AddPersonData> dataDeserializer = (String json) =>
      AddPersonData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddPersonVariables> varsSerializer =
      (AddPersonVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddPersonData, AddPersonVariables> build() {
    AddPersonVariables vars = AddPersonVariables(
      name: name,
    );

    return dataConnect.mutation(
        "addPerson", dataDeserializer, varsSerializer, vars);
  }
}

class AddPerson {
  String name = "addPerson";
  AddPerson({required this.dataConnect});
  AddPersonVariablesBuilder ref({
    String? name,
  }) {
    return AddPersonVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class AddPersonPersonInsert {
  String id;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddPersonPersonInsert.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  AddPersonPersonInsert({
    required this.id,
  });
}

class AddPersonData {
  AddPersonPersonInsert person_insert;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddPersonData.fromJson(Map<String, dynamic> json)
      : person_insert = AddPersonPersonInsert.fromJson(json['person_insert']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['person_insert'] = person_insert.toJson();

    return json;
  }

  AddPersonData({
    required this.person_insert,
  });
}

class AddPersonVariables {
  String? name;

  // TODO(mtewani): Check what happens when an optional field is retrieved from json.
  AddPersonVariables.fromJson(Map<String, dynamic> json) {
    name = json['name'] == null ? null : nativeFromJson<String>(json['name']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (name != null) {
      json['name'] = nativeToJson<String?>(name);
    }

    return json;
  }

  AddPersonVariables({
    this.name,
  });
}
