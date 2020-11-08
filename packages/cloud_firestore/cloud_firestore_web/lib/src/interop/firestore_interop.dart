// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase.firestore')
library firebase_interop.firestore;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'dart:typed_data' show Uint8List;

import 'package:js/js.dart';

/// Sets the verbosity of Cloud Firestore logs.
///
/// Parameter [logLevel] is the verbosity you set for activity and error
/// logging.
///
/// Can be any of the following values:
/// * 'debug' for the most verbose logging level, primarily for debugging.
/// * 'error' to log errors only.
/// * 'silent' to turn off logging.
@JS()
external void setLogLevel(String logLevel);

@JS('Firestore')
abstract class FirestoreJsImpl {
  external AppJsImpl get app;

  external set app(AppJsImpl a);

  external WriteBatchJsImpl batch();

  external CollectionReferenceJsImpl collection(String collectionPath);

  external QueryJsImpl collectionGroup(String collectionId);

  external DocumentReferenceJsImpl doc(String documentPath);

  external PromiseJsImpl<Null> enablePersistence(
      [PersistenceSettings settings]);

  external void Function() onSnapshotsInSync(observer);

  external PromiseJsImpl<Null> clearPersistence();

  external PromiseJsImpl<void> runTransaction(
      Func1<TransactionJsImpl, PromiseJsImpl> updateFunction);

  external void settings(Settings settings);

  external PromiseJsImpl<Null> disableNetwork();

  external PromiseJsImpl<Null> enableNetwork();

  external PromiseJsImpl<Null> terminate();

  external PromiseJsImpl<Null> waitForPendingWrites();
}

@JS('WriteBatch')
abstract class WriteBatchJsImpl {
  external PromiseJsImpl<Null> commit();

  external WriteBatchJsImpl delete(DocumentReferenceJsImpl documentRef);

  external WriteBatchJsImpl set(DocumentReferenceJsImpl documentRef, data,
      [SetOptions options]);

  external WriteBatchJsImpl update(
      DocumentReferenceJsImpl documentRef, dataOrFieldsAndValues);
}

@JS('CollectionReference')
class CollectionReferenceJsImpl extends QueryJsImpl {
  external String get id;

  external set id(String v);

  external DocumentReferenceJsImpl get parent;

  external set parent(DocumentReferenceJsImpl d);

  external String get path;

  external set path(String v);

  external factory CollectionReferenceJsImpl();

  external PromiseJsImpl<DocumentReferenceJsImpl> add(data);

  external DocumentReferenceJsImpl doc([String documentPath]);

  external bool isEqual(CollectionReferenceJsImpl other);
}

@anonymous
@JS()
class PersistenceSettings {
  external bool get synchronizeTabs;

  external factory PersistenceSettings({bool synchronizeTabs});
}

/// A [FieldPath] refers to a field in a document.
/// The path may consist of a single field name (referring to a top-level field
/// in the document), or a list of field names (referring to a nested field in
/// the document).
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FieldPath>.
@JS()
class FieldPath {
  /// Creates a [FieldPath] from the provided field names. If more than one
  /// field name is provided, the path will point to a nested field in a
  /// document.
  external factory FieldPath(String fieldName0,
      [String fieldName1,
      String fieldName2,
      String fieldName3,
      String fieldName4,
      String fieldName5,
      String fieldName6,
      String fieldName7,
      String fieldName8,
      String fieldName9]);

  /// Returns a special sentinel FieldPath to refer to the ID of a document.
  /// It can be used in queries to sort or filter by the document ID.
  external static FieldPath documentId();

  /// Returns `true` if this [FieldPath] is equal to the [other].
  external bool isEqual(Object other);
}

/// An immutable object representing a geo point in Cloud Firestore.
/// The geo point is represented as latitude/longitude pair.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.GeoPoint>.
@JS()
class GeoPoint {
  /// Creates a new immutable [GeoPoint] object with the provided [latitude] and
  /// [longitude] values.
  ///
  /// [latitude] values are in the range of -90 to 90.
  /// [longitude] values are in the range of -180 to 180.
  external factory GeoPoint(num latitude, num longitude);

  /// The latitude of this GeoPoint instance.
  external num get latitude;

  /// The longitude of this GeoPoint instance.
  external num get longitude;

  /// Returns `true` if this [GeoPoint] is equal to the provided [other].
  external bool isEqual(Object other);
}

@JS('Blob')
@anonymous
abstract class Blob {
  external static Blob fromBase64String(String base64);

  external static Blob fromUint8Array(Uint8List list);

  external String toBase64();

  external Uint8List toUint8Array();

  /// Returns `true` if this [Blob] is equal to the provided [other].
  external bool isEqual(Object other);
}

@anonymous
@JS()
abstract class DocumentChangeJsImpl {
  external String /*'added'|'removed'|'modified'*/ get type;

  external set type(String /*'added'|'removed'|'modified'*/ v);

  external DocumentSnapshotJsImpl get doc;

  external set doc(DocumentSnapshotJsImpl v);

  external num get oldIndex;

  external set oldIndex(num v);

  external num get newIndex;

  external set newIndex(num v);
}

@JS('DocumentReference')
abstract class DocumentReferenceJsImpl {
  external FirestoreJsImpl get firestore;

  external set firestore(FirestoreJsImpl f);

  external String get id;

  external set id(String s);

  external CollectionReferenceJsImpl get parent;

  external set parent(CollectionReferenceJsImpl c);

  external String get path;

  external set path(String v);

  external CollectionReferenceJsImpl collection(String collectionPath);

  external PromiseJsImpl<Null> delete();

  external PromiseJsImpl<DocumentSnapshotJsImpl> get([GetOptions options]);

  external void Function() onSnapshot(
    optionsOrObserverOrOnNext,
    observerOrOnNextOrOnError, [
    Func1<FirebaseError, dynamic> onError,
  ]);

  external PromiseJsImpl<Null> set(data, [SetOptions options]);

  external PromiseJsImpl<Null> update(dataOrFieldsAndValues);
}

@JS('DocumentSnapshot')
abstract class DocumentSnapshotJsImpl {
  external bool get exists;

  external set exists(bool v);

  external String get id;

  external set id(String v);

  external SnapshotMetadata get metadata;

  external set metadata(SnapshotMetadata v);

  external DocumentReferenceJsImpl get ref;

  external set ref(DocumentReferenceJsImpl v);

  external dynamic data();

  external dynamic get(/*String|FieldPath*/ fieldPath);

  /// Returns [true] if this [DocumentSnapshotJsImpl] is equal to the provided
  /// one.
  external bool isEqual(DocumentSnapshotJsImpl other);
}

/// Sentinel values that can be used when writing document fields with
/// [set()] or [update()].
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FieldValue>.
@JS()
@anonymous
abstract class FieldValue {
  /// Returns a sentinel for use with [update()] to mark a field for deletion.
  external static FieldValue delete();

  /// Returns a sentinel used with [set()] or [update()] to include a
  /// server-generated timestamp in the written data.
  external static FieldValue serverTimestamp();

  external static FieldValue increment(num n);

  /// Returns `true` if this [FieldValue] is equal to the provided [other].
  external bool isEqual(Object other);
}

/// Used internally to allow calling FieldValue.arrayUnion and arrayRemove
@JS('FieldValue')
external dynamic get fieldValues;

@JS('Query')
abstract class QueryJsImpl {
  external FirestoreJsImpl get firestore;

  external set firestore(FirestoreJsImpl f);

  external QueryJsImpl endAt(
      /*DocumentSnapshot|List<dynamic>*/
      snapshotOrFieldValues);

  external QueryJsImpl endBefore(
      /*DocumentSnapshot|List<dynamic>*/
      snapshotOrFieldValues);

  external PromiseJsImpl<QuerySnapshotJsImpl> get();

  external QueryJsImpl limit(num limit);

  external QueryJsImpl limitToLast(num limit);

  external void Function() onSnapshot(
      SnapshotListenOptions options,
      void Function(QuerySnapshotJsImpl) onNext,
      Func1<FirebaseError, dynamic> onError);

  external QueryJsImpl orderBy(/*String|FieldPath*/ fieldPath,
      [String /*'desc'|'asc'*/ directionStr]);

  external QueryJsImpl startAfter(
      /*DocumentSnapshot|List<dynamic>*/
      snapshotOrFieldValues);

  external QueryJsImpl startAt(
      /*DocumentSnapshot|List<dynamic>*/
      snapshotOrFieldValues);

  external QueryJsImpl where(/*String|FieldPath*/ fieldPath,
      String /*'<'|'<='|'=='|'>='|'>'*/ opStr, value);
}

@JS('QuerySnapshot')
abstract class QuerySnapshotJsImpl {
  // TODO: [SnapshotListenOptions] not currently used.
  external List<DocumentChangeJsImpl> docChanges(
      [SnapshotListenOptions options]);

  external List<DocumentSnapshotJsImpl> get docs;

  external set docs(List<DocumentSnapshotJsImpl> v);

  external bool get empty;

  external set empty(bool v);

  external SnapshotMetadata get metadata;

  external set metadata(SnapshotMetadata v);

  external QueryJsImpl get query;

  external set query(QueryJsImpl v);

  external num get size;

  external set size(num v);

  external void forEach(
    void Function(DocumentSnapshotJsImpl) callback, [
    thisArg,
  ]);

  external bool isEqual(QuerySnapshotJsImpl other);
}

@JS('Transaction')
abstract class TransactionJsImpl {
  external TransactionJsImpl delete(DocumentReferenceJsImpl documentRef);

  external PromiseJsImpl<DocumentSnapshotJsImpl> get(
      DocumentReferenceJsImpl documentRef);

  external TransactionJsImpl set(DocumentReferenceJsImpl documentRef, data,
      [SetOptions options]);

  external TransactionJsImpl update(
      DocumentReferenceJsImpl documentRef, dataOrFieldsAndValues);
}

@JS('Timestamp')
abstract class TimestampJsImpl {
  external int get seconds;

  external int get nanoseconds;

  external factory TimestampJsImpl(int seconds, int nanoseconds);

  //external JsDate toDate();
  external int toMillis();

  external static TimestampJsImpl now();

  //external static TimestampJsImpl fromDate(JsDate date);
  external static TimestampJsImpl fromMillis(int milliseconds);

  external bool isEqual(TimestampJsImpl other);

  @override
  external String toString();
}

/// The set of Cloud Firestore status codes.
/// These status codes are also exposed by gRPC.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FirestoreError>.
@anonymous
@JS()
abstract class FirestoreError {
  external dynamic /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ get code;

  external set code(
      /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/
      v);

  external String get message;

  external set message(String v);

  external String get name;

  external set name(String v);

  external String get stack;

  external set stack(String v);

  external factory FirestoreError(
      {/*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ code,
      String message,
      String name,
      String stack});
}

/// Options for use with `Query.onSnapshot() to control the behavior of the
/// snapshot listener.
@anonymous
@JS()
abstract class SnapshotListenOptions {
  /// Raise an event even if only metadata of the query or document changes.
  ///
  /// Default is `false`.
  external bool get includeMetadataChanges;

  external set includeMetadataChanges(bool value);

  external factory SnapshotListenOptions({bool includeMetadataChanges});
}

/// Specifies custom configurations for your Cloud Firestore instance.
/// You must set these before invoking any other methods.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.Settings>.
@anonymous
@JS()
abstract class Settings {
  external set cacheSizeBytes(int i);

  external set host(String h);

  external set ssl(bool v);

  @Deprecated(
    'This setting will be removed in a future release. You should update '
    'your code to expect Timestamp objects and stop using the '
    'timestampsInSnapshots setting.',
  )
  external set timestampsInSnapshots(bool v);

  external factory Settings({
    int cacheSizeBytes,
    String host,
    bool ssl,
    @Deprecated(
      'This setting will be removed in a future release. You should update '
      'your code to expect Timestamp objects and stop using the '
      'timestampsInSnapshots setting.',
    )
        bool timestampsInSnapshots,
  });
}

/// Metadata about a snapshot, describing the state of the snapshot.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.SnapshotMetadata>.
@JS()
abstract class SnapshotMetadata {
  /// [:true:] if the snapshot includes local writes (set() or update() calls)
  /// that haven't been committed to the backend yet. If your listener has opted
  /// into metadata updates via onDocumentMetadataSnapshot,
  /// onQueryMetadataSnapshot or onMetadataSnapshot, you receive another
  /// snapshot with [hasPendingWrites] set to [:false:] once the writes have
  /// been committed to the backend.
  external bool get hasPendingWrites;

  external set hasPendingWrites(bool v);

  /// [:true:] if the snapshot was created from cached data rather than
  /// guaranteed up-to-date server data. If your listener has opted into
  /// metadata updates (onDocumentMetadataSnapshot, onQueryMetadataSnapshot or
  /// onMetadataSnapshot) you will receive another snapshot with [fromCache] set
  /// to [:false:] once the client has received up-to-date data from the
  /// backend.
  external bool get fromCache;

  external set fromCache(bool v);

  /// Returns [true] if this [SnapshotMetadata] is equal to the provided one.
  external bool isEqual(SnapshotMetadata other);
}

/// Options for use with [DocumentReference.onMetadataChangesSnapshot()] to
/// control the behavior of the snapshot listener.
@anonymous
@JS()
abstract class DocumentListenOptions {
  /// Raise an event even if only metadata of the document changed. Default is
  /// [:false:].
  external bool get includeMetadataChanges;

  external set includeMetadataChanges(bool v);

  external factory DocumentListenOptions({bool includeMetadataChanges});
}

/// An object to configure the [DocumentReference.get] and [Query.get] behavior.
@anonymous
@JS()
abstract class GetOptions {
  /// Describes whether we should get from server or cache.
  external String get source;

  external factory GetOptions({String source});
}

/// An object to configure the [WriteBatch.set] behavior.
/// Pass [: {merge: true} :] to only replace the values specified in the data
/// argument. Fields omitted will remain untouched.
@anonymous
@JS()
abstract class SetOptions {
  /// Set to true to replace only the values from the new data.
  /// Fields omitted will remain untouched.
  external bool get merge;

  external set merge(bool v);

  external set mergeFields(List<String> v);

  external factory SetOptions({bool merge, List<String> mergeFields});
}

/// Options that configure how data is retrieved from a DocumentSnapshot
/// (e.g. the desired behavior for server timestamps that have not yet been set
/// to their final value).
///
/// See: https://firebase.google.com/docs/reference/js/firebase.firestore.SnapshotOptions.
@anonymous
@JS()
abstract class SnapshotOptions {
  /// If set, controls the return value for server timestamps that have not yet
  /// been set to their final value. Possible values are "estimate", "previous"
  /// and "none".
  /// If omitted or set to 'none', null will be returned by default until the
  /// server value becomes available.
  external String get serverTimestamps;

  external factory SnapshotOptions({String serverTimestamps});
}
