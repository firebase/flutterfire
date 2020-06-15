// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml;

/// Describes a remote model to be downloaded to the device.
///
/// Defines the download conditions of the model,
/// whether or not to download updated versions of the model,
/// and the model's name specified by the developer in the cloud console.
///
/// https://firebase.google.com/docs/reference/android/com/google/
/// firebase/ml/common/modeldownload/FirebaseRemoteModel
class FirebaseRemoteModel {
  String _modelName;

  /// Returns the name of your model
  String getModelName() => this._modelName;
}

/// Describes a remote model to be downloaded to the device.
/// Create a remote model object with the model's name
/// specified by the developer in the cloud console.
///
/// https://firebase.google.com/docs/reference/android/com/google/
/// firebase/ml/custom/FirebaseCustomRemoteModel
class FirebaseCustomRemoteModel extends FirebaseRemoteModel {
  FirebaseCustomRemoteModel._builder(FirebaseCustomRemoteModelBuilder builder) {
    this._modelName = builder._modelName;
  }
}

/// Builder of [FirebaseCustomRemoteModel].
class FirebaseCustomRemoteModelBuilder {
  String _modelName;

  /// Constructor for [FirebaseCustomRemoteModelBuilder]
  /// that takes in model's name specified by the developer in the console.
  FirebaseCustomRemoteModelBuilder(this._modelName);

  /// Builds [FirebaseCustomRemoteModel] with a specified model name.
  FirebaseCustomRemoteModel build() => FirebaseCustomRemoteModel._builder(this);
}

