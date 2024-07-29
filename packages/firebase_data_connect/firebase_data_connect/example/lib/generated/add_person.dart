// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;

class AddPerson {
  String name = "addPerson";
  AddPerson({required this.dataConnect});

  Deserializer<AddPersonResponse> dataDeserializer = (String json) =>
      AddPersonResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddPersonVariables> varsSerializer = jsonEncode;
  MutationRef<AddPersonResponse, AddPersonVariables> ref(
      AddPersonVariables vars) {
    return dataConnect.mutation(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class AddPersonPersonInsert {
  String id;

  AddPersonPersonInsert.fromJson(Map<String, dynamic> json) : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  AddPersonPersonInsert(
    this.id,
  );
}

class AddPersonResponse {
  AddPersonPersonInsert person_insert;

  AddPersonResponse.fromJson(Map<String, dynamic> json)
      : person_insert = AddPersonPersonInsert.fromJson(json['person_insert']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['person_insert'] = person_insert.toJson();

    return json;
  }

  AddPersonResponse(
    this.person_insert,
  );
}

class AddPersonVariables {
  String? name;

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

  AddPersonVariables(
    this.name,
  );
}
