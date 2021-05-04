import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_firestore.dart';

import 'utils/exception.dart';

class MethodChannelLoadBundleTask extends LoadBundleTaskPlatform {
  MethodChannelLoadBundleTask(this.task) : super() {
    _controller = StreamController<LoadBundleTaskSnapshotPlatform>.broadcast(
        onCancel: () {
      nativePlatformStream?.cancel();
    });

    task.then((observerId) {
      StreamSubscription<dynamic>? nativePlatformStream;
      nativePlatformStream =
          MethodChannelFirebaseFirestore.documentSnapshotChannel(observerId!)
              .receiveBroadcastStream()
              .listen((snapshot) {
        _controller.add(
            LoadBundleTaskSnapshotPlatform(snapshot['taskState'], snapshot));
      }, onError: (error, stack) {
        _controller.addError(convertPlatformException(error), stack);
        _controller.close();
        nativePlatformStream?.cancel();
      });
    });
  }

  StreamSubscription<dynamic>? nativePlatformStream;
  late StreamController<LoadBundleTaskSnapshotPlatform> _controller;

  final Future<String?> task;

  @override
  Stream<LoadBundleTaskSnapshotPlatform> get stream {
    return _controller.stream;
  }
}
