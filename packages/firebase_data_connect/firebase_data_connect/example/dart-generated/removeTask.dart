import 'package:firebase_data_connect/firebase_data_connect.dart';


import 'RemoveTaskResponse.dart';
import 'RemoveTaskVariables.dart';
class RemoveTask {
  String name = "removeTask";
  RemoveTask({required this.dataConnect});
  
  late Deserializer<RemoveTaskResponse> dataDeserializer;
  late Serializer<RemoveTaskVariables> varsSerializer;
  QueryRef<RemoveTaskResponse, RemoveTaskVariables> ref(
      RemoveTaskVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}