// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase.storage')
library firebase.storage_interop;

import 'package:js/js.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS('Storage')
abstract class StorageJsImpl {
  external AppJsImpl get app;
  external set app(AppJsImpl a);
  external int get maxOperationRetryTime;
  external set maxOperationRetryTime(int t);
  external int get maxUploadRetryTime;
  external set maxUploadRetryTime(int t);
  external ReferenceJsImpl ref([String? path]);
  external ReferenceJsImpl refFromURL(String url);
  external void setMaxOperationRetryTime(int time);
  external void setMaxUploadRetryTime(int time);
}

@JS('Reference')
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
  external ReferenceJsImpl child(String path);
  external PromiseJsImpl<void> delete();
  external PromiseJsImpl<String> getDownloadURL();
  external PromiseJsImpl<FullMetadataJsImpl> getMetadata();
  external PromiseJsImpl<ListResultJsImpl> list([ListOptionsJsImpl? options]);
  external PromiseJsImpl<ListResultJsImpl> listAll();
  external UploadTaskJsImpl put(dynamic blob, [UploadMetadataJsImpl? metadata]);
  external UploadTaskJsImpl putString(String value,
      [String? format, UploadMetadataJsImpl? metadata]);
  @override
  external String toString();
  external PromiseJsImpl<FullMetadataJsImpl> updateMetadata(
      SettableMetadataJsImpl metadata);
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

// ignore: avoid_classes_with_only_static_members
/// An event that is triggered on a task.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage#.TaskEvent>.
@JS()
abstract class TaskEvent {
  external static String get STATE_CHANGED;
}
