// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_storage_platform_interface.dart';
import '../method_channel/method_channel_firebase_storage.dart';

/// The Firebase Storage platform interface.
///
/// This class should be extended by any classes implementing the plugin on
/// other Flutter supported platforms.
abstract class FirebaseStoragePlatform extends PlatformInterface {
  /// Create an instance using [app]
  FirebaseStoragePlatform({this.appInstance, required this.bucket})
      : super(token: _token);

  /// Returns a [FirebaseStoragePlatform] with the provided arguments.
  factory FirebaseStoragePlatform.instanceFor(
      {required FirebaseApp app, required String bucket}) {
    return FirebaseStoragePlatform.instance
        .delegateFor(app: app, bucket: bucket);
  }

  @protected
  // ignore: public_member_api_docs
  final FirebaseApp? appInstance;

  /// The storage bucket of this instance.
  final String bucket;

  static final Object _token = Object();

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance!;
  }

  static FirebaseStoragePlatform? _instance;

  /// The current default [FirebaseStoragePlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseStorage]
  /// if no other implementation was provided.
  static FirebaseStoragePlatform get instance {
    return _instance ??= MethodChannelFirebaseStorage.instance;
  }

  /// Sets the [FirebaseStoragePlatform.instance]
  static set instance(FirebaseStoragePlatform instance) {
    PlatformInterface.verify(instance, _token);
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

  /// The Storage emulator host this instance is configured to use. This
  /// was required since iOS does not persist these settings on instances and
  /// they need to be set every time when getting a `FIRStorage` instance.
  String? emulatorHost;

  /// The Storage emulator port this instance is configured to use. This
  /// was required since iOS does not persist these settings on instances and
  /// they need to be set every time when getting a `FIRStorage` instance.
  int? emulatorPort;

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseStoragePlatform delegateFor(
      {required FirebaseApp app, required String bucket}) {
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

  /// Changes this instance to point to a Storage emulator running locally.
  ///
  /// Set the [host] (ex: localhost) and [port] (ex: 9199) of the local emulator.
  ///
  /// Note: Must be called immediately, prior to accessing storage methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  ///
  /// Note: storage emulator is not supported for web yet. firebase-js-sdk does not support
  /// storage.useStorageEmulator until v9
  Future<void> useStorageEmulator(String host, int port) {
    throw UnimplementedError('useStorageEmulator() is not implemented');
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
