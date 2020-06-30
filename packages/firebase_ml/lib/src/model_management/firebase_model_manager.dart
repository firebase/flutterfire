// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  @visibleForTesting

  /// Means for communication with native platform code
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_ml');

  /// Singleton of [FirebaseModelManager].
  static final FirebaseModelManager instance = FirebaseModelManager._();

  /// Initiates the download of remoteModel if the download hasn't begun.
  Future<void> download(FirebaseRemoteModel model,
      FirebaseModelDownloadConditions conditions) async {
    Map modelMap = await channel.invokeMethod("FirebaseModelManager#download",
        {'modelName': model.modelName, 'conditions': conditions.toMap()});
    model.modelHash = modelMap['modelHash'];
  }

  /// Returns the [File] containing the latest model for the remote model name.
  Future<File> getLatestModelFile(FirebaseRemoteModel model) async {
    String modelPath = await channel.invokeMethod(
        "FirebaseModelManager#getLatestModelFile", {'modelName': model.modelName});
    return File(modelPath);
  }

  /// Returns whether the given [FirebaseRemoteModel] is currently downloaded.
  Future<bool> isModelDownloaded(FirebaseRemoteModel model) async {
    return await channel.invokeMethod(
        "FirebaseModelManager#isModelDownloaded", {'modelName': model.modelName});
  }
}
