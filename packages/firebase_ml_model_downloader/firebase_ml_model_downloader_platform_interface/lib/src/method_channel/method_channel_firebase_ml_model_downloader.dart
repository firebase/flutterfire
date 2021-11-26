// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:firebase_ml_model_downloader_platform_interface/src/download_conditions.dart';
import 'package:firebase_ml_model_downloader_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';

class MethodChannelFirebaseMlModelDownloader
    extends FirebaseMlModelDownloaderPlatform {
  /// The [MethodChannelFirebaseAuth] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_ml_model_downloader',
  );

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseMlModelDownloader get instance {
    return MethodChannelFirebaseMlModelDownloader._();
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseMlModelDownloader._() : super(appInstance: null);

  /// Creates a new instance with a given [FirebaseApp].
  MethodChannelFirebaseMlModelDownloader({required FirebaseApp app})
      : super(appInstance: app);

  /// Gets a [FirebaseMlModelDownloaderPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseMlModelDownloaderPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseMlModelDownloader(app: app);
  }

  @override
  Future<CustomModel> getModel(String modelName, DownloadType downloadType,
      DownloadConditions conditions) async {
    try {
      final result = await channel.invokeMapMethod<String, dynamic>(
          'FirebaseMlModelDownloader#getModel', {
        'appName': app.name,
        'modelName': modelName,
        'downloadType': _downloadTypeToString(downloadType),
        'conditions': conditions.toMap(),
      });

      return _resultToCustomModel(result!);
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<List<CustomModel>> listDownloadedModels() async {
    try {
      final result = await channel.invokeListMethod<Map<String, dynamic>>(
          'FirebaseMlModelDownloader#listDownloadedModels', {
        'appName': app.name,
      });

      return result!.map(_resultToCustomModel).toList(growable: false);
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> deleteDownloadedModel(String modelName) async {
    try {
      await channel.invokeMethod<void>(
          'FirebaseMlModelDownloader#deleteDownloadedModel', {
        'appName': app.name,
        'modelName': modelName,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  CustomModel _resultToCustomModel(Map<dynamic, dynamic> result) {
    return CustomModel(
      file: File(result['filePath']),
      size: result['size'],
      name: result['name'],
      hash: result['hash'],
    );
  }
}

String _downloadTypeToString(DownloadType downloadType) {
  switch (downloadType) {
    case DownloadType.localModel:
      return 'local';
    case DownloadType.localModelUpdateInBackground:
      return 'local_background';
    case DownloadType.latestModel:
      return 'latest';
  }
}
