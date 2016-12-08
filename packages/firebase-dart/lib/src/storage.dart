import 'dart:async';

import 'package:js/js.dart';

import 'app.dart';
import 'interop/storage_interop.dart' as storage_interop;
import 'js.dart';
import 'utils.dart';

export 'interop/storage_interop.dart' show StringFormat;

/// Represents the current state of a running upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage#.TaskState>.
enum TaskState { RUNNING, PAUSED, SUCCESS, CANCELED, ERROR }

/// A service for uploading and downloading large objects to and from the
/// Google Cloud Storage.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.Storage>
class Storage extends JsObjectWrapper<storage_interop.StorageJsImpl> {
  App _app;

  /// App for this instance of storage service.
  App get app {
    if (_app != null) {
      _app.jsObject = jsObject.app;
    } else {
      _app = new App.fromJsObject(jsObject.app);
    }
    return _app;
  }

  /// Returns the maximum time to retry operations other than uploads
  /// or downloads (in milliseconds).
  int get maxOperationRetryTime => jsObject.maxOperationRetryTime;

  /// Returns the maximum time to retry uploads (in milliseconds).
  int get maxUploadRetryTime => jsObject.maxUploadRetryTime;

  /// Creates a new Storage from a [jsObject].
  Storage.fromJsObject(storage_interop.StorageJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Returns a [StorageReference] for the given [path] in the default bucket.
  StorageReference ref([String path]) =>
      new StorageReference.fromJsObject(jsObject.ref(path));

  /// Returns a [StorageReference] for the given absolute [url].
  StorageReference refFromURL(String url) =>
      new StorageReference.fromJsObject(jsObject.refFromURL(url));

  /// Sets the maximum operation retry time to a value of [time].
  void setMaxOperationRetryTime(int time) =>
      jsObject.setMaxOperationRetryTime(time);

  /// Sets the maximum upload retry time to a value of [time].
  void setMaxUploadRetryTime(int time) => jsObject.setMaxUploadRetryTime(time);
}

/// StorageReference is a reference to a Google Cloud Storage object.
/// It is possible to upload, download, and delete objects, as well as
/// get or set the object metadata.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.Reference>
class StorageReference
    extends JsObjectWrapper<storage_interop.ReferenceJsImpl> {
  /// The name of the bucket.
  String get bucket => jsObject.bucket;

  /// The full path.
  String get fullPath => jsObject.fullPath;

  /// The short name. Which is the last component of the full path.
  String get name => jsObject.name;

  StorageReference _parent;

  /// The reference to the parent location of this reference.
  /// It is [null] in case of root StorageReference.
  StorageReference get parent {
    if (jsObject.parent != null) {
      if (_parent != null) {
        _parent.jsObject = jsObject.parent;
      } else {
        _parent = new StorageReference.fromJsObject(jsObject.parent);
      }
    } else {
      _parent = null;
    }
    return _parent;
  }

  StorageReference _root;

  /// The reference to the root of this storage reference's bucket.
  StorageReference get root {
    if (_root != null) {
      _root.jsObject = jsObject.root;
    } else {
      _root = new StorageReference.fromJsObject(jsObject.root);
    }
    return _root;
  }

  Storage _storage;

  /// The [Storage] service associated with this reference.
  Storage get storage {
    if (_storage != null) {
      _storage.jsObject = jsObject.storage;
    } else {
      _storage = new Storage.fromJsObject(jsObject.storage);
    }
    return _storage;
  }

  /// Creates a new StorageReference from a [jsObject].
  StorageReference.fromJsObject(storage_interop.ReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Returns a child StorageReference to a relative [path]
  /// from the actual reference.
  StorageReference child(String path) =>
      new StorageReference.fromJsObject(jsObject.child(path));

  /// Deletes the object at the actual location.
  Future delete() => handleThenable(jsObject.delete());

  /// Returns a long lived download URL for this reference.
  Future<Uri> getDownloadURL() async {
    var uriString = await handleThenable(jsObject.getDownloadURL());
    return Uri.parse(uriString);
  }

  /// Returns a [FullMetadata] from this reference at actual location.
  Future<FullMetadata> getMetadata() => handleThenableWithMapper(
      jsObject.getMetadata(), (m) => new FullMetadata.fromJsObject(m));

  /// Uploads data [blob] to the actual location with optional [metadata].
  /// Returns the [UploadTask] which can be used to monitor and manage
  /// the upload.
  UploadTask put(blob, [UploadMetadata metadata]) {
    storage_interop.UploadTaskJsImpl taskImpl;
    if (metadata != null) {
      taskImpl = jsObject.put(blob, metadata.jsObject);
    } else {
      taskImpl = jsObject.put(blob);
    }
    return new UploadTask.fromJsObject(taskImpl);
  }

  /// Uploads String [data] to the actual location with optional String [format]
  /// and [metadata].
  /// Returns the [UploadTask] which can be used to monitor and manage
  /// the upload.
  UploadTask putString(String data, [String format, UploadMetadata metadata]) {
    storage_interop.UploadTaskJsImpl taskImpl;
    if (metadata != null) {
      taskImpl = jsObject.putString(data, format, metadata.jsObject);
    } else if (format != null) {
      taskImpl = jsObject.putString(data, format);
    } else {
      taskImpl = jsObject.putString(data);
    }
    return new UploadTask.fromJsObject(taskImpl);
  }

  /// Returns the String representation of the current storage reference.
  @override
  String toString() => jsObject.toString();

  /// Updates metadata from this reference at actual location with
  /// the new [metadata].
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) =>
      handleThenableWithMapper(jsObject.updateMetadata(metadata.jsObject),
          (m) => new FullMetadata.fromJsObject(m));
}

/// The full set of object metadata, including read-only properties.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.FullMetadata>
class FullMetadata
    extends _UploadMetadataBase<storage_interop.FullMetadataJsImpl> {
  /// The bucket the actual object is contained in.
  String get bucket => jsObject.bucket;

  /// Returns an array of long-lived download URLs. With at least one URL.
  List<Uri> get downloadURLs => jsObject.downloadURLs.map(Uri.parse).toList();

  /// The full path.
  String get fullPath => jsObject.fullPath;

  /// The generation.
  String get generation => jsObject.generation;

  /// The metageneration.
  String get metageneration => jsObject.metageneration;

  /// The short name. Which is the last component of the full path.
  String get name => jsObject.name;

  /// The size in bytes.
  int get size => jsObject.size;

  /// Returns the time it was created as a [DateTime].
  DateTime get timeCreated => DateTime.parse(jsObject.timeCreated);

  /// Returns the time it was last updated as a [DateTime].
  DateTime get updated => DateTime.parse(jsObject.updated);

  /// Creates a new FullMetadata with optional metadata parameters.
  factory FullMetadata(
          {String bucket,
          List<String> downloadURLs,
          String fullPath,
          String generation,
          String metageneration,
          String name,
          int size,
          String timeCreated,
          String updated,
          String md5Hash,
          String cacheControl,
          String contentDisposition,
          String contentEncoding,
          String contentLanguage,
          String contentType,
          Map customMetadata}) =>
      new FullMetadata.fromJsObject(new storage_interop.FullMetadataJsImpl(
          md5Hash: md5Hash,
          cacheControl: cacheControl,
          contentDisposition: contentDisposition,
          contentEncoding: contentEncoding,
          contentLanguage: contentLanguage,
          contentType: contentType,
          customMetadata:
              (customMetadata != null) ? jsify(customMetadata) : null));

  /// Creates a new FullMetadata from a [jsObject].
  FullMetadata.fromJsObject(jsObject) : super.fromJsObject(jsObject);
}

/// Object metadata that can be set at upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.UploadMetadata>.
class UploadMetadata
    extends _UploadMetadataBase<storage_interop.UploadMetadataJsImpl> {
  /// Creates a new UploadMetadata with optional metadata parameters.
  factory UploadMetadata(
          {String md5Hash,
          String cacheControl,
          String contentDisposition,
          String contentEncoding,
          String contentLanguage,
          String contentType,
          Map<String, String> customMetadata}) =>
      new UploadMetadata.fromJsObject(new storage_interop.UploadMetadataJsImpl(
          md5Hash: md5Hash,
          cacheControl: cacheControl,
          contentDisposition: contentDisposition,
          contentEncoding: contentEncoding,
          contentLanguage: contentLanguage,
          contentType: contentType,
          customMetadata:
              (customMetadata != null) ? jsify(customMetadata) : null));

  /// Creates a new UploadMetadata from a [jsObject].
  UploadMetadata.fromJsObject(storage_interop.UploadMetadataJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

abstract class _UploadMetadataBase<
        T extends storage_interop.UploadMetadataJsImpl>
    extends _SettableMetadataBase<T> {
  /// The Base64-encoded MD5 hash for the object being uploaded.
  String get md5Hash => jsObject.md5Hash;
  void set md5Hash(String s) {
    jsObject.md5Hash = s;
  }

  _UploadMetadataBase.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}

/// Represents the process of uploading an object, and allows to monitor
/// and manage the upload.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.UploadTask>.
class UploadTask extends JsObjectWrapper<storage_interop.UploadTaskJsImpl> {
  Future<UploadTaskSnapshot> _future;

  /// Returns the UploadTaskSnapshot when the upload successfully completes.
  Future<UploadTaskSnapshot> get future {
    if (_future == null) {
      _future = handleThenableWithMapper(
          jsObject, (val) => new UploadTaskSnapshot.fromJsObject(val));
    }
    return _future;
  }

  UploadTaskSnapshot _snapshot;

  /// Returns the upload task snapshot of the current task state.
  UploadTaskSnapshot get snapshot {
    if (_snapshot != null) {
      _snapshot.jsObject = jsObject.snapshot;
    } else {
      _snapshot = new UploadTaskSnapshot.fromJsObject(jsObject.snapshot);
    }
    return _snapshot;
  }

  /// Creates a new UploadTask from a [jsObject].
  UploadTask.fromJsObject(storage_interop.UploadTaskJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Cancels a running task. Has no effect on a complete or failed task.
  /// Returns [:true:] if it had an effect.
  bool cancel() => jsObject.cancel();

  var _onStateChangedUnsubscribe;
  StreamController<UploadTaskSnapshot> _changeController;

  /// Stream for upload task state changed event.
  Stream<UploadTaskSnapshot> get onStateChanged {
    if (_changeController == null) {
      var nextWrapper =
          allowInterop((storage_interop.UploadTaskSnapshotJsImpl data) {
        _changeController.add(new UploadTaskSnapshot.fromJsObject(data));
      });

      var errorWrapper = allowInterop((e) => _changeController.addError(e));
      var onCompletion = allowInterop(() => _changeController.close());

      void startListen() {
        _onStateChangedUnsubscribe = jsObject.on(
            storage_interop.TaskEvent.STATE_CHANGED,
            nextWrapper,
            errorWrapper,
            onCompletion);
      }

      void stopListen() {
        _onStateChangedUnsubscribe();
      }

      _changeController = new StreamController<UploadTaskSnapshot>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _changeController.stream;
  }

  /// Pauses the running task. Has no effect on a paused or failed task.
  /// Returns [:true:] if it had an effect.
  bool pause() => jsObject.pause();

  /// Resumes the paused task. Has no effect on a running or failed task.
  /// Returns [:true:] if it had an effect.
  bool resume() => jsObject.resume();
}

/// Holds data about the current state of the upload task.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.UploadTaskSnapshot>.
class UploadTaskSnapshot
    extends JsObjectWrapper<storage_interop.UploadTaskSnapshotJsImpl> {
  /// The number of bytes that have been successfully transferred.
  int get bytesTransferred => jsObject.bytesTransferred;

  /// Contains a long-lived download URL for the object after the upload
  /// completes. It is also accessible from [metadata].
  Uri get downloadURL => Uri.parse(jsObject.downloadURL);

  FullMetadata _metadata;

  /// The metadata. Before the upload completes, it contains the metadata sent
  /// to the server. After the upload completes, it contains the metadata sent
  /// back from the server.
  FullMetadata get metadata {
    if (jsObject.metadata != null) {
      if (_metadata != null) {
        _metadata.jsObject = jsObject.metadata;
      } else {
        _metadata = new FullMetadata.fromJsObject(jsObject.metadata);
      }
    } else {
      _metadata = null;
    }
    return _metadata;
  }

  StorageReference _ref;

  /// The StorageReference that spawned the current snapshot's upload task.
  StorageReference get ref {
    if (_ref != null) {
      _ref.jsObject = jsObject.ref;
    } else {
      _ref = new StorageReference.fromJsObject(jsObject.ref);
    }
    return _ref;
  }

  /// The actual task state.
  TaskState get state {
    switch (jsObject.state) {
      case "running":
        return TaskState.RUNNING;
      case "paused":
        return TaskState.PAUSED;
      case "success":
        return TaskState.SUCCESS;
      case "canceled":
        return TaskState.CANCELED;
      case "error":
        return TaskState.ERROR;
      default:
        throw new UnsupportedError(
            'Unknown state "${jsObject.state}" please file a bug.');
    }
  }

  UploadTask _task;

  /// The UploadTask for this snapshot.
  UploadTask get task {
    if (_task != null) {
      _task.jsObject = jsObject.task;
    } else {
      _task = new UploadTask.fromJsObject(jsObject.task);
    }
    return _task;
  }

  /// The total number of bytes to be uploaded.
  int get totalBytes => jsObject.totalBytes;

  /// Creates a new UploadTaskSnapshot from a [jsObject].
  UploadTaskSnapshot.fromJsObject(
      storage_interop.UploadTaskSnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

/// Object metadata that can be set at any time.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.storage.SettableMetadata>.
class SettableMetadata
    extends _SettableMetadataBase<storage_interop.SettableMetadataJsImpl> {
  /// Creates a new SettableMetadata with optional metadata parameters.
  factory SettableMetadata(
          {String cacheControl,
          String contentDisposition,
          String contentEncoding,
          String contentLanguage,
          String contentType,
          Map customMetadata}) =>
      new SettableMetadata.fromJsObject(
          new storage_interop.SettableMetadataJsImpl(
              cacheControl: cacheControl,
              contentDisposition: contentDisposition,
              contentEncoding: contentEncoding,
              contentLanguage: contentLanguage,
              contentType: contentType,
              customMetadata:
                  (customMetadata != null) ? jsify(customMetadata) : null));

  /// Creates a new SettableMetadata from a [jsObject].
  SettableMetadata.fromJsObject(storage_interop.SettableMetadataJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

abstract class _SettableMetadataBase<
        T extends storage_interop.SettableMetadataJsImpl>
    extends JsObjectWrapper<T> {
  /// Served as the 'Cache-Control' header on object download.
  String get cacheControl => jsObject.cacheControl;
  void set cacheControl(String s) {
    jsObject.cacheControl = s;
  }

  /// Served as the 'Content-Disposition' header on object download.
  String get contentDisposition => jsObject.contentDisposition;
  void set contentDisposition(String s) {
    jsObject.contentDisposition = s;
  }

  /// Served as the 'Content-Encoding' header on object download.
  String get contentEncoding => jsObject.contentEncoding;
  void set contentEncoding(String s) {
    jsObject.contentEncoding = s;
  }

  /// Served as the 'Content-Language' header on object download.
  String get contentLanguage => jsObject.contentLanguage;
  void set contentLanguage(String s) {
    jsObject.contentLanguage = s;
  }

  /// Served as the 'Content-Type' header on object download.
  String get contentType => jsObject.contentType;
  void set contentType(String s) {
    jsObject.contentType = s;
  }

  /// Additional user-defined custom metadata.
  Map<String, String> get customMetadata =>
      dartify(jsObject.customMetadata) as Map<String, String>;
  void set customMetadata(Map<String, String> m) {
    jsObject.customMetadata = jsify(m);
  }

  _SettableMetadataBase.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}
