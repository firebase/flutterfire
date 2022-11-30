// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_storage')
library firebase.storage_interop;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS()
external StorageJsImpl getStorage([AppJsImpl? app, String? bucketUrl]);

@JS()
external void connectStorageEmulator(
    StorageJsImpl storage, String host, int port,
    [EmulatorOptions? options]);

@JS()
external PromiseJsImpl<void> deleteObject(ReferenceJsImpl ref);

@JS()
external PromiseJsImpl<String> getDownloadURL(ReferenceJsImpl ref);

@JS()
external PromiseJsImpl<String> getBlob(ReferenceJsImpl ref,
    [int? maxDownloadSizeBytes]);

@JS()
external PromiseJsImpl<List<String>> getBytes(ReferenceJsImpl ref,
    [int? maxDownloadSizeBytes]);

@JS()
external PromiseJsImpl<FullMetadataJsImpl> getMetadata(ReferenceJsImpl ref);

@JS()
external PromiseJsImpl<ListResultJsImpl> list(ReferenceJsImpl ref,
    [ListOptionsJsImpl? listOptions]);

@JS()
external PromiseJsImpl<ListResultJsImpl> listAll(ReferenceJsImpl ref);

@JS()
/* if 2nd arg is `url`, first arg has to be StorageJsImpl */
/* if 2nd arg is `path`, first arg can be StorageJsImpl || ReferenceJsImpl */
external ReferenceJsImpl ref(Object storageOrRef, [String? urlOrPath]);

@JS()
external PromiseJsImpl<FullMetadataJsImpl> updateMetadata(
    ReferenceJsImpl ref, SettableMetadataJsImpl settableMetadata);

@JS()
external UploadTaskJsImpl uploadBytesResumable(
    ReferenceJsImpl ref, dynamic /* Blob | Uint8Array | ArrayBuffer */ data,
    [UploadMetadataJsImpl? metadata]);

@JS()
@anonymous
class EmulatorOptions {
  external factory EmulatorOptions({mockUserToken});
  external String get mockUserToken;
}

@JS('FirebaseStorage')
abstract class StorageJsImpl {
  external AppJsImpl get app;
  external set app(AppJsImpl a);
  external int get maxOperationRetryTime;
  external set maxOperationRetryTime(int t);
  external int get maxUploadRetryTime;
  external set maxUploadRetryTime(int t);
}

@JS('StorageReference')
abstract class ReferenceJsImpl {
  external String get bucket;
  external set bucket(String s);
  external String get fullPath;
  external set fullPath(String s);
  external String get name;
  external set name(String s);
  external ReferenceJsImpl get parent;
  external set parent(ReferenceJsImpl r);
  external ReferenceJsImpl get root;
  external set root(ReferenceJsImpl r);
  external StorageJsImpl get storage;
  external set storage(StorageJsImpl s);

  @override
  external String toString();
}

//@JS('FullMetadata')
@JS()
@anonymous
class FullMetadataJsImpl extends UploadMetadataJsImpl {
  external factory FullMetadataJsImpl(
      {String? md5Hash,
      String? cacheControl,
      String? contentDisposition,
      String? contentEncoding,
      String? contentLanguage,
      String? contentType,
      dynamic customMetadata});

  external String get bucket;
  // TODO - new API.
  external List<String>? get downloadTokens;
  // TODO - new API.
  external ReferenceJsImpl? get ref;
  external String? get fullPath;
  external String? get generation;
  external String? get metageneration;
  external String? get name;
  external int? get size;
  external String? get timeCreated;
  external String? get updated;
}

@JS()
@anonymous
class UploadMetadataJsImpl extends SettableMetadataJsImpl {
  external factory UploadMetadataJsImpl(
      {String? md5Hash,
      String? cacheControl,
      String? contentDisposition,
      String? contentEncoding,
      String? contentLanguage,
      String? contentType,
      dynamic customMetadata});

  external String get md5Hash;
  external set md5Hash(String s);
}

@JS('UploadTask')
abstract class UploadTaskJsImpl
    implements PromiseJsImpl<UploadTaskSnapshotJsImpl> {
  external UploadTaskSnapshotJsImpl get snapshot;
  external set snapshot(UploadTaskSnapshotJsImpl t);
  external bool cancel();
  external Func0 on(String event,
      [dynamic nextOrObserver, Func1? error, Func0? complete]);
  external bool pause();
  external bool resume();
  @override
  external PromiseJsImpl<void> then([Func1? onResolve, Func1? onReject]);
}

@JS()
@anonymous
abstract class UploadTaskSnapshotJsImpl {
  external int get bytesTransferred;
  external FullMetadataJsImpl get metadata;
  external ReferenceJsImpl get ref;
  external String get state;
  external UploadTaskJsImpl get task;
  external int get totalBytes;
}

@JS()
@anonymous
class SettableMetadataJsImpl {
  external factory SettableMetadataJsImpl(
      {String? cacheControl,
      String? contentDisposition,
      String? contentEncoding,
      String? contentLanguage,
      String? contentType,
      dynamic customMetadata});

  external String get cacheControl;
  external set cacheControl(String s);
  external String get contentDisposition;
  external set contentDisposition(String s);
  external String get contentEncoding;
  external set contentEncoding(String s);
  external String get contentLanguage;
  external set contentLanguage(String s);
  external String get contentType;
  external set contentType(String s);
  external dynamic get customMetadata;
  external set customMetadata(dynamic s);
}

@JS()
@anonymous
class ListOptionsJsImpl {
  external factory ListOptionsJsImpl({int? maxResults, String? pageToken});

  external set maxResults(int s);
  external int get maxResults;
  external set pageToken(String s);
  external String get pageToken;
}

@JS()
@anonymous
class ListResultJsImpl {
  external List<ReferenceJsImpl> get items;
  external String get nextPageToken;
  external List<ReferenceJsImpl> get prefixes;
}

// ignore: avoid_classes_with_only_static_members
/// An enumeration of the possible string formats for upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage#.StringFormat>
@JS()
class StringFormat {
  /// Indicates the string should be interpreted 'raw', that is, as normal text.
  /// The string will be interpreted as UTF-16, then uploaded as a UTF-8 byte
  /// sequence.
  external static String get RAW;

  /// Indicates the string should be interpreted as base64-encoded data.
  /// Padding characters (trailing '='s) are optional.
  external static String get BASE64;

  /// Indicates the string should be interpreted as base64url-encoded data.
  /// Padding characters (trailing '='s) are optional.
  external static String get BASE64URL;

  /// Indicates the string is a data URL, such as one obtained from
  /// [:canvas.toDataURL():].
  external static String get DATA_URL;
}

external String get TaskEvent;
