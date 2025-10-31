// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_database')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    show AppJsImpl;

part 'data_snapshot_interop.dart';
part 'query_interop.dart';
part 'reference_interop.dart';

@JS()
@staticInterop
external ReferenceJsImpl child(ReferenceJsImpl parentRef, JSString path);

@JS()
@staticInterop
external void connectDatabaseEmulator(
    DatabaseJsImpl database, JSString host, JSNumber port);

@JS()
@staticInterop
external void enableLogging(
    [JSAny /* Func message || JSBoolean enabled */ loggerOrEnabled,
    JSBoolean persistent]);

@JS()
@staticInterop
external JSPromise update(
  ReferenceJsImpl ref,
  JSAny? values,
);
// TODO - new API for implementing post web v9 SDK integration
@JS()
@staticInterop
external void forceLongPolling();

// TODO - new API for implementing post web v9 SDK integration
@JS()
@staticInterop
external void forceWebSockets();

@JS()
@staticInterop
external JSPromise<DataSnapshotJsImpl> get(QueryJsImpl query);

@JS()
@staticInterop
external DatabaseJsImpl getDatabase([AppJsImpl? app, JSString? databaseUrl]);

@JS()
@staticInterop
external void goOffline(DatabaseJsImpl database);

@JS()
@staticInterop
external void goOnline(DatabaseJsImpl database);

@JS()
@staticInterop
external JSAny increment(JSNumber delta);

@JS()
@staticInterop
external JSFunction onChildAdded(
  QueryJsImpl query,
  JSFunction callback,
  // JSAny Function(DataSnapshotJsImpl, [JSString previousChildName]) callback,
  JSFunction cancelCallback,
  // JSAny Function(FirebaseError error) cancelCallback,
);

@JS()
@staticInterop
external JSFunction onChildChanged(
  QueryJsImpl query,
  JSFunction callback,
  // JSAny Function(DataSnapshotJsImpl, [JSString previousChildName]) callback,
  JSFunction cancelCallback,
  // JSAny Function(FirebaseError error) cancelCallback,
);

@JS()
@staticInterop
external JSFunction onChildMoved(
  QueryJsImpl query,
  JSFunction callback,
  // JSAny Function(DataSnapshotJsImpl, [JSString previousChildName]) callback,
  JSFunction cancelCallback,
  // JSAny Function(FirebaseError error) cancelCallback,
);

@JS()
@staticInterop
external JSFunction onChildRemoved(
  QueryJsImpl query,
  JSFunction callback,
  // JSAny Function(DataSnapshotJsImpl, [JSString previousChildName]) callback,
  JSFunction cancelCallback,
  // JSAny Function(FirebaseError error) cancelCallback,
);

@JS()
@staticInterop
external OnDisconnectJsImpl onDisconnect(ReferenceJsImpl ref);

@JS()
@staticInterop
external JSFunction onValue(
  QueryJsImpl query,
  JSFunction callback,
  // JSAny Function(DataSnapshotJsImpl, [JSString previousChildName]) callback,
  JSFunction cancelCallback,
  // JSAny Function(FirebaseError error) cancelCallback,
  [
  ListenOptions options,
]);

@JS()
@staticInterop
external QueryConstraintJsImpl orderByChild(JSString path);

@JS()
@staticInterop
external QueryConstraintJsImpl orderByKey();

@JS()
@staticInterop
external QueryConstraintJsImpl orderByPriority();

@JS()
@staticInterop
external QueryConstraintJsImpl orderByValue();

@JS()
@staticInterop
external ThenableReferenceJsImpl push(ReferenceJsImpl ref, JSAny? value);

@JS()
@staticInterop
external QueryJsImpl query(
  QueryJsImpl query,
  QueryConstraintJsImpl queryConstraint,
);

@JS()
@staticInterop
external ReferenceJsImpl ref(DatabaseJsImpl database, [JSString path]);

@JS()
@staticInterop
external ReferenceJsImpl refFromURL(
  DatabaseJsImpl database,
  JSString url,
);

@JS()
@staticInterop
external JSPromise<ReferenceJsImpl> remove(
  ReferenceJsImpl ref,
);

@JS()
@staticInterop
external JSPromise<TransactionResultJsImpl> runTransaction(
  ReferenceJsImpl ref,
  JSFunction transactionUpdate,
  // Function(JSAny currentData) transactionUpdate,
  TransactionOptions options,
);

@JS()
@staticInterop
external JSAny serverTimestamp();

@JS()
@staticInterop
external JSPromise set(ReferenceJsImpl ref, JSAny? value);

@JS()
@staticInterop
external JSPromise setPriority(
    ReferenceJsImpl ref, /* JSString | JSNumber | null */ JSAny? priority);

@JS()
@staticInterop
external JSPromise setWithPriority(ReferenceJsImpl ref, JSAny? value,
    /* JSString | JSNumber | null */ JSAny? priority);

@JS()
@staticInterop
@anonymous
abstract class TransactionOptions {
  external factory TransactionOptions({JSBoolean applyLocally});

  /// By default, events are raised each time the transaction update function runs.
  /// So if it is run multiple times, you may see intermediate states. You can set
  /// this to false to suppress these intermediate states and instead wait until
  /// the transaction has completed before events are raised.
  external static JSBoolean get applyLocally;
}

// ignore: avoid_classes_with_only_static_members
/// A placeholder value for auto-populating the current timestamp
/// (time since the Unix epoch, in milliseconds) as determined
/// by the Firebase servers.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database#.ServerValue>.
@JS()
@staticInterop
abstract class ServerValue {
  external static JSAny get TIMESTAMP;
}

extension type DatabaseJsImpl._(JSObject _) implements JSObject {
  external AppJsImpl get app;
  external set app(AppJsImpl a);
  external JSString get type;
}

extension type QueryConstraintJsImpl._(JSObject _) implements JSObject {
  external JSString get type;
}

extension type OnDisconnectJsImpl._(JSObject _) implements JSObject {
  external JSPromise cancel([
    JSFunction onComplete,
    //void Function(JSAny) onComplete
  ]);

  external JSPromise remove([
    JSFunction onComplete,
    //void Function(JSAny) onComplete
  ]);

  external JSPromise set(
    JSAny? value, [
    JSFunction onComplete,
    //void Function(JSAny) onComplete
  ]);

  external JSPromise setWithPriority(
    JSAny? value,
    JSAny? priority,
  );

  external JSPromise update(
    JSAny? values,
  );
}

extension type ThenableReferenceJsImpl._(JSObject _)
    implements JSObject, ReferenceJsImpl {
  external JSPromise then([JSFunction? onResolve, JSFunction? onReject]);
}

@JS()
@staticInterop
@anonymous
class TransactionJsImpl {
  external factory TransactionJsImpl({
    JSBoolean? committed,
    DataSnapshotJsImpl? snapshot,
  });
}

extension TransactionJsImplExtension on TransactionJsImpl {
  external JSBoolean get committed;

  external DataSnapshotJsImpl get snapshot;
}

@JS()
@staticInterop
@anonymous
abstract class ListenOptions {
  external factory ListenOptions({JSBoolean onlyOnce});

  external static JSBoolean get onlyOnce;
}

extension type FirebaseError._(JSObject _) implements JSObject {
  external JSString get code;
  external JSString get message;
  external JSString get name;
  external JSString get stack;

  /// Not part of the core JS API, but occasionally exposed in error objects.
  external JSAny get serverResponse;
}

// We type those 7 functions as Object to avoid an issue with dart2js compilation
// in release mode
// Discussed internally with dart2js team
@JS()
@staticInterop
external QueryConstraintJsImpl endAt(JSAny? value, [JSString? key]);

@JS()
@staticInterop
external QueryConstraintJsImpl endBefore(JSAny? value, [JSString? key]);

@JS()
@staticInterop
external QueryConstraintJsImpl equalTo(JSAny? value, [JSString? key]);

@JS()
@staticInterop
external QueryConstraintJsImpl startAfter(JSAny? value, [JSString? key]);

@JS()
@staticInterop
external QueryConstraintJsImpl startAt(JSAny? value, [JSString? key]);

@JS()
@staticInterop
external QueryConstraintJsImpl limitToFirst(JSNumber limit);

@JS()
@staticInterop
external QueryConstraintJsImpl limitToLast(JSNumber limit);
