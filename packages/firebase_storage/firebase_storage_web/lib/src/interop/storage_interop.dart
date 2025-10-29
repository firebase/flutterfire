// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_storage')
library firebase.storage_interop;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external StorageJsImpl getStorage([AppJsImpl? app, JSString? bucketUrl]);

@JS()
@staticInterop
external void connectStorageEmulator(
    StorageJsImpl storage, JSString host, JSNumber port,
    [EmulatorOptions? options]);

@JS()
@staticInterop
external JSPromise /* void */ deleteObject(ReferenceJsImpl ref);

@JS()
@staticInterop
external JSPromise<JSString> getBlob(ReferenceJsImpl ref,
    [JSNumber? maxDownloadSizeBytes]);

@JS()
@staticInterop
external JSPromise<JSArray<JSString>> getBytes(ReferenceJsImpl ref,
    [JSNumber? maxDownloadSizeBytes]);

@JS()
@staticInterop
external JSPromise<JSString> getDownloadURL(ReferenceJsImpl ref);

@JS()
@staticInterop
external JSPromise<FullMetadataJsImpl> getMetadata(ReferenceJsImpl ref);

@JS()
@staticInterop
external JSPromise<ListResultJsImpl> list(ReferenceJsImpl ref,
    [ListOptionsJsImpl? listOptions]);

@JS()
@staticInterop
external JSPromise<ListResultJsImpl> listAll(ReferenceJsImpl ref);

@JS()
@staticInterop
/* if 2nd arg is `url`, first arg has to be StorageJsImpl */
/* if 2nd arg is `path`, first arg can be StorageJsImpl || ReferenceJsImpl */
external ReferenceJsImpl ref(JSAny storageOrRef, [JSString? urlOrPath]);

@JS()
@staticInterop
external JSPromise<FullMetadataJsImpl> updateMetadata(
    ReferenceJsImpl ref, SettableMetadataJsImpl settableMetadata);

@JS()
@staticInterop
external UploadTaskJsImpl uploadBytesResumable(
    ReferenceJsImpl ref, JSAny /* Blob | Uint8Array | ArrayBuffer */ data,
    [UploadMetadataJsImpl? metadata]);

@JS()
@staticInterop
@anonymous
class EmulatorOptions {
  external factory EmulatorOptions({JSString? mockUserToken});
}

extension EmulatorOptionsJsImplX on EmulatorOptions {
  external JSString? get mockUserToken;
}

extension type StorageJsImpl._(JSObject _) implements JSObject {
  external AppJsImpl get app;
  external set app(AppJsImpl a);
  external JSNumber get maxOperationRetryTime;
  external set maxOperationRetryTime(JSNumber t);
  external JSNumber get maxUploadRetryTime;
  external set maxUploadRetryTime(JSNumber t);
}

extension type ReferenceJsImpl._(JSObject _) implements JSObject {
  external JSString get bucket;
  external set bucket(JSString s);
  external JSString get fullPath;
  external set fullPath(JSString s);
  external JSString get name;
  external set name(JSString s);
  external ReferenceJsImpl? get parent;
  external set parent(ReferenceJsImpl? r);
  external ReferenceJsImpl get root;
  external set root(ReferenceJsImpl r);
  external StorageJsImpl get storage;
  external set storage(StorageJsImpl s);
}

@JS('FullMetadata')
extension type FullMetadataJsImpl._(JSObject _)
    implements UploadMetadataJsImpl, JSObject {
  external factory FullMetadataJsImpl({
    JSString bucket,
    JSArray? downloadTokens,
    ReferenceJsImpl? ref,
    JSString? fullPath,
    JSString? generation,
    JSString? metageneration,
    JSString? name,
    JSNumber? size,
    JSString? timeCreated,
    JSString? updated,
    JSString? md5Hash,
    JSString? cacheControl,
    JSString? contentDisposition,
    JSString? contentEncoding,
    JSString? contentLanguage,
    JSString? contentType,
    JSAny? customMetadata,
  });

  external JSString get bucket;
  // TODO - new API.
  external JSArray? get downloadTokens;
  // TODO - new API.
  external ReferenceJsImpl? get ref;
  external JSString? get fullPath;
  external JSString? get generation;
  external JSString? get metageneration;
  external JSString? get name;
  external JSNumber? get size;
  external JSString? get timeCreated;
  external JSString? get updated;
}

@JS('UploadMetadata')
extension type UploadMetadataJsImpl._(JSObject _)
    implements SettableMetadataJsImpl, JSObject {
  external factory UploadMetadataJsImpl(
      {JSString? md5Hash,
      JSString? cacheControl,
      JSString? contentDisposition,
      JSString? contentEncoding,
      JSString? contentLanguage,
      JSString? contentType,
      JSAny? customMetadata});

  external JSString? get md5Hash;
  external set md5Hash(JSString? s);
}

extension type UploadTaskJsImpl._(JSObject _) implements JSObject {
  external UploadTaskSnapshotJsImpl get snapshot;
  external set snapshot(UploadTaskSnapshotJsImpl t);
  external JSBoolean cancel();
  external JSFunction on(JSString event,
      [JSAny nextOrObserver, JSFunction? error, JSFunction? complete]);
  external JSBoolean pause();
  external JSBoolean resume();
  external JSPromise /* void */ then(
      [JSFunction? onResolve, JSFunction? onReject]);
}

extension type UploadTaskSnapshotJsImpl._(JSObject _) implements JSObject {
  external JSNumber get bytesTransferred;
  external FullMetadataJsImpl get metadata;
  external ReferenceJsImpl get ref;
  external JSString get state;
  external UploadTaskJsImpl get task;
  external JSNumber get totalBytes;
}

@JS('SettableMetadata')
extension type SettableMetadataJsImpl._(JSObject _) implements JSObject {
  external factory SettableMetadataJsImpl(
      {JSString? cacheControl,
      JSString? contentDisposition,
      JSString? contentEncoding,
      JSString? contentLanguage,
      JSString? contentType,
      JSAny? customMetadata});

  external JSString? get cacheControl;
  external set cacheControl(JSString? s);
  external JSString? get contentDisposition;
  external set contentDisposition(JSString? s);
  external JSString? get contentEncoding;
  external set contentEncoding(JSString? s);
  external JSString? get contentLanguage;
  external set contentLanguage(JSString? s);
  external JSString? get contentType;
  external set contentType(JSString? s);
  external JSAny? get customMetadata;
  external set customMetadata(JSAny? s);
}

@JS('ListOptions')
@staticInterop
@anonymous
class ListOptionsJsImpl {
  external factory ListOptionsJsImpl({int? maxResults, JSString? pageToken});
}

extension ListOptionsJsImplX on ListOptionsJsImpl {
  external set maxResults(JSNumber? s);
  external JSNumber? get maxResults;
  external set pageToken(JSString? s);
  external JSString? get pageToken;
}

extension type ListResultJsImpl._(JSObject _) implements JSObject {
  external JSArray /* ReferenceJsImpl */ get items;
  external JSString? get nextPageToken;
  external JSArray /* ReferenceJsImpl */ get prefixes;
}

// ignore: avoid_classes_with_only_static_members
/// An enumeration of the possible string formats for upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage#stringformat>
@JS()
@staticInterop
class StringFormat {
  /// Indicates the string should be interpreted 'raw', that is, as normal text.
  /// The string will be interpreted as UTF-16, then uploaded as a UTF-8 byte
  /// sequence.
  external static JSString get RAW;

  /// Indicates the string should be interpreted as base64-encoded data.
  /// Padding characters (trailing '='s) are optional.
  external static JSString get BASE64;

  /// Indicates the string should be interpreted as base64url-encoded data.
  /// Padding characters (trailing '='s) are optional.
  external static JSString get BASE64URL;

  /// Indicates the string is a data URL, such as one obtained from
  /// [:canvas.toDataURL():].
  external static JSString get DATA_URL;
}

@JS()
external JSString get TaskEvent;
