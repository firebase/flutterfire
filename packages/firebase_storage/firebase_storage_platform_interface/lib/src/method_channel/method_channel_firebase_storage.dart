// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import './utils/exception.dart';
import '../../firebase_storage_platform_interface.dart';
import '../pigeon/messages.pigeon.dart';
import 'method_channel_reference.dart';
import 'method_channel_task_snapshot.dart';

/// Method Channel delegate for [FirebaseStoragePlatform].
class MethodChannelFirebaseStorage extends FirebaseStoragePlatform {
  /// Creates a new [MethodChannelFirebaseStorage] instance with an [app] and/or
  /// [bucket].
  MethodChannelFirebaseStorage(
      {required FirebaseApp app, required String bucket})
      : super(appInstance: app, bucket: bucket) {}

  /// Internal stub class initializer.
  ///
  /// When the user code calls an storage method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseStorage._() : super(appInstance: null, bucket: '');

  static const String STORAGE_METHOD_CHANNEL_NAME =
      'plugins.flutter.io/firebase_storage';
  static const String STORAGE_TASK_EVENT_NAME = "taskEvent";

  /// The [EventChannel] used for storageTask
  static EventChannel storageTaskChannel(String id) {
    return EventChannel(
        '$STORAGE_METHOD_CHANNEL_NAME/$STORAGE_TASK_EVENT_NAME/$id');
  }

  static final FirebaseStorageHostApi pigeonChannel = FirebaseStorageHostApi();

  /// Default FirebaseApp pigeon instance
  PigeonStorageFirebaseApp get pigeonFirebaseAppDefault {
    return PigeonStorageFirebaseApp(
      appName: app.name,
    );
  }

  /// Returns a unique key to identify the instance by [FirebaseApp] name and
  /// any custom storage buckets.
  static String _getInstanceKey(String /*!*/ appName, String bucket) {
    return '$appName|$bucket';
  }

  /// The [MethodChannelFirebaseStorage] method channel.
  static const MethodChannel channel = MethodChannel(
    STORAGE_METHOD_CHANNEL_NAME,
  );

  static Map<String, MethodChannelFirebaseStorage>
      _methodChannelFirebaseStorageInstances =
      <String, MethodChannelFirebaseStorage>{};

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseStorage get instance {
    return MethodChannelFirebaseStorage._();
  }

  static PigeonStorageReference getPigeonReference(
      String bucket, String fullPath, String name) {
    return PigeonStorageReference(
        bucket: bucket, fullPath: fullPath, name: name);
  }

  static PigeonStorageFirebaseApp getPigeonFirebaseApp(String appName) {
    return PigeonStorageFirebaseApp(
      appName: appName,
    );
  }

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
          pigeonFirebaseAppDefault, host, port);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  void setMaxOperationRetryTime(int time) {
    maxOperationRetryTime = time;
    pigeonChannel.setMaxOperationRetryTime(pigeonFirebaseAppDefault, time);
  }

  @override
  void setMaxUploadRetryTime(int time) {
    maxUploadRetryTime = time;
    pigeonChannel.setMaxUploadRetryTime(pigeonFirebaseAppDefault, time);
  }

  @override
  void setMaxDownloadRetryTime(int time) {
    maxDownloadRetryTime = time;
    pigeonChannel.setMaxDownloadRetryTime(pigeonFirebaseAppDefault, time);
  }
}
