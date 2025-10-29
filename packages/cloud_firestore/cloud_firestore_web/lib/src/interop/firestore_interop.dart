// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_firestore')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import './firestore.dart';

@JS()
@staticInterop
external FirestoreJsImpl getFirestore([AppJsImpl? app, JSString? databaseURL]);

@JS()
@staticInterop
external FirestoreJsImpl initializeFirestore(
    [AppJsImpl app, FirestoreSettings settings, JSString? databaseURL]);

@JS()
@staticInterop

/// Type DocumentReferenceJsImpl
external JSPromise<DocumentReferenceJsImpl> addDoc(
  CollectionReferenceJsImpl reference,
  JSAny data,
);

@JS()
@staticInterop
external JSPromise clearIndexedDbPersistence(
  FirestoreJsImpl firestore,
);

@JS()
@staticInterop
external JSPromise setIndexConfiguration(
    FirestoreJsImpl firestore, JSString indexConfiguration);

@JS()
@staticInterop
external PersistentCacheIndexManager? getPersistentCacheIndexManager(
    FirestoreJsImpl firestore);

@JS()
@staticInterop
external void enablePersistentCacheIndexAutoCreation(
    PersistentCacheIndexManager indexManager);

@JS()
@staticInterop
external void disablePersistentCacheIndexAutoCreation(
    PersistentCacheIndexManager indexManager);

@JS()
@staticInterop
external void deleteAllPersistentCacheIndexes(
    PersistentCacheIndexManager indexManager);

@JS()
@staticInterop
external CollectionReferenceJsImpl collection(
  FirestoreJsImpl firestore,
  JSString collectionPath,
);

@JS()
@staticInterop
external QueryJsImpl collectionGroup(
  FirestoreJsImpl firestore,
  JSString collectionId,
);

@JS()
@staticInterop
external void connectFirestoreEmulator(
  FirestoreJsImpl firestore,
  JSString host,
  JSNumber port,
);

@JS()
@staticInterop
external JSPromise deleteDoc(
  DocumentReferenceJsImpl reference,
);

@JS()
@staticInterop
external FieldValue deleteField();

@JS()
@staticInterop
external JSPromise disableNetwork(FirestoreJsImpl firestore);

@JS()
@staticInterop
external DocumentReferenceJsImpl doc(
  JSAny reference, // Firestore | CollectionReference
  [
  JSString documentPath,
]);

@JS()
@staticInterop
external FieldPath documentId();

@JS()
@staticInterop
external JSPromise enableMultiTabIndexedDbPersistence(
  FirestoreJsImpl firestore,
);

@JS()
@staticInterop
external JSPromise enableNetwork(FirestoreJsImpl firestore);

@JS()
@staticInterop
external JSPromise<DocumentSnapshotJsImpl> getDoc(
  DocumentReferenceJsImpl reference,
);

@JS()
@staticInterop
external JSPromise<DocumentSnapshotJsImpl> getDocFromCache(
  DocumentReferenceJsImpl reference,
);

@JS()
@staticInterop
external JSPromise<DocumentSnapshotJsImpl> getDocFromServer(
  DocumentReferenceJsImpl reference,
);

@JS()
@staticInterop
external JSPromise<QuerySnapshotJsImpl> getDocs(
  QueryJsImpl query,
);

@JS()
@staticInterop
external JSPromise<QuerySnapshotJsImpl> getDocsFromCache(
  QueryJsImpl query,
);

@JS()
@staticInterop
external JSPromise<QuerySnapshotJsImpl> getDocsFromServer(
  QueryJsImpl query,
);

@JS()
@staticInterop
external FieldValue increment(JSNumber n);

@JS()
@staticInterop
external QueryConstraintJsImpl limit(JSNumber limit);

@JS()
@staticInterop
external QueryConstraintJsImpl limitToLast(JSNumber limit);

@JS()
@staticInterop
external LoadBundleTaskJsImpl loadBundle(
  FirestoreJsImpl firestore,
  JSUint8Array bundle,
);

@JS()
@staticInterop
external JSPromise namedQuery(
  FirestoreJsImpl firestore,
  JSString name,
);

@JS()
@staticInterop
external JSFunction onSnapshot(
  JSObject reference, // DocumentReference | Query
  JSAny optionsOrObserverOrOnNext,
  JSFunction observerOrOnNextOrOnError, [
  JSFunction? onError,
]);

@JS()
@staticInterop
external JSFunction onSnapshotsInSync(
    FirestoreJsImpl firestore, JSFunction observer);

@JS()
@staticInterop
external QueryConstraintJsImpl orderBy(
  JSObject fieldPath, [
  JSString? direction,
]);

@JS()
@staticInterop
external MemoryLocalCache memoryLocalCache(
  MemoryCacheSettings? settings,
);

@JS()
@staticInterop
external MemoryLruGarbageCollector memoryLruGarbageCollector(
  JSNumber? cacheSizeBytes,
);

@JS()
@staticInterop
external MemoryEagerGarbageCollector memoryEagerGarbageCollector();

@JS()
@staticInterop
external PersistentLocalCache persistentLocalCache(
  PersistentCacheSettings settings,
);

@JS()
@staticInterop
external PersistentSingleTabManager persistentSingleTabManager(
  PersistentSingleTabManagerSettings? settings,
);

@JS()
@staticInterop
external PersistentMultipleTabManager persistentMultipleTabManager(
  PersistentSingleTabManagerSettings? settings,
);

@JS()
@staticInterop
external QueryJsImpl query(
  QueryJsImpl query,
  QueryConstraintJsImpl queryConstraint,
);

@JS()
@staticInterop
external JSBoolean queryEqual(QueryJsImpl left, QueryJsImpl right);

@JS()
@staticInterop
external JSBoolean refEqual(
  JSObject /* DocumentReference | CollectionReference */ left,
  JSObject /* DocumentReference | CollectionReference */ right,
);

@JS()
@staticInterop
external JSPromise runTransaction(
  FirestoreJsImpl firestore,
  // JSPromise Function(TransactionJsImpl) updateFunction,
  JSFunction updateFunction, [
  TransactionOptionsJsImpl? options,
]);

@JS('TransactionOptions')
@staticInterop
@anonymous
abstract class TransactionOptionsJsImpl {
  external factory TransactionOptionsJsImpl({JSNumber maxAttempts});

  /// Maximum number of attempts to commit, after which transaction fails. Default is 5.
  external static JSNumber get maxAttempts;
}

@JS()
@staticInterop
external FieldValue serverTimestamp();

@JS()
@staticInterop
external JSPromise setDoc(
  DocumentReferenceJsImpl reference,
  JSAny? data, [
  SetOptions? options,
]);

@JS()
@staticInterop
external void setLogLevel(JSString logLevel);

@JS()
@staticInterop
external JSBoolean snapshotEqual(
  JSObject /* DocumentSnapshot | QuerySnapshot */ left,
  JSObject /* DocumentSnapshot | QuerySnapshot */ right,
);

@JS()
@staticInterop
external JSPromise terminate(FirestoreJsImpl firestore);

// Object type is forced to prevent JS interop from ignoring the value
@JS()
@staticInterop
external JSObject get updateDoc;

@JS()
@staticInterop
external JSPromise waitForPendingWrites(FirestoreJsImpl firestore);

@JS()
@staticInterop
external QueryConstraintJsImpl where(
  JSAny fieldPath,
  JSString opStr,
  JSAny? value,
);

// Object type is forced to prevent JS interop from ignoring the value
// when using it with an arbitrary number of arguments
@JS()
@staticInterop
external JSObject get or;

// Object type is forced to prevent JS interop from ignoring the value
// when using it with an arbitrary number of arguments
@JS()
@staticInterop
external JSObject get and;

@JS()
@staticInterop
external WriteBatchJsImpl writeBatch(FirestoreJsImpl firestore);

@JS('Firestore')
@staticInterop
abstract class FirestoreJsImpl {}

extension FirestoreJsImplExtension on FirestoreJsImpl {
  external AppJsImpl get app;
  external JSString get type;
}

extension type WriteBatchJsImpl._(JSObject _) implements JSObject {
  external JSPromise commit();

  external WriteBatchJsImpl delete(DocumentReferenceJsImpl documentRef);

  external WriteBatchJsImpl set(
      DocumentReferenceJsImpl documentRef, JSObject data,
      [SetOptions? options]);

  external WriteBatchJsImpl update(
    DocumentReferenceJsImpl documentRef,
    JSAny? dataOrFieldsAndValues,
  );
}

extension type CollectionReferenceJsImpl._(JSObject _) implements QueryJsImpl {
  external JSString get id;
  external DocumentReferenceJsImpl get parent;
  external JSString get path;
}

@anonymous
@JS()
@staticInterop
class PersistenceSettings {
  external factory PersistenceSettings({JSBoolean? synchronizeTabs});
}

extension PersistenceSettingsExtension on PersistenceSettings {
  external JSBoolean get synchronizeTabs;
}

@JS()
@staticInterop
class FieldPath {
  external factory FieldPath(JSString fieldName0,
      [JSString? fieldName1,
      JSString? fieldName2,
      JSString? fieldName3,
      JSString? fieldName4,
      JSString? fieldName5,
      JSString? fieldName6,
      JSString? fieldName7,
      JSString? fieldName8,
      JSString? fieldName9]);
}

extension FieldPathExtension on FieldPath {
  external JSBoolean isEqual(JSObject other);
}

@JS('GeoPoint')
@staticInterop
external GeoPointJsImpl get GeoPointConstructor;

@JS('GeoPoint')
@staticInterop
class GeoPointJsImpl {
  external factory GeoPointJsImpl(JSNumber latitude, JSNumber longitude);
}

extension GeoPointJsImplExtension on GeoPointJsImpl {
  /// The latitude of this GeoPoint instance.
  external JSNumber get latitude;

  /// The longitude of this GeoPoint instance.
  external JSNumber get longitude;

  /// Returns `true` if this [GeoPoint] is equal to the provided [other].
  external JSBoolean isEqual(JSObject other);
}

@JS('VectorValue')
@staticInterop
external VectorValueJsImpl get VectorValueConstructor;

extension type VectorValueJsImpl._(JSObject _) implements JSObject {
  external JSArray toArray();
}

@JS()
@staticInterop
external VectorValueJsImpl vector(JSArray values);

@JS('Bytes')
@staticInterop
external BytesJsImpl get BytesConstructor;

@JS('Bytes')
@staticInterop
@anonymous
abstract class BytesJsImpl {
  external static BytesJsImpl fromBase64JSString(JSString base64);

  external static BytesJsImpl fromUint8Array(JSUint8Array list);
}

extension BytesJsImplExtension on BytesJsImpl {
  external JSString toBase64();

  external JSUint8Array toUint8Array();

  /// Returns `true` if this [Blob] is equal to the provided [other].
  external JSBoolean isEqual(JSObject other);
}

extension type DocumentChangeJsImpl._(JSObject _) implements JSObject {
  external JSString /*'added'|'removed'|'modified'*/ get type;

  external set type(JSString /*'added'|'removed'|'modified'*/ v);

  external DocumentSnapshotJsImpl get doc;

  external set doc(DocumentSnapshotJsImpl v);

  external JSNumber get oldIndex;

  external set oldIndex(JSNumber v);

  external JSNumber get newIndex;

  external set newIndex(JSNumber v);
}

@JS('DocumentReference')
@staticInterop
external DocumentReferenceJsImpl get DocumentReferenceJsConstructor;

extension type DocumentReferenceJsImpl._(JSObject _) implements JSObject {
  external FirestoreJsImpl get firestore;
  external JSString get id;
  external CollectionReferenceJsImpl get parent;
  external JSString get path;
  external JSString get type;
}

@JS('QueryConstraint')
@staticInterop
abstract class QueryConstraintJsImpl {}

extension QueryConstraintJsImplExtension on QueryConstraintJsImpl {
  external JSString get type;
}

extension type LoadBundleTaskJsImpl._(JSObject _) implements JSObject {
  external void onProgress(
    JSFunction? next,
  );

  external JSPromise then([
    JSFunction? onResolve,
    JSFunction onReject,
  ]);
}

extension type LoadBundleTaskProgressJsImpl._(JSObject _) implements JSObject {
// int or String?
  external JSAny get bytesLoaded;

  external JSNumber get documentsLoaded;

  external JSString get taskState;

// int or String?
  external JSAny get totalBytes;

  external JSNumber get totalDocuments;
}

extension type DocumentSnapshotJsImpl._(JSObject _) implements JSObject {
  external JSString get id;
  external SnapshotMetadata get metadata;
  external DocumentReferenceJsImpl get ref;

  external JSObject? data([SnapshotOptions? options]);
  external JSBoolean exists();
  external JSObject get(/*JSString|FieldPath*/ JSObject fieldPath);
}

/// Sentinel values that can be used when writing document fields with
/// [set()] or [update()].
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FieldValue>.
extension type FieldValue._(JSObject _) implements JSObject {
  /// Returns `true` if this [FieldValue] is equal to the provided [other].
  external JSBoolean isEqual(FieldValue other);
}

/// Used internally to allow calling FieldValue.arrayUnion and arrayRemove
@JS('FieldValue')
@staticInterop
external JSObject get fieldValues;

extension type QueryJsImpl._(JSObject _) implements JSObject {
  external FirestoreJsImpl get firestore;
  external JSString get type;
}

extension type QuerySnapshotJsImpl._(JSObject _) implements JSObject {
  external JSArray get docs;
  external JSBoolean get empty;
  external SnapshotMetadata get metadata;
  external JSNumber get size;
  external QueryJsImpl get query;

  external JSArray docChanges([SnapshotListenOptions? options]);

  external void forEach(
    JSFunction callback, [
    JSObject thisArg,
  ]);
}

extension type TransactionJsImpl._(JSObject _) implements JSObject {
  external TransactionJsImpl delete(DocumentReferenceJsImpl documentRef);

  external JSPromise get(DocumentReferenceJsImpl documentRef);

  external TransactionJsImpl set(
      DocumentReferenceJsImpl documentRef, JSObject data,
      [SetOptions? options]);

  external TransactionJsImpl update(
      DocumentReferenceJsImpl documentRef, JSAny dataOrFieldsAndValues);
}

@JS('Timestamp')
@staticInterop
external TimestampJsImpl get TimestampJsConstructor;

@JS('Timestamp')
@staticInterop
abstract class TimestampJsImpl {
  external factory TimestampJsImpl(JSNumber seconds, JSNumber nanoseconds);

  external static TimestampJsImpl now();

  //external static TimestampJsImpl fromDate(JsDate date);
  external static TimestampJsImpl fromMillis(JSNumber milliseconds);
}

extension TimestampJsImplExtension on TimestampJsImpl {
  external JSNumber get seconds;

  external JSNumber get nanoseconds;

  //external JsDate toDate();
  external JSNumber toMillis();

  external JSBoolean isEqual(TimestampJsImpl other);
}

/// The set of Cloud Firestore status codes.
/// These status codes are also exposed by gRPC.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.FirestoreError>.
@anonymous
@JS()
@staticInterop
abstract class FirestoreError {
  external factory FirestoreError(
      {/*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/ JSString
          code,
      JSString? message,
      JSString? name,
      JSString? stack});
}

extension FirestoreErrorExtension on FirestoreError {
  external JSString /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/
      get code;

  external set code(
      /*|'cancelled'|'unknown'|'invalid-argument'|'deadline-exceeded'|'not-found'|'already-exists'|'permission-denied'|'resource-exhausted'|'failed-precondition'|'aborted'|'out-of-range'|'unimplemented'|'internal'|'unavailable'|'data-loss'|'unauthenticated'*/
      JSString v);

  external JSString get message;

  external set message(JSString v);

  external JSString get name;

  external set name(JSString v);

  external JSString get stack;

  external set stack(JSString v);
}

/// Options for use with `Query.onSnapshot() to control the behavior of the
/// snapshot listener.
@anonymous
@JS()
@staticInterop
abstract class SnapshotListenOptions {
  external factory SnapshotListenOptions({
    JSBoolean? includeMetadataChanges,
    JSString? source,
  });
}

extension SnapshotListenOptionsExtension on SnapshotListenOptions {
  /// Raise an event even if only metadata of the query or document changes.
  ///
  /// Default is `false`.
  external JSBoolean get includeMetadataChanges;

  external set includeMetadataChanges(JSBoolean value);

  /// Describes whether we should get from server or cache.
  external JSString get source;
  external set source(JSString value);
}

/// Specifies custom configurations for your Cloud Firestore instance.
/// You must set these before invoking any other methods.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.Settings>.
@anonymous
@JS()
@staticInterop
abstract class FirestoreSettings {
  external factory FirestoreSettings({
    JSNumber? cacheSizeBytes,
    JSString? host,
    JSBoolean? ssl,
    JSBoolean? ignoreUndefinedProperties,
    JSBoolean? experimentalForceLongPolling,
    JSBoolean? experimentalAutoDetectLongPolling,
    JSAny? experimentalLongPollingOptions,
    JSObject localCache,
  });
}

extension FirestoreSettingsExtension on FirestoreSettings {
  //ignore: avoid_setters_without_getters
  external set host(JSString h);

  //ignore: avoid_setters_without_getters
  external set ssl(JSBoolean v);

  //ignore: avoid_setters_without_getters
  external set ignoreUndefinedProperties(JSBoolean u);

  /// Specifies the cache used by the SDK.
  /// Available options are MemoryLocalCache and PersistentLocalCache, each with different configuration options.
  /// When unspecified, MemoryLocalCache will be used by default.
  /// NOTE: setting this field and cacheSizeBytes at the same time will throw exception during SDK initialization.
  /// Instead, using the configuration in the FirestoreLocalCache object to specify the cache size.
  ///
  /// Union type MemoryLocalCache | PersistentLocalCache;
  //ignore: avoid_setters_without_getters
  external set localCache(JSObject u);

  external set experimentalLongPollingOptions(JSAny v);
}

/// Options that configure the SDK’s underlying network transport (WebChannel) when long-polling is used
/// These options are only used if experimentalForceLongPolling is true
/// or if experimentalAutoDetectLongPolling is true and the auto-detection determined that long-polling was needed.
/// Otherwise, these options have no effect.
@anonymous
@JS()
@staticInterop
abstract class ExperimentalLongPollingOptions {
  external factory ExperimentalLongPollingOptions({
    JSNumber? timeoutSeconds,
  });
}

extension ExperimentalLongPollingOptionsExtension
    on ExperimentalLongPollingOptions {
  /// The desired maximum timeout interval, in seconds, to complete a long-polling GET response
  /// Valid values are between 5 and 30, inclusive.
  /// Floating point values are allowed and will be rounded to the nearest millisecond
  /// By default, when long-polling is used the "hanging GET" request sent by the client times out after 30 seconds.
  /// To request a different timeout from the server, set this setting with the desired timeout.
  /// Changing the default timeout may be useful, for example,
  /// if the buffering proxy that necessitated enabling long-polling in the first place has a shorter timeout for hanging GET requests,
  /// in which case setting the long-polling timeout to a shorter value,
  /// such as 25 seconds, may fix prematurely-closed hanging GET requests.
  external JSNumber? get timeoutSeconds;

  external set timeoutSeconds(JSNumber? v);
}

/// Union type from all supported SDK cache layer.
///
/// [MemoryLocalCache] and [MemoryCacheSettings] are the two only cache types supported by the SDK. Custom implementation is not supported.
@anonymous
@JS()
@staticInterop
abstract class FirestoreLocalCache {}

/// Provides an in-memory cache to the SDK. This is the default cache unless explicitly configured otherwise.
///
/// To use, create an instance using the factory function , then set the instance to FirestoreSettings.cache
/// and call initializeFirestore using the settings object.
extension type MemoryLocalCache._(JSObject _) implements JSObject {
  external JSString get kind;
}

/// A tab manager supporting only one tab, no synchronization will be performed across tabs.
extension type PersistentSingleTabManager._(JSObject _) implements JSObject {
  external JSString get kind;
}

/// A tab manager supporting multiple tabs. SDK will synchronize queries and mutations done across all tabs using the SDK.
extension type PersistentMultipleTabManager._(JSObject _) implements JSObject {
  external JSString get kind;
}

/// A garbage collector deletes documents whenever they are not part of any active queries, and have no local mutations attached to them.
///
extension type MemoryEagerGarbageCollector._(JSObject _) implements JSObject {
  external JSString get kind;
}

/// A garbage collector deletes Least-Recently-Used documents in multiple batches.
extension type MemoryLruGarbageCollector._(JSObject _) implements JSObject {
  external JSString get kind;
}

/// Provides an in-memory cache to the SDK. This is the default cache unless explicitly configured otherwise.
///
/// To use, create an instance using the factory function , then set the instance to FirestoreSettings.cache
/// and call initializeFirestore using the settings object.
extension type PersistentLocalCache._(JSObject _) implements JSObject {
  external JSString get kind;
}

/// An settings object to configure an MemoryLocalCache instance.
///
/// See: <https://firebase.google.com/docs/reference/js/firestore_.memorycachesettings>.
@anonymous
@JS()
@staticInterop
abstract class MemoryCacheSettings {
  external factory MemoryCacheSettings({JSObject? garbageCollector});
}

extension MemoryCacheSettingsExtension on MemoryCacheSettings {
  /// The garbage collector to use, for the memory cache layer.
  /// A MemoryEagerGarbageCollector is used when this is undefined.
  /// Union type MemoryEagerGarbageCollector | MemoryLruGarbageCollector;
  external JSObject get garbageCollector;

  external set garbageCollector(JSObject v);
}

/// An settings object to configure an PersistentLocalCache instance.
///
/// See: <https://firebase.google.com/docs/reference/js/firestore_.persistentcachesettings.md#persistentcachesettings_interface>.
@anonymous
@JS()
@staticInterop
abstract class PersistentCacheSettings {
  external factory PersistentCacheSettings({
    JSNumber? cacheSizeBytes,
    JSObject? tabManager,
  });
}

extension PersistentCacheSettingsExtension on PersistentCacheSettings {
  /// An approximate cache size threshold for the on-disk data.
  /// If the cache grows beyond this size, Firestore will start removing data that hasn't been recently used.
  /// The SDK does not guarantee that the cache will stay below that size,
  /// only that if the cache exceeds the given size, cleanup will be attempted.
  /// The default value is 40 MB. The threshold must be set to at least 1 MB,
  /// and can be set to CACHE_SIZE_UNLIMITED to disable garbage collection.
  external JSNumber? get cacheSizeBytes;

  external set cacheSizeBytes(JSNumber? v);

  /// Specifies how multiple tabs/windows will be managed by the SDK.
  /// Union type PersistentSingleTabManager | PersistentMultipleTabManager
  external JSObject get tabManager;

  external set tabManager(JSObject v);
}

/// An settings object to configure an PersistentLocalCache instance.
///
/// See: <https://firebase.google.com/docs/reference/js/firestore_.persistentsingletabmanagersettings>.
extension type PersistentSingleTabManagerSettings._(JSObject _)
    implements JSObject {
  /// Whether to force-enable persistent (IndexedDB) cache for the client.
  /// This cannot be used with multi-tab synchronization and is primarily
  /// intended for use with Web Workers.
  /// Setting this to true will enable IndexedDB, but cause other tabs using
  /// IndexedDB cache to fail.
  external JSBoolean get forceOwnership;

  external set forceOwnership(JSBoolean v);
}

/// Metadata about a snapshot, describing the state of the snapshot.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.firestore.SnapshotMetadata>.
extension type SnapshotMetadata._(JSObject _) implements JSObject {
  /// [:true:] if the snapshot includes local writes (set() or update() calls)
  /// that haven't been committed to the backend yet. If your listener has opted
  /// into metadata updates via onDocumentMetadataSnapshot,
  /// onQueryMetadataSnapshot or onMetadataSnapshot, you receive another
  /// snapshot with [hasPendingWrites] set to [:false:] once the writes have
  /// been committed to the backend.
  external JSBoolean get hasPendingWrites;

  external set hasPendingWrites(JSBoolean v);

  /// [:true:] if the snapshot was created from cached data rather than
  /// guaranteed up-to-date server data. If your listener has opted into
  /// metadata updates (onDocumentMetadataSnapshot, onQueryMetadataSnapshot or
  /// onMetadataSnapshot) you will receive another snapshot with [fromCache] set
  /// to [:false:] once the client has received up-to-date data from the
  /// backend.
  external JSBoolean get fromCache;

  external set fromCache(JSBoolean v);

  /// Returns [true] if this [SnapshotMetadata] is equal to the provided one.
  external JSBoolean isEqual(SnapshotMetadata other);
}

/// Options for use with [DocumentReference.onMetadataChangesSnapshot()] to
/// control the behavior of the snapshot listener.
@anonymous
@JS()
@staticInterop
abstract class DocumentListenOptions {
  external factory DocumentListenOptions({
    JSBoolean? includeMetadataChanges,
    JSString? source,
  });
}

extension DocumentListenOptionsExtension on DocumentListenOptions {
  /// Raise an event even if only metadata of the document changed. Default is
  /// [:false:].
  external JSBoolean get includeMetadataChanges;

  external set includeMetadataChanges(JSBoolean v);

  /// Describes whether we should get from server or cache.
  external JSString get source;
  external set source(JSString v);
}

/// An object to configure the [DocumentReference.get] and [Query.get] behavior.
@anonymous
@JS()
@staticInterop
abstract class GetOptions {
  external factory GetOptions({JSString? source});
}

extension GetOptionsExtension on GetOptions {
  /// Describes whether we should get from server or cache.
  external JSString get source;
}

/// An object to configure the [WriteBatch.set] behavior.
/// Pass [: {merge: true} :] to only replace the values specified in the data
/// argument. Fields omitted will remain untouched.
@anonymous
@JS()
@staticInterop
abstract class SetOptions {
  external factory SetOptions({JSBoolean? merge, JSArray? mergeFields});
}

extension SetOptionsExtension on SetOptions {
  /// Set to true to replace only the values from the new data.
  /// Fields omitted will remain untouched.
  external JSBoolean get merge;

  external set merge(JSBoolean v);

//ignore: avoid_setters_without_getters
  external set mergeFields(JSArray v);
}

/// Options that configure how data is retrieved from a DocumentSnapshot
/// (e.g. the desired behavior for server timestamps that have not yet been set
/// to their final value).
///
/// See: https://firebase.google.com/docs/reference/js/firebase.firestore.SnapshotOptions.
@anonymous
@JS()
@staticInterop
abstract class SnapshotOptions {
  external factory SnapshotOptions({JSString? serverTimestamps});
}

extension SnapshotOptionsExtension on SnapshotOptions {
  /// If set, controls the return value for server timestamps that have not yet
  /// been set to their final value. Possible values are "estimate", "previous"
  /// and "none".
  /// If omitted or set to 'none', null will be returned by default until the
  /// server value becomes available.
  external JSString get serverTimestamps;
}

// We type these 6 functions as Object to avoid an issue with dart2js compilation
// in release mode
// Discussed internally with dart2js team
@JS()
@staticInterop
external JSObject get startAfter;

@JS()
@staticInterop
external JSObject get startAt;

@JS()
@staticInterop
external JSObject get endBefore;

@JS()
@staticInterop
external JSObject get endAt;

@JS()
@staticInterop
external JSObject get arrayRemove;

@JS()
@staticInterop
external JSObject get arrayUnion;

@JS()
@staticInterop
external JSObject count();

@JS()
@staticInterop
external JSObject average(JSString field);

@JS()
@staticInterop
external JSObject sum(JSString field);

@JS()
@staticInterop
external JSPromise getCountFromServer(
  QueryJsImpl query,
);

@JS()
@staticInterop
external JSPromise getAggregateFromServer(
  QueryJsImpl query,
  JSObject specs,
);

extension type AggregateQuerySnapshotJsImpl._(JSObject _) implements JSObject {
  external JSObject data();
}

@anonymous
@JS()
@staticInterop
abstract class PersistentCacheIndexManager {}
