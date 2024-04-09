// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../firebase_storage_platform_interface.dart';
import '../pigeon/messages.pigeon.dart';
import './utils/exception.dart';
import 'method_channel_reference.dart';

/// Method Channel delegate for [FirebaseStoragePlatform].
class MethodChannelFirebaseStorage extends FirebaseStoragePlatform {
  /// Creates a new [MethodChannelFirebaseStorage] instance with an [app] and/or
  /// [bucket].
  MethodChannelFirebaseStorage(
      {required FirebaseApp app, required String bucket})
      : super(appInstance: app, bucket: bucket);

  /// Internal stub class initializer.
  ///
  /// When the user code calls an storage method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseStorage._() : super(appInstance: null, bucket: '');

  /// Const Method channel name for Firebase Storage.
  static const String storageMethodChannelName =
      'plugins.flutter.io/firebase_storage';

  /// Const task event name for the storage tasks
  static const String storageTaskEventName = 'taskEvent';

  /// The [EventChannel] used for storageTask
  static EventChannel storageTaskChannel(String id) {
    return EventChannel('$storageMethodChannelName/$storageTaskEventName/$id');
  }

  /// The pigeon channel instance to communicate through.
  static final FirebaseStorageHostApi pigeonChannel = FirebaseStorageHostApi();

  /// FirebaseApp pigeon instance
  PigeonStorageFirebaseApp get pigeonFirebaseApp {
    return PigeonStorageFirebaseApp(
      appName: app.name,
      bucket: bucket,
    );
  }

  /// Returns a unique key to identify the instance by [FirebaseApp] name and
  /// any custom storage buckets.
  static String _getInstanceKey(String /*!*/ appName, String bucket) {
    return '$appName|$bucket';
  }

  /// The [MethodChannelFirebaseStorage] method channel.
  static const MethodChannel channel = MethodChannel(
    storageMethodChannelName,
  );

  static Map<String, MethodChannelFirebaseStorage>
      _methodChannelFirebaseStorageInstances =
      <String, MethodChannelFirebaseStorage>{};

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseStorage get instance {
    return MethodChannelFirebaseStorage._();
  }

  /// Return an instance of a [PigeonStorageReference]
  static PigeonStorageReference getPigeonReference(
      String bucket, String fullPath, String name) {
    return PigeonStorageReference(
        bucket: bucket, fullPath: fullPath, name: name);
  }

  /// Return an instance of a [PigeonStorageFirebaseApp]
  PigeonStorageFirebaseApp getPigeonFirebaseApp(String appName) {
    return PigeonStorageFirebaseApp(
      appName: appName,
      bucket: bucket,
    );
  }

  /// Convert a [SettableMetadata] to [PigeonSettableMetadata]
  static PigeonSettableMetadata getPigeonSettableMetaData(
      SettableMetadata? metaData) {
    if (metaData == null) {
      return PigeonSettableMetadata();
    }
    return PigeonSettableMetadata(
        cacheControl: metaData.cacheControl,
        contentDisposition: metaData.contentDisposition,
        contentEncoding: metaData.contentEncoding,
        contentLanguage: metaData.contentLanguage,
        contentType: metaData.contentType,
        customMetadata: metaData.customMetadata);
  }

  static int _methodChannelHandleId = 0;

  /// Increments and returns the next channel ID handler for Storage.
  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  @override
  int maxOperationRetryTime = const Duration(minutes: 2).inMilliseconds;

  @override
  int maxUploadRetryTime = const Duration(minutes: 10).inMilliseconds;

  @override
  int maxDownloadRetryTime = const Duration(minutes: 10).inMilliseconds;

  @override
  FirebaseStoragePlatform delegateFor(
      {required FirebaseApp app, required String bucket}) {
    String key = _getInstanceKey(app.name, bucket);

    return _methodChannelFirebaseStorageInstances[key] ??=
        MethodChannelFirebaseStorage(app: app, bucket: bucket);
  }

  @override
  ReferencePlatform ref(String path) {
    return MethodChannelReference(this, path);
  }

  @override
  Future<void> useStorageEmulator(String host, int port) async {
    emulatorHost = host;
    emulatorPort = port;
    try {
      return await pigeonChannel.useStorageEmulator(
          pigeonFirebaseApp, host, port);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  void setMaxOperationRetryTime(int time) {
    maxOperationRetryTime = time;
    pigeonChannel.setMaxOperationRetryTime(pigeonFirebaseApp, time);
  }

  @override
  void setMaxUploadRetryTime(int time) {
    maxUploadRetryTime = time;
    pigeonChannel.setMaxUploadRetryTime(pigeonFirebaseApp, time);
  }

  @override
  void setMaxDownloadRetryTime(int time) {
    maxDownloadRetryTime = time;
    pigeonChannel.setMaxDownloadRetryTime(pigeonFirebaseApp, time);
  }
}
