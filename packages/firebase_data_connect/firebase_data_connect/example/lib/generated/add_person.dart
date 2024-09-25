part of movies;

class AddPerson {
  String name = "addPerson";
  AddPerson({required this.dataConnect});

  Deserializer<AddPersonData> dataDeserializer = (String json) =>
      AddPersonData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddPersonVariables> varsSerializer =
      (AddPersonVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddPersonData, AddPersonVariables> ref({
    String? name,
  }) {
    AddPersonVariables vars = AddPersonVariables(
      name: name,
    );

    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class AddPersonPersonInsert {
  String id;

  AddPersonPersonInsert.fromJson(Map<String, dynamic> json)
      : id = nativeFromJson<String>(json['id']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = nativeToJson<String>(id);

    return json;
  }

  AddPersonPersonInsert({
    required this.id,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class AddPersonData {
  AddPersonPersonInsert person_insert;

  AddPersonData.fromJson(Map<String, dynamic> json)
      : person_insert = AddPersonPersonInsert.fromJson(json['person_insert']) {}

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['person_insert'] = person_insert.toJson();

    return json;
  }

  AddPersonData({
    required this.person_insert,
  }) {
    // TODO: Only show this if there are optional fields.
  }
}

class AddPersonVariables {
  String? name;

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
  }) {
    // TODO: Only show this if there are optional fields.
  }
}
