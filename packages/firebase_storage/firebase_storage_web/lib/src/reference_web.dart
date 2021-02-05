// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import './firebase_storage_web.dart';
import './utils/errors.dart';
import './utils/metadata.dart';
import 'interop/storage.dart' as storage_interop;
import 'task_web.dart';
import 'utils/list.dart';
import 'utils/metadata_cache.dart';

final _storageUrlPrefix = RegExp(r'^(?:gs|https?):\//');

/// The web implementation of a Firebase Storage 'ref'
class ReferenceWeb extends ReferencePlatform {
  /// Constructor for this ref
  @override
  ReferenceWeb(FirebaseStorageWeb storage, String path)
      : _path = path,
        super(storage, path) {
    if (_path.startsWith(_storageUrlPrefix)) {
      _ref = storage.webStorage!.refFromURL(_path);
    } else {
      _ref = storage.webStorage!.ref(_path);
    }
  }

  // The js-interop layer for the ref that is wrapped by this class...
  late storage_interop.StorageReference _ref;

  // Remember what metadata has already been set on this ref.
  // TODO: Should this be initialized with the metadata currently in firebase?
  final SettableMetadataCache _cache = SettableMetadataCache();

  // The path for the current ref
  final String _path;

  // Platform overrides follow

  /// Deletes the object at this reference's location.
  @override
  Future<void> delete() async {
    try {
      await _ref.delete();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  /// Fetches a long lived download URL for this object.
  @override
  Future<String> getDownloadURL() async {
    try {
      Uri uri = await _ref.getDownloadURL();
      return uri.toString();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  /// Fetches metadata for the object at this location, if one exists.
  @override
  Future<FullMetadata> getMetadata() async {
    try {
      storage_interop.FullMetadata fullMetadata = await _ref.getMetadata();
      return fbFullMetadataToFullMetadata(fullMetadata);
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

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
  @override
  Future<ListResultPlatform> list([ListOptions? options]) async {
    try {
      storage_interop.ListResult listResult =
          await _ref.list(listOptionsToFbListOptions(options));
      return fbListResultToListResultWeb(storage, listResult);
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  ///List all items (files) and prefixes (folders) under this storage reference.
  ///
  /// This is a helper method for calling [list] repeatedly until there are no
  /// more results. The default pagination size is 1000.
  ///
  /// Note: The results may not be consistent if objects are changed while this
  /// operation is running.
  ///
  /// Warning: [listAll] may potentially consume too many resources if there are
  /// too many results.
  @override
  Future<ListResultPlatform> listAll() async {
    try {
      storage_interop.ListResult listResult = await _ref.listAll();
      return fbListResultToListResultWeb(storage, listResult);
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  /// Asynchronously downloads the object at the StorageReference to a list in memory.
  ///
  /// Returns a [Uint8List] of the data. If the [maxSize] (in bytes) is exceeded,
  /// the operation will be canceled.
  @override
  Future<Uint8List?> getData(
    int maxSize, {
    @visibleForTesting
        Future<Uint8List> Function(Uri url) readBytes = http.readBytes,
  }) async {
    if (maxSize > 0) {
      final metadata = await getMetadata();
      if (metadata.size! > maxSize) {
        return null;
      }
    }

    try {
      String url = await getDownloadURL();
      return await readBytes(Uri.parse(url));
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  /// Uploads data to this reference's location.
  ///
  /// Use this method to upload fixed sized data as a [Uint8List].
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  @override
  TaskPlatform putData(Uint8List data, [SettableMetadata? metadata]) {
    return TaskWeb(
      this,
      _ref.put(
        data,
        settableMetadataToFbUploadMetadata(
          _cache.store(metadata),
        ),
      ),
    );
  }

  /// Upload a [html.Blob]. Note; this is only supported on web platforms.
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  @override
  TaskPlatform putBlob(dynamic data, [SettableMetadata? metadata]) {
    assert(data is html.Blob, 'data must be a dart:html Blob object.');

    return TaskWeb(
      this,
      _ref.put(
        data,
        settableMetadataToFbUploadMetadata(
          _cache.store(metadata),
          // md5 is computed server-side, so we don't have to unpack a potentially huge Blob.
        ),
      ),
    );
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
  @override
  TaskPlatform putString(
    String data,
    PutStringFormat format, [
    SettableMetadata? metadata,
  ]) {
    return TaskWeb(
      this,
      _ref.putString(
        data,
        putStringFormatToString(format),
        settableMetadataToFbUploadMetadata(
          _cache.store(metadata),
        ),
      ),
    );
  }

  /// Updates the metadata on a storage object.
  @override
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) async {
    try {
      storage_interop.FullMetadata fullMetadata = await _ref.updateMetadata(
          settableMetadataToFbSettableMetadata(_cache.store(metadata)));
      return fbFullMetadataToFullMetadata(fullMetadata);
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  // Purposefully left unimplemented because of lack of dart:io support in web:

  // TaskPlatform writeToFile(File file) {}
  // TaskPlatform putFile(File file, [SettableMetadata metadata]) {}
}
