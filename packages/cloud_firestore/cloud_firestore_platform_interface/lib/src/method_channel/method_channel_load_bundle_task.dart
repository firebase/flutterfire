import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_firestore.dart';

import 'utils/exception.dart';

class MethodChannelLoadBundleTask extends LoadBundleTaskPlatform {
  MethodChannelLoadBundleTask(this._task, this._bundle, this._firestore)
      : super() {
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
        'firestore': _firestore
      }).listen((snapshot) {
        _controller.add(LoadBundleTaskSnapshotPlatform(
            convertToTaskState(snapshot['taskState']),
            Map<String, dynamic>.from(snapshot)));

        if (snapshot['taskState'] == 'success') {
          _controller.close();
          nativePlatformStream?.cancel();
        }
      }, onError: (error, stack) {
        _controller.addError(convertPlatformException(error), stack);
        _controller.close();
        nativePlatformStream?.cancel();
      });
    });
  }

  final MethodChannelFirebaseFirestore _firestore;
  final Uint8List _bundle;
  final Future<String?> _task;
  StreamSubscription<dynamic>? nativePlatformStream;
  late StreamController<LoadBundleTaskSnapshotPlatform> _controller;

  @override
  Stream<LoadBundleTaskSnapshotPlatform> get stream {
    return _controller.stream;
  }
}
