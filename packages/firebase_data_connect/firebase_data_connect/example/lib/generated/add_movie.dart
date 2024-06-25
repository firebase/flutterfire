import 'dart:convert';
import 'package:firebase_data_connect/firebase_data_connect.dart';




import 'add_movie_response.dart';
import 'add_movie_variables.dart';
class AddMovie {
  String name = "addMovie";
  AddMovie({required this.dataConnect});
  
  Deserializer<AddMovieResponse> dataDeserializer = (String json)  => AddMovieResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddMovieVariables> varsSerializer = jsonEncode;
  MutationRef<AddMovieResponse, AddMovieVariables> ref(
      AddMovieVariables vars) {
    return dataConnect.mutation(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}