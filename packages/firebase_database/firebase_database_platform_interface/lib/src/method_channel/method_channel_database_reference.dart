part of firebase_database_platform_interface;

/// DatabaseReference represents a particular location in your Firebase
/// Database and can be used for reading or writing data to that location.
///
/// This class is the starting point for all Firebase Database operations.
/// After you’ve obtained your first DatabaseReference via
/// `FirebaseDatabase.reference()`, you can use it to read data
/// (ie. `onChildAdded`), write data (ie. `setValue`), and to create new
/// `DatabaseReference`s (ie. `child`).
class MethodChannelDatabaseReference extends MethodChannelQuery
    implements DatabaseReferencePlatform {
  /// Create a [MethodChannelDatabaseReference] from [pathComponents]
  MethodChannelDatabaseReference({
    DatabasePlatform database,
    List<String> pathComponents,
  }) : super(
          database: database,
          pathComponents: pathComponents,
          parameters: {},
        );

  /// Write `value` to the location with the specified `priority` if applicable.
  ///
  /// This will overwrite any data at this location and all child locations.
  ///
  /// Data types that are allowed are String, boolean, int, double, Map, List.
  ///
  /// The effect of the write will be visible immediately and the corresponding
  /// events will be triggered. Synchronization of the data to the Firebase
  /// Database servers will also be started.
  ///
  /// Passing null for the new value means all data at this location or any
  /// child location will be deleted.
  Future<void> set(dynamic value, {dynamic priority}) {
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'DatabaseReference#set',
      <String, dynamic>{
        'app': database.app?.name,
        'databaseURL': database.databaseURL,
        'path': path,
        'value': value,
        'priority': priority,
      },
    );
  }

  /// Update the node with the `value`
  Future<void> update(Map<String, dynamic> value) {
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'DatabaseReference#update',
      <String, dynamic>{
        'app': database.app?.name,
        'databaseURL': database.databaseURL,
        'path': path,
        'value': value,
      },
    );
  }

  /// Sets a priority for the data at this Firebase Database location.
  ///
  /// Priorities can be used to provide a custom ordering for the children at a
  /// location (if no priorities are specified, the children are ordered by
  /// key).
  ///
  /// You cannot set a priority on an empty location. For this reason
  /// set() should be used when setting initial data with a specific priority
  /// and setPriority() should be used when updating the priority of existing
  /// data.
  ///
  /// Children are sorted based on this priority using the following rules:
  ///
  /// Children with no priority come first. Children with a number as their
  /// priority come next. They are sorted numerically by priority (small to
  /// large). Children with a string as their priority come last. They are
  /// sorted lexicographically by priority. Whenever two children have the same
  /// priority (including no priority), they are sorted by key. Numeric keys
  /// come first (sorted numerically), followed by the remaining keys (sorted
  /// lexicographically).
  ///
  /// Note that priorities are parsed and ordered as IEEE 754 double-precision
  /// floating-point numbers. Keys are always stored as strings and are treated
  /// as numbers only when they can be parsed as a 32-bit integer.
  Future<void> setPriority(dynamic priority) async {
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'DatabaseReference#setPriority',
      <String, dynamic>{
        'app': database.app?.name,
        'databaseURL': database.databaseURL,
        'path': path,
        'priority': priority,
      },
    );
  }

  /// Remove the data at this Firebase Database location. Any data at child
  /// locations will also be deleted.
  ///
  /// The effect of the delete will be visible immediately and the corresponding
  /// events will be triggered. Synchronization of the delete to the Firebase
  /// Database servers will also be started.
  ///
  /// remove() is equivalent to calling set(null)
  Future<void> remove() => set(null);

  /// Performs an optimistic-concurrency transactional update to the data at
  /// this Firebase Database location.
  Future<TransactionResultPlatform> runTransaction(
      TransactionHandlerPlatform transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    assert(timeout.inMilliseconds > 0,
        'Transaction timeout must be more than 0 milliseconds.');

    final Completer<TransactionResultPlatform> completer =
        Completer<TransactionResultPlatform>();

    final int transactionKey = MethodChannelDatabase._transactions.isEmpty
        ? 0
        : MethodChannelDatabase._transactions.keys.last + 1;

    MethodChannelDatabase._transactions[transactionKey] = transactionHandler;

    TransactionResultPlatform toTransactionResult(Map<dynamic, dynamic> map) {
      final DatabaseErrorPlatform databaseError = map['error'] != null
          ? _fromMapToPlatformDatabaseError(map['error'])
          : null;
      final bool committed = map['committed'];
      final DataSnapshotPlatform dataSnapshot = map['snapshot'] != null
          ? _fromMapToPlatformSnapShot(map['snapshot'])
          : null;

      MethodChannelDatabase._transactions.remove(transactionKey);

      return TransactionResultPlatform(databaseError, committed, dataSnapshot);
    }

    await MethodChannelDatabase.channel.invokeMethod<void>(
        'DatabaseReference#runTransaction', <String, dynamic>{
      'app': database.app?.name,
      'databaseURL': database.databaseURL,
      'path': path,
      'transactionKey': transactionKey,
      'transactionTimeout': timeout.inMilliseconds
    }).then((dynamic response) {
      completer.complete(toTransactionResult(response));
    });

    return completer.future;
  }

  @override
  DatabaseReferencePlatform child(String path) {
    return MethodChannelDatabaseReference(
        database: database,
        pathComponents: pathComponents..addAll(path.split("/")));
  }

  @override
  String get key => pathComponents.isEmpty ? null : pathComponents.last;

  @override
  OnDisconnectPlatform onDisconnect() {
    return MethodChannelOnDisconnect(
      database: database,
      reference: this,
    );
  }

  @override
  DatabaseReferencePlatform parent() {
    if (pathComponents.length < 2) {
      return null;
    }
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: (List<String>.from(pathComponents))..removeLast(),
    );
  }

  @override
  DatabaseReferencePlatform push() {
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: List<String>.from(pathComponents)
        ..add(PushIdGenerator.generatePushChildName()),
    );
  }

  @override
  DatabaseReferencePlatform root() {
    return MethodChannelDatabaseReference(
      database: database,
      pathComponents: [],
    );
  }
}
