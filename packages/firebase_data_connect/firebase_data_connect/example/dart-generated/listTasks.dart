import 'package:firebase_data_connect/firebase_data_connect.dart';


import 'ListTasksResponse.dart';
import 'ListTasksVariables.dart';
class ListTasks {
  String name = "listTasks";
  ListTasks({required this.dataConnect});
  
  late Deserializer<ListTasksResponse> dataDeserializer;
  late Serializer<ListTasksVariables> varsSerializer;
  QueryRef<ListTasksResponse, ListTasksVariables> ref(
      ListTasksVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}