import 'package:firebase_data_connect/firebase_data_connect.dart';


import 'ListTasksForTodayResponse.dart';
import 'ListTasksForTodayVariables.dart';
class ListTasksForToday {
  String name = "listTasksForToday";
  ListTasksForToday({required this.dataConnect});
  
  late Deserializer<ListTasksForTodayResponse> dataDeserializer;
  late Serializer<ListTasksForTodayVariables> varsSerializer;
  QueryRef<ListTasksForTodayResponse, ListTasksForTodayVariables> ref(
      ListTasksForTodayVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}