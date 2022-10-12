// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_model_downloader;

class FirebaseModelDownloader extends FirebasePluginPlatform {
  FirebaseModelDownloader._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_ml_model_downloader');

  // Cached and lazily loaded instance of [FirebaseModelDownloaderPlatform] to avoid
  // creating a [MethodChannelFirebaseFunctions] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseModelDownloaderPlatform? _delegatePackingProperty;

  /// The [FirebaseApp] for this current [FirebaseModelDownloader] instance.
  final FirebaseApp app;

  static final Map<String, FirebaseModelDownloader> _cachedInstances = {};

  /// Returns the underlying [FirebaseModelDownloaderPlatform] delegate for this
  /// [FirebaseModelDownloader] instance. This is useful for testing purposes only.
  @visibleForTesting
  FirebaseModelDownloaderPlatform get delegate {
    return _delegatePackingProperty ??=
        FirebaseModelDownloaderPlatform.instanceFor(app: app);
  }

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseModelDownloader get instance {
    return FirebaseModelDownloader.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  factory FirebaseModelDownloader.instanceFor({required FirebaseApp app}) {
    return _cachedInstances.putIfAbsent(app.name, () {
      return FirebaseModelDownloader._(app: app);
    });
  }

  /// Gets the downloaded model file based on download type and conditions.
  Future<FirebaseCustomModel> getModel(
    String modelName,
    FirebaseModelDownloadType downloadType, [
    FirebaseModelDownloadConditions? conditions,
  ]) {
    return delegate.getModel(
      modelName,
      downloadType,
      conditions ?? FirebaseModelDownloadConditions(),
    );
  }

  /// Lists all models downloaded to device.
  Future<List<FirebaseCustomModel>> listDownloadedModels() {
    return delegate.listDownloadedModels();
  }

  /// Deletes a locally downloaded model by name.
  Future<void> deleteDownloadedModel(String modelName) {
    return delegate.deleteDownloadedModel(modelName);
  }
}
