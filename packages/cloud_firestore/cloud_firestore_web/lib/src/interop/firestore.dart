// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs
// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    hide jsify, dartify;
import 'package:js/js.dart';

import 'firebase_interop.dart' as firebase_interop;
import 'firestore_interop.dart' as firestore_interop;
import 'utils/utils.dart';

export 'firestore_interop.dart';

/// Given an AppJSImp, return the Firestore instance.
Firestore getFirestoreInstance([App? app]) {
  return Firestore.getInstance(app != null
      ? firebase_interop.firestore(app.jsObject)
      : firebase_interop.firestore());
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

  WriteBatch? batch() => WriteBatch.getInstance(jsObject.batch());

  CollectionReference collection(String collectionPath) =>
      CollectionReference.getInstance(jsObject.collection(collectionPath));

  Query collectionGroup(String collectionId) =>
      Query.fromJsObject(jsObject.collectionGroup(collectionId));

  DocumentReference doc(String documentPath) =>
      DocumentReference.getInstance(jsObject.doc(documentPath));

  Future<Null> enablePersistence(
          [firestore_interop.PersistenceSettings? settings]) =>
      handleThenable(jsObject.enablePersistence(settings));

  Stream<void> snapshotsInSync() {
    late StreamController<void> controller;
    late ZoneCallback onSnapshotsInSyncUnsubscribe;
    var nextWrapper =
        allowInterop((firestore_interop.DocumentSnapshotJsImpl snapshot) {
      controller.add(null);
    });

    void startListen() {
      onSnapshotsInSyncUnsubscribe = jsObject.onSnapshotsInSync(nextWrapper);
    }

    void stopListen() {
      onSnapshotsInSyncUnsubscribe();
      controller.close();
    }

    controller = StreamController<void>.broadcast(
      onListen: startListen,
      onCancel: stopListen,
    );

    return controller.stream;
  }

  Future<Null> clearPersistence() =>
      handleThenable(jsObject.clearPersistence());

  Future runTransaction(Function(Transaction?) updateFunction) {
    var updateFunctionWrap = allowInterop((transaction) =>
        handleFutureWithMapper(
            updateFunction(Transaction.getInstance(transaction)), jsify));

    return handleThenable(jsObject.runTransaction(updateFunctionWrap))
        .then((value) => dartify(null));
  }

  void settings(firestore_interop.Settings settings) =>
      jsObject.settings(settings);

  Future enableNetwork() => handleThenable(jsObject.enableNetwork());

  Future disableNetwork() => handleThenable(jsObject.disableNetwork());

  Future<Null> terminate() => handleThenable(jsObject.terminate());

  Future<Null> waitForPendingWrites() =>
      handleThenable(jsObject.waitForPendingWrites());
}

class WriteBatch extends JsObjectWrapper<firestore_interop.WriteBatchJsImpl>
    with _Updatable {
  static final _expando = Expando<WriteBatch>();

  /// Creates a new WriteBatch from a [jsObject].
  static WriteBatch getInstance(firestore_interop.WriteBatchJsImpl jsObject) {
    return _expando[jsObject] ??= WriteBatch._fromJsObject(jsObject);
  }

  WriteBatch._fromJsObject(firestore_interop.WriteBatchJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Future<Null> commit() => handleThenable(jsObject.commit());

  WriteBatch delete(DocumentReference documentRef) =>
      WriteBatch.getInstance(jsObject.delete(documentRef.jsObject));

  WriteBatch set(DocumentReference documentRef, Map<String, dynamic> data,
      [firestore_interop.SetOptions? options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(documentRef.jsObject, jsify(data), options)
        : jsObject.set(documentRef.jsObject, jsify(data));
    return WriteBatch.getInstance(jsObjectSet);
  }

  WriteBatch update(DocumentReference documentRef, Map<String, dynamic> data) =>
      WriteBatch.getInstance(
          _wrapUpdateFunctionCall(jsObject, data, documentRef));
}

class DocumentReference
    extends JsObjectWrapper<firestore_interop.DocumentReferenceJsImpl>
    with _Updatable {
  static final _expando = Expando<DocumentReference>();

  /// Non-null [Firestore] the document is in.
  /// This is useful for performing transactions, for example.
  Firestore get firestore => Firestore.getInstance(jsObject.firestore);

  String get id => jsObject.id;

  CollectionReference? get parent =>
      CollectionReference.getInstance(jsObject.parent);

  String get path => jsObject.path;

  /// Creates a new DocumentReference from a [jsObject].
  static DocumentReference getInstance(
      firestore_interop.DocumentReferenceJsImpl jsObject) {
    return _expando[jsObject] ??= DocumentReference._fromJsObject(jsObject);
  }

  DocumentReference._fromJsObject(
      firestore_interop.DocumentReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  CollectionReference? collection(String collectionPath) =>
      CollectionReference.getInstance(jsObject.collection(collectionPath));

  Future<Null> delete() => handleThenable(jsObject.delete());

  Future<DocumentSnapshot> get([firestore_interop.GetOptions? options]) {
    var jsObjectSet =
        (options != null) ? jsObject.get(options) : jsObject.get();
    return handleThenable(jsObjectSet).then(DocumentSnapshot.getInstance);
  }

  /// Attaches a listener for [DocumentSnapshot] events.
  Stream<DocumentSnapshot> get onSnapshot => _createStream();

  Stream<DocumentSnapshot> get onMetadataChangesSnapshot => _createStream(
      firestore_interop.DocumentListenOptions(includeMetadataChanges: true));

  Stream<DocumentSnapshot> _createStream(
      [firestore_interop.DocumentListenOptions? options]) {
    late ZoneCallback onSnapshotUnsubscribe;
    late StreamController<DocumentSnapshot> controller;

    final nextWrapper =
        allowInterop((firestore_interop.DocumentSnapshotJsImpl snapshot) {
      controller.add(DocumentSnapshot.getInstance(snapshot));
    });

    final errorWrapper = allowInterop((e) => controller.addError(e));

    void startListen() {
      onSnapshotUnsubscribe = (options != null)
          ? jsObject.onSnapshot(options, nextWrapper, errorWrapper)
          : jsObject.onSnapshot(nextWrapper, errorWrapper);
    }

    void stopListen() {
      onSnapshotUnsubscribe();
      controller.close();
    }

    controller = StreamController<DocumentSnapshot>.broadcast(
        onListen: startListen, onCancel: stopListen, sync: true);

    return controller.stream;
  }

  Future<Null> set(Map<String, dynamic> data,
      [firestore_interop.SetOptions? options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(jsify(data), options)
        : jsObject.set(jsify(data));
    return handleThenable(jsObjectSet);
  }

  Future<Null> update(Map<String, dynamic> data) =>
      handleThenable(_wrapUpdateFunctionCall(jsObject, data));
}

class Query<T extends firestore_interop.QueryJsImpl>
    extends JsObjectWrapper<T> {
  Firestore get firestore => Firestore.getInstance(jsObject.firestore);

  /// Creates a new Query from a [jsObject].
  Query.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  Query endAt({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(
          _wrapPaginatingFunctionCall('endAt', snapshot, fieldValues));

  Query endBefore({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(
          _wrapPaginatingFunctionCall('endBefore', snapshot, fieldValues));

  Future<QuerySnapshot> get([firestore_interop.GetOptions? options]) =>
      handleThenable<firestore_interop.QuerySnapshotJsImpl>(jsObject.get())
          .then(QuerySnapshot.getInstance);

  Query limit(num limit) => Query.fromJsObject(jsObject.limit(limit));

  Query limitToLast(num limit) =>
      Query.fromJsObject(jsObject.limitToLast(limit));

  Stream<QuerySnapshot> get onSnapshot => _createStream(false);

  Stream<QuerySnapshot> get onSnapshotMetadata => _createStream(true);

  Stream<QuerySnapshot> _createStream(bool includeMetadataChanges) {
    late ZoneCallback onSnapshotUnsubscribe;
    late StreamController<QuerySnapshot> controller;

    final nextWrapper =
        allowInterop((firestore_interop.QuerySnapshotJsImpl snapshot) {
      controller.add(QuerySnapshot._fromJsObject(snapshot));
    });
    final errorWrapper = allowInterop((e) => controller.addError(e));
    final options = firestore_interop.SnapshotListenOptions(
        includeMetadataChanges: includeMetadataChanges);

    void startListen() {
      onSnapshotUnsubscribe =
          jsObject.onSnapshot(options, nextWrapper, errorWrapper);
    }

    void stopListen() {
      onSnapshotUnsubscribe();
      controller.close();
    }

    controller = StreamController<QuerySnapshot>.broadcast(
        onListen: startListen, onCancel: stopListen, sync: true);

    return controller.stream;
  }

  Query orderBy(/*String|FieldPath*/ dynamic fieldPath,
      [String? /*'desc'|'asc'*/ directionStr]) {
    var jsObjectOrderBy = (directionStr != null)
        ? jsObject.orderBy(fieldPath, directionStr)
        : jsObject.orderBy(fieldPath);
    return Query.fromJsObject(jsObjectOrderBy);
  }

  Query startAfter({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(
          _wrapPaginatingFunctionCall('startAfter', snapshot, fieldValues));

  Query startAt({DocumentSnapshot? snapshot, List<dynamic>? fieldValues}) =>
      Query.fromJsObject(
          _wrapPaginatingFunctionCall('startAt', snapshot, fieldValues));

  Query where(/*String|FieldPath*/ dynamic fieldPath,
          String /*'<'|'<='|'=='|'>='|'>'*/ opStr, dynamic value) =>
      Query.fromJsObject(jsObject.where(fieldPath, opStr, jsify(value)));

  /// Calls js paginating [method] with [DocumentSnapshot] or List of
  /// [fieldValues].
  /// We need to call this method in all paginating methods to fix that Dart
  /// doesn't support varargs - we need to use [List] to call js function.
  S? _wrapPaginatingFunctionCall<S>(
      String method, DocumentSnapshot? snapshot, List<dynamic>? fieldValues) {
    if (snapshot == null && fieldValues == null) {
      throw ArgumentError(
          'Please provide either snapshot or fieldValues parameter.');
    }

    var args = (snapshot != null)
        ? [snapshot.jsObject]
        : fieldValues!.map(jsify).toList();
    return callMethod(jsObject, method, args);
  }
}

class CollectionReference<T extends firestore_interop.CollectionReferenceJsImpl>
    extends Query<T> {
  static final _expando = Expando<CollectionReference>();

  String get id => jsObject.id;

  DocumentReference? get parent =>
      DocumentReference.getInstance(jsObject.parent);

  String get path => jsObject.path;

  /// Creates a new CollectionReference from a [jsObject].
  static CollectionReference getInstance(
      firestore_interop.CollectionReferenceJsImpl jsObject) {
    return _expando[jsObject] ??= CollectionReference._fromJsObject(jsObject);
  }

  factory CollectionReference() => CollectionReference._fromJsObject(
      firestore_interop.CollectionReferenceJsImpl());

  CollectionReference._fromJsObject(
      firestore_interop.CollectionReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject as T);

  Future<DocumentReference> add(Map<String, dynamic> data) =>
      handleThenable<firestore_interop.DocumentReferenceJsImpl>(
              jsObject.add(jsify(data)))
          .then(DocumentReference.getInstance);

  DocumentReference doc([String? documentPath]) {
    var jsObjectDoc =
        (documentPath != null) ? jsObject.doc(documentPath) : jsObject.doc();
    return DocumentReference.getInstance(jsObjectDoc);
  }

  bool isEqual(CollectionReference other) => jsObject.isEqual(other.jsObject);
}

class DocumentChange
    extends JsObjectWrapper<firestore_interop.DocumentChangeJsImpl> {
  static final _expando = Expando<DocumentChange>();

  String get type => jsObject.type;

  DocumentSnapshot? get doc => DocumentSnapshot.getInstance(jsObject.doc);

  num get oldIndex => jsObject.oldIndex;

  num get newIndex => jsObject.newIndex;

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

  bool get exists => jsObject.exists;

  String get id => jsObject.id;

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

  Map<String, dynamic>? data() => dartify(jsObject.data());

  dynamic get(/*String|FieldPath*/ dynamic fieldPath) =>
      dartify(jsObject.get(fieldPath));

  bool isEqual(DocumentSnapshot other) => jsObject.isEqual(other.jsObject);
}

class QuerySnapshot
    extends JsObjectWrapper<firestore_interop.QuerySnapshotJsImpl> {
  static final _expando = Expando<QuerySnapshot>();

  // TODO: [SnapshotListenOptions options]
  List<DocumentChange> docChanges(
          [firestore_interop.SnapshotListenOptions? options]) =>
      jsObject
          .docChanges(jsify(options))
          // explicitly typing the param as dynamic to work-around
          // https://github.com/dart-lang/sdk/issues/33537
          // ignore: unnecessary_lambdas
          .map((dynamic e) => DocumentChange.getInstance(e))
          .toList();

  List<DocumentSnapshot?> get docs => jsObject.docs
      // explicitly typing the param as dynamic to work-around
      // https://github.com/dart-lang/sdk/issues/33537
      // ignore: unnecessary_lambdas
      .map((dynamic e) => DocumentSnapshot.getInstance(e))
      .toList();

  bool get empty => jsObject.empty;

  firestore_interop.SnapshotMetadata get metadata => jsObject.metadata;

  Query get query => Query.fromJsObject(jsObject.query);

  num get size => jsObject.size;

  static QuerySnapshot getInstance(
      firestore_interop.QuerySnapshotJsImpl jsObject) {
    return _expando[jsObject] ??= QuerySnapshot._fromJsObject(jsObject);
  }

  QuerySnapshot._fromJsObject(firestore_interop.QuerySnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  void forEach(Function(DocumentSnapshot?) callback) {
    var callbackWrap =
        allowInterop((s) => callback(DocumentSnapshot.getInstance(s)));
    return jsObject.forEach(callbackWrap);
  }

  bool isEqual(QuerySnapshot other) => jsObject.isEqual(other.jsObject);
}

class Transaction extends JsObjectWrapper<firestore_interop.TransactionJsImpl>
    with _Updatable {
  static final _expando = Expando<Transaction>();

  /// Creates a new Transaction from a [jsObject].
  static Transaction getInstance(firestore_interop.TransactionJsImpl jsObject) {
    return _expando[jsObject] ??= Transaction._fromJsObject(jsObject);
  }

  Transaction._fromJsObject(firestore_interop.TransactionJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Transaction delete(DocumentReference documentRef) =>
      Transaction.getInstance(jsObject.delete(documentRef.jsObject));

  Future<DocumentSnapshot> get(DocumentReference documentRef) =>
      handleThenable<firestore_interop.DocumentSnapshotJsImpl>(
              jsObject.get(documentRef.jsObject))
          .then(DocumentSnapshot.getInstance);

  Transaction set(DocumentReference documentRef, Map<String, dynamic> data,
      [firestore_interop.SetOptions? options]) {
    var jsObjectSet = (options != null)
        ? jsObject.set(documentRef.jsObject, jsify(data), options)
        : jsObject.set(documentRef.jsObject, jsify(data));
    return Transaction.getInstance(jsObjectSet);
  }

  Transaction update(
          DocumentReference documentRef, Map<String, dynamic> data) =>
      Transaction.getInstance(
          _wrapUpdateFunctionCall(jsObject, data, documentRef));
}

/// Mixin class for all classes with the [update()] method. We need to call
/// [_wrapUpdateFunctionCall()] in all [update()] methods to fix that Dart
/// doesn't support varargs - we need to use [List] to call js function.
abstract class _Updatable {
  /// Calls js [:update():] method on [jsObject] with [data] or list of
  /// [fieldsAndValues] and optionally [documentRef].
  T? _wrapUpdateFunctionCall<T>(jsObject, Map<String, dynamic> data,
      [DocumentReference? documentRef]) {
    var args = [jsify(data)];
    // documentRef has to be the first parameter in list of args
    if (documentRef != null) {
      args.insert(0, documentRef.jsObject);
    }
    return callMethod(jsObject, 'update', args);
  }
}

class _FieldValueDelete implements FieldValue {
  @override
  firestore_interop.FieldValue _jsify() =>
      firestore_interop.FieldValue.delete();

  @override
  String toString() => 'FieldValue.delete()';
}

class _FieldValueServerTimestamp implements FieldValue {
  @override
  firestore_interop.FieldValue _jsify() =>
      firestore_interop.FieldValue.serverTimestamp();

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
    // This uses var arg so cannot use js package
    return callMethod(
        firestore_interop.fieldValues, 'arrayUnion', jsify(elements));
  }

  @override
  String toString() => 'FieldValue.arrayUnion($elements)';
}

class _FieldValueArrayRemove extends _FieldValueArray {
  _FieldValueArrayRemove(List? elements) : super(elements);

  @override
  firestore_interop.FieldValue? _jsify() {
    // This uses var arg so cannot use js package
    return callMethod(
        firestore_interop.fieldValues, 'arrayRemove', jsify(elements));
  }

  @override
  String toString() => 'FieldValue.arrayRemove($elements)';
}

class _FieldValueIncrement implements FieldValue {
  final num n;

  _FieldValueIncrement(this.n);

  @override
  firestore_interop.FieldValue _jsify() =>
      firestore_interop.FieldValue.increment(n);

  @override
  String toString() => 'FieldValue.increment($n)';
}

dynamic jsifyFieldValue(FieldValue fieldValue) => fieldValue._jsify();

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
