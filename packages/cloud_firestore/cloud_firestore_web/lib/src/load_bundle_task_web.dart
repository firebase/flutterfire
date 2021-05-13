import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'interop/firestore.dart';

class LoadBundleTaskWeb extends LoadBundleTaskPlatform {
  LoadBundleTaskWeb(this._task)
      : super() {
    _controller = StreamController<LoadBundleTaskSnapshotPlatform>.broadcast(
        onListen: () {
          _task.onProgress(
                  (LoadBundleTaskProgress progress) {
                Map<String, dynamic> data = {
                  'bytesLoaded': progress.bytesLoaded,
                  'documentsLoaded': progress.documentsLoaded,
                  'totalBytes': progress.totalBytes,
                  'totalDocuments': progress.totalDocuments
                };
                LoadBundleTaskState taskState = convertToTaskState(progress.taskState.toLowerCase());

                _controller.add(LoadBundleTaskSnapshotPlatform(taskState, data));

                if (taskState == LoadBundleTaskState.success) {
                  _controller.close();
                }
              });
        }, onCancel: () {
      _controller.close();
    });
  }

  final LoadBundleTask _task;
  late StreamController<LoadBundleTaskSnapshotPlatform> _controller;

  @override
  Stream<LoadBundleTaskSnapshotPlatform> get stream {
    return _controller.stream;
  }
}
