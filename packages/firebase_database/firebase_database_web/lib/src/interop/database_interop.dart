// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_database')
library firebase.database_interop;

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    show PromiseJsImpl, Func1, AppJsImpl;
import 'package:js/js.dart';

part 'data_snapshot_interop.dart';
part 'query_interop.dart';
part 'reference_interop.dart';

@JS()
external ReferenceJsImpl child(ReferenceJsImpl parentRef, String path);

@JS()
external void connectDatabaseEmulator(
    DatabaseJsImpl database, String host, int port);

@JS()
external void enableLogging(
    [/* Func message || bool enabled */ loggerOrEnabled, bool persistent]);

@JS()
external PromiseJsImpl<void> update(
  ReferenceJsImpl ref,
  Object values,
);
// TODO - new API for implementing post web v9 SDK integration
@JS()
external void forceLongPolling();

// TODO - new API for implementing post web v9 SDK integration
@JS()
external void forceWebSockets();

@JS()
external PromiseJsImpl<DataSnapshotJsImpl> get(QueryJsImpl query);

@JS()
external DatabaseJsImpl getDatabase([AppJsImpl? app, String? databaseUrl]);

@JS()
external void goOffline(DatabaseJsImpl database);

@JS()
external void goOnline(DatabaseJsImpl database);

@JS()
external dynamic increment(int delta);

@JS()
external void off([
  QueryJsImpl query,
  String eventType,
  dynamic Function(DataSnapshotJsImpl, [String previousChildName]) callback,
]);

@JS()
external QueryConstraintJsImpl onChildAdded(
  QueryJsImpl query,
  dynamic Function(DataSnapshotJsImpl, [String previousChildName]) callback,
  dynamic Function(FirebaseError error) cancelCallback,
);

@JS()
external QueryConstraintJsImpl onChildChanged(
  QueryJsImpl query,
  dynamic Function(DataSnapshotJsImpl, [String previousChildName]) callback,
  dynamic Function(FirebaseError error) cancelCallback,
);

@JS()
external QueryConstraintJsImpl onChildMoved(
  QueryJsImpl query,
  dynamic Function(DataSnapshotJsImpl, [String previousChildName]) callback,
  dynamic Function(FirebaseError error) cancelCallback,
);

@JS()
external QueryConstraintJsImpl onChildRemoved(
  QueryJsImpl query,
  dynamic Function(DataSnapshotJsImpl, [String previousChildName]) callback,
  dynamic Function(FirebaseError error) cancelCallback,
);

@JS()
external OnDisconnectJsImpl onDisconnect(ReferenceJsImpl ref);

@JS()
external void onValue(
    QueryJsImpl query,
    dynamic Function(DataSnapshotJsImpl) callback,
    dynamic Function(FirebaseError error) cancelCallback,
    [ListenOptions options]);

@JS()
external QueryConstraintJsImpl orderByChild(String path);

@JS()
external QueryConstraintJsImpl orderByKey();

@JS()
external QueryConstraintJsImpl orderByPriority();

@JS()
external QueryConstraintJsImpl orderByValue();

@JS()
external ThenableReferenceJsImpl push(ReferenceJsImpl ref, dynamic value);

@JS()
external QueryJsImpl query(
  QueryJsImpl query,
  QueryConstraintJsImpl queryConstraint,
);

@JS()
external ReferenceJsImpl ref(DatabaseJsImpl database, [String path]);

@JS()
external ReferenceJsImpl refFromURL(
  DatabaseJsImpl database,
  String url,
);

@JS()
external PromiseJsImpl<void> remove(
  ReferenceJsImpl ref,
);

@JS()
external PromiseJsImpl<TransactionResultJsImpl> runTransaction(
  ReferenceJsImpl ref,
  Function(dynamic currentData) transactionUpdate,
  TransactionOptions options,
);

@JS()
external dynamic serverTimestamp();

@JS()
external PromiseJsImpl<void> set(ReferenceJsImpl ref, dynamic value);

@JS()
external PromiseJsImpl<void> setPriority(
    ReferenceJsImpl ref, /* string | int | null */ dynamic priority);

@JS()
external PromiseJsImpl<void> setWithPriority(ReferenceJsImpl ref, dynamic value,
    /* string | int | null */ dynamic priority);

@JS()
@anonymous
abstract class TransactionOptions {
  /// By default, events are raised each time the transaction update function runs.
  /// So if it is run multiple times, you may see intermediate states. You can set
  /// this to false to suppress these intermediate states and instead wait until
  /// the transaction has completed before events are raised.
  external static bool get applyLocally;

  external factory TransactionOptions({bool applyLocally});
}

// ignore: avoid_classes_with_only_static_members
/// A placeholder value for auto-populating the current timestamp
/// (time since the Unix epoch, in milliseconds) as determined
/// by the Firebase servers.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database#.ServerValue>.
@JS()
abstract class ServerValue {
  external static Object get TIMESTAMP;
}

@JS('Database')
abstract class DatabaseJsImpl {
  external AppJsImpl get app;
  external set app(AppJsImpl a);
  external String get type;
}

@JS('QueryConstraint')
abstract class QueryConstraintJsImpl {
  external String get type;
}

@JS('OnDisconnect')
abstract class OnDisconnectJsImpl {
  external PromiseJsImpl<void> cancel([void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> remove([void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> set(value, [void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> setWithPriority(
    value,
    priority,
  );

  external PromiseJsImpl<void> update(
    values,
  );
}

@JS('ThenableReference')
abstract class ThenableReferenceJsImpl extends ReferenceJsImpl
    implements PromiseJsImpl<ReferenceJsImpl> {
  @override
  external PromiseJsImpl<void> then([Func1? onResolve, Func1? onReject]);
}

@JS()
@anonymous
class TransactionJsImpl {
  external bool get committed;

  external DataSnapshotJsImpl get snapshot;

  external factory TransactionJsImpl({
    bool? committed,
    DataSnapshotJsImpl? snapshot,
  });
}

@JS()
@anonymous
abstract class ListenOptions {
  // Whether to remove the listener after its first invocation.
  external static bool get onlyOnce;

  external factory ListenOptions({bool onlyOnce});
}

@JS()
@anonymous
abstract class FirebaseError {
  external String get code;
  external String get message;
  external String get name;
  external String get stack;

  /// Not part of the core JS API, but occasionally exposed in error objects.
  external Object get serverResponse;
}

// We type those 7 functions as Object to avoid an issue with dart2js compilation
// in release mode
// Discussed internally with dart2js team
@JS()
external Object get endAt;

@JS()
external Object get endBefore;

@JS()
external Object get equalTo;

@JS()
external Object get startAfter;

@JS()
external Object get startAt;

@JS()
external Object get limitToFirst;

@JS()
external Object get limitToLast;
