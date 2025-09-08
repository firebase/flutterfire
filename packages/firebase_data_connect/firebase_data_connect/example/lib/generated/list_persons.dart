part of 'movies.dart';

class ListPersonsVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListPersonsVariablesBuilder(
    this._dataConnect,
  );
  Deserializer<ListPersonsData> dataDeserializer =
      (dynamic json) => ListPersonsData.fromJson(jsonDecode(json));

  Future<QueryResult<ListPersonsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListPersonsData, void> ref() {
    return _dataConnect.query(
        "ListPersons", dataDeserializer, emptySerializer, null);
  }
}

class ListPersonsPeople {
  String id;
  String name;
  ListPersonsPeople.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        name = nativeFromJson<String>(json['name']);

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
  ListPersonsData.fromJson(dynamic json)
      : people = (json['people'] as List<dynamic>)
            .map((e) => ListPersonsPeople.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['people'] = people.map((e) => e.toJson()).toList();
    return json;
  }

  ListPersonsData({
    required this.people,
  });
}
