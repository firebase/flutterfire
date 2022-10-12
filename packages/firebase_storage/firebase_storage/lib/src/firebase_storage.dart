// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_storage;

/// The entrypoint for [FirebaseStorage].
class FirebaseStorage extends FirebasePluginPlatform {
  FirebaseStorage._({required this.app, required this.bucket})
      : super(app.name, 'plugins.flutter.io/firebase_storage');

  // Cached and lazily loaded instance of [FirebaseStoragePlatform] to avoid
  // creating a [MethodChannelStorage] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseStoragePlatform? _delegatePackingProperty;

  FirebaseStoragePlatform get _delegate {
    return _delegatePackingProperty ??= FirebaseStoragePlatform.instanceFor(
      app: app,
      bucket: bucket,
    );
  }

  /// The [FirebaseApp] for this current [FirebaseStorage] instance.
  FirebaseApp app;

  /// The storage bucket of this instance.
  String bucket;

  /// The maximum time to retry operations other than uploads or downloads in milliseconds.
  Duration get maxOperationRetryTime {
    return Duration(milliseconds: _delegate.maxOperationRetryTime);
  }

  /// The maximum time to retry uploads in milliseconds.
  Duration get maxUploadRetryTime {
    return Duration(milliseconds: _delegate.maxUploadRetryTime);
  }

  /// The maximum time to retry downloads in milliseconds.
  Duration get maxDownloadRetryTime {
    return Duration(milliseconds: _delegate.maxDownloadRetryTime);
  }

  static final Map<String, FirebaseStorage> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseStorage get instance {
    return FirebaseStorage.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp] and/or custom storage bucket.
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If [bucket] is not provided, the default storage bucket will be used.
  static FirebaseStorage instanceFor({
    FirebaseApp? app,
    String? bucket,
  }) {
    app ??= Firebase.app();

    if (bucket == null && app.options.storageBucket == null) {
      if (app.name == defaultFirebaseAppName) {
        _throwNoBucketError(
            'No default storage bucket could be found. Ensure you have correctly followed the Getting Started guide.');
      } else {
        _throwNoBucketError(
            "No storage bucket could be found for the app '${app.name}'. Ensure you have set the [storageBucket] on [FirebaseOptions] whilst initializing the secondary Firebase app.");
      }
    }

    String _bucket = bucket ?? app.options.storageBucket!;

    // Previous versions allow storage buckets starting with "gs://".
    // Since we need to create a key using the bucket, it must not include "gs://"
    // since native does not include it when requesting the bucket. This keeps
    // the code backwards compatible but also works with the refactor.
    if (_bucket.startsWith('gs://')) {
      _bucket = _bucket.replaceFirst('gs://', '');
    }

    String key = '${app.name}|$_bucket';
    if (_cachedInstances.containsKey(key)) {
      return _cachedInstances[key]!;
    }

    FirebaseStorage newInstance = FirebaseStorage._(app: app, bucket: _bucket);
    _cachedInstances[key] = newInstance;

    return newInstance;
  }

  /// Returns a new [Reference].
  ///
  /// If the [path] is empty, the reference will point to the root of the
  /// storage bucket.
  Reference ref([String? path]) {
    path ??= '/';
    return Reference._(this, _delegate.ref(path.isEmpty ? '/' : path));
  }

  /// Returns a new [Reference] from a given URL.
  ///
  /// The [url] can either be a HTTP or Google Storage URL pointing to an object.
  /// If the URL contains a storage bucket which is different to the current
  /// [FirebaseStorage.bucket], a new [FirebaseStorage] instance for the
  /// [Reference] will be used instead.
  Reference refFromURL(String url) {
    assert(url.startsWith('gs://') || url.startsWith('http'),
        "'a url must start with 'gs://' or 'https://'");

    String? bucket;
    String? path;

    if (url.startsWith('http')) {
      final parts = partsFromHttpUrl(url);

      assert(parts != null,
          "url could not be parsed, ensure it's a valid storage url");

      bucket = parts!['bucket'];
      path = parts['path'];
    } else {
      bucket = bucketFromGoogleStorageUrl(url);
      path = pathFromGoogleStorageUrl(url);
    }

    return FirebaseStorage.instanceFor(app: app, bucket: 'gs://$bucket')
        .ref(path);
  }

  /// Sets the new maximum operation retry time.
  void setMaxOperationRetryTime(Duration time) {
    assert(!time.isNegative);
    return _delegate.setMaxOperationRetryTime(time.inMilliseconds);
  }

  /// Sets the new maximum upload retry time.
  void setMaxUploadRetryTime(Duration time) {
    assert(!time.isNegative);
    return _delegate.setMaxUploadRetryTime(time.inMilliseconds);
  }

  /// Sets the new maximum download retry time.
  void setMaxDownloadRetryTime(Duration time) {
    assert(!time.isNegative);
    return _delegate.setMaxDownloadRetryTime(time.inMilliseconds);
  }

  /// Changes this instance to point to a Storage emulator running locally.
  ///
  /// Set the [host] (ex: localhost) and [port] (ex: 9199) of the local emulator.
  ///
  /// Note: Must be called immediately, prior to accessing storage methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  @Deprecated(
    'Will be removed in future release. '
    'Use useStorageEmulator().',
  )
  Future<void> useEmulator({required String host, required int port}) async {
    assert(host.isNotEmpty);
    assert(!port.isNegative);

    String mappedHost = host;
    // Android considers localhost as 10.0.2.2 - automatically handle this for users.
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      if (mappedHost == 'localhost' || mappedHost == '127.0.0.1') {
        // ignore: avoid_print
        print('Mapping Storage Emulator host "$mappedHost" to "10.0.2.2".');
        mappedHost = '10.0.2.2';
      }
    }

    await useStorageEmulator(host, port);
  }

  /// Changes this instance to point to a Storage emulator running locally.
  ///
  /// Set the [host] of the local emulator, such as "localhost"
  /// Set the [port] of the local emulator, such as "9199" (port 9199 is default for storage package)
  ///
  /// Note: Must be called immediately, prior to accessing storage methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  Future<void> useStorageEmulator(String host, int port) async {
    assert(host.isNotEmpty);
    assert(!port.isNegative);

    String mappedHost = host;

    // Android considers localhost as 10.0.2.2 - automatically handle this for users.
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      if (mappedHost == 'localhost' || mappedHost == '127.0.0.1') {
        // ignore: avoid_print
        print('Mapping Storage Emulator host "$mappedHost" to "10.0.2.2".');
        mappedHost = '10.0.2.2';
      }
    }

    await _delegate.useStorageEmulator(mappedHost, port);
  }

  @override
  bool operator ==(Object other) =>
      other is FirebaseStorage &&
      other.app.name == app.name &&
      other.bucket == bucket;

  @override
  int get hashCode => Object.hash(app.name, bucket);

  @override
  String toString() => '$FirebaseStorage(app: ${app.name}, bucket: $bucket)';
}

void _throwNoBucketError(String message) {
  throw FirebaseException(
      plugin: 'firebase_storage', code: 'no-bucket', message: message);
}
