// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_storage;

/// The entrypoint for [FirebaseStorage].
class FirebaseStorage extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [FirebaseStoragePlatform] to avoid
  // creating a [MethodChannelStorage] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseStoragePlatform _delegatePackingProperty;

  FirebaseStoragePlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty = FirebaseStoragePlatform.instanceFor(
        app: app,
        bucket: bucket,
      );
    }
    return _delegatePackingProperty;
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

  FirebaseStorage._({this.app, this.bucket})
      : super(app.name, 'plugins.flutter.io/firebase_storage');

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
    FirebaseApp app,
    String bucket,
  }) {
    app ??= Firebase.app();
    assert(app != null);

    bucket ??= app.options.storageBucket;

    // A bucket must exist at this point
    if (bucket == null) {
      if (app.name == defaultFirebaseAppName) {
        _throwNoBucketError(
            "No default storage bucket could be found. Ensure you have correctly followed the Getting Started guide.");
      } else {
        _throwNoBucketError(
            "No storage bucket could be found for the app '${app.name}'. Ensure you have set the [storageBucket] on [FirebaseOptions] whilst initializing the secondary Firebase app.");
      }
    }

    // Previous versions allow storage buckets starting with "gs://".
    // Since we need to create a key using the bucket, it must not include "gs://"
    // since native does not include it when requesting the bucket. This keeps
    // the code backwards compatible but also works with the refactor.
    if (bucket.startsWith('gs://')) {
      bucket = bucket.replaceFirst('gs://', '');
    }

    String key = '${app.name}|${bucket}';
    if (_cachedInstances.containsKey(key)) {
      return _cachedInstances[key];
    }

    FirebaseStorage newInstance = FirebaseStorage._(app: app, bucket: bucket);
    _cachedInstances[key] = newInstance;

    return newInstance;
  }

  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing Storage is deprecated, use 'FirebaseStorage.instance' or 'FirebaseStorage.instanceFor' instead")
  factory FirebaseStorage({FirebaseApp app, String storageBucket}) {
    return FirebaseStorage.instanceFor(app: app, bucket: storageBucket);
  }

  /// Returns a new [Reference].
  ///
  /// If the [path] is empty, the reference will point to the root of the
  /// storage bucket.
  Reference ref([String path]) {
    path ??= '/';
    path = path.isEmpty ? '/' : path;
    return Reference._(this, _delegate.ref(path));
  }

  /// Returns a new [Reference] from a given URL.
  ///
  /// The [url] can either be a HTTP or Google Storage URL pointing to an object.
  /// If the URL contains a storage bucket which is different to the current
  /// [FirebaseStorage.bucket], a new [FirebaseStorage] instance for the
  /// [Reference] will be used instead.
  Reference refFromURL(String url) {
    assert(url != null);
    assert(url.startsWith('gs://') || url.startsWith('http'),
        "'a url must start with 'gs://' or 'https://'");

    String bucket;
    String path;

    if (url.startsWith('http')) {
      final parts = partsFromHttpUrl(url);

      assert(parts != null,
          "url could not be parsed, ensure it's a valid storage url");

      bucket = parts['bucket'];
      path = parts['path'];
    } else {
      bucket = bucketFromGoogleStorageUrl(url);
      path = pathFromGoogleStorageUrl(url);
    }

    return FirebaseStorage.instanceFor(app: app, bucket: 'gs://$bucket')
        .ref(path);
  }

  @Deprecated("Deprecated in favor of refFromURL")
  // ignore: public_member_api_docs
  Future<Reference> getReferenceFromUrl(String url) async {
    return refFromURL(url);
  }

  @Deprecated("Deprecated in favor of get.maxOperationRetryTime")
  // ignore: public_member_api_docs
  Future<int> getMaxOperationRetryTimeMillis() async {
    return maxOperationRetryTime.inMilliseconds;
  }

  @Deprecated("Deprecated in favor of get.maxUploadRetryTime")
  // ignore: public_member_api_docs
  Future<int> getMaxUploadRetryTimeMillis() async {
    return maxUploadRetryTime.inMilliseconds;
  }

  @Deprecated("Deprecated in favor of get.maxDownloadRetryTime")
  // ignore: public_member_api_docs
  Future<int> getMaxDownloadRetryTimeMillis() async {
    return maxDownloadRetryTime.inMilliseconds;
  }

  /// Sets the new maximum operation retry time.
  void setMaxOperationRetryTime(Duration time) {
    assert(time != null);
    assert(!time.isNegative);
    return _delegate.setMaxOperationRetryTime(time.inMilliseconds);
  }

  /// Sets the new maximum operation retry time in milliseconds.
  @Deprecated("Deprecated in favor of setMaxUploadRetryTime()")
  Future<void> setMaxOperationRetryTimeMillis(int time) async {
    return setMaxOperationRetryTime(Duration(milliseconds: time));
  }

  /// Sets the new maximum upload retry time.
  void setMaxUploadRetryTime(Duration time) {
    assert(time != null);
    assert(!time.isNegative);
    return _delegate.setMaxUploadRetryTime(time.inMilliseconds);
  }

  /// Sets the new maximum upload retry time in milliseconds.
  @Deprecated("Deprecated in favor of setMaxUploadRetryTime()")
  Future<void> setMaxUploadRetryTimeMillis(int time) async {
    return setMaxUploadRetryTime(Duration(milliseconds: time));
  }

  /// Sets the new maximum download retry time.
  void setMaxDownloadRetryTime(Duration time) {
    assert(time != null);
    assert(!time.isNegative);
    return _delegate.setMaxDownloadRetryTime(time.inMilliseconds);
  }

  /// Sets the new maximum download retry time in milliseconds.
  @Deprecated("Deprecated in favor of setMaxDownloadRetryTime()")
  Future<void> setMaxDownloadRetryTimeMillis(int time) async {
    return setMaxDownloadRetryTime(Duration(milliseconds: time));
  }

  @override
  bool operator ==(dynamic o) =>
      o is FirebaseStorage && o.app.name == app.name && o.bucket == bucket;

  @override
  int get hashCode => hash2(app.name, bucket);

  @override
  String toString() => '$FirebaseStorage(app: ${app.name}, bucket: $bucket)';
}

_throwNoBucketError(String message) {
  throw FirebaseException(
      plugin: "firebase_storage", code: "no-bucket", message: message);
}
