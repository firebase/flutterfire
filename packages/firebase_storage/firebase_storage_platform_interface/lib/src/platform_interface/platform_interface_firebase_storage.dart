// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import '../method_channel/method_channel_firebase_storage.dart';

/// The Firebase Storage platform interface.
///
/// This class should be extended by any classes implementing the plugin on
/// other Flutter supported platforms.
abstract class FirebaseStoragePlatform extends PlatformInterface {
  @protected
  // ignore: public_member_api_docs
  final FirebaseApp appInstance;

  /// The storage bucket of this instance.
  final String bucket;

  /// Create an instance using [app]
  FirebaseStoragePlatform({this.appInstance, this.bucket})
      : super(token: _token);

  static final Object _token = Object();

  /// Returns a [FirebaseStoragePlatform] with the provided arguments.
  factory FirebaseStoragePlatform.instanceFor(
      {FirebaseApp app, String bucket}) {
    return FirebaseStoragePlatform.instance
        .delegateFor(app: app, bucket: bucket);
  }

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance;
  }

  static FirebaseStoragePlatform _instance;

  /// The current default [FirebaseStoragePlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseStorage]
  /// if no other implementation was provided.
  static FirebaseStoragePlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirebaseStorage.instance;
    }
    return _instance;
  }

  /// Sets the [FirebaseStoragePlatform.instance]
  static set instance(FirebaseStoragePlatform instance) {
    assert(instance != null);
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// The maximum time to retry operations other than uploads or downloads in milliseconds.
  int get maxOperationRetryTime {
    throw UnimplementedError('get.maxOperationRetryTime is not implemented');
  }

  /// The maximum time to retry uploads in milliseconds.
  int get maxUploadRetryTime {
    throw UnimplementedError('get.maxUploadRetryTime is not implemented');
  }

  /// The maximum time to retry downloads in milliseconds.
  int get maxDownloadRetryTime {
    throw UnimplementedError('get.maxDownloadRetryTime is not implemented');
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseStoragePlatform delegateFor({FirebaseApp app, String bucket}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Returns a reference for the given path in the default bucket.
  ///
  /// [path] A relative path to initialize the reference with, for example
  ///   `path/to/image.jpg`. If not passed, the returned reference points to
  ///   the bucket root.
  ReferencePlatform ref(String path) {
    throw UnimplementedError('ref() is not implemented');
  }

  /// The new maximum operation retry time in milliseconds.
  void setMaxOperationRetryTime(int time) {
    throw UnimplementedError('setMaxOperationRetryTime() is not implemented');
  }

  /// The new maximum upload retry time in milliseconds.
  void setMaxUploadRetryTime(int time) {
    throw UnimplementedError('setMaxUploadRetryTime() is not implemented');
  }

  /// The new maximum download retry time in milliseconds.
  void setMaxDownloadRetryTime(int time) {
    throw UnimplementedError('setMaxDownloadRetryTime() is not implemented');
  }
}
