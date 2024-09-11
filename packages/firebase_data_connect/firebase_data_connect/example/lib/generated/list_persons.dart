part of movies;

class ListPersons {
  String name = "ListPersons";
  ListPersons({required this.dataConnect});

  Deserializer<ListPersonsResponse> dataDeserializer = (String json) =>
      ListPersonsResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);

  QueryRef<ListPersonsResponse, void> ref() {
    return dataConnect.query(this.name, dataDeserializer, null, null);
  }

  FirebaseDataConnect dataConnect;
}

class ListPersonsPeople {
  late String id;

  late String name;

  late List<ListPersonsPeopleDirectedMovies> directed_movies;

  ListPersonsPeople.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        directed_movies = (json['directed_movies'] as List<dynamic>)
            .map((e) => ListPersonsPeopleDirectedMovies.fromJson(e))
            .toList() {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['id'] = id;

    json['name'] = name;

    json['directed_movies'] = directed_movies.map((e) => e.toJson()).toList();

    return json;
  }

  ListPersonsPeople({
    required this.id,
    required this.name,
    required this.directed_movies,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListPersonsPeopleDirectedMovies {
  late String title;

  ListPersonsPeopleDirectedMovies.fromJson(Map<String, dynamic> json)
      : title = json['title'] {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['title'] = title;

    return json;
  }

  ListPersonsPeopleDirectedMovies({
    required this.title,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}

class ListPersonsResponse {
  late List<ListPersonsPeople> people;

  ListPersonsResponse.fromJson(Map<String, dynamic> json)
      : people = (json['people'] as List<dynamic>)
            .map((e) => ListPersonsPeople.fromJson(e))
            .toList() {}

  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['people'] = people.map((e) => e.toJson()).toList();

    return json;
  }

  ListPersonsResponse({
    required this.people,
  }) {
    // TODO(mtewani): Only show this if there are optional fields.
  }
}
