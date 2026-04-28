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

@immutable
class ListPersonsPeople {
  final String id;
  final String name;
  ListPersonsPeople.fromJson(dynamic json)
      : id = nativeFromJson<String>(json['id']),
        name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListPersonsPeople otherTyped = other as ListPersonsPeople;
    return id == otherTyped.id && name == otherTyped.name;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);

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

@immutable
class ListPersonsData {
  final List<ListPersonsPeople> people;
  ListPersonsData.fromJson(dynamic json)
      : people = (json['people'] as List<dynamic>)
            .map((e) => ListPersonsPeople.fromJson(e))
            .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListPersonsData otherTyped = other as ListPersonsData;
    return people == otherTyped.people;
  }

  @override
  int get hashCode => people.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['people'] = people.map((e) => e.toJson()).toList();
    return json;
  }

  ListPersonsData({
    required this.people,
  });
}
