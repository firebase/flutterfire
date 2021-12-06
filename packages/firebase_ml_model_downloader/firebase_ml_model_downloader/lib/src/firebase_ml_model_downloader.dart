// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_ml_model_downloader;

class FirebaseMlModelDownloader extends FirebasePluginPlatform {
  FirebaseMlModelDownloader._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_ml_model_downloader');

  // Cached and lazily loaded instance of [FirebaseMlModelDownloaderPlatform] to avoid
  // creating a [MethodChannelFirebaseFunctions] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseMlModelDownloaderPlatform? _delegatePackingProperty;

  /// The [FirebaseApp] for this current [FirebaseMlModelDownloader] instance.
  final FirebaseApp app;

  static final Map<String, FirebaseMlModelDownloader> _cachedInstances = {};

  /// Returns the underlying [FirebaseMlModelDownloaderPlatform] delegate for this
  /// [FirebaseMlModelDownloader] instance. This is useful for testing purposes only.
  @visibleForTesting
  FirebaseMlModelDownloaderPlatform get delegate {
    return _delegatePackingProperty ??=
        FirebaseMlModelDownloaderPlatform.instanceFor(app: app);
  }

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseMlModelDownloader get instance {
    return FirebaseMlModelDownloader.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  factory FirebaseMlModelDownloader.instanceFor({required FirebaseApp app}) {
    return _cachedInstances.putIfAbsent(app.name, () {
      return FirebaseMlModelDownloader._(app: app);
    });
  }

  /// Gets the downloaded model file based on download type and conditions.
  Future<CustomModel> getModel(
    String modelName,
    DownloadType downloadType, [
    DownloadConditions? conditions,
  ]) {
    return delegate.getModel(
      modelName,
      downloadType,
      conditions ?? DownloadConditions(),
    );
  }

  /// Lists all models downloaded to device.
  Future<List<CustomModel>> listDownloadedModels() {
    return delegate.listDownloadedModels();
  }

  /// Deletes a locally downloaded model by name.
  Future<void> deleteDownloadedModel(String modelName) {
    return delegate.deleteDownloadedModel(modelName);
  }
}
