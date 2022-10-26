// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_storage_platform_interface.dart';
import '../internal/pointer.dart';

/// The interface a reference must implement.
abstract class ReferencePlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  ReferencePlatform(this.storage, String path)
      : _pointer = Pointer(path),
        super(token: _token);

  Pointer _pointer;

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [ReferencePlatform].
  ///
  /// This is used by the app-facing [Reference] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(ReferencePlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The storage service associated with this reference.
  final FirebaseStoragePlatform storage;

  /// The name of the bucket containing this reference's object.
  String get bucket {
    return storage.bucket;
  }

  /// The full path of this object.
  String get fullPath => _pointer.path;

  /// The short name of this object, which is the last component of the full path.
  ///
  /// For example, if fullPath is 'full/path/image.png', name is 'image.png'.
  String get name => _pointer.name;

  /// A reference pointing to the parent location of this reference, or `null`
  /// if this reference is the root.
  ReferencePlatform? get parent {
    String? parentPath = _pointer.parent;

    if (parentPath == null) {
      return null;
    }

    return storage.ref(parentPath);
  }

  /// A reference to the root of this reference's bucket.
  ReferencePlatform get root {
    return storage.ref('/');
  }

  /// Returns a reference to a relative path from this reference.
  ///
  /// [path] The relative path from this reference. Leading, trailing, and
  ///   consecutive slashes are removed.
  ReferencePlatform child(String path) {
    return storage.ref(_pointer.child(path));
  }

  /// Deletes the object at this reference's location.
  Future<void> delete() {
    throw UnimplementedError('delete() is not implemented');
  }

  /// Fetches a long lived download URL for this object.
  Future<String> getDownloadURL() {
    throw UnimplementedError('getDownloadURL() is not implemented');
  }

  /// Fetches metadata for the object at this location, if one exists.
  Future<FullMetadata> getMetadata() {
    throw UnimplementedError('getMetadata() is not implemented');
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
  Future<ListResultPlatform> list([ListOptions? options]) {
    throw UnimplementedError('list() is not implemented');
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
  Future<ListResultPlatform> listAll() {
    throw UnimplementedError('listAll() is not implemented');
  }

  /// Asynchronously downloads the object at the StorageReference to a list in memory.
  ///
  /// Returns a [Uint8List] of the data. If the [maxSize] (in bytes) is exceeded,
  /// the operation will be canceled.
  Future<Uint8List?> getData(int maxSize) async {
    throw UnimplementedError('getData() is not implemented');
  }

  /// Uploads data to this reference's location.
  ///
  /// Use this method to upload fixed sized data as a [Uint8List].
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  TaskPlatform putData(Uint8List data, [SettableMetadata? metadata]) {
    throw UnimplementedError('putData() is not implemented');
  }

  /// Upload a [Blob]. Note; this is only supported on web platforms.
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  TaskPlatform putBlob(dynamic data, [SettableMetadata? metadata]) {
    throw UnimplementedError('putBlob() is not implemented');
  }

  /// Upload a [File] from the filesystem. The file must exist.
  ///
  /// Optionally, you can also set metadata onto the uploaded object.
  TaskPlatform putFile(File file, [SettableMetadata? metadata]) {
    throw UnimplementedError('putFile() is not implemented');
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
  TaskPlatform putString(String data, PutStringFormat format,
      [SettableMetadata? metadata]) {
    throw UnimplementedError('putString() is not implemented');
  }

  /// Updates the metadata on a storage object.
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) {
    throw UnimplementedError('updateMetadata() is not implemented');
  }

  /// Writes a remote storage object to the local filesystem.
  ///
  /// If a file already exists at the given location, it will be overwritten.
  TaskPlatform writeToFile(File file) {
    throw UnimplementedError('writeToFile() is not implemented');
  }
}
