// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of movies;

class AddDirectorToMovie {
  String name = "addDirectorToMovie";
  AddDirectorToMovie({required this.dataConnect});

  Deserializer<AddDirectorToMovieResponse> dataDeserializer = (String json) =>
      AddDirectorToMovieResponse.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddDirectorToMovieVariables> varsSerializer =
      (AddDirectorToMovieVariables vars) => jsonEncode(vars.toJson());
  MutationRef<AddDirectorToMovieResponse, AddDirectorToMovieVariables> ref(
      {AddDirectorToMovieVariablesPersonId? personId,
      String? movieId,
      AddDirectorToMovieVariables? addDirectorToMovieVariables}) {
    AddDirectorToMovieVariables vars1 = AddDirectorToMovieVariables(
      personId: personId,
      movieId: movieId,
    );
    AddDirectorToMovieVariables vars = addDirectorToMovieVariables ?? vars1;
    return dataConnect.mutation(
        this.name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}

class AddDirectorToMovieDirectedByInsert {
  late String directedbyId;

  late String movieId;

  AddDirectorToMovieDirectedByInsert.fromJson(Map<String, dynamic> json)
      : directedbyId = json['directedbyId'],
        movieId = json['movieId'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['directedbyId'] = directedbyId;

    json['movieId'] = movieId;

    return json;
  }

  AddDirectorToMovieDirectedByInsert({
    required this.directedbyId,
    required this.movieId,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddDirectorToMovieResponse {
  late AddDirectorToMovieDirectedByInsert directedBy_insert;

  AddDirectorToMovieResponse.fromJson(Map<String, dynamic> json)
      : directedBy_insert = AddDirectorToMovieDirectedByInsert.fromJson(
            json['directedBy_insert']) {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['directedBy_insert'] = directedBy_insert.toJson();

    return json;
  }

  AddDirectorToMovieResponse({
    required this.directedBy_insert,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddDirectorToMovieVariablesPersonId {
  late String id;

  AddDirectorToMovieVariablesPersonId.fromJson(Map<String, dynamic> json)
      : id = json['id'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    return json;
  }

  AddDirectorToMovieVariablesPersonId({
    required this.id,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class AddDirectorToMovieVariables {
  late AddDirectorToMovieVariablesPersonId? personId;

  late String? movieId;

  AddDirectorToMovieVariables.fromJson(Map<String, dynamic> json)
      : personId =
            AddDirectorToMovieVariablesPersonId.fromJson(json['personId']),
        movieId = json['movieId'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (personId != null) {
      json['personId'] = personId!.toJson();
    }

    if (movieId != null) {
      json['movieId'] = movieId;
    }

    return json;
  }

  AddDirectorToMovieVariables({
    this.personId,
    this.movieId,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
