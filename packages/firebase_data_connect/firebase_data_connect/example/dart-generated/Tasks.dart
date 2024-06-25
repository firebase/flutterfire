import 'package:firebase_data_connect/firebase_data_connect.dart';

import 'Create_Task_Response.dart';

import 'Toggle_Completed_Response.dart';

import 'Remove_Task_Response.dart';

import 'List_Tasks_Response.dart';

import 'List_Tasks_For_Today_Response.dart';

import 'List_Tasks_Public_Response.dart';


class TasksConnector {
  
  CreateTask get createTask {
    return CreateTask(dataConnect: dataConnect);
  }
  
  ToggleCompleted get toggleCompleted {
    return ToggleCompleted(dataConnect: dataConnect);
  }
  
  RemoveTask get removeTask {
    return RemoveTask(dataConnect: dataConnect);
  }
  
  ListTasks get listTasks {
    return ListTasks(dataConnect: dataConnect);
  }
  
  ListTasksForToday get listTasksForToday {
    return ListTasksForToday(dataConnect: dataConnect);
  }
  
  ListTasksPublic get listTasksPUBLIC {
    return ListTasksPublic(dataConnect: dataConnect);
  }
  

  TasksConnector({required this.dataConnect});
  static TasksConnector get instance {
    return TasksConnector(
        dataConnect:
            FirebaseDataConnect.instanceFor(connectorConfig: connectorConfig));
  }

  FirebaseDataConnect dataConnect;
}