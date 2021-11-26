// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:firebase_ml_model_downloader_platform_interface/src/method_channel/method_channel_firebase_ml_model_downloader.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../download_conditions.dart';

abstract class FirebaseMlModelDownloaderPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp? appInstance;

  FirebaseMlModelDownloaderPlatform({this.appInstance}) : super(token: _token);

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseMlModelDownloaderPlatform.instanceFor({
    required FirebaseApp app,
  }) {
    return FirebaseMlModelDownloaderPlatform.instance.delegateFor(app: app);
  }

  /// The current default [FirebaseMlModelDownloaderPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseMlModelDownloader]
  /// if no other implementation was provided.
  static FirebaseMlModelDownloaderPlatform get instance {
    _instance ??= MethodChannelFirebaseMlModelDownloader.instance;
    return _instance!;
  }

  static FirebaseMlModelDownloaderPlatform? _instance;

  /// Sets the [FirebaseMlModelDownloaderPlatform.instance]
  static set instance(FirebaseMlModelDownloaderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance!;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseMlModelDownloaderPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Gets the downloaded model file based on download type and conditions.
  Future<CustomModel> getModel(String modelName, DownloadType downloadType,
      DownloadConditions conditions) {
    throw UnimplementedError('getModel() is not implemented');
  }

  /// Lists all models downloaded to device.
  Future<List<CustomModel>> listDownloadedModels() {
    throw UnimplementedError('listDownloadedModels() is not implemented');
  }

  /// Deletes a locally downloaded model by name.
  Future<void> deleteDownloadedModel(String modelName) {
    throw UnimplementedError('deleteDownloadedModel() is not implemented');
  }
}
