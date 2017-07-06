import 'dart:async';

import 'package:func/func.dart';
import 'package:js/js.dart';

import 'app.dart';
import 'interop/database_interop.dart' as database_interop;
import 'js.dart';
import 'utils.dart';

export 'interop/database_interop.dart' show ServerValue;

/// Logs debugging information to the console.
/// If [persistent], it remembers the logging state between page refreshes.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database#.enableLogging>.
void enableLogging([logger, bool persistent = false]) =>
    database_interop.enableLogging(jsify(logger), persistent);

/// Firebase realtime database service class.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database>.
class Database extends JsObjectWrapper<database_interop.DatabaseJsImpl> {
  App _app;

  /// App for this instance of database service.
  App get app {
    if (_app != null) {
      _app.jsObject = jsObject.app;
    } else {
      _app = new App.fromJsObject(jsObject.app);
    }
    return _app;
  }

  /// Creates a new Database from a [jsObject].
  Database.fromJsObject(database_interop.DatabaseJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Disconnects from the server, all database operations will be
  /// completed offline.
  void goOffline() => jsObject.goOffline();

  /// Connects to the server and synchronizes the offline database
  /// state with the server state.
  void goOnline() => jsObject.goOnline();

  /// Returns a [DatabaseReference] to the root or provided [path].
  DatabaseReference ref([String path]) =>
      new DatabaseReference.fromJsObject(jsObject.ref(path));

  /// Returns a [DatabaseReference] from provided [url].
  /// Url must be in the same domain as the current database.
  DatabaseReference refFromURL(String url) =>
      new DatabaseReference.fromJsObject(jsObject.refFromURL(url));
}

/// A DatabaseReference represents a specific location in database and
/// can be used for reading or writing data to that database location.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.Reference>.
class DatabaseReference<T extends database_interop.ReferenceJsImpl>
    extends Query<T> {
  /// The last part of the current path.
  /// It is [null] in case of root DatabaseReference.
  String get key => jsObject.key;

  DatabaseReference _parent;

  /// The parent location of a DatabaseReference.
  DatabaseReference get parent {
    if (jsObject.parent != null) {
      if (_parent != null) {
        _parent.jsObject = jsObject.parent;
      } else {
        _parent = new DatabaseReference.fromJsObject(jsObject.parent);
      }
    } else {
      _parent = null;
    }
    return _parent;
  }

  DatabaseReference _root;

  /// The root location of a DatabaseReference.
  DatabaseReference get root {
    if (_root != null) {
      _root.jsObject = jsObject.root;
    } else {
      _root = new DatabaseReference.fromJsObject(jsObject.root);
    }
    return _root;
  }

  /// Creates a new DatabaseReference from a [jsObject].
  DatabaseReference.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Returns child DatabaseReference from provided relative [path].
  DatabaseReference child(String path) =>
      new DatabaseReference.fromJsObject(jsObject.child(path));

  /// Returns [OnDisconnect] object.
  OnDisconnect onDisconnect() =>
      new OnDisconnect.fromJsObject(jsObject.onDisconnect());

  /// Pushes provided [value] to the actual location.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  ///
  /// If the [value] is not provided, no data is written to the database
  /// but the [ThenableReference] is still returned and can be used for later
  /// operation.
  ///
  ///     DatabaseReference ref = firebase.database().ref("messages");
  ///     ThenableReference childRef = ref.push();
  ///     childRef.set({"text": "Hello"});
  ///
  /// This method returns [ThenableReference], [DatabaseReference]
  /// with a [Future] property.
  ThenableReference push([value]) =>
      new ThenableReference.fromJsObject(jsObject.push(jsify(value)));

  /// Removes data from actual database location.
  Future remove() => handleThenable(jsObject.remove());

  /// Sets data at actual database location to provided [value].
  /// Overwrites any existing data at actual location and all child locations.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future set(value) => handleThenable(jsObject.set(jsify(value)));

  /// Sets a priority for data at actual database location.
  ///
  /// The [priority] must be a [String], [num] or [null], or the error is thrown.
  Future setPriority(priority) =>
      handleThenable(jsObject.setPriority(priority));

  /// Sets data [newVal] at actual database location with provided priority
  /// [newPriority].
  ///
  /// Like [set()] but also specifies the priority.
  ///
  /// The [newVal] must be a Dart basic type or the error is thrown.
  /// The [newPriority] must be a [String], [num] or [null], or the error
  /// is thrown.
  Future setWithPriority(newVal, newPriority) =>
      handleThenable(jsObject.setWithPriority(jsify(newVal), newPriority));

  /// Atomically updates data at actual database location.
  ///
  /// This method is used to update the existing value to a new value,
  /// ensuring there are no conflicts with other clients writing to the same
  /// location at the same time.
  ///
  /// The provided [transactionUpdate] function is used to update
  /// the current value into a new value.
  ///
  ///     DatabaseReference ref = firebase.database().ref("numbers");
  ///     ref.set(2);
  ///     ref.transaction((currentValue) => currentValue * 2);
  ///
  ///     var event = await ref.once("value");
  ///     print(event.snapshot.val()); //prints 4
  ///
  /// The returned value from [transactionUpdate] function must be a Dart basic
  /// type or the error is thrown.
  ///
  /// Set [applyLocally] to [false] to not see intermediate states.
  Future<Transaction> transaction(Func1 transactionUpdate,
      [bool applyLocally = true]) {
    Completer<Transaction> c = new Completer<Transaction>();

    var transactionUpdateWrap =
        allowInterop((update) => jsify(transactionUpdate(dartify(update))));

    var onCompleteWrap = allowInterop(
        (error, bool committed, database_interop.DataSnapshotJsImpl snapshot) {
      var dataSnapshot =
          (snapshot != null) ? new DataSnapshot.fromJsObject(snapshot) : null;
      if (error != null) {
        c.completeError(error);
      } else {
        c.complete(
            new Transaction(committed: committed, snapshot: dataSnapshot));
      }
    });

    jsObject.transaction(transactionUpdateWrap, onCompleteWrap, applyLocally);
    return c.future;
  }

  /// Updates data with [values] at actual database location.
  ///
  /// The [values] must be a Dart basic type or the error is thrown.
  Future update(values) => handleThenable(jsObject.update(jsify(values)));
}

/// Event fired when data changes at location.
///
/// Example:
///
///     Database database = firebase.database();
///     database.ref("messages").onValue.listen((QueryEvent e) {
///       DataSnapshot datasnapshot = e.snapshot;
///       //...
///     });
class QueryEvent {
  /// Immutable copy of the data at a database location.
  final DataSnapshot snapshot;

  /// String containing the key of the previous child.
  final String prevChildKey;

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
  DatabaseReference _ref;

  /// DatabaseReference to the Query's location.
  DatabaseReference get ref {
    if (_ref != null) {
      _ref.jsObject = jsObject.ref;
    } else {
      _ref = new DatabaseReference.fromJsObject(jsObject.ref);
    }
    return _ref;
  }

  Stream<QueryEvent> _onValue;

  /// Stream for a value event. Event is triggered once with the initial
  /// data stored at location, and then again each time the data changes.
  Stream<QueryEvent> get onValue => _onValue ??= _createStream("value");

  Stream<QueryEvent> _onChildAdded;

  /// Stream for a child_added event. Event is triggered once for each
  /// initial child at location, and then again every time a new child is added.
  Stream<QueryEvent> get onChildAdded =>
      _onChildAdded ??= _createStream("child_added");

  Stream<QueryEvent> _onChildRemoved;

  /// Stream for a child_removed event. Event is triggered once every time
  /// a child is removed.
  Stream<QueryEvent> get onChildRemoved =>
      _onChildRemoved ??= _createStream("child_removed");

  Stream<QueryEvent> _onChildChanged;

  /// Stream for a child_changed event. Event is triggered when the data
  /// stored in a child (or any of its descendants) changes.
  /// Single child_changed event may represent multiple changes to the child.
  Stream<QueryEvent> get onChildChanged =>
      _onChildChanged ??= _createStream("child_changed");

  Stream<QueryEvent> _onChildMoved;

  /// Stream for a child_moved event. Event is triggered when a child's priority
  /// changes such that its position relative to its siblings changes.
  Stream<QueryEvent> get onChildMoved =>
      _onChildMoved ??= _createStream("child_moved");

  /// Creates a new Query from a [jsObject].
  Query.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Returns a Query with the ending point [value]. The ending point
  /// is inclusive.
  ///
  /// The [value] must be a [num], [String], [bool], or [null], or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query endAt(value, [String key]) => new Query.fromJsObject(
      key == null ? jsObject.endAt(value) : jsObject.endAt(value, key));

  /// Returns a Query which includes children which match the specified [value].
  ///
  /// The [value] must be a [num], [String], [bool], or [null], or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query equalTo(value, [String key]) => new Query.fromJsObject(
      key == null ? jsObject.equalTo(value) : jsObject.equalTo(value, key));

  /// Returns [true] if the current and [other] queries are equal - they
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
      new Query.fromJsObject(jsObject.limitToFirst(limit));

  /// Returns a new Query limited to the last specific number of children
  /// provided by [limit].
  Query limitToLast(int limit) =>
      new Query.fromJsObject(jsObject.limitToLast(limit));

  Stream<QueryEvent> _createStream(String eventType) {
    StreamController<QueryEvent> streamController;

    var callbackWrap = allowInterop((database_interop.DataSnapshotJsImpl data,
        [String string]) {
      streamController
          .add(new QueryEvent(new DataSnapshot.fromJsObject(data), string));
    });

    void startListen() {
      // TODO(kevmoo) – should probably implement cancel callback
      // See https://firebase.google.com/docs/reference/js/firebase.database.Query#on
      jsObject.on(eventType, callbackWrap);
    }

    void stopListen() {
      jsObject.off(eventType);
    }

    streamController = new StreamController<QueryEvent>.broadcast(
        onListen: startListen, onCancel: stopListen, sync: true);
    return streamController.stream;
  }

  /// Listens for exactly one [eventType] and then stops listening.
  Future<QueryEvent> once(String eventType) {
    Completer<QueryEvent> c = new Completer<QueryEvent>();

    jsObject.once(eventType, allowInterop(
        (database_interop.DataSnapshotJsImpl snapshot, [String string]) {
      c.complete(
          new QueryEvent(new DataSnapshot.fromJsObject(snapshot), string));
    }), resolveError(c));

    return c.future;
  }

  /// Returns a new Query ordered by the specified child [path].
  Query orderByChild(String path) =>
      new Query.fromJsObject(jsObject.orderByChild(path));

  /// Returns a new Query ordered by key.
  Query orderByKey() => new Query.fromJsObject(jsObject.orderByKey());

  /// Returns a new Query ordered by priority.
  Query orderByPriority() => new Query.fromJsObject(jsObject.orderByPriority());

  /// Returns a new Query ordered by child values.
  Query orderByValue() => new Query.fromJsObject(jsObject.orderByValue());

  /// Returns a Query with the starting point [value]. The starting point
  /// is inclusive.
  ///
  /// The [value] must be a [num], [String], [bool], or [null], or the error
  /// is thrown.
  /// The optional [key] can be used to further limit the range of the query.
  Query startAt(value, [String key]) => new Query.fromJsObject(
      key == null ? jsObject.startAt(value) : jsObject.startAt(value, key));

  /// Returns a String representation of Query object.
  @override
  String toString() => jsObject.toString();
}

/// A DataSnapshot contains data from a database location.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.DataSnapshot>.
class DataSnapshot
    extends JsObjectWrapper<database_interop.DataSnapshotJsImpl> {
  /// The last part of the path at location for this DataSnapshot.
  String get key => jsObject.key;

  DatabaseReference _ref;

  /// The DatabaseReference for the location that generated this DataSnapshot.
  DatabaseReference get ref {
    if (_ref != null) {
      _ref.jsObject = jsObject.ref;
    } else {
      _ref = new DatabaseReference.fromJsObject(jsObject.ref);
    }
    return _ref;
  }

  /// Creates a new DataSnapshot from a [jsObject].
  DataSnapshot.fromJsObject(database_interop.DataSnapshotJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Returns DataSnapshot for the location at the specified relative [path].
  DataSnapshot child(String path) =>
      new DataSnapshot.fromJsObject(jsObject.child(path));

  /// Returns [true] if this DataSnapshot contains any data.
  bool exists() => jsObject.exists();

  /// Exports the contents of the DataSnapshot as a Dart object.
  dynamic exportVal() => dartify(jsObject.exportVal());

  /// Enumerates the top-level children of the DataSnapshot in their query-order.
  /// [action] is called for each child DataSnapshot.
  bool forEach(Func1<DataSnapshot, dynamic> action) {
    var actionWrap = allowInterop((database_interop.DataSnapshotJsImpl data) {
      action(new DataSnapshot.fromJsObject(data));
    });
    return jsObject.forEach(actionWrap);
  }

  /// Returns priority for data in this DataSnapshot.
  dynamic getPriority() => jsObject.getPriority();

  /// Returns [true] if the specified child [path] has data.
  bool hasChild(String path) => jsObject.hasChild(path);

  /// Returns [true] if this DataSnapshot has any children.
  bool hasChildren() => jsObject.hasChildren();

  /// Returns the number of child properties for this DataSnapshot.
  int numChildren() => jsObject.numChildren();

  /// Returns Dart value from a DataSnapshot.
  dynamic val() => dartify(jsObject.val());
}

/// The OnDisconnect class allows you to write or clear data when your client
/// disconnects from the database server.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.OnDisconnect>.
class OnDisconnect
    extends JsObjectWrapper<database_interop.OnDisconnectJsImpl> {
  OnDisconnect.fromJsObject(database_interop.OnDisconnectJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Cancels all previously queued onDisconnect() events for actual location
  /// and all children.
  Future cancel() => handleThenable(jsObject.cancel());

  /// Ensures the data for actual location is deleted when the client
  /// is disconnected.
  Future remove() => handleThenable(jsObject.remove());

  /// Ensures the data for actual location is set to the specified [value]
  /// when the client is disconnected.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  Future set(value) => handleThenable(jsObject.set(jsify(value)));

  /// Ensures the data for actual location is set to the specified [value]
  /// and [priority] when the client is disconnected.
  ///
  /// The [value] must be a Dart basic type or the error is thrown.
  /// The [priority] must be a [String], [num] or [null], or the error is thrown.
  Future setWithPriority(value, priority) =>
      handleThenable(jsObject.setWithPriority(jsify(value), priority));

  /// Writes multiple [values] at actual location when the client is disconnected.
  ///
  /// The [values] must be a Dart basic type or the error is thrown.
  Future update(values) => handleThenable(jsObject.update(jsify(values)));
}

/// The ThenableReference class represents [DatabaseReference] with a
/// [Future] property.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.database.ThenableReference>.
class ThenableReference
    extends DatabaseReference<database_interop.ThenableReferenceJsImpl> {
  Future<DatabaseReference> _future;

  /// Creates a new ThenableReference from a [jsObject].
  ThenableReference.fromJsObject(
      database_interop.ThenableReferenceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// A Future property.
  Future<DatabaseReference> get future => _future ??= handleThenableWithMapper(
      jsObject,
      (database_interop.ReferenceJsImpl val) =>
          new DatabaseReference.fromJsObject(val));
}

/// A structure used in [DatabaseReference.transaction].
class Transaction extends JsObjectWrapper<database_interop.TransactionJsImpl> {
  /// If transaction was committed.
  bool get committed => jsObject.committed;

  /// Sets committed to [c].
  void set committed(bool c) {
    jsObject.committed = c;
  }

  DataSnapshot _snapshot;

  /// Returns the DataSnapshot.
  DataSnapshot get snapshot {
    if (jsObject.snapshot != null) {
      if (_snapshot != null) {
        _snapshot.jsObject = jsObject.snapshot;
      } else {
        _snapshot = new DataSnapshot.fromJsObject(jsObject.snapshot);
      }
    } else {
      _snapshot = null;
    }
    return _snapshot;
  }

  /// Sets the DataSnapshot to [s].
  void set snapshot(DataSnapshot s) {
    _snapshot = s;
    jsObject.snapshot = s.jsObject;
  }

  /// Creates a new Transaction with optional [committed] and [snapshot]
  /// properties.
  factory Transaction({bool committed, DataSnapshot snapshot}) =>
      new Transaction.fromJsObject(new database_interop.TransactionJsImpl(
          committed: committed, snapshot: snapshot.jsObject));

  /// Creates a new Transaction from a [jsObject].
  Transaction.fromJsObject(database_interop.TransactionJsImpl jsObject)
      : super.fromJsObject(jsObject);
}
