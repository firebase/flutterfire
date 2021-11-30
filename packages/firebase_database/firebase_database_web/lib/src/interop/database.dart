// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references, require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_web/firebase_database_web.dart'
    show convertFirebaseDatabaseException;
import 'package:flutter/widgets.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'app.dart';
import 'database_interop.dart' as database_interop;
import 'firebase_interop.dart' as firebase_interop;
import 'utils/utils.dart';

/// Given an AppJSImp, return the Database instance.
Database getDatabaseInstance([App? app, String? databaseURL]) {
  App databaseApp =
      app ?? Database.getInstance(firebase_interop.database()).app;
  return databaseApp.database(databaseURL);
}

/// get the App instance
App getApp(String? name) {
  final jsObject =
      (name != null) ? firebase_interop.app(name) : firebase_interop.app();

  return App.getInstance(jsObject);
}

/// Logs debugging information to the console.
/// If [persistent], it remembers the logging state between page refreshes.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database#.enableLogging>.
void enableLogging(bool enable, [bool persistent = false]) {
  database_interop.enableLogging(
    enable ? (message) => debugPrint('@firebase/database: $message') : enable,
    persistent,
  );
}

/// Firebase realtime database service class.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database>.
class Database
    extends core_interop.JsObjectWrapper<database_interop.DatabaseJsImpl> {
  static final _expando = Expando<Database>();

  /// App for this instance of database service.
  App get app => App.getInstance(jsObject.app);

  /// Creates a new Database from a [jsObject].
  static Database getInstance(database_interop.DatabaseJsImpl jsObject) =>
      _expando[jsObject] ??= Database._fromJsObject(jsObject);

  Database._fromJsObject(database_interop.DatabaseJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Disconnects from the server, all database operations will be
  /// completed offline.
  void goOffline() => jsObject.goOffline();

  /// Connects to the server and synchronizes the offline database
  /// state with the server state.
  void goOnline() => jsObject.goOnline();

  void useDatabaseEmulator(String host, int port) =>
      jsObject.useEmulator(host, port);

  /// Returns a [DatabaseReference] to the root or provided [path].
  DatabaseReference ref([String? path = '/']) =>
      DatabaseReference.getInstance(jsObject.ref(path ?? '/'));

  /// Returns a [DatabaseReference] from provided [url].
  /// Url must be in the same domain as the current database.
  DatabaseReference refFromURL(String url) =>
      DatabaseReference.getInstance(jsObject.refFromURL(url));
}

/// A DatabaseReference represents a specific location in database and
/// can be used for reading or writing data to that database location.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.Reference>.
class DatabaseReference<T extends database_interop.ReferenceJsImpl>
    extends Query<T> {
  static final _expando = Expando<DatabaseReference>();

  /// The last part of the current path.
  /// It is `null` in case of root DatabaseReference.
  String? get key => jsObject.key;

  /// The parent location of a DatabaseReference.
  DatabaseReference? get parent {
    final jsParent = jsObject.parent;
    if (jsParent == null) return null;
    return DatabaseReference.getInstance(jsParent);
  }

  /// The root location of a DatabaseReference.
  DatabaseReference get root => DatabaseReference.getInstance(jsObject.root);

  /// Creates a new DatabaseReference from a [jsObject].
  static DatabaseReference getInstance(
    database_interop.ReferenceJsImpl jsObject,
  ) =>
      _expando[jsObject] ??= DatabaseReference._fromJsObject(jsObject);

  DatabaseReference._fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Returns child DatabaseReference from provided relative [path].
  DatabaseReference child(String path) =>
      DatabaseReference.getInstance(jsObject.child(path));

  /// Returns [OnDisconnect] object.
  OnDisconnect onDisconnect() =>
      OnDisconnect.fromJsObject(jsObject.onDisconnect());

  /// Pushes provided [value] to the actual location.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  ///
  /// If the [value] is not provided, no data is written to the database
  /// but the [ThenableReference] is still returned and can be used for later
  /// operation.
  ///
  ///     DatabaseReference ref = firebase.database().ref('messages');
  ///     ThenableReference childRef = ref.push();
  ///     childRef.set({'text': 'Hello'});
  ///
  /// This method returns [ThenableReference], [DatabaseReference]
  /// with a [Future] property.
  ThenableReference push([value]) =>
      ThenableReference.fromJsObject(jsObject.push(jsify(value)));

  /// Removes data from actual database location.
  Future remove() => core_interop.handleThenable(jsObject.remove());

  /// Sets data at actual database location to provided [value].
  /// Overwrites any existing data at actual location and all child locations.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future set(value) => core_interop.handleThenable(jsObject.set(jsify(value)));

  /// Sets a priority for data at actual database location.
  ///
  /// The [priority] must be a [String], [num] or `null`, or the error is thrown.
  Future setPriority(priority) =>
      core_interop.handleThenable(jsObject.setPriority(priority));

  /// Sets data [newVal] at actual database location with provided priority
  /// [newPriority].
  ///
  /// Like [set()] but also specifies the priority.
  ///
  /// The [newVal] must be a Dart basic type or the error is thrown.
  /// The [newPriority] must be a [String], [num] or `null`, or the error
  /// is thrown.
  Future setWithPriority(newVal, newPriority) => core_interop
      .handleThenable(jsObject.setWithPriority(jsify(newVal), newPriority));

  /// Atomically updates data at actual database location.
  ///
  /// This method is used to update the existing value to a new value,
  /// ensuring there are no conflicts with other clients writing to the same
  /// location at the same time.
  ///
  /// The provided [transactionUpdate] function is used to update
  /// the current value into a new value.
  ///
  ///     DatabaseReference ref = firebase.database().ref('numbers');
  ///     ref.set(2);
  ///     ref.transaction((currentValue) => currentValue * 2);
  ///
  ///     var event = await ref.once('value');
  ///     print(event.snapshot.val()); //prints 4
  ///
  /// The returned value from [transactionUpdate] function must be a Dart basic
  /// type or the error is thrown.
  ///
  /// Set [applyLocally] to `false` to not see intermediate states.
  Future<Transaction> transaction(
      TransactionHandler transactionUpdate, bool applyLocally) async {
    final c = Completer<Transaction>();

    final transactionUpdateWrap = allowInterop((update) {
      final dartUpdate = dartify(update);
      final transaction = transactionUpdate(dartUpdate);
      if (transaction.aborted) {
        return undefined;
      }
      return jsify(transaction.value);
    });

    final onCompleteWrap = allowInterop((error, committed, snapshot) {
      if (error != null) {
        final dartified = dartify(error);

        c.completeError(convertFirebaseDatabaseException(dartified));
      } else {
        c.complete(Transaction(
          committed: committed,
          snapshot: DataSnapshot._fromJsObject(snapshot),
        ));
      }
    });

    jsObject.transaction(
      transactionUpdateWrap,
      onCompleteWrap,
      applyLocally,
    );

    return c.future;
  }

  /// Updates data with [values] at actual database location.
  ///
  /// The [values] must be a Dart basic type or the error is thrown.
  Future update(values) =>
      core_interop.handleThenable(jsObject.update(jsify(values)));
}

/// Event fired when data changes at location.
///
/// Example:
///
///     Database database = firebase.database();
///     database.ref('messages').onValue.listen((QueryEvent e) {
///       DataSnapshot dataSnapshot = e.snapshot;
///       //...
///     });
class QueryEvent {
  /// Immutable copy of the data at a database location.
  final DataSnapshot snapshot;

  /// String containing the key of the previous child.
  final String? prevChildKey;

  /// Creates a new QueryEvent with [snapshot] and optional [prevChildKey].
  QueryEvent(this.snapshot, [this.prevChildKey]);
}

/// A Query sorts and filters the data at a database location so only
/// a subset of the child data is included. This can be used to order
/// a collection of data by some attribute as well as to restrict
/// a large list of items down to a number suitable for synchronizing
/// to the client.
///
/// Queries are created by chaining together one or more of the filter
/// methods defined in this class.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.Query>.
class Query<T extends database_interop.QueryJsImpl>
    extends core_interop.JsObjectWrapper<T> {
  /// DatabaseReference to the Query's location.
  DatabaseReference get ref => DatabaseReference.getInstance(jsObject.ref);

  late final Stream<QueryEvent> _onValue = _createStream('value');

  /// Stream for a value event. Event is triggered once with the initial
  /// data stored at location, and then again each time the data changes.
  Stream<QueryEvent> get onValue => _onValue;

  late final Stream<QueryEvent> _onChildAdded = _createStream('child_added');

  /// Stream for a child_added event. Event is triggered once for each
  /// initial child at location, and then again every time a new child is added.
  Stream<QueryEvent> get onChildAdded => _onChildAdded;

  late final Stream<QueryEvent> _onChildRemoved =
      _createStream('child_removed');

  /// Stream for a child_removed event. Event is triggered once every time
  /// a child is removed.
  Stream<QueryEvent> get onChildRemoved => _onChildRemoved;

  late final Stream<QueryEvent> _onChildChanged =
      _createStream('child_changed');

  /// Stream for a child_changed event. Event is triggered when the data
  /// stored in a child (or any of its descendants) changes.
  /// Single child_changed event may represent multiple changes to the child.
  Stream<QueryEvent> get onChildChanged => _onChildChanged;
  late final Stream<QueryEvent> _onChildMoved = _createStream('child_moved');

  /// Stream for a child_moved event. Event is triggered when a child's priority
  /// changes such that its position relative to its siblings changes.
  Stream<QueryEvent> get onChildMoved => _onChildMoved;

  /// Creates a new Query from a [jsObject].
  Query.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Gets the most up-to-date result for this query.
  Future<DataSnapshot> get() async {
    final jsSnapshotPromise = jsObject.get();
    final snapshot = await promiseToFuture<database_interop.DataSnapshotJsImpl>(
      jsSnapshotPromise,
    );

    return DataSnapshot.getInstance(snapshot);
  }

  /// Returns a Query with the ending point [value]. The ending point
  /// is inclusive.
  ///
  /// The [value] must be a [num], [String], [bool], or `null`, or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query endAt(value, [String? key]) => Query.fromJsObject(key == null
      ? jsObject.endAt(jsify(value))
      : jsObject.endAt(jsify(value), key));

  /// Creates a [Query] with the specified ending point (exclusive)
  /// The ending point is exclusive. If only a value is provided,
  /// children with a value less than the specified value will be included in
  /// the query. If a key is specified, then children must have a value lesss
  /// than or equal to the specified value and a a key name less than the
  /// specified key.
  Query endBefore(value, [String? key]) => Query.fromJsObject(key == null
      ? jsObject.endBefore(jsify(value))
      : jsObject.endBefore(jsify(value), key));

  /// Returns a Query which includes children which match the specified [value].
  ///
  /// The [value] must be a [num], [String], [bool], or `null`, or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query equalTo(value, [String? key]) => Query.fromJsObject(key == null
      ? jsObject.equalTo(jsify(value))
      : jsObject.equalTo(jsify(value), key));

  /// Returns `true` if the current and [other] queries are equal - they
  /// represent the exactly same location, have the same query parameters,
  /// and are from the same instance of [App].
  /// Equivalent queries share the same sort order, limits, starting
  /// and ending points.
  ///
  /// Two [DatabaseReference] objects are equivalent if they represent the same
  /// location and are from the same instance of [App].
  bool isEqual(Query other) => jsObject.isEqual(other.jsObject);

  /// Returns a new Query limited to the first specific number of children
  /// provided by [limit].
  Query limitToFirst(int limit) =>
      Query.fromJsObject(jsObject.limitToFirst(limit));

  /// Returns a new Query limited to the last specific number of children
  /// provided by [limit].
  Query limitToLast(int limit) =>
      Query.fromJsObject(jsObject.limitToLast(limit));

  Stream<QueryEvent> _createStream(String eventType) {
    late StreamController<QueryEvent> streamController;

    final callbackWrap = allowInterop((
      database_interop.DataSnapshotJsImpl data, [
      String? string,
    ]) {
      streamController.add(QueryEvent(DataSnapshot.getInstance(data), string));
    });

    final cancelCallbackWrap = allowInterop((Object error) {
      final dartified = dartify(error);
      streamController.addError(convertFirebaseDatabaseException(dartified));
      streamController.close();
    });

    void startListen() {
      jsObject.on(eventType, callbackWrap, cancelCallbackWrap);
    }

    void stopListen() {
      jsObject.off(eventType, callbackWrap);
    }

    streamController = StreamController<QueryEvent>.broadcast(
      onListen: startListen,
      onCancel: stopListen,
      sync: true,
    );
    return streamController.stream;
  }

  /// Listens for exactly one [eventType] and then stops listening.
  Future<QueryEvent> once(String eventType) {
    final c = Completer<QueryEvent>();

    jsObject.once(eventType, allowInterop(
      (database_interop.DataSnapshotJsImpl snapshot, [String? string]) {
        c.complete(QueryEvent(DataSnapshot.getInstance(snapshot), string));
      },
    ), resolveError(c));

    return c.future;
  }

  /// Returns a new Query ordered by the specified child [path].
  Query orderByChild(String path) =>
      Query.fromJsObject(jsObject.orderByChild(path));

  /// Returns a new Query ordered by key.
  Query orderByKey() => Query.fromJsObject(jsObject.orderByKey());

  /// Returns a new Query ordered by priority.
  Query orderByPriority() => Query.fromJsObject(jsObject.orderByPriority());

  /// Returns a new Query ordered by child values.
  Query orderByValue() => Query.fromJsObject(jsObject.orderByValue());

  /// Returns a Query with the starting point [value]. The starting point
  /// is inclusive.
  ///
  /// The [value] must be a [num], [String], [bool], or `null`, or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query startAt(value, [String? key]) => Query.fromJsObject(
        key == null
            ? jsObject.startAt(jsify(value))
            : jsObject.startAt(jsify(value), key),
      );

  Query startAfter(value, [String? key]) => Query.fromJsObject(key == null
      ? jsObject.startAfter(jsify(value))
      : jsObject.startAfter(jsify(value), key));

  /// Returns a String representation of Query object.
  @override
  String toString() => jsObject.toString();

  /// Returns a JSON-serializable representation of this object.
  dynamic toJson() => dartify(jsObject.toJSON());
}

/// A DataSnapshot contains data from a database location.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.DataSnapshot>.
class DataSnapshot
    extends core_interop.JsObjectWrapper<database_interop.DataSnapshotJsImpl> {
  static final _expando = Expando<DataSnapshot>();

  /// The last part of the path at location for this DataSnapshot.
  String get key => jsObject.key;

  /// The DatabaseReference for the location that generated this DataSnapshot.
  DatabaseReference get ref => DatabaseReference.getInstance(jsObject.ref);

  /// Creates a new DataSnapshot from a [jsObject].
  static DataSnapshot getInstance(
    database_interop.DataSnapshotJsImpl jsObject,
  ) =>
      _expando[jsObject] ??= DataSnapshot._fromJsObject(jsObject);

  DataSnapshot._fromJsObject(database_interop.DataSnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Returns DataSnapshot for the location at the specified relative [path].
  DataSnapshot child(String path) =>
      DataSnapshot.getInstance(jsObject.child(path));

  /// Returns `true` if this DataSnapshot contains any data.
  bool exists() => jsObject.exists();

  /// Exports the contents of the DataSnapshot as a Dart object.
  dynamic exportVal() => dartify(jsObject.exportVal());

  /// Enumerates the top-level children of the DataSnapshot in their query-order.
  /// [action] is called for each child DataSnapshot.
  bool forEach(Function(DataSnapshot) action) {
    final actionWrap = allowInterop((d) => action(DataSnapshot.getInstance(d)));
    return jsObject.forEach(actionWrap);
  }

  /// Returns priority for data in this DataSnapshot.
  dynamic getPriority() => jsObject.getPriority();

  /// Returns `true` if the specified child [path] has data.
  bool hasChild(String path) => jsObject.hasChild(path);

  /// Returns `true` if this DataSnapshot has any children.
  bool hasChildren() => jsObject.hasChildren();

  /// Returns the number of child properties for this DataSnapshot.
  int numChildren() => jsObject.numChildren();

  /// Returns Dart value from a DataSnapshot.
  dynamic val() => dartify(jsObject.val());

  /// Returns a JSON-serializable representation of this object.
  dynamic toJson() => dartify(jsObject.toJSON());
}

/// The OnDisconnect class allows you to write or clear data when your client
/// disconnects from the database server.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.OnDisconnect>.
class OnDisconnect
    extends core_interop.JsObjectWrapper<database_interop.OnDisconnectJsImpl> {
  OnDisconnect.fromJsObject(database_interop.OnDisconnectJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Cancels all previously queued onDisconnect() events for actual location
  /// and all children.
  Future cancel() => core_interop.handleThenable(jsObject.cancel());

  /// Ensures the data for actual location is deleted when the client
  /// is disconnected.
  Future remove() => core_interop.handleThenable(jsObject.remove());

  /// Ensures the data for actual location is set to the specified [value]
  /// when the client is disconnected.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future set(value) => core_interop.handleThenable(jsObject.set(jsify(value)));

  /// Ensures the data for actual location is set to the specified [value]
  /// and [priority] when the client is disconnected.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  /// The [priority] must be a [String], [num] or `null`, or the error is thrown.
  Future setWithPriority(value, priority) => core_interop
      .handleThenable(jsObject.setWithPriority(jsify(value), priority));

  /// Writes multiple [values] at actual location when the client is disconnected.
  ///
  /// The [values] must be a Dart basic type or the error is thrown.
  Future update(values) =>
      core_interop.handleThenable(jsObject.update(jsify(values)));
}

/// The ThenableReference class represents [DatabaseReference] with a
/// [Future] property.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.ThenableReference>.
class ThenableReference
    extends DatabaseReference<database_interop.ThenableReferenceJsImpl> {
  late final Future<DatabaseReference> _future =
      core_interop.handleThenable(jsObject).then(DatabaseReference.getInstance);

  /// Creates a new ThenableReference from a [jsObject].
  ThenableReference.fromJsObject(
    database_interop.ThenableReferenceJsImpl jsObject,
  ) : super._fromJsObject(jsObject);

  /// A Future property.
  Future<DatabaseReference> get future => _future;
}

/// A structure used in [DatabaseReference.transaction].
class Transaction
    extends core_interop.JsObjectWrapper<database_interop.TransactionJsImpl> {
  /// If transaction was committed.
  bool get committed => jsObject.committed;

  /// Returns the DataSnapshot.
  DataSnapshot get snapshot => DataSnapshot.getInstance(jsObject.snapshot);

  /// Creates a new Transaction with optional [committed] and [snapshot]
  /// properties.
  factory Transaction({bool? committed, DataSnapshot? snapshot}) =>
      Transaction.fromJsObject(
        database_interop.TransactionJsImpl(
          committed: committed,
          snapshot: snapshot?.jsObject,
        ),
      );

  /// Creates a new Transaction from a [jsObject].
  Transaction.fromJsObject(database_interop.TransactionJsImpl jsObject)
      : super.fromJsObject(jsObject);
}
