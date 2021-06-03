import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

LoadBundleTaskState convertToTaskState(String state) {
  switch (state) {
    case 'running':
      return LoadBundleTaskState.running;
    case 'success':
      return LoadBundleTaskState.success;
    case 'error':
      return LoadBundleTaskState.error;
    default:
      throw FallThroughError();
  }
}
