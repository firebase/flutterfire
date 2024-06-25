import 'package:firebase_data_connect/firebase_data_connect.dart';


import 'ToggleCompletedResponse.dart';
import 'ToggleCompletedVariables.dart';
class ToggleCompleted {
  String name = "toggleCompleted";
  ToggleCompleted({required this.dataConnect});
  
  late Deserializer<ToggleCompletedResponse> dataDeserializer;
  late Serializer<ToggleCompletedVariables> varsSerializer;
  QueryRef<ToggleCompletedResponse, ToggleCompletedVariables> ref(
      ToggleCompletedVariables vars) {
    return dataConnect.query(name, dataDeserializer, varsSerializer, vars);
  }

  FirebaseDataConnect dataConnect;
}