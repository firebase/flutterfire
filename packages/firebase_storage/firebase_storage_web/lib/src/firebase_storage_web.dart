// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_web/src/reference_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase/firebase.dart' as fb;

/// The Web implementation of the FirebaseStoragePlatform.
class FirebaseStorageWeb extends FirebaseStoragePlatform {
  /// The js-interop layer for Firebase Storage
  final fb.Storage fbStorage;

  // The max download retry time
  // Same default as the method channel implementation
  int _maxDownloadRetryTime = Duration(minutes: 10).inMilliseconds;

  // Empty constructor. This is only used by the registerWith method.
  FirebaseStorageWeb._nullInstance() : fbStorage = null;

  /// Construct the plugin.
  /// (Web doesn't use the `bucket`, since the init happens in index.html)
  FirebaseStorageWeb({FirebaseApp app, String bucket})
      : fbStorage = fb.storage(fb.app(app?.name)),
        super(appInstance: app, bucket: bucket);

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseStoragePlatform.instance = FirebaseStorageWeb._nullInstance();
  }

  /// Returns a [FirebaseStorageWeb] with the provided arguments.
  @override
  FirebaseStorageWeb delegateFor({FirebaseApp app, String bucket}) {
    return FirebaseStorageWeb(app: app, bucket: bucket);
  }

  /// The maximum time to retry operations other than uploads or downloads in milliseconds.
  int get maxOperationRetryTime {
    return fbStorage?.maxOperationRetryTime;
  }

  /// The maximum time to retry uploads in milliseconds.
  int get maxUploadRetryTime {
    return fbStorage?.maxUploadRetryTime;
  }

  /// The maximum time to retry downloads in milliseconds.
  int get maxDownloadRetryTime {
    return _maxDownloadRetryTime;
  }

  /// Returns a reference for the given path in the default bucket.
  ///
  /// [path] A relative path to initialize the reference with, for example
  ///   `path/to/image.jpg`. If not passed, the returned reference points to
  ///   the bucket root.
  ReferencePlatform ref(String path) {
    return ReferenceWeb(this, path);
  }

  /// The new maximum operation retry time in milliseconds.
  void setMaxOperationRetryTime(int time) {
    fbStorage.setMaxOperationRetryTime(time);
  }

  /// The new maximum upload retry time in milliseconds.
  void setMaxUploadRetryTime(int time) {
    fbStorage.setMaxUploadRetryTime(time);
  }

  /// The new maximum download retry time in milliseconds.
  void setMaxDownloadRetryTime(int time) {
    _maxDownloadRetryTime = time;
  }
}
