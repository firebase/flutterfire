import 'dart:convert';
import 'package:firebase_data_connect/firebase_data_connect.dart';




import 'list_movies_response.dart';
import 'list_movies_variables.dart';
class ListMovies {
  String name = "listMovies";
  ListMovies({required this.dataConnect});
  
  Deserializer<ListMoviesResponse> dataDeserializer = (String json)  => ListMoviesResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<ListMoviesVariables> varsSerializer = jsonEncode;
  QueryRef<ListMoviesResponse, ListMoviesVariables> ref(
      ListMoviesVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}