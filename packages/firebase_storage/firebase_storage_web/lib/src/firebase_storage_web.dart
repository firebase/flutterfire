// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

import 'firebase_storage_version.dart';
import 'interop/storage.dart' as storage_interop;
import 'reference_web.dart';
import 'utils/errors.dart';

/// The type for functions that implement the `ref` method of the [FirebaseStorageWeb] class.
@visibleForTesting
typedef ReferenceBuilder = ReferencePlatform Function(
    FirebaseStorageWeb storage, String path);

/// The Web implementation of the FirebaseStoragePlatform.
class FirebaseStorageWeb extends FirebaseStoragePlatform {
  /// Construct the plugin.
  FirebaseStorageWeb({FirebaseApp? app, required String bucket})
      : _bucket = bucket,
        super(appInstance: app, bucket: bucket);

  /// Create a FirebaseStorageWeb injecting a [fb.Storage] object.
  @visibleForTesting
  FirebaseStorageWeb.forMock(this._webStorage,
      {required String bucket, FirebaseApp? app})
      : super(appInstance: app, bucket: bucket);

  // Empty constructor. This is only used by the registerWith method.
  // superclass also needs to be initialized and 'bucket' param is required.
  FirebaseStorageWeb._nullInstance()
      : _webStorage = null,
        super(bucket: '');
  static const String _libraryName = 'flutter-fire-gcs';

  /// The js-interop layer for Firebase Storage
  storage_interop.Storage? _webStorage;

  /// Keep the default bucket to pass it down to the [delegate] when first initialized
  String? _bucket;

  /// Lazily initialize [webStorage] on first method call
  storage_interop.Storage get delegate {
    return _webStorage ??=
        storage_interop.getStorageInstance(core_interop.app(app.name), _bucket);
  }

  // Same default as the method channel implementation
  int _maxDownloadRetryTime = const Duration(minutes: 10).inMilliseconds;

  // Same default as the method channel implementation
  int _maxOperationRetryTime = const Duration(minutes: 2).inMilliseconds;

  /// Called by PluginRegistry to register this plugin for Flutter Web.
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerLibraryVersion(_libraryName, packageVersion);

    FirebaseCoreWeb.registerService('storage');
    FirebaseStoragePlatform.instance = FirebaseStorageWeb._nullInstance();
  }

  /// Returns a [FirebaseStorageWeb] with the provided arguments.
  @override
  FirebaseStoragePlatform delegateFor(
      {FirebaseApp? app, required String bucket}) {
    return FirebaseStorageWeb(app: app, bucket: bucket);
  }

  /// The maximum time to retry operations other than uploads or downloads in milliseconds.
  @override
  int get maxOperationRetryTime {
    return _maxOperationRetryTime;
  }

  /// The maximum time to retry uploads in milliseconds.
  @override
  int get maxUploadRetryTime {
    return delegate.maxUploadRetryTime;
  }

  /// The maximum time to retry downloads in milliseconds.
  @override
  int get maxDownloadRetryTime {
    return _maxDownloadRetryTime;
  }

  /// Returns a reference for the given path in the default bucket.
  ///
  /// [path] A relative path to initialize the reference with, for example
  ///   `path/to/image.jpg`. If not passed, the returned reference points to
  ///   the bucket root.
  @override
  ReferencePlatform ref(
    String path, {
    @visibleForTesting ReferenceBuilder? refBuilder,
  }) {
    return guard(() {
      ReferenceBuilder refBuilderFunction = refBuilder ?? _createReference;
      ReferencePlatform ref = refBuilderFunction(this, path);

      return ref;
    });
  }

  // The default [ReferenceBuilder] function used by the [ref] method.
  ReferencePlatform _createReference(FirebaseStorageWeb storage, String path) {
    return ReferenceWeb(storage, path);
  }

  /// The new maximum operation retry time in milliseconds.
  @override
  void setMaxOperationRetryTime(int time) {
    _maxOperationRetryTime = time;
    delegate.maxOperationRetryTime = time;
  }

  /// The new maximum upload retry time in milliseconds.
  @override
  void setMaxUploadRetryTime(int time) {
    delegate.maxUploadRetryTime = time;
  }

  /// The new maximum download retry time in milliseconds.
  @override
  void setMaxDownloadRetryTime(int time) {
    _maxDownloadRetryTime = time;
  }

  @override
  Future<void> useStorageEmulator(String host, int port) async {
    guard(() => delegate.useStorageEmulator(host, port));
  }
}
