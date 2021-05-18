import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'interop/firestore.dart';

class LoadBundleTaskWeb extends LoadBundleTaskPlatform {
  LoadBundleTaskWeb(LoadBundleTask task) : super() {
    Stream<LoadBundleTaskSnapshotPlatform> mapNativeStream() async* {
      await for (final snapshot in task.stream()) {
        Map<String, dynamic> data = {
          'bytesLoaded': snapshot.bytesLoaded,
          'documentsLoaded': snapshot.documentsLoaded,
          'totalBytes': snapshot.totalBytes,
          'totalDocuments': snapshot.totalDocuments
        };

        LoadBundleTaskState taskState =
            convertToTaskState(snapshot.taskState.toLowerCase());

        yield LoadBundleTaskSnapshotPlatform(taskState, data);

        if (taskState == LoadBundleTaskState.success) {
          //closes stream
          return;
        }
      }
    }

    stream =
        mapNativeStream().asBroadcastStream(onCancel: (sub) => sub.cancel());
  }

  @override
  late final Stream<LoadBundleTaskSnapshotPlatform> stream;
}
