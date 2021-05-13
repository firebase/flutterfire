import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

LoadBundleTaskState convertToTaskState(String state) {
  if (state == 'running') {
    return LoadBundleTaskState.running;
  }

  if (state == 'error') {
    return LoadBundleTaskState.error;
  }

  if (state == 'success') {
    return LoadBundleTaskState.success;
  }

  throw StateError(
      'LoadBundleTaskState ought to be one of three values: "running", "success", "error" from native platforms');
}
