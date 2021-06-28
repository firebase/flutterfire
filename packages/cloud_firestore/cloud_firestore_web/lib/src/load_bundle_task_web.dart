import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'interop/firestore.dart';

class LoadBundleTaskWeb extends LoadBundleTaskPlatform {
  LoadBundleTaskWeb(LoadBundleTask task) : super() {
    stream = task.stream
        .asBroadcastStream(
            onListen: (sub) => sub.resume(), onCancel: (sub) => sub.pause())
        .map((snapshot) {
      Map<String, dynamic> data = {
        'bytesLoaded': snapshot.bytesLoaded,
        'documentsLoaded': snapshot.documentsLoaded,
        'totalBytes': snapshot.totalBytes,
        'totalDocuments': snapshot.totalDocuments
      };

      return LoadBundleTaskSnapshotPlatform(snapshot.taskState, data);
    });
  }

  @override
  late final Stream<LoadBundleTaskSnapshotPlatform> stream;
}
