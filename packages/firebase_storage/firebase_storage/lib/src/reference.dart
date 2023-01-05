// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// Represents a reference to a Google Cloud Storage object. Developers can
/// upload, download, and delete objects, as well as get/set object metadata.
class Reference {
  Reference._(this.storage, this._delegate) {
    ReferencePlatform.verify(_delegate);
  }

  ReferencePlatform _delegate;

  /// The storage service associated with this reference.
  final FirebaseStorage storage;

  /// The name of the bucket containing this reference's object.
  String get bucket => _delegate.bucket;

  /// The full path of this object.
  String get fullPath => _delegate.fullPath;

  /// The short name of this object, which is the last component of the full path.
  ///
  /// For example, if fullPath is 'full/path/image.png', name is 'image.png'.
  String get name => _delegate.name;

  /// A reference pointing to the parent location of this reference, or `null`
  /// if this reference is the root.
  Reference? get parent {
    ReferencePlatform? referenceParentPlatform = _delegate.parent;

    if (referenceParentPlatform == null) {
      return null;
    }

    return Reference._(storage, referenceParentPlatform);
  }

  /// A reference to the root of this reference's bucket.
  Reference get root => Reference._(storage, _delegate.root);

  /// Returns a reference to a relative path from this reference.
  ///
  /// [path] The relative path from this reference. Leading, trailing, and
  ///   consecutive slashes are removed.
  Reference child(String path) {
    return Reference._(storage, _delegate.child(path));
  }

  /// Deletes the object at this reference's location.
  Future<void> delete() => _delegate.delete();

  /// Fetches a long lived download URL for this object.
  Future<String> getDownloadURL() => _delegate.getDownloadURL();

  /// Fetches metadata for the object at this location, if one exists.
  Future<FullMetadata> getMetadata() => _delegate.getMetadata();

  /// List items (files) and prefixes (folders) under this storage reference.
  ///
  /// List API is only available for Firebase Rules Version 2.
  ///
  /// GCS is a key-blob store. Firebase Storage imposes the semantic of '/'
  /// delimited folder structure. Refer to GCS's List API if you want to learn more.
  ///
  /// To adhere to Firebase Rules's Semantics, Firebase Storage does not support
  /// objects whose paths end with "/" or contain two consecutive "/"s. Firebase
  /// Storage List API will filter these unsupported objects. [list] may fail
  /// if there are too many unsupported objects in the bucket.
  Future<ListResult> list([ListOptions? options]) async {
    assert(options == null ||
        options.maxResults == null ||
        options.maxResults! > 0 && options.maxResults! <= 1000);
    return ListResult._(storage, await _delegate.list(options));
  }

  /// List all items (files) and prefixes (folders) under this storage reference.
  ///
  /// This is a helper method for calling [list] repeatedly until there are no
  /// more results. The default pagination size is 1000.
  ///
  /// Note: The results may not be consistent if objects are changed while this
  /// operation is running.
  ///
  /// Warning: [listAll] may potentially consume too many resources if there are
  /// too many results.
  Future<ListResult> listAll() async {
    return ListResult._(storage, await _delegate.listAll());
  }

  /// Asynchronously downloads the object at the StorageReference to a list in memory.
  ///
  /// Returns a [Uint8List] of the data.
  ///
  /// If the [maxSize] (in bytes) is exceeded, the operation will be canceled. By
  /// default the [maxSize] is 10mb (10485760 bytes).
  Future<Uint8List?> getData([int maxSize = 10485760]) async {
    assert(maxSize > 0);
    return _delegate.getData(maxSize);
  }

  /// Uploads data to this reference's location.
  ///
  /// Use this method to upload fixed sized data as a [Uint8List].
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    return UploadTask._(storage, _delegate.putData(data, metadata));
  }

  /// Upload a [Blob]. Note; this is only supported on web platforms.
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  UploadTask putBlob(dynamic blob, [SettableMetadata? metadata]) {
    assert(blob != null);
    return UploadTask._(storage, _delegate.putBlob(blob, metadata));
  }

  /// Upload a [File] from the filesystem. The file must exist.
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    assert(file.absolute.existsSync());
    return UploadTask._(storage, _delegate.putFile(file, metadata));
  }

  /// Upload a [String] value as a storage object.
  ///
  /// Use [PutStringFormat] to correctly encode the string:
  ///   - [PutStringFormat.raw] the string will be encoded in a Base64 format.
  ///   - [PutStringFormat.dataUrl] the string must be in a data url format
  ///     (e.g. "data:text/plain;base64,SGVsbG8sIFdvcmxkIQ=="). If no
  ///     [SettableMetadata.mimeType] is provided as part of the [metadata]
  ///     argument, the [mimeType] will be automatically set.
  ///   - [PutStringFormat.base64] will be encoded as a Base64 string.
  ///   - [PutStringFormat.base64Url] will be encoded as a Base64 string safe URL.
  UploadTask putString(
    String data, {
    PutStringFormat format = PutStringFormat.raw,
    SettableMetadata? metadata,
  }) {
    String _data = data;
    PutStringFormat _format = format;
    SettableMetadata? _metadata = metadata;

    // Convert any raw string values into a Base64 format
    if (format == PutStringFormat.raw) {
      _data = base64.encode(utf8.encode(_data));
      _format = PutStringFormat.base64;
    }

    // Convert a data_url into a Base64 format
    if (format == PutStringFormat.dataUrl) {
      _format = PutStringFormat.base64;
      UriData uri = UriData.fromUri(Uri.parse(data));
      assert(uri.isBase64);
      _data = uri.contentText;

      if (_metadata == null && uri.mimeType.isNotEmpty) {
        _metadata = SettableMetadata(
          contentType: uri.mimeType,
        );
      }

      // If the data_url contains a mime-type & the user has not provided it,
      // set it
      if ((_metadata!.contentType == null || _metadata.contentType!.isEmpty) &&
          uri.mimeType.isNotEmpty) {
        _metadata = SettableMetadata(
          cacheControl: metadata!.cacheControl,
          contentDisposition: metadata.contentDisposition,
          contentEncoding: metadata.contentEncoding,
          contentLanguage: metadata.contentLanguage,
          contentType: uri.mimeType,
        );
      }
    }
    return UploadTask._(
        storage, _delegate.putString(_data, _format, _metadata));
  }

  /// Updates the metadata on a storage object.
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) {
    return _delegate.updateMetadata(metadata);
  }

  /// Writes a remote storage object to the local filesystem.
  ///
  /// If a file already exists at the given location, it will be overwritten.
  DownloadTask writeToFile(File file) {
    return DownloadTask._(storage, _delegate.writeToFile(file));
  }

  @override
  bool operator ==(Object other) =>
      other is Reference &&
      other.fullPath == fullPath &&
      other.storage == storage;

  @override
  int get hashCode => Object.hash(storage, fullPath);

  @override
  String toString() =>
      '$Reference(app: ${storage.app.name}, fullPath: $fullPath)';
}
