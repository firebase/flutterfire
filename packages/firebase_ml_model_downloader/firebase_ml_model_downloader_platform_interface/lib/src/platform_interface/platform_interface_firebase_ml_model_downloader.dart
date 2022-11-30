// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../custom_model.dart';
import '../download_conditions.dart';
import '../download_type.dart';
import '../method_channel/method_channel_firebase_ml_model_downloader.dart';

abstract class FirebaseModelDownloaderPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp? appInstance;

  FirebaseModelDownloaderPlatform({this.appInstance}) : super(token: _token);

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseModelDownloaderPlatform.instanceFor({
    required FirebaseApp app,
  }) {
    return FirebaseModelDownloaderPlatform.instance.delegateFor(app: app);
  }

  /// The current default [FirebaseModelDownloaderPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseModelDownloader]
  /// if no other implementation was provided.
  static FirebaseModelDownloaderPlatform get instance {
    _instance ??= MethodChannelFirebaseModelDownloader.instance;
    return _instance!;
  }

  static FirebaseModelDownloaderPlatform? _instance;

  /// Sets the [FirebaseModelDownloaderPlatform.instance]
  static set instance(FirebaseModelDownloaderPlatform instance) {
    PlatformInterface.verify(instance, _token);
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
  FirebaseModelDownloaderPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Gets the downloaded model file based on download type and conditions.
  Future<FirebaseCustomModel> getModel(
    String modelName,
    FirebaseModelDownloadType downloadType,
    FirebaseModelDownloadConditions conditions,
  ) {
    throw UnimplementedError('getModel() is not implemented');
  }

  /// Lists all models downloaded to device.
  Future<List<FirebaseCustomModel>> listDownloadedModels() {
    throw UnimplementedError('listDownloadedModels() is not implemented');
  }

  /// Deletes a locally downloaded model by name.
  Future<void> deleteDownloadedModel(String modelName) {
    throw UnimplementedError('deleteDownloadedModel() is not implemented');
  }
}
