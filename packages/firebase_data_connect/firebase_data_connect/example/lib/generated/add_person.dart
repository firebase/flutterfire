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
  late String id;

  AddPersonPersonInsert.fromJson(Map<String, dynamic> json) : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  AddPersonPersonInsert({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddPersonData {
  late AddPersonPersonInsert person_insert;

  AddPersonData.fromJson(Map<String, dynamic> json)
      : person_insert = AddPersonPersonInsert.fromJson(json['person_insert']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['person_insert'] = person_insert.toJson();

    return json;
  }

  AddPersonData({
    required this.person_insert,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddPersonVariables {
  late String? name;

  AddPersonVariables.fromJson(Map<String, dynamic> json)
      : name = json['name'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (name != null) {
      json['name'] = name;
    }

    return json;
  }

  AddPersonVariables({
    this.name,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
