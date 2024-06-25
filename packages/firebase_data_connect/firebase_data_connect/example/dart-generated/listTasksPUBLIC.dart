import 'package:firebase_data_connect/firebase_data_connect.dart';


import 'ListTasksPublicResponse.dart';
import 'ListTasksPublicVariables.dart';
class ListTasksPublic {
  String name = "listTasksPUBLIC";
  ListTasksPublic({required this.dataConnect});
  
  late Deserializer<ListTasksPublicResponse> dataDeserializer;
  late Serializer<ListTasksPublicVariables> varsSerializer;
  QueryRef<ListTasksPublicResponse, ListTasksPublicVariables> ref(
      ListTasksPublicVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}