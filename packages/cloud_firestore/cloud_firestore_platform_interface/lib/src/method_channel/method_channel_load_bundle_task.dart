import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_firestore.dart';

import 'utils/exception.dart';

class MethodChannelLoadBundleTask extends LoadBundleTaskPlatform {
  MethodChannelLoadBundleTask(this._task, this._bundle) : super() {
    _controller = StreamController<LoadBundleTaskSnapshotPlatform>.broadcast(
        onCancel: () {
      nativePlatformStream?.cancel();
    });

    _task.then((observerId) {
      StreamSubscription<dynamic>? nativePlatformStream;
      nativePlatformStream =
          MethodChannelFirebaseFirestore.loadBundleChannel(observerId!)
              .receiveBroadcastStream(<String, Object>{
        'bundle': _bundle,
      }).listen((snapshot) {
        _controller.add(LoadBundleTaskSnapshotPlatform(
            _convertToTaskState(snapshot['taskState']),
            Map<String, dynamic>.from(snapshot)));
      }, onError: (error, stack) {
        _controller.addError(convertPlatformException(error), stack);
        _controller.close();
        nativePlatformStream?.cancel();
      });
    });
  }

  static LoadBundleTaskState _convertToTaskState(String state) {
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

  final Uint8List _bundle;
  final Future<String?> _task;
  StreamSubscription<dynamic>? nativePlatformStream;
  late StreamController<LoadBundleTaskSnapshotPlatform> _controller;

  @override
  Stream<LoadBundleTaskSnapshotPlatform> get stream {
    return _controller.stream;
  }
}
