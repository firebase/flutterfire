// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml;

/// Before using a remote model,
/// the user downloads it with [FirebaseModelManager].
///
/// The model name is the key for a model,
/// and should be consistent with the name of the model
/// that has been uploaded to the Firebase console.
///
/// https://firebase.google.com/docs/reference/android/com/google/
/// firebase/ml/common/modeldownload/FirebaseModelManager
class FirebaseModelManager {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/firebase_ml');

  FirebaseModelManager._();

  /// Singleton of [FirebaseModelManager].
  static final FirebaseModelManager instance = FirebaseModelManager._();

  /// Initiates the download of remoteModel if the download hasn't begun.
  Future<void> download(FirebaseRemoteModel model,
      FirebaseModelDownloadConditions conditions) async {
    // Example call
    await _channel.invokeMethod(
        "FirebaseModelManager#download", {'model': model.toString()});
  }

  /// Deletes the given [FirebaseRemoteModel] from disk.
  Future<void> deleteDownloadedModel(FirebaseRemoteModel model) async {}

  /// Returns the [File] containing the latest model for the remote model name.
  Future<File> getLatestModelFile(
      FirebaseRemoteModel firebaseRemoteModel) async {
    return File("");
  }

  /// Returns whether the given [FirebaseRemoteModel] is currently downloaded.
  Future<bool> isModelDownloaded(
      FirebaseRemoteModel firebaseRemoteModel) async {
    return true;
  }
}
