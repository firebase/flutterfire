// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

/// A remote model to be downloaded to the device.
///
/// https://firebase.google.com/docs/reference/android/com/google/
/// firebase/ml/common/modeldownload/FirebaseRemoteModel
abstract class FirebaseRemoteModel {
  /// Constructor for [FirebaseRemoteModel].
  ///
  /// Called only by classes that extend [FirebaseRemoteModel].
  FirebaseRemoteModel(this.modelName) : assert(modelName != null);

  /// Name associated with remote model in the Firebase console.
  final String modelName;
}

/// A custom remote model to be downloaded to the device.
///
/// Create a remote model object with the model's name
/// specified by the developer in the cloud console.
///
/// https://firebase.google.com/docs/reference/android/com/google/
/// firebase/ml/custom/FirebaseCustomRemoteModel
class FirebaseCustomRemoteModel extends FirebaseRemoteModel {
  /// Constructor for [FirebaseCustomRemoteModel].
  FirebaseCustomRemoteModel(String modelName) : super(modelName);
}
