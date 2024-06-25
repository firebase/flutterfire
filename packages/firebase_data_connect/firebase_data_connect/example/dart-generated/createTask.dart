import 'package:firebase_data_connect/firebase_data_connect.dart';


import 'CreateTaskResponse.dart';
import 'CreateTaskVariables.dart';
class CreateTask {
  String name = "createTask";
  CreateTask({required this.dataConnect});
  
  late Deserializer<CreateTaskResponse> dataDeserializer;
  late Serializer<CreateTaskVariables> varsSerializer;
  QueryRef<CreateTaskResponse, CreateTaskVariables> ref(
      CreateTaskVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}