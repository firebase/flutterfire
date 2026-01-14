// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references, require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_web/firebase_database_web.dart'
    show convertFirebaseDatabaseException;
import 'package:flutter/widgets.dart';

import 'database_interop.dart' as database_interop;

/// Given an AppJSImp, return the Database instance.
Database getDatabaseInstance([App? app, String? databaseURL]) {
  return Database.getInstance(
      database_interop.getDatabase(app?.jsObject, databaseURL?.toJS));
}

/// Logs debugging information to the console.
/// If [persistent], it remembers the logging state between page refreshes.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database#.enableLogging>.
void enableLogging(bool enable, [bool persistent = false]) {
  database_interop.enableLogging(
    (enable ? (message) => debugPrint('@firebase/database: $message') : enable)
        .toJSBox,
    persistent.toJS,
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

  Database._fromJsObject(super.jsObject) : super.fromJsObject();

  /// Disconnects from the server, all database operations will be
  /// completed offline.
  void goOffline() => database_interop.goOffline(jsObject);

  /// Connects to the server and synchronizes the offline database
  /// state with the server state.
  void goOnline() => database_interop.goOnline(jsObject);

  void useDatabaseEmulator(String host, int port) =>
      database_interop.connectDatabaseEmulator(jsObject, host.toJS, port.toJS);

  /// Returns a [DatabaseReference] to the root or provided [path].
  DatabaseReference ref([String? path = '/']) => DatabaseReference.getInstance(
      database_interop.ref(jsObject, (path ?? '/').toJS));

  /// Returns a [DatabaseReference] from provided [url].
  /// Url must be in the same domain as the current database.
  DatabaseReference refFromURL(String url) => DatabaseReference.getInstance(
      database_interop.refFromURL(jsObject, url.toJS));
}

/// A DatabaseReference represents a specific location in database and
/// can be used for reading or writing data to that database location.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.Reference>.
class DatabaseReference extends Query<database_interop.ReferenceJsImpl> {
  static final _expando = Expando<DatabaseReference>();

  /// The last part of the current path.
  /// It is `null` in case of root DatabaseReference.
  String? get key => jsObject.key?.toDart;

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

  DatabaseReference._fromJsObject(super.jsObject) : super.fromJsObject();

  /// Returns child DatabaseReference from provided relative [path].
  DatabaseReference child(String path) => DatabaseReference.getInstance(
      database_interop.child(jsObject, path.toJS));

  /// Returns [OnDisconnect] object.
  OnDisconnect onDisconnect() =>
      OnDisconnect.fromJsObject(database_interop.onDisconnect(jsObject));

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
  ThenableReference push([value]) => ThenableReference.fromJsObject(
      database_interop.push(jsObject, value?.jsify()));

  /// Removes data from actual database location.
  Future remove() => database_interop.remove(jsObject).toDart;

  /// Sets data at actual database location to provided [value].
  /// Overwrites any existing data at actual location and all child locations.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future set(Object? value) {
    return database_interop.set(jsObject, value?.jsify()).toDart;
  }

  /// Updates data with [value] at actual database location.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future update(Object? value) =>
      database_interop.update(jsObject, value?.jsify()).toDart;

  /// Sets a priority for data at actual database location.
  ///
  /// The [priority] must be a [String], [num] or `null`, or the error is thrown.
  Future setPriority(priority) =>
      database_interop.setPriority(jsObject, priority).toDart;

  /// Sets data [newVal] at actual database location with provided priority
  /// [newPriority].
  ///
  /// Like [set()] but also specifies the priority.
  ///
  /// The [newVal] must be a Dart basic type or the error is thrown.
  /// The [newPriority] must be a [String], [num] or `null`, or the error
  /// is thrown.
  Future setWithPriority(Object? newVal, newPriority) => database_interop
      .setWithPriority(jsObject, newVal?.jsify(), newPriority)
      .toDart;

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
    final JSAny? Function(JSAny?) transactionUpdateWrap = ((JSAny? update) {
      final dartUpdate = update?.dartify();
      final transaction = transactionUpdate(dartUpdate);
      if (transaction.aborted) {
        return globalContext.getProperty("undefined".toJS);
      }
      return transaction.value.jsify();
    });

    try {
      final jsTransactionResult = await database_interop
          .runTransaction(
            jsObject,
            transactionUpdateWrap.toJS,
            database_interop.TransactionOptions(
                applyLocally: applyLocally.toJS),
          )
          .toDart;
      return Transaction(
        committed: (jsTransactionResult.committed).toDart,
        snapshot: DataSnapshot._fromJsObject(jsTransactionResult.snapshot),
      );
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }
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
class Query<T extends database_interop.QueryJsImpl> extends JsObjectWrapper<T> {
  /// DatabaseReference to the Query's location.
  DatabaseReference get ref => DatabaseReference.getInstance(jsObject.ref);

  Stream<QueryEvent> _onValue(String appName, String hashCode) => _createStream(
        'value',
        appName,
        hashCode,
      );

  /// Stream for a value event. Event is triggered once with the initial
  /// data stored at location, and then again each time the data changes.
  Stream<QueryEvent> onValue(String appName, String hashCode) =>
      _onValue(appName, hashCode);

  Stream<QueryEvent> _onChildAdded(String appName, String hashCode) =>
      _createStream(
        'child_added',
        appName,
        hashCode,
      );

  /// Stream for a child_added event. Event is triggered once for each
  /// initial child at location, and then again every time a new child is added.
  Stream<QueryEvent> onChildAdded(String appName, String hashCode) =>
      _onChildAdded(appName, hashCode);

  Stream<QueryEvent> _onChildRemoved(String appName, String hashCode) =>
      _createStream(
        'child_removed',
        appName,
        hashCode,
      );

  /// Stream for a child_removed event. Event is triggered once every time
  /// a child is removed.
  Stream<QueryEvent> onChildRemoved(String appName, String hashCode) =>
      _onChildRemoved(appName, hashCode);

  Stream<QueryEvent> _onChildChanged(String appName, String hashCode) =>
      _createStream(
        'child_changed',
        appName,
        hashCode,
      );

  /// Stream for a child_changed event. Event is triggered when the data
  /// stored in a child (or any of its descendants) changes.
  /// Single child_changed event may represent multiple changes to the child.
  Stream<QueryEvent> onChildChanged(String appName, String hashCode) =>
      _onChildChanged(appName, hashCode);
  Stream<QueryEvent> _onChildMoved(String appName, String hashCode) =>
      _createStream(
        'child_moved',
        appName,
        hashCode,
      );

  /// Stream for a child_moved event. Event is triggered when a child's priority
  /// changes such that its position relative to its siblings changes.
  Stream<QueryEvent> onChildMoved(String appName, String hashCode) =>
      _onChildMoved(appName, hashCode);

  /// Creates a new Query from a [jsObject].
  Query.fromJsObject(super.jsObject) : super.fromJsObject();

  /// Gets the most up-to-date result for this query.
  Future<DataSnapshot> get() async {
    final jsSnapshotPromise = database_interop.get(jsObject);
    final snapshot = await jsSnapshotPromise.toDart;

    return DataSnapshot.getInstance(snapshot);
  }

  /// Returns a Query with the ending point [value]. The ending point
  /// is inclusive.
  ///
  /// The [value] must be a [num], [String], [bool], or `null`, or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query endAt(Object? value, [String? key]) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        key == null
            ? database_interop.endAt(value?.jsify())
            : database_interop.endAt(value?.jsify(), key.toJS),
      ),
    );
  }

  /// Creates a [Query] with the specified ending point (exclusive)
  /// The ending point is exclusive. If only a value is provided,
  /// children with a value less than the specified value will be included in
  /// the query. If a key is specified, then children must have a value lesss
  /// than or equal to the specified value and a a key name less than the
  /// specified key.
  Query endBefore(Object? value, [String? key]) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        key == null
            ? database_interop.endBefore(value?.jsify())
            : database_interop.endBefore(value?.jsify(), key.toJS),
      ),
    );
  }

  /// Returns a Query which includes children which match the specified [value].
  ///
  /// The [value] must be a [num], [String], [bool], or `null`, or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query equalTo(Object? value, [String? key]) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        key == null
            ? database_interop.equalTo(value?.jsify())
            : database_interop.equalTo(value?.jsify(), key.toJS),
      ),
    );
  }

  /// Returns `true` if the current and [other] queries are equal - they
  /// represent the exactly same location, have the same query parameters,
  /// and are from the same instance of [App].
  /// Equivalent queries share the same sort order, limits, starting
  /// and ending points.
  ///
  /// Two [DatabaseReference] objects are equivalent if they represent the same
  /// location and are from the same instance of [App].
  bool isEqual(Query other) => jsObject.isEqual(other.jsObject).toDart;

  /// Returns a new Query limited to the first specific number of children
  /// provided by [limit].
  Query limitToFirst(int limit) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        database_interop.limitToFirst(limit.toJS),
      ),
    );
  }

  /// Returns a new Query limited to the last specific number of children
  /// provided by [limit].
  Query limitToLast(int limit) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        database_interop.limitToLast(limit.toJS),
      ),
    );
  }

  String _streamWindowsKey(String appName, String eventType, String hashCode) =>
      'flutterfire-${appName}_${eventType}_${hashCode}_snapshot';

  Stream<QueryEvent> _createStream(
    String eventType,
    String appName,
    String hashCode,
  ) {
    late StreamController<QueryEvent> streamController;
    unsubscribeWindowsListener(_streamWindowsKey(appName, eventType, hashCode));
    final callbackWrap = ((
      database_interop.DataSnapshotJsImpl data, [
      String? prevChild,
    ]) {
      streamController
          .add(QueryEvent(DataSnapshot.getInstance(data), prevChild));
    });

    final void Function(JSObject) cancelCallbackWrap = ((JSObject error) {
      streamController.addError(convertFirebaseDatabaseException(error));
    });

    late JSFunction onUnsubscribe;

    void startListen() {
      if (eventType == 'child_added') {
        onUnsubscribe = database_interop.onChildAdded(
          jsObject,
          callbackWrap.toJS,
          cancelCallbackWrap.toJS,
        );
      }
      if (eventType == 'value') {
        onUnsubscribe = database_interop.onValue(
          jsObject,
          callbackWrap.toJS,
          cancelCallbackWrap.toJS,
        );
      }
      if (eventType == 'child_removed') {
        onUnsubscribe = database_interop.onChildRemoved(
          jsObject,
          callbackWrap.toJS,
          cancelCallbackWrap.toJS,
        );
      }
      if (eventType == 'child_changed') {
        onUnsubscribe = database_interop.onChildChanged(
          jsObject,
          callbackWrap.toJS,
          cancelCallbackWrap.toJS,
        );
      }
      if (eventType == 'child_moved') {
        onUnsubscribe = database_interop.onChildMoved(
          jsObject,
          callbackWrap.toJS,
          cancelCallbackWrap.toJS,
        );
      }
      setWindowsListener(
        _streamWindowsKey(appName, eventType, hashCode),
        onUnsubscribe,
      );
    }

    void stopListen() {
      onUnsubscribe.callAsFunction();
      streamController.close();
      removeWindowsListener(_streamWindowsKey(
        appName,
        eventType,
        hashCode,
      ));
    }

    streamController = StreamController<QueryEvent>.broadcast(
      onListen: startListen,
      onCancel: stopListen,
    );
    return streamController.stream;
  }

  /// Listens for exactly one [eventType] and then stops listening.
  Future<QueryEvent> once(String eventType) {
    final c = Completer<QueryEvent>();

    database_interop.onValue(
      jsObject,
      ((database_interop.DataSnapshotJsImpl snapshot, [String? prevChild]) {
        c.complete(QueryEvent(DataSnapshot.getInstance(snapshot), prevChild));
      }).toJS,
      ((JSAny error) {
        c.completeError(convertFirebaseDatabaseException(error));
      }).toJS,
      database_interop.ListenOptions(onlyOnce: true.toJS),
    );

    return c.future;
  }

  /// Returns a new Query ordered by the specified child [path].
  Query orderByChild(String path) => Query.fromJsObject(
        database_interop.query(
          jsObject,
          database_interop.orderByChild(path.toJS),
        ),
      );

  /// Returns a new Query ordered by key.
  Query orderByKey() => Query.fromJsObject(
      database_interop.query(jsObject, database_interop.orderByKey()));

  /// Returns a new Query ordered by priority.
  Query orderByPriority() => Query.fromJsObject(
      database_interop.query(jsObject, database_interop.orderByPriority()));

  /// Returns a new Query ordered by child values.
  Query orderByValue() => Query.fromJsObject(
      database_interop.query(jsObject, database_interop.orderByValue()));

  /// Returns a Query with the starting point [value]. The starting point
  /// is inclusive.
  ///
  /// The [value] must be a [num], [String], [bool], or `null`, or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query startAt(Object? value, [String? key]) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        key == null
            ? database_interop.startAt(value?.jsify())
            : database_interop.startAt(value?.jsify(), key.toJS),
      ),
    );
  }

  Query startAfter(Object? value, [String? key]) {
    return Query.fromJsObject(
      database_interop.query(
        jsObject,
        key == null
            ? database_interop.startAfter(value?.jsify())
            : database_interop.startAfter(value?.jsify(), key.toJS),
      ),
    );
  }

  /// Returns a String representation of Query object.
  @override
  String toString() => jsObject.toString();

  /// Returns a JSON-serializable representation of this object.
  dynamic toJson() => jsObject.toJSON().dartify();
}

class TransactionResult
    extends JsObjectWrapper<database_interop.TransactionResultJsImpl> {
  static final _expando = Expando<TransactionResult>();

  /// Creates a new TransactionResult from a [jsObject].
  static TransactionResult getInstance(
    database_interop.TransactionResultJsImpl jsObject,
  ) =>
      _expando[jsObject] ??= TransactionResult._fromJsObject(jsObject);

  TransactionResult._fromJsObject(super.jsObject) : super.fromJsObject();

  bool get committed => jsObject.committed.toDart;

  DataSnapshot get snapshot => DataSnapshot.getInstance(jsObject.snapshot);

  dynamic toJSON() => jsObject.toJSON();
}

/// A DataSnapshot contains data from a database location.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.DataSnapshot>.
class DataSnapshot
    extends JsObjectWrapper<database_interop.DataSnapshotJsImpl> {
  static final _expando = Expando<DataSnapshot>();

  /// The last part of the path at location for this DataSnapshot.
  String? get key => jsObject.key?.toDart;

  /// The DatabaseReference for the location that generated this DataSnapshot.
  DatabaseReference get ref => DatabaseReference.getInstance(jsObject.ref);

  /// Creates a new DataSnapshot from a [jsObject].
  static DataSnapshot getInstance(
    database_interop.DataSnapshotJsImpl jsObject,
  ) =>
      _expando[jsObject] ??= DataSnapshot._fromJsObject(jsObject);

  DataSnapshot._fromJsObject(super.jsObject) : super.fromJsObject();

  /// Returns DataSnapshot for the location at the specified relative [path].
  DataSnapshot child(String path) =>
      DataSnapshot.getInstance(jsObject.child(path.toJS));

  /// Returns `true` if this DataSnapshot contains any data.
  bool exists() => jsObject.exists().toDart;

  /// Exports the contents of the DataSnapshot as a Dart object.
  dynamic exportVal() => jsObject.exportVal().dartify();

  /// Enumerates the top-level children of the DataSnapshot in their query-order.
  /// [action] is called for each child DataSnapshot.
  bool forEach(void Function(DataSnapshot) action) {
    final actionWrap = ((database_interop.DataSnapshotJsImpl d) =>
        action(DataSnapshot.getInstance(d))).toJS;
    return (jsObject.forEach(actionWrap)).toDart;
  }

  /// Returns priority for data in this DataSnapshot.
  dynamic getPriority() => jsObject.priority;

  /// Returns `true` if the specified child [path] has data.
  bool hasChild(String path) => jsObject.hasChild(path.toJS).toDart;

  /// Returns `true` if this DataSnapshot has any children.
  bool hasChildren() => jsObject.hasChildren().toDart;

  /// Returns Dart value from a DataSnapshot.
  dynamic val() => (jsObject.val()).dartify();

  /// Returns a JSON-serializable representation of this object.
  dynamic toJson() => (jsObject.toJSON()).dartify();
}

/// The OnDisconnect class allows you to write or clear data when your client
/// disconnects from the database server.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.OnDisconnect>.
class OnDisconnect
    extends JsObjectWrapper<database_interop.OnDisconnectJsImpl> {
  OnDisconnect.fromJsObject(super.jsObject) : super.fromJsObject();

  /// Cancels all previously queued onDisconnect() events for actual location
  /// and all children.
  Future cancel() => (jsObject.cancel()).toDart;

  /// Ensures the data for actual location is deleted when the client
  /// is disconnected.
  Future remove() => (jsObject.remove()).toDart;

  /// Ensures the data for actual location is set to the specified [value]
  /// when the client is disconnected.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future set(Object? value) => (jsObject.set((value)?.jsify())).toDart;

  /// Ensures the data for actual location is set to the specified [value]
  /// and [priority] when the client is disconnected.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  /// The [priority] must be a [String], [num] or `null`, or the error is thrown.
  Future setWithPriority(Object? value, priority) =>
      (jsObject.setWithPriority((value)?.jsify(), priority)).toDart;

  /// Writes multiple [values] at actual location when the client is disconnected.
  ///
  /// The [values] must be a Dart basic type or the error is thrown.
  Future update(Object? values) => (jsObject.update((values)?.jsify())).toDart;
}

/// The ThenableReference class represents [DatabaseReference] with a
/// [Future] property.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.ThenableReference>.
class ThenableReference extends DatabaseReference {
  late final Future<DatabaseReference> _future =
      (jsObject as database_interop.ThenableReferenceJsImpl)
          .then(((database_interop.ReferenceJsImpl reference) {
            return reference;
          }).toJS)
          .toDart
          .then((value) => DatabaseReference.getInstance(
              value as database_interop.ReferenceJsImpl));

  /// Creates a new ThenableReference from a [jsObject].
  ThenableReference.fromJsObject(
    database_interop.ThenableReferenceJsImpl super.jsObject,
  ) : super._fromJsObject();

  /// A Future property.
  Future<DatabaseReference> get future => _future;
}

/// A structure used in [DatabaseReference.transaction].
class Transaction extends JsObjectWrapper<database_interop.TransactionJsImpl> {
  /// If transaction was committed.
  bool get committed => jsObject.committed.toDart;

  /// Returns the DataSnapshot.
  DataSnapshot get snapshot => DataSnapshot.getInstance(jsObject.snapshot);

  /// Creates a new Transaction with optional [committed] and [snapshot]
  /// properties.
  factory Transaction({bool? committed, DataSnapshot? snapshot}) =>
      Transaction.fromJsObject(
        database_interop.TransactionJsImpl(
          committed: committed?.toJS,
          snapshot: snapshot?.jsObject,
        ),
      );

  /// Creates a new Transaction from a [jsObject].
  Transaction.fromJsObject(super.jsObject) : super.fromJsObject();
}
