// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'firebase_remote_model.dart';
import 'firebase_model_download_conditions.dart';

/// The user downloads a remote model with [FirebaseModelManager].
///
/// The model name is the key for a model,
/// and should be consistent with the name of the model
/// that has been uploaded to the Firebase console.
///
/// https://firebase.google.com/docs/reference/android/com/google/
/// firebase/ml/common/modeldownload/FirebaseModelManager
class FirebaseModelManager {
  FirebaseModelManager._();

  /// Means for communication with native platform code
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_ml_custom');

  /// Singleton of [FirebaseModelManager].
  static final FirebaseModelManager instance = FirebaseModelManager._();

  /// Initiates the download of remoteModel if the download hasn't begun.
  ///
  /// If the model's download is already in progress,
  /// new download will not be initiated.
  ///
  /// If the model is already downloaded to the device,
  /// and there is no update, the task will immediately succeed.
  ///
  /// If the model is already downloaded to the device, and there is update,
  /// a download for the updated version will be attempted.
  ///
  /// If the model update is failed to schedule, no error is raised,
  /// and the caller should use the existing model.
  Future<void> download(FirebaseRemoteModel model,
      FirebaseModelDownloadConditions conditions) async {
    assert(model != null);
    assert(conditions != null);
    await channel.invokeMethod('FirebaseModelManager#download', {
      'modelName': model.modelName,
      'conditions': conditions.toMap(),
    });
  }

  /// Returns a [File] containing the latest model for the remote model name.
  ///
  /// This will fail with if the model is not yet downloaded on the device or valid custom remote model is not provided.
  Future<File> getLatestModelFile(FirebaseRemoteModel model) async {
    assert(model != null);
    var modelPath = await channel.invokeMethod(
      'FirebaseModelManager#getLatestModelFile',
      {'modelName': model.modelName},
    );
    return File(modelPath);
  }

  /// Returns whether the given [FirebaseRemoteModel] is currently downloaded.
  Future<bool> isModelDownloaded(FirebaseRemoteModel model) async {
    assert(model != null);
    return channel.invokeMethod(
      'FirebaseModelManager#isModelDownloaded',
      {'modelName': model.modelName},
    );
  }
}
