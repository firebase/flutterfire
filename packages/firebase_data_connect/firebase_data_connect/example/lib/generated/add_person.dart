part of movies;

class AddPersonVariablesBuilder {
  Optional<String> _name = Optional.optional(nativeFromJson, nativeToJson);

  FirebaseDataConnect _dataConnect;
  AddPersonVariablesBuilder name(String? t) {
    this._name.value = t;
    return this;
  }

  AddPersonVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<AddPersonData> dataDeserializer =
      (dynamic json) => AddPersonData.fromJson(jsonDecode(json));
  Serializer<AddPersonVariables> varsSerializer =
      (AddPersonVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddPersonData, AddPersonVariables> build() {
    AddPersonVariables vars = AddPersonVariables(
      name: _name,
    );

    return _dataConnect.mutation(
        "addPerson", dataDeserializer, varsSerializer, vars);
  }
}

class AddPerson {
  String name = "addPerson";
  AddPerson({required this.dataConnect});
  AddPersonVariablesBuilder ref() {
    return AddPersonVariablesBuilder(
      dataConnect,
    );
  }

  FirebaseDataConnect dataConnect;
}

class AddPersonPersonInsert {
  String id;

  AddPersonPersonInsert.fromJson(dynamic json)
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

  AddPersonData.fromJson(dynamic json)
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
  late Optional<String> name;

  AddPersonVariables.fromJson(Map<String, dynamic> json) {
    name = Optional.optional(nativeFromJson, nativeToJson);
    name.value =
        json['name'] == null ? null : nativeFromJson<String>(json['name']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (name.state == OptionalState.set) {
      json['name'] = name.toJson();
    }

    return json;
  }

  AddPersonVariables({
    required this.name,
  });
}
