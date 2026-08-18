// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:flutter/foundation.dart';

import 'storage_interop.dart' as storage_interop;

export 'storage_interop.dart';

/// Represents the current state of a running upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage#.TaskState>.
// ignore: constant_identifier_names
enum TaskState { RUNNING, PAUSED, SUCCESS, CANCELED, ERROR }

/// Given an AppJSImp, return the Storage instance.
Storage getStorageInstance([App? app, String? bucket]) {
  core_interop.App appImpl =
      app != null ? core_interop.app(app.name) : core_interop.app();

  return Storage.getInstance(bucket != null
      ? storage_interop.getStorage(appImpl.jsObject, bucket.toJS)
      : storage_interop.getStorage(appImpl.jsObject));
}

/// A service for uploading and downloading large objects to and from the
/// Google Cloud Storage.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.Storage>
class Storage extends JsObjectWrapper<storage_interop.StorageJsImpl> {
  Storage._fromJsObject(storage_interop.StorageJsImpl jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<Storage>();

  /// App for this instance of storage service.
  App get app => App.getInstance(jsObject.app);

  /// Returns the maximum time to retry operations other than uploads
  /// or downloads (in milliseconds).
  int get maxOperationRetryTime => jsObject.maxOperationRetryTime.toDartInt;

  /// Returns the maximum time to retry uploads (in milliseconds).
  int get maxUploadRetryTime => jsObject.maxUploadRetryTime.toDartInt;

  /// Creates a new Storage from a [jsObject].
  static Storage getInstance(storage_interop.StorageJsImpl jsObject) {
    return _expando[jsObject] ??= Storage._fromJsObject(jsObject);
  }

  /// Returns a [StorageReference] for the given [path] in the default bucket.
  StorageReference ref([String? path]) => StorageReference.getInstance(
      storage_interop.ref(jsObject as JSAny, path?.toJS));

  /// Returns a [StorageReference] for the given absolute [url].
  StorageReference refFromURL(String url) => StorageReference.getInstance(
      storage_interop.ref(jsObject as JSAny, url.toJS));

  /// Sets the maximum operation retry time to a value of [time].
  set maxOperationRetryTime(int time) {
    jsObject.maxOperationRetryTime = time.toJS;
  }

  /// Sets the maximum upload retry time to a value of [time].
  set maxUploadRetryTime(int time) {
    jsObject.maxUploadRetryTime = time.toJS;
  }

  /// Configures the Storage instance to work with a local emulator.
  ///
  /// Note: must be called before using storage methods, do not use
  /// with production credentials as local connections are unencrypted
  void useStorageEmulator(String host, int port) =>
      storage_interop.connectStorageEmulator(jsObject, host.toJS, port.toJS);
}

/// StorageReference is a reference to a Google Cloud Storage object.
/// It is possible to upload, download, and delete objects, as well as
/// get or set the object metadata.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.Reference>
class StorageReference
    extends JsObjectWrapper<storage_interop.ReferenceJsImpl> {
  StorageReference._fromJsObject(storage_interop.ReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<StorageReference>();

  /// The name of the bucket.
  String get bucket => jsObject.bucket.toDart;

  /// The full path.
  String get fullPath => jsObject.fullPath.toDart;

  /// The short name. Which is the last component of the full path.
  String get name => jsObject.name.toDart;

  /// The reference to the parent location of this reference.
  /// It is `null` in case of root StorageReference.
  StorageReference? get parent => jsObject.parent != null
      ? StorageReference.getInstance(jsObject.parent!)
      : null;

  /// The reference to the root of this storage reference's bucket.
  StorageReference get root => StorageReference.getInstance(jsObject.root);

  /// The [Storage] service associated with this reference.
  Storage get storage => Storage.getInstance(jsObject.storage);

  /// Creates a new StorageReference from a [jsObject].
  static StorageReference getInstance(
      storage_interop.ReferenceJsImpl jsObject) {
    return _expando[jsObject] ??= StorageReference._fromJsObject(jsObject);
  }

  /// Returns a child StorageReference to a relative [path]
  /// from the actual reference.
  StorageReference child(String path) => StorageReference.getInstance(
      storage_interop.ref(jsObject as JSAny, path.toJS));

  /// Deletes the object at the actual location.
  Future delete() => storage_interop.deleteObject(jsObject).toDart;

  /// Returns a long lived download URL for this reference.
  Future<Uri> getDownloadURL() async {
    final uriString = await storage_interop.getDownloadURL(jsObject).toDart;
    final dartString = uriString.toDart;
    return Uri.parse(dartString);
  }

  /// Returns a [FullMetadata] from this reference at actual location.
  Future<FullMetadata> getMetadata() async {
    final data = await storage_interop.getMetadata(jsObject).toDart;
    return FullMetadata.getInstance(data);
  }

  /// List items (files) and prefixes (folders) under this storage reference.
  /// List API is only available for Firebase Storage Rules Version 2.
  ///
  /// GCS is a key-blob store. Firebase Storage imposes the semantic of '/' delimited
  /// folder structure. Refer to GCS's List API if you want to learn more.
  ///
  /// To adhere to Firebase Rules's Semantics, Firebase Storage does not
  /// support objects whose paths end with "/' or contain two consecutive '/"s.
  /// Firebase Storage List API will filter these unsupported objects.
  /// [list()] may fail if there are too many unsupported objects in the bucket.
  Future<ListResult> list(ListOptions? options) async {
    final data = await storage_interop.list(jsObject, options?.jsObject).toDart;
    return ListResult.getInstance(data);
  }

  /// List all items (files) and prefixes (folders) under this storage reference.
  /// List API is only available for Firebase Rules Version 2.
  ///
  /// This is a helper method for calling [list()] repeatedly until there are no
  /// more results. The default pagination size is 1000.
  ///
  /// Note: The results may not be consistent if objects are changed while this
  /// operation is running.
  ///
  /// Warning: [listAll] may potentially consume too many resources if there are
  /// too many results.
  Future<ListResult> listAll() async {
    final data = await storage_interop.listAll(jsObject).toDart;
    return ListResult.getInstance(data);
  }

  /// Uploads data [blob] to the actual location with optional [metadata].
  /// Returns the [UploadTask] which can be used to monitor and manage
  /// the upload.
  ///
  /// `blob` can be a [Uint8List] or [Blob].
  UploadTask put(JSAny blob, [UploadMetadata? metadata]) {
    storage_interop.UploadTaskJsImpl taskImpl;
    if (metadata != null) {
      taskImpl = storage_interop.uploadBytesResumable(
          jsObject, blob, metadata.jsObject);
    } else {
      taskImpl = storage_interop.uploadBytesResumable(jsObject, blob);
    }
    return UploadTask.getInstance(taskImpl);
  }

  /// Returns the String representation of the current storage reference.
  @override
  String toString() => jsObject.toString();

  /// Updates metadata from this reference at actual location with
  /// the new [metadata].
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) async {
    await storage_interop.updateMetadata(jsObject, metadata.jsObject).toDart;
    return getMetadata();
  }
}

/// The full set of object metadata, including read-only properties.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.FullMetadata>
class FullMetadata
    extends _UploadMetadataBase<storage_interop.FullMetadataJsImpl> {
  FullMetadata._fromJsObject(jsObject) : super.fromJsObject(jsObject);

  static final _expando = Expando<FullMetadata>();

  /// The bucket the actual object is contained in.
  String get bucket => jsObject.bucket.toDart;

  /// The full path.
  String? get fullPath => jsObject.fullPath?.toDart;

  /// The generation.
  String? get generation => jsObject.generation?.toDart;

  /// The metageneration.
  String? get metageneration => jsObject.metageneration?.toDart;

  /// The short name. Which is the last component of the full path.
  String? get name => jsObject.name?.toDart;

  /// The size in bytes.
  int? get size => jsObject.size?.toDartInt;

  /// Returns the time it was created as a [DateTime].
  DateTime? get timeCreated => jsObject.timeCreated == null
      ? null
      : DateTime.parse(jsObject.timeCreated!.toDart);

  /// Returns the time it was last updated as a [DateTime].
  DateTime? get updated => jsObject.updated == null
      ? null
      : DateTime.parse(jsObject.updated!.toDart);

  /// Creates a new FullMetadata from a [jsObject].
  static FullMetadata getInstance(storage_interop.FullMetadataJsImpl jsObject) {
    return _expando[jsObject] ??= FullMetadata._fromJsObject(jsObject);
  }
}

/// Object metadata that can be set at upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.UploadMetadata>.
class UploadMetadata
    extends _UploadMetadataBase<storage_interop.UploadMetadataJsImpl> {
  /// Creates a new UploadMetadata with optional metadata parameters.
  factory UploadMetadata(
      {String? md5Hash,
      String? cacheControl,
      String? contentDisposition,
      String? contentEncoding,
      String? contentLanguage,
      String? contentType,
      Map<String, String>? customMetadata}) {
    final metadata = storage_interop.UploadMetadataJsImpl();

    if (md5Hash != null) {
      metadata.md5Hash = md5Hash.toJS;
    }
    if (cacheControl != null) {
      metadata.cacheControl = cacheControl.toJS;
    }
    if (contentDisposition != null) {
      metadata.contentDisposition = contentDisposition.toJS;
    }
    if (contentEncoding != null) {
      metadata.contentEncoding = contentEncoding.toJS;
    }
    if (contentLanguage != null) {
      metadata.contentLanguage = contentLanguage.toJS;
    }
    if (contentType != null) {
      metadata.contentType = contentType.toJS;
    }
    if (customMetadata != null) {
      metadata.customMetadata = customMetadata.jsify();
    }
    return UploadMetadata.fromJsObject(metadata);
  }

  /// Creates a new UploadMetadata from a [jsObject].
  UploadMetadata.fromJsObject(storage_interop.UploadMetadataJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

// TODO(kevmoo) - figure out if a settable md5Hash makes any sense
// See https://stackoverflow.com/q/44959703/39827
abstract class _UploadMetadataBase<
        T extends storage_interop.UploadMetadataJsImpl>
    extends _SettableMetadataBase<T> {
  _UploadMetadataBase.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// The Base64-encoded MD5 hash for the object being uploaded.
  String? get md5Hash => jsObject.md5Hash?.toDart;

  set md5Hash(String? s) {
    jsObject.md5Hash = s?.toJS;
  }
}

/// Represents the process of uploading an object, and allows to monitor
/// and manage the upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.UploadTask>.
class UploadTask extends JsObjectWrapper<storage_interop.UploadTaskJsImpl> {
  UploadTask._fromJsObject(storage_interop.UploadTaskJsImpl jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<UploadTask>();

  Future<UploadTaskSnapshot>? _future;

  /// Returns the UploadTaskSnapshot when the upload successfully completes.
  Future<UploadTaskSnapshot> get future async {
    return _future ??= jsObject
        .then(((JSAny value) {
          return value as storage_interop.UploadTaskSnapshotJsImpl;
        }).toJS)
        .toDart
        .then(
          (value) => UploadTaskSnapshot.getInstance(
            value! as storage_interop.UploadTaskSnapshotJsImpl,
          ),
        );
  }

  /// Returns the upload task snapshot of the current task state.
  UploadTaskSnapshot get snapshot =>
      UploadTaskSnapshot.getInstance(jsObject.snapshot);

  /// Creates a new UploadTask from a [jsObject].
  static UploadTask getInstance(storage_interop.UploadTaskJsImpl jsObject) {
    return _expando[jsObject] ??= UploadTask._fromJsObject(jsObject);
  }

  /// Cancels a running task. Has no effect on a complete or failed task.
  /// Returns [:true:] if it had an effect.
  bool cancel() => jsObject.cancel().toDart;

  // purely for debug mode and tracking listeners to clean up on "hot restart"
  final Map<String, int> _snapshotListeners = {};
  String _taskSnapshotWindowsKey(String appName, String bucket, String path) {
    if (kDebugMode) {
      final key = 'flutterfire-${appName}_${bucket}_${path}_storageTask';
      if (_snapshotListeners.containsKey(key)) {
        _snapshotListeners[key] = _snapshotListeners[key]! + 1;
      } else {
        _snapshotListeners[key] = 0;
      }
      return '$key-${_snapshotListeners[key]}';
    }
    return 'no-op';
  }

  /// Stream for upload task state changed event.
  Stream<UploadTaskSnapshot> onStateChanged(
    String appName,
    String bucket,
    String path,
  ) {
    final windowsKey = _taskSnapshotWindowsKey(appName, bucket, path);
    unsubscribeWindowsListener(windowsKey);
    late StreamController<UploadTaskSnapshot> changeController;
    late JSFunction onStateChangedUnsubscribe;

    var nextWrapper = ((storage_interop.UploadTaskSnapshotJsImpl data) {
      changeController.add(UploadTaskSnapshot.getInstance(data));
    }).toJS;

    var errorWrapper = ((JSError e) => changeController.addError(e)).toJS;
    var onCompletion = (() {
      // Needing a block here (instead of an inline => function) seems to be a
      // dart-lang/sdk quirk/feature.
      // See https://github.com/dart-lang/sdk/issues/43781
      changeController.close();
    }).toJS;

    void startListen() {
      onStateChangedUnsubscribe = jsObject.on(
        'state_changed'.toJS,
        nextWrapper,
        errorWrapper,
        onCompletion,
      );
      setWindowsListener(
        windowsKey,
        onStateChangedUnsubscribe,
      );
    }

    void stopListen() {
      onStateChangedUnsubscribe.callAsFunction();
      changeController.close();
      removeWindowsListener(windowsKey);
    }

    changeController = StreamController<UploadTaskSnapshot>.broadcast(
        onListen: startListen, onCancel: stopListen, sync: true);

    return changeController.stream;
  }

  /// Pauses the running task. Has no effect on a paused or failed task.
  /// Returns [:true:] if it had an effect.
  bool pause() => jsObject.pause().toDart;

  /// Resumes the paused task. Has no effect on a running or failed task.
  /// Returns [:true:] if it had an effect.
  bool resume() => jsObject.resume().toDart;
}

/// Holds data about the current state of the upload task.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.UploadTaskSnapshot>.
class UploadTaskSnapshot
    extends JsObjectWrapper<storage_interop.UploadTaskSnapshotJsImpl> {
  UploadTaskSnapshot._fromJsObject(
      storage_interop.UploadTaskSnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<UploadTaskSnapshot>();

  /// The number of bytes that have been successfully transferred.
  int get bytesTransferred => jsObject.bytesTransferred.toDartInt;

  /// The metadata. Before the upload completes, it contains the metadata sent
  /// to the server. After the upload completes, it contains the metadata sent
  /// back from the server.
  FullMetadata get metadata => FullMetadata.getInstance(jsObject.metadata);

  /// The StorageReference that spawned the current snapshot's upload task.
  StorageReference get ref => StorageReference.getInstance(jsObject.ref);

  /// The actual task state.
  TaskState get state {
    switch (jsObject.state.toDart) {
      case 'running':
        return TaskState.RUNNING;
      case 'paused':
        return TaskState.PAUSED;
      case 'success':
        return TaskState.SUCCESS;
      case 'canceled':
        return TaskState.CANCELED;
      case 'error':
        return TaskState.ERROR;
      default:
        throw UnsupportedError(
            "Unknown state '${jsObject.state}' please file a bug.");
    }
  }

  /// The UploadTask for this snapshot.
  UploadTask get task => UploadTask.getInstance(jsObject.task);

  /// The total number of bytes to be uploaded.
  int get totalBytes => jsObject.totalBytes.toDartInt;

  /// Creates a new UploadTaskSnapshot from a [jsObject].
  static UploadTaskSnapshot getInstance(
      storage_interop.UploadTaskSnapshotJsImpl jsObject) {
    return _expando[jsObject] ??= UploadTaskSnapshot._fromJsObject(jsObject);
  }
}

/// Object metadata that can be set at any time.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.SettableMetadata>.
class SettableMetadata
    extends _SettableMetadataBase<storage_interop.SettableMetadataJsImpl> {
  /// Creates a new SettableMetadata with optional metadata parameters.
  factory SettableMetadata(
      {String? cacheControl,
      String? contentDisposition,
      String? contentEncoding,
      String? contentLanguage,
      String? contentType,
      Map? customMetadata}) {
    final metadata = storage_interop.SettableMetadataJsImpl();

    if (cacheControl != null) {
      metadata.cacheControl = cacheControl.toJS;
    }
    if (contentDisposition != null) {
      metadata.contentDisposition = contentDisposition.toJS;
    }
    if (contentEncoding != null) {
      metadata.contentEncoding = contentEncoding.toJS;
    }
    if (contentLanguage != null) {
      metadata.contentLanguage = contentLanguage.toJS;
    }
    if (contentType != null) {
      metadata.contentType = contentType.toJS;
    }
    if (customMetadata != null) {
      metadata.customMetadata = customMetadata.jsify();
    }
    return SettableMetadata.fromJsObject(metadata);
  }

  /// Creates a new SettableMetadata from a [jsObject].
  SettableMetadata.fromJsObject(storage_interop.SettableMetadataJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

abstract class _SettableMetadataBase<
        T extends storage_interop.SettableMetadataJsImpl>
    extends JsObjectWrapper<T> {
  _SettableMetadataBase.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Served as the 'Cache-Control' header on object download.
  String? get cacheControl => jsObject.cacheControl?.toDart;

  set cacheControl(String? s) {
    jsObject.cacheControl = s?.toJS;
  }

  /// Served as the 'Content-Disposition' header on object download.
  String? get contentDisposition => jsObject.contentDisposition?.toDart;

  set contentDisposition(String? s) {
    jsObject.contentDisposition = s?.toJS;
  }

  /// Served as the 'Content-Encoding' header on object download.
  String? get contentEncoding => jsObject.contentEncoding?.toDart;

  set contentEncoding(String? s) {
    jsObject.contentEncoding = s?.toJS;
  }

  /// Served as the 'Content-Language' header on object download.
  String? get contentLanguage => jsObject.contentLanguage?.toDart;

  set contentLanguage(String? s) {
    jsObject.contentLanguage = s?.toJS;
  }

  /// Served as the 'Content-Type' header on object download.
  String? get contentType => jsObject.contentType?.toDart;

  set contentType(String? s) {
    jsObject.contentType = s?.toJS;
  }

  /// Additional user-defined custom metadata.
  Map<String, String> get customMetadata {
    final customMetadata = jsObject.customMetadata.dartify();
    if (customMetadata == null) {
      return <String, String>{};
    }
    return (customMetadata as Map).cast<String, String>();
  }

  set customMetadata(Map<String, String> m) {
    jsObject.customMetadata = m.jsify()! as JSObject;
  }
}

/// The options [StorageReference.list] accepts.
class ListOptions extends JsObjectWrapper<storage_interop.ListOptionsJsImpl> {
  factory ListOptions({int? maxResults, String? pageToken}) {
    return ListOptions._fromJsObject(storage_interop.ListOptionsJsImpl(
        maxResults: maxResults, pageToken: pageToken?.toJS));
  }

  ListOptions._fromJsObject(storage_interop.ListOptionsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// If set, limits the total number of prefixes and items to return.
  /// The default and maximum maxResults is 1000.
  int? get maxResults => jsObject.maxResults?.toDartInt;

  set maxResults(int? n) => jsObject.maxResults = n?.toJS;

  /// The [ListResult.nextPageToken] from a previous call to
  /// [StorageReference.list]. If provided, listing is resumed from the
  /// previous position.
  String? get pageToken => jsObject.pageToken?.toDart;

  set pageToken(String? t) => jsObject.pageToken = t?.toJS;
}

/// Result returned by [StorageReference.list].
class ListResult extends JsObjectWrapper<storage_interop.ListResultJsImpl> {
  ListResult._fromJsObject(storage_interop.ListResultJsImpl jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<ListResult>();

  /// Objects in this directory. You can call [getMetadata()] and
  /// [getDownloadUrl()] on them.
  List<StorageReference> get items => jsObject.items.toDart
      // ignore: unnecessary_lambdas, false positive, data is dynamic
      .map((dynamic data) => StorageReference._fromJsObject(data))
      .toList();

  /// If set, there might be more results for this list. Use this
  /// token to resume the list.
  String? get nextPageToken => jsObject.nextPageToken?.toDart;

  /// References to prefixes (sub-folders). You can call [list()] on
  /// them to get its contents.
  /// Folders are implicit based on '/' in the object paths. For example,
  /// if a bucket has two objects '/a/b/1' and '/a/b/2', [list('/a')] will
  /// return '/a/b' as a prefix.
  List<StorageReference> get prefixes => jsObject.prefixes.toDart
      // ignore: unnecessary_lambdas, false positive, data is dynamic
      .map((dynamic data) => StorageReference._fromJsObject(data))
      .toList();

  /// Creates a new ListResult from a [jsObject].
  static ListResult getInstance(storage_interop.ListResultJsImpl jsObject) {
    return _expando[jsObject] ??= ListResult._fromJsObject(jsObject);
  }
}
