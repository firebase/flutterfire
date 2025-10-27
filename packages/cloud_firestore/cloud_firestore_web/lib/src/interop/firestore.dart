// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform_interface;
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/encode_utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:flutter/foundation.dart';

import 'firestore_interop.dart' as firestore_interop;
import 'utils/utils.dart';

export 'firestore_interop.dart';

/// Given an AppJSImp, return the Firestore instance.
Firestore getFirestoreInstance([
  App? app,
  firestore_interop.FirestoreSettings? settings,
  String? databaseURL,
]) {
  String database = databaseURL ?? '(default)';

  if (app != null && settings != null) {
    try {
      return Firestore.getInstance(firestore_interop.initializeFirestore(
          app.jsObject, settings, database.toJS));
    } catch (e) {
      if (kDebugMode) {
        // Fallback to initialize without settings, happens during hot restart
        return Firestore.getInstance(
            firestore_interop.getFirestore(app.jsObject, database.toJS));
      }
      rethrow;
    }
  }

  return Firestore.getInstance(app != null
      ? firestore_interop.getFirestore(app.jsObject, database.toJS)
      : firestore_interop.getFirestore());
}

JSString convertListenSource(ListenSource source) {
  return switch (source) {
    ListenSource.defaultSource => 'default'.toJS,
    ListenSource.cache => 'cache'.toJS
  };
}

/// The Cloud Firestore service interface.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.Firestore>.
class Firestore extends JsObjectWrapper<firestore_interop.FirestoreJsImpl> {
  static final _expando = Expando<Firestore>();

  /// Non-null App for this instance of firestore service.
  App get app => App.getInstance(jsObject.app);

  /// Creates a new Firestore from a [jsObject].
  static Firestore getInstance(firestore_interop.FirestoreJsImpl jsObject) {
    return _expando[jsObject] ??= Firestore._fromJsObject(jsObject);
  }

  Firestore._fromJsObject(firestore_interop.FirestoreJsImpl jsObject)
      : super.fromJsObject(jsObject);

  WriteBatch? batch() =>
      WriteBatch.getInstance(firestore_interop.writeBatch(jsObject));

  CollectionReference collection(String collectionPath) =>
      CollectionReference.getInstance(
          firestore_interop.collection(jsObject, collectionPath.toJS));

  Query collectionGroup(String collectionId) => Query.fromJsObject(
      firestore_interop.collectionGroup(jsObject, collectionId.toJS));

  DocumentReference doc(String documentPath) => DocumentReference.getInstance(
      firestore_interop.doc(jsObject as JSAny, documentPath.toJS));

// purely for debug mode and tracking listeners to clean up on "hot restart"
  static final Map<String, int> _snapshotInSyncListeners = {};
  String _snapshotInSyncWindowsKey() {
    if (kDebugMode) {
      final key = 'flutterfire-${app.name}_snapshotInSync';
      if (_snapshotInSyncListeners.containsKey(key)) {
        _snapshotInSyncListeners[key] = _snapshotInSyncListeners[key]! + 1;
      } else {
        _snapshotInSyncListeners[key] = 0;
      }
      return '$key-${_snapshotInSyncListeners[key]}';
    }
    return 'no-op';
  }

  Stream<void> snapshotsInSync() {
    final snapshotKey = _snapshotInSyncWindowsKey();
    unsubscribeWindowsListener(snapshotKey);
    late StreamController<void> controller;
    late JSFunction onSnapshotsInSyncUnsubscribe;
    var nextWrapper = ((JSObject? noValue) {
      controller.add(null);
    }).toJS;

    void startListen() {
      onSnapshotsInSyncUnsubscribe =
          firestore_interop.onSnapshotsInSync(jsObject, nextWrapper);
      setWindowsListener(
        snapshotKey,
        onSnapshotsInSyncUnsubscribe,
      );
    }

    void stopListen() {
      onSnapshotsInSyncUnsubscribe.callAsFunction();
      controller.close();
      removeWindowsListener(snapshotKey);
    }

    controller = StreamController<void>.broadcast(
      onListen: startListen,
      onCancel: stopListen,
    );

    return controller.stream;
  }

  Future<void> clearPersistence() =>
      firestore_interop.clearIndexedDbPersistence(jsObject).toDart;

  Future runTransaction(
      Function(Transaction?) updateFunction, int maxAttempts) async {
    final updateFunctionWrap =
        (firestore_interop.TransactionJsImpl transaction) {
      return handleFutureWithMapper(
          updateFunction(Transaction.getInstance(transaction)), jsify);
    };

    final future = firestore_interop
        .runTransaction(
          jsObject,
          updateFunctionWrap.toJS,
          firestore_interop.TransactionOptionsJsImpl(
            maxAttempts: maxAttempts.toJS,
          ),
        )
        .toDart;
    await future;
  }

  void useEmulator(String host, int port) => firestore_interop
      .connectFirestoreEmulator(jsObject, host.toJS, port.toJS);

  Future enableNetwork() => firestore_interop.enableNetwork(jsObject).toDart;

  Future disableNetwork() => firestore_interop.disableNetwork(jsObject).toDart;

  Future<void> terminate() => firestore_interop.terminate(jsObject).toDart;

  Future<void> waitForPendingWrites() =>
      firestore_interop.waitForPendingWrites(jsObject).toDart;

  LoadBundleTask loadBundle(Uint8List bundle) {
    return LoadBundleTask.getInstance(
        firestore_interop.loadBundle(jsObject, bundle.toJS));
  }

  Future<void> setIndexConfiguration(String indexConfiguration) =>
      firestore_interop
          .setIndexConfiguration(jsObject, indexConfiguration.toJS)
          .toDart;

  Future<void> persistenceCacheIndexManagerRequest(
    PersistenceCacheIndexManagerRequest request,
  ) async {
    firestore_interop.PersistentCacheIndexManager? indexManager =
        firestore_interop.getPersistentCacheIndexManager(jsObject);

    if (indexManager != null) {
      return switch (request) {
        PersistenceCacheIndexManagerRequest.enableIndexAutoCreation =>
          firestore_interop
              .enablePersistentCacheIndexAutoCreation(indexManager),
        PersistenceCacheIndexManagerRequest.disableIndexAutoCreation =>
          firestore_interop
              .disablePersistentCacheIndexAutoCreation(indexManager),
        PersistenceCacheIndexManagerRequest.deleteAllIndexes =>
          firestore_interop.deleteAllPersistentCacheIndexes(indexManager)
      };
    } else {
      // ignore: avoid_print
      print('Firestore: `PersistentCacheIndexManager` is not available');
    }
  }

  Future<Query> namedQuery(String name) async {
    final future = firestore_interop.namedQuery(jsObject, name.toJS).toDart;
    final result = await future;
    firestore_interop.QueryJsImpl? query =
        result as firestore_interop.QueryJsImpl?;

    if (query == null) {
      // same error as iOS & android to maintain consistency
      throw FirebaseException(
          plugin: 'cloud_firestore',
          message:
              'Named query has not been found. Please check it has been loaded properly via loadBundle().',
          code: 'non-existent-named-query');
    }

    return Query.fromJsObject(query);
  }

  bool refEqual(dynamic /* DocumentReference | CollectionReference */ left,
      dynamic /* DocumentReference | CollectionReference */ right) {
    return firestore_interop.refEqual(left, right).toDart;
  }

  void setLoggingEnabled(String logLevel) {
    firestore_interop.setLogLevel(logLevel.toJS);
  }
}

class LoadBundleTask
    extends JsObjectWrapper<firestore_interop.LoadBundleTaskJsImpl> {
  LoadBundleTask._fromJsObject(firestore_interop.LoadBundleTaskJsImpl jsObject)
      : super.fromJsObject(jsObject);

  static final _expando = Expando<LoadBundleTask>();

  /// Creates a new LoadBundleTask from a [jsObject].
  static LoadBundleTask getInstance(
    firestore_interop.LoadBundleTaskJsImpl jsObject,
  ) {
    return _expando[jsObject] ??= LoadBundleTask._fromJsObject(jsObject);
  }

  ///Tracks progress of loadBundle snapshots as the documents are loaded into cache
  Stream<LoadBundleTaskProgress> get stream {
    late StreamController<LoadBundleTaskProgress> controller;
    controller = StreamController<LoadBundleTaskProgress>(onListen: () {
      /// Calls underlying onProgress method on a LoadBundleTask [jsObject].
      jsObject
          .onProgress(((firestore_interop.LoadBundleTaskProgressJsImpl data) {
        LoadBundleTaskProgress taskProgress =
            LoadBundleTaskProgress._fromJsObject(data);

        if (LoadBundleTaskState.error != taskProgress.taskState) {
          // Error handled in addError() call below.
          controller.add(taskProgress);
        }
      }).toJS);

      jsObject.then(
        ((JSObject value) {
          controller.close();
        }).toJS,
        ((JSError error) {
          controller.addError(
            FirebaseException(
              plugin: 'cloud_firestore',
              message: error.message?.toDart,
              code: 'load-bundle-error',
              stackTrace: StackTrace.fromString(error.stack?.toDart ?? ''),
            ),
          );
          controller.close();
        }).toJS,
      );
    }, onCancel: () {
      controller.close();
    });

    return controller.stream;
  }
}

class LoadBundleTaskProgress
    extends JsObjectWrapper<firestore_interop.LoadBundleTaskProgressJsImpl> {
  LoadBundleTaskProgress._fromJsObject(
    firestore_interop.LoadBundleTaskProgressJsImpl jsObject,
  )   : taskState = convertToTaskState(jsObject.taskState.toDart.toLowerCase()),
        // Cannot be done with Dart 3.2 constraints
        // ignore: invalid_runtime_check_with_js_interop_types
        bytesLoaded = jsObject.bytesLoaded is JSNumber
            ? (jsObject.bytesLoaded as JSNumber).toDartInt
            : int.parse((jsObject.bytesLoaded as JSString).toDart),
        documentsLoaded = jsObject.documentsLoaded.toDartInt,
        // Cannot be done with Dart 3.2 constraints
        // ignore: invalid_runtime_check_with_js_interop_types
        totalBytes = jsObject.totalBytes is JSNumber
            ? (jsObject.totalBytes as JSNumber).toDartInt
            : int.parse((jsObject.totalBytes as JSString).toDart),
        totalDocuments = jsObject.totalDocuments.toDartInt,
        super.fromJsObject(jsObject);

  static final _expando = Expando<LoadBundleTaskProgress>();

  /// Creates a new LoadBundleTaskProgress from a [jsObject].
  static LoadBundleTaskProgress getInstance(
    firestore_interop.LoadBundleTaskProgressJsImpl jsObject,
  ) {
    return _expando[jsObject] ??=
        LoadBundleTaskProgress._fromJsObject(jsObject);
  }

  final LoadBundleTaskState taskState;
  final int bytesLoaded;
  final int documentsLoaded;
  final int totalBytes;
  final int totalDocuments;
}

class WriteBatch extends JsObjectWrapper<firestore_interop.WriteBatchJsImpl> {
  static final _expando = Expando<WriteBatch>();

  /// Creates a new WriteBatch from a [jsObject].
  static WriteBatch getInstance(firestore_interop.WriteBatchJsImpl jsObject) {
    return _expando[jsObject] ??= WriteBatch._fromJsObject(jsObject);
  }

  WriteBatch._fromJsObject(firestore_interop.WriteBatchJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Future<void> commit() => jsObject.commit().toDart;

  WriteBatch delete(DocumentReference documentRef) =>
      WriteBatch.getInstance(jsObject.delete(documentRef.jsObject));

  WriteBatch set(DocumentReference documentRef, Map<String, dynamic> data,
      [firestore_interop.SetOptions? options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(documentRef.jsObject, jsify(data)! as JSObject, options)
        : jsObject.set(documentRef.jsObject, jsify(data)! as JSObject);
    return WriteBatch.getInstance(jsObjectSet);
  }

  WriteBatch update(DocumentReference documentRef, Map<String, dynamic> data) =>
      WriteBatch.getInstance(
        jsObject.update(documentRef.jsObject, jsify(data)! as JSObject),
      );
}

class DocumentReference
    extends JsObjectWrapper<firestore_interop.DocumentReferenceJsImpl> {
  static final _expando = Expando<DocumentReference>();

  /// Non-null [Firestore] the document is in.
  /// This is useful for performing transactions, for example.
  Firestore get firestore => Firestore.getInstance(jsObject.firestore);

  String get id => jsObject.id.toDart;

  CollectionReference? get parent =>
      CollectionReference.getInstance(jsObject.parent);

  String get path => jsObject.path.toDart;

  /// Creates a new DocumentReference from a [jsObject].
  static DocumentReference getInstance(
      firestore_interop.DocumentReferenceJsImpl jsObject) {
    return _expando[jsObject] ??= DocumentReference._fromJsObject(jsObject);
  }

  DocumentReference._fromJsObject(
      firestore_interop.DocumentReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  CollectionReference? collection(String collectionPath) {
    return CollectionReference.getInstance(firestore_interop.collection(
        firestore.jsObject, '$path/$collectionPath'.toJS));
  }

  Future<void> delete() => firestore_interop.deleteDoc(jsObject).toDart;

  Future<DocumentSnapshot> get([firestore_interop.GetOptions? options]) async {
    late Future future;
    if (options == null || options.source.toDart == 'default') {
      future = firestore_interop.getDoc(jsObject).toDart;
    } else if (options.source.toDart == 'server') {
      future = firestore_interop.getDocFromServer(jsObject).toDart;
    } else {
      future = firestore_interop.getDocFromCache(jsObject).toDart;
    }
    final result = await future;
    return DocumentSnapshot.getInstance(
        (result)! as firestore_interop.DocumentSnapshotJsImpl);
  }

  // purely for debug mode and tracking listeners to clean up on "hot restart"
  static final Map<String, int> _docListeners = {};
  String _documentSnapshotWindowsKey() {
    if (kDebugMode) {
      final key = 'flutterfire-${firestore.app.name}_${path}_documentSnapshot';
      if (_docListeners.containsKey(key)) {
        _docListeners[key] = _docListeners[key]! + 1;
      } else {
        _docListeners[key] = 0;
      }
      return '$key-${_docListeners[key]}';
    }
    return 'no-op';
  }

  /// Attaches a listener for [DocumentSnapshot] events.
  Stream<DocumentSnapshot> onSnapshot({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      _createSnapshotStream(
        firestore_interop.DocumentListenOptions(
          includeMetadataChanges: includeMetadataChanges.toJS,
          source: convertListenSource(source),
        ),
      ).stream;

  StreamController<DocumentSnapshot> _createSnapshotStream([
    firestore_interop.DocumentListenOptions? options,
  ]) {
    final documentKey = _documentSnapshotWindowsKey();
    unsubscribeWindowsListener(documentKey);
    late JSFunction onSnapshotUnsubscribe;
    // ignore: close_sinks, the controller is returned
    late StreamController<DocumentSnapshot> controller;

    final nextWrapper = ((firestore_interop.DocumentSnapshotJsImpl snapshot) {
      controller.add(DocumentSnapshot.getInstance(snapshot));
    }).toJS;

    final errorWrapper = ((JSError e) => controller.addError(e)).toJS;

    void startListen() {
      onSnapshotUnsubscribe = (options != null)
          ? firestore_interop.onSnapshot(
              jsObject as JSObject, options as JSAny, nextWrapper, errorWrapper)
          : firestore_interop.onSnapshot(
              jsObject as JSObject, nextWrapper, errorWrapper);
      setWindowsListener(documentKey, onSnapshotUnsubscribe);
    }

    void stopListen() {
      onSnapshotUnsubscribe.callAsFunction();
      removeWindowsListener(documentKey);
    }

    return controller = StreamController<DocumentSnapshot>.broadcast(
      onListen: startListen,
      onCancel: stopListen,
      sync: true,
    );
  }

  Future<void> set(Map<String, dynamic> data,
      [firestore_interop.SetOptions? options]) async {
    if (options != null) {
      await firestore_interop.setDoc(jsObject, jsify(data), options).toDart;
      return;
    }
    await firestore_interop.setDoc(jsObject, jsify(data)).toDart;
  }

  Future<void> update(Map<firestore_interop.FieldPath, dynamic> data) async {
    final List<JSAny?> alternatingFieldValues = data.keys
        .map((e) => [jsify(e), jsify(data[e])])
        .expand((e) => e)
        .toList();

    await firestore_interop.updateDoc
        .callMethodVarArgs<JSPromise>('apply'.toJS, [
      null,
      [jsObject, ...alternatingFieldValues].jsify()
    ]).toDart;
  }
}

class Query<T extends firestore_interop.QueryJsImpl>
    extends JsObjectWrapper<T> {
  Firestore get firestore => Firestore.getInstance(jsObject.firestore);

  /// Creates a new Query from a [jsObject].
  Query.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  Query endAt({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(firestore_interop.query(
          jsObject,
          _createQueryConstraint(
              firestore_interop.endAt, snapshot, fieldValues)));

  Query endBefore({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(firestore_interop.query(
          jsObject,
          _createQueryConstraint(
              firestore_interop.endBefore, snapshot, fieldValues)));

  Future<QuerySnapshot> get([firestore_interop.GetOptions? options]) async {
    late Future future;

    if (options == null || options.source.toDart == 'default') {
      future = firestore_interop.getDocs(jsObject).toDart;
    } else if (options.source.toDart == 'server') {
      future = firestore_interop.getDocsFromServer(jsObject).toDart;
    } else {
      future = firestore_interop.getDocsFromCache(jsObject).toDart;
    }
    final result = await future;
    return QuerySnapshot.getInstance(
        result! as firestore_interop.QuerySnapshotJsImpl);
  }

  Query limit(num limit) => Query.fromJsObject(
      firestore_interop.query(jsObject, firestore_interop.limit(limit.toJS)));

  Query limitToLast(num limit) => Query.fromJsObject(firestore_interop.query(
      jsObject, firestore_interop.limitToLast(limit.toJS)));

  // purely for debug mode and tracking listeners to clean up on "hot restart"
  static final Map<String, int> _snapshotListeners = {};
  String _querySnapshotWindowsKey(hashCode) {
    if (kDebugMode) {
      final key = 'flutterfire-${firestore.app.name}_${hashCode}_querySnapshot';
      if (_snapshotListeners.containsKey(key)) {
        _snapshotListeners[key] = _snapshotListeners[key]! + 1;
      } else {
        _snapshotListeners[key] = 0;
      }
      return '$key-${_snapshotListeners[key]}';
    }
    return 'no-op';
  }

  Stream<QuerySnapshot> onSnapshot(
          {bool includeMetadataChanges = false,
          required ListenSource listenSource,
          required int hashCode}) =>
      _createSnapshotStream(
        firestore_interop.DocumentListenOptions(
          includeMetadataChanges: includeMetadataChanges.toJS,
          source: convertListenSource(listenSource),
        ),
        hashCode,
      ).stream;

  StreamController<QuerySnapshot> _createSnapshotStream(
    firestore_interop.DocumentListenOptions options,
    int hashCode,
  ) {
    final snapshotKey = _querySnapshotWindowsKey(hashCode);
    unsubscribeWindowsListener(snapshotKey);
    late JSFunction onSnapshotUnsubscribe;
    // ignore: close_sinks, the controller is returned
    late StreamController<QuerySnapshot> controller;

    final nextWrapper = ((firestore_interop.QuerySnapshotJsImpl snapshot) {
      controller.add(QuerySnapshot._fromJsObject(snapshot));
    }).toJS;
    final errorWrapper = ((JSError e) => controller.addError(e)).toJS;

    void startListen() {
      onSnapshotUnsubscribe = firestore_interop.onSnapshot(
          jsObject as JSObject, options as JSObject, nextWrapper, errorWrapper);
      setWindowsListener(
        snapshotKey,
        onSnapshotUnsubscribe,
      );
    }

    void stopListen() {
      onSnapshotUnsubscribe.callAsFunction();
      removeWindowsListener(snapshotKey);
    }

    return controller = StreamController<QuerySnapshot>.broadcast(
      onListen: startListen,
      onCancel: stopListen,
      sync: true,
    );
  }

  Query orderBy(/*String|FieldPath*/ dynamic fieldPath,
      [String? /*'desc'|'asc'*/ directionStr]) {
    var jsObjectOrderBy = (directionStr != null)
        ? firestore_interop.orderBy(fieldPath, directionStr.toJS)
        : firestore_interop.orderBy(fieldPath);

    return Query.fromJsObject(
        firestore_interop.query(jsObject, jsObjectOrderBy));
  }

  Query startAfter({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(
        firestore_interop.query(
          jsObject,
          _createQueryConstraint(
            firestore_interop.startAfter,
            snapshot,
            fieldValues,
          ),
        ),
      );

  Query startAt({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(
        firestore_interop.query(
          jsObject,
          _createQueryConstraint(
            firestore_interop.startAt,
            snapshot,
            fieldValues,
          ),
        ),
      );

  Query where(dynamic fieldPath, String opStr, dynamic value) =>
      Query.fromJsObject(
        firestore_interop.query(
          jsObject,
          firestore_interop.where(
            fieldPath,
            opStr.toJS,
            jsify(value),
          ),
        ),
      );

  /// Calls js paginating [method] with [DocumentSnapshot] or List of
  /// [fieldValues].
  /// We need to call this method in all paginating methods to fix that Dart
  /// doesn't support varargs - we need to use [List] to call js function.
  firestore_interop.QueryConstraintJsImpl _createQueryConstraint<S>(
      Object method, DocumentSnapshot? snapshot, List<dynamic>? fieldValues) {
    if (snapshot == null && fieldValues == null) {
      throw ArgumentError(
          'Please provide either snapshot or fieldValues parameter.');
    }

    final args = (snapshot != null)
        ? [snapshot.jsObject]
        : fieldValues!.map(jsify).toList();

    return (method as JSObject).callMethodVarArgs<JSAny>(
      'apply'.toJS,
      [
        null,
        jsify(args).jsify(),
      ],
    ) as firestore_interop.QueryConstraintJsImpl;
  }

  Object _parseFilterWith(Map<String, Object?> map) {
    if (map['fieldPath'] != null) {
      dynamic fieldPath = EncodeUtility.valueEncode(map['fieldPath']);
      String opStr = map['op']! as String;
      dynamic value = EncodeUtility.valueEncode(map['value']);

      return firestore_interop.where(
        fieldPath,
        opStr.toJS,
        jsify(value),
      );
    }

    String opStr = map['op']! as String;
    List<dynamic> filters = map['queries']! as List<dynamic>;
    List<dynamic> jsFilters = [];

    for (final Map<String, Object?> filter in filters) {
      jsFilters.add(_parseFilterWith(filter));
    }

    if (opStr == 'OR') {
      return firestore_interop.or.callMethodVarArgs<JSAny>(
        'apply'.toJS,
        [
          null,
          jsFilters.jsify(),
        ],
      );
    } else if (opStr == 'AND') {
      return firestore_interop.and.callMethodVarArgs<JSAny>(
        'apply'.toJS,
        [
          null,
          jsFilters.jsify(),
        ],
      );
    }

    throw Exception('InvalidOperator');
  }

  Query filterWith(Map<String, Object?> map) {
    return Query.fromJsObject(firestore_interop.query(jsObject,
        _parseFilterWith(map) as firestore_interop.QueryConstraintJsImpl));
  }
}

class CollectionReference<T extends firestore_interop.CollectionReferenceJsImpl>
    extends Query<T> {
  static final _expando = Expando<CollectionReference>();

  String get id => jsObject.id.toDart;

  DocumentReference? get parent =>
      DocumentReference.getInstance(jsObject.parent);

  String get path => jsObject.path.toDart;

  /// Creates a new CollectionReference from a [jsObject].
  static CollectionReference getInstance(
      firestore_interop.CollectionReferenceJsImpl jsObject) {
    return _expando[jsObject] ??= CollectionReference._fromJsObject(jsObject);
  }

  factory CollectionReference(
          firestore_interop.CollectionReferenceJsImpl jsObject) =>
      CollectionReference._fromJsObject(jsObject);

  CollectionReference._fromJsObject(
      firestore_interop.CollectionReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject as T);

  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final future =
        firestore_interop.addDoc(jsObject, jsify(data)! as JSObject).toDart;
    final result = await future;
    return DocumentReference.getInstance(result);
  }

  DocumentReference doc([String? documentPath]) {
    final ref = documentPath != null
        ? firestore_interop.doc(jsObject as JSObject, documentPath.toJS)
        : firestore_interop.doc(jsObject as JSObject);

    return DocumentReference.getInstance(ref);
  }

  bool isEqual(CollectionReference other) =>
      firestore_interop.queryEqual(jsObject, other.jsObject).toDart;
}

class DocumentChange
    extends JsObjectWrapper<firestore_interop.DocumentChangeJsImpl> {
  static final _expando = Expando<DocumentChange>();

  String get type => jsObject.type.toDart;

  DocumentSnapshot? get doc => DocumentSnapshot.getInstance(jsObject.doc);

  num get oldIndex => jsObject.oldIndex.toDartInt;

  num get newIndex => jsObject.newIndex.toDartInt;

  /// Creates a new DocumentChange from a [jsObject].
  static DocumentChange getInstance(
      firestore_interop.DocumentChangeJsImpl jsObject) {
    return _expando[jsObject] ??= DocumentChange._fromJsObject(jsObject);
  }

  DocumentChange._fromJsObject(firestore_interop.DocumentChangeJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

class DocumentSnapshot
    extends JsObjectWrapper<firestore_interop.DocumentSnapshotJsImpl> {
  static final _expando = Expando<DocumentSnapshot>();

  bool get exists => jsObject.exists().toDart;

  String get id => jsObject.id.toDart;

  firestore_interop.SnapshotMetadata get metadata => jsObject.metadata;

  DocumentReference? get ref => DocumentReference.getInstance(jsObject.ref);

  /// Creates a new DocumentSnapshot from a [jsObject].
  static DocumentSnapshot getInstance(
      firestore_interop.DocumentSnapshotJsImpl jsObject) {
    return _expando[jsObject] ??= DocumentSnapshot._fromJsObject(jsObject);
  }

  DocumentSnapshot._fromJsObject(
      firestore_interop.DocumentSnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Map<String, dynamic>? data([firestore_interop.SnapshotOptions? options]) {
    final parsedData = dartify(jsObject.data(options));
    if (parsedData != null) {
      return Map<String, dynamic>.from(parsedData);
    } else {
      return null;
    }
  }

  dynamic get(/*String|FieldPath*/ dynamic fieldPath) =>
      dartify(jsObject.get(fieldPath));

  bool isEqual(DocumentSnapshot other) => firestore_interop
      .snapshotEqual(jsObject as JSObject, other.jsObject as JSObject)
      .toDart;
}

class QuerySnapshot
    extends JsObjectWrapper<firestore_interop.QuerySnapshotJsImpl> {
  static final _expando = Expando<QuerySnapshot>();

  // TODO: [SnapshotListenOptions options]
  List<DocumentChange> docChanges(
      [firestore_interop.SnapshotListenOptions? options]) {
    List<firestore_interop.DocumentChangeJsImpl> changes = options != null
        ? jsObject
            .docChanges(
                jsify(options)! as firestore_interop.SnapshotListenOptions)
            .toDart
            .map((e) => e! as firestore_interop.DocumentChangeJsImpl)
            .toList()
        : jsObject
            .docChanges()
            .toDart
            .map((e) => e! as firestore_interop.DocumentChangeJsImpl)
            .toList();

    return changes
        // explicitly typing the param as dynamic to work-around
        // https://github.com/dart-lang/sdk/issues/33537
        // ignore: unnecessary_lambdas
        .map((dynamic e) => DocumentChange.getInstance(e))
        .toList();
  }

  List<DocumentSnapshot?> get docs => jsObject.docs.toDart
      // explicitly typing the param as dynamic to work-around
      // https://github.com/dart-lang/sdk/issues/33537
      // ignore: unnecessary_lambdas
      .map((dynamic e) => DocumentSnapshot.getInstance(e))
      .toList();

  bool get empty => jsObject.empty.toDart;

  firestore_interop.SnapshotMetadata get metadata => jsObject.metadata;

  Query get query => Query.fromJsObject(jsObject.query);

  num get size => jsObject.size.toDartInt;

  static QuerySnapshot getInstance(
      firestore_interop.QuerySnapshotJsImpl jsObject) {
    return _expando[jsObject] ??= QuerySnapshot._fromJsObject(jsObject);
  }

  QuerySnapshot._fromJsObject(firestore_interop.QuerySnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  void forEach(void Function(DocumentSnapshot?) callback) {
    final callbackWrap = ((JSObject s) => callback(DocumentSnapshot.getInstance(
        s as firestore_interop.DocumentSnapshotJsImpl))).toJS;
    return jsObject.forEach(callbackWrap);
  }

  bool isEqual(QuerySnapshot other) => firestore_interop
      .snapshotEqual(jsObject as JSObject, other.jsObject as JSObject)
      .toDart;
}

class Transaction extends JsObjectWrapper<firestore_interop.TransactionJsImpl> {
  static final _expando = Expando<Transaction>();

  /// Creates a new Transaction from a [jsObject].
  static Transaction getInstance(firestore_interop.TransactionJsImpl jsObject) {
    return _expando[jsObject] ??= Transaction._fromJsObject(jsObject);
  }

  Transaction._fromJsObject(firestore_interop.TransactionJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Transaction delete(DocumentReference documentRef) =>
      Transaction.getInstance(jsObject.delete(documentRef.jsObject));

  Future<DocumentSnapshot> get(DocumentReference documentRef) async {
    final future = jsObject.get(documentRef.jsObject).toDart;
    final result = (await future)! as firestore_interop.DocumentSnapshotJsImpl;
    return DocumentSnapshot.getInstance(result);
  }

  Transaction set(DocumentReference documentRef, Map<String, dynamic> data,
      [firestore_interop.SetOptions? options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(documentRef.jsObject, jsify(data)! as JSObject, options)
        : jsObject.set(documentRef.jsObject, jsify(data)! as JSObject);
    return Transaction.getInstance(jsObjectSet);
  }

  Transaction update(
          DocumentReference documentRef, Map<String, dynamic> data) =>
      Transaction.getInstance(
        jsObject.update(documentRef.jsObject, jsify(data)!),
      );
}

class _FieldValueDelete implements FieldValue {
  @override
  firestore_interop.FieldValue _jsify() => firestore_interop.deleteField();

  @override
  String toString() => 'FieldValue.delete()';
}

class _FieldValueServerTimestamp implements FieldValue {
  @override
  firestore_interop.FieldValue _jsify() => firestore_interop.serverTimestamp();

  @override
  String toString() => 'FieldValue.serverTimestamp()';
}

abstract class _FieldValueArray implements FieldValue {
  final List? elements;

  _FieldValueArray(this.elements);
}

class _FieldValueArrayUnion extends _FieldValueArray {
  _FieldValueArrayUnion(List? elements) : super(elements);

  @override
  firestore_interop.FieldValue? _jsify() {
    return firestore_interop.arrayUnion.callMethodVarArgs<JSAny>(
      'apply'.toJS,
      [
        null,
        jsify(elements),
      ],
    ) as firestore_interop.FieldValue;
  }

  @override
  String toString() => 'FieldValue.arrayUnion($elements)';
}

class _FieldValueArrayRemove extends _FieldValueArray {
  _FieldValueArrayRemove(List? elements) : super(elements);

  @override
  firestore_interop.FieldValue? _jsify() {
    return firestore_interop.arrayRemove.callMethodVarArgs<JSAny>(
      'apply'.toJS,
      [
        null,
        jsify(elements),
      ],
    ) as firestore_interop.FieldValue;
  }

  @override
  String toString() => 'FieldValue.arrayRemove($elements)';
}

class _FieldValueIncrement implements FieldValue {
  final num n;

  _FieldValueIncrement(this.n);

  @override
  firestore_interop.FieldValue _jsify() => firestore_interop.increment(n.toJS);

  @override
  String toString() => 'FieldValue.increment($n)';
}

JSAny? jsifyFieldValue(FieldValue fieldValue) => fieldValue._jsify() as JSAny?;

/// Sentinel values that can be used when writing document fields with set()
/// or update().
abstract class FieldValue {
  firestore_interop.FieldValue? _jsify() {
    throw UnimplementedError('_jsify() has not been implemented');
  }

  static FieldValue serverTimestamp() => _serverTimestamp;

  static FieldValue delete() => _delete;

  static FieldValue arrayUnion(List? elements) =>
      _FieldValueArrayUnion(elements);

  static FieldValue arrayRemove(List? elements) =>
      _FieldValueArrayRemove(elements);

  // If either the operand or the current field value uses floating point
  // precision, all arithmetic follows IEEE 754 semantics. If both values are
  // integers, values outside of JavaScript's safe number range
  // (Number.MIN_SAFE_INTEGER to Number.MAX_SAFE_INTEGER) are also subject
  // to precision loss. Furthermore, once processed by the Firestore backend,
  // all integer operations are capped between -2^63 and 2^63-1.
  static FieldValue increment(num n) => _FieldValueIncrement(n);

  FieldValue._();

  static final FieldValue _serverTimestamp = _FieldValueServerTimestamp();
  static final FieldValue _delete = _FieldValueDelete();
}

class AggregateQuery {
  AggregateQuery(Query query) : _jsQuery = query.jsObject;
  final firestore_interop.QueryJsImpl _jsQuery;

  static String name(platform_interface.AggregateQuery query) {
    return '${query.type.name}_${query.field}';
  }

  Future<AggregateQuerySnapshot> get(
    List<platform_interface.AggregateQuery> aggregateQueries,
  ) async {
    // Create a map of the requests
    final Map<String, Object> requests = {};
    for (final platform_interface.AggregateQuery aggregateQuery
        in aggregateQueries) {
      switch (aggregateQuery.type) {
        case AggregateType.count:
          requests['count'] = firestore_interop.count();
          break;
        case AggregateType.sum:
          requests[name(aggregateQuery)] =
              firestore_interop.sum(aggregateQuery.field!.toJS);
          break;
        case AggregateType.average:
          requests[name(aggregateQuery)] =
              firestore_interop.average(aggregateQuery.field!.toJS);
          break;
      }
    }

    final future = firestore_interop
        .getAggregateFromServer(_jsQuery, jsify(requests)! as JSObject)
        .toDart;
    final result =
        (await future)! as firestore_interop.AggregateQuerySnapshotJsImpl;

    return AggregateQuerySnapshot.getInstance(result);
  }
}

class AggregateQuerySnapshot
    extends JsObjectWrapper<firestore_interop.AggregateQuerySnapshotJsImpl> {
  static final _expando = Expando<AggregateQuerySnapshot>();
  late final Map<String, Object?> _data;

  /// Creates a new [AggregateQuerySnapshot] from a [jsObject].
  static AggregateQuerySnapshot getInstance(
      firestore_interop.AggregateQuerySnapshotJsImpl jsObject) {
    return _expando[jsObject] ??=
        AggregateQuerySnapshot._fromJsObject(jsObject);
  }

  AggregateQuerySnapshot._fromJsObject(
      firestore_interop.AggregateQuerySnapshotJsImpl jsObject)
      : _data = Map.from(dartify(jsObject.data())),
        super.fromJsObject(jsObject);

  int? get count => (_data['count'] as num?)?.toInt();

  double? getDataValue(platform_interface.AggregateQuery query) {
    final value = _data[AggregateQuery.name(query)];
    if (value == null) {
      return null;
    } else {
      return (value as num).toDouble();
    }
  }
}
