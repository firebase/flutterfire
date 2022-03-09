// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import './utils/exception.dart';
import '../../firebase_ml_model_downloader_platform_interface.dart';

class MethodChannelFirebaseModelDownloader
    extends FirebaseModelDownloaderPlatform {
  /// The [MethodChannelFirebaseAuth] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_ml_model_downloader',
  );

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseModelDownloader get instance {
    return MethodChannelFirebaseModelDownloader._();
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseModelDownloader._() : super(appInstance: null);

  /// Creates a new instance with a given [FirebaseApp].
  MethodChannelFirebaseModelDownloader({required FirebaseApp app})
      : super(appInstance: app);

  /// Gets a [FirebaseModelDownloaderPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseModelDownloaderPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseModelDownloader(app: app);
  }

  @override
  Future<FirebaseCustomModel> getModel(
    String modelName,
    FirebaseModelDownloadType downloadType,
    FirebaseModelDownloadConditions conditions,
  ) async {
    try {
      final result = await channel.invokeMapMethod<String, dynamic>(
          'FirebaseModelDownloader#getModel', {
        'appName': app.name,
        'modelName': modelName,
        'downloadType': _downloadTypeToString(downloadType),
        'conditions': conditions.toMap(),
      });

      return _resultToFirebaseCustomModel(result!);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<List<FirebaseCustomModel>> listDownloadedModels() async {
    try {
      final result = await channel.invokeListMethod<Map>(
          'FirebaseModelDownloader#listDownloadedModels', {
        'appName': app.name,
      });

      return result!.map(_resultToFirebaseCustomModel).toList(growable: false);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> deleteDownloadedModel(String modelName) async {
    try {
      await channel
          .invokeMethod<void>('FirebaseModelDownloader#deleteDownloadedModel', {
        'appName': app.name,
        'modelName': modelName,
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  FirebaseCustomModel _resultToFirebaseCustomModel(
    Map result,
  ) {
    return FirebaseCustomModel(
      file: File(result['filePath']),
      size: result['size'],
      name: result['name'],
      hash: result['hash'],
    );
  }
}

String _downloadTypeToString(FirebaseModelDownloadType downloadType) {
  switch (downloadType) {
    case FirebaseModelDownloadType.localModel:
      return 'local';
    case FirebaseModelDownloadType.localModelUpdateInBackground:
      return 'local_background';
    case FirebaseModelDownloadType.latestModel:
      return 'latest';
  }
}
