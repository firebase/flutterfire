// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  /// Hash associated with remote model in the Firebase console.
  ///
  /// It's used for caching -- SDK send the hash of the model it already has and
  /// server determines whether it has changed.
  ///
  /// User can access it to compare downloaded models. Change of this modelHash
  /// will not change the hash of the model.
  String modelHash;

  /// Express download conditions via map.
  ///
  /// This method is used for ease of transfer via channel and printing.
  Map<String, String> toMap() {
    return <String, String>{
      'modelName': modelName,
      'modelHash': modelHash,
    };
  }
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
