// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [DatabaseReferencePlatform]
class DatabaseReferenceWeb extends QueryWeb
    implements DatabaseReferencePlatform {
  /// Builds an instance of [DatabaseReferenceWeb] delegating to a package:firebase [DatabaseReferencePlatform]
  /// to delegate queries to underlying firebase web plugin
  DatabaseReferenceWeb(
    database_interop.Database firebaseDatabase,
    DatabasePlatform databasePlatform,
    List<String> pathComponents,
  ) : super(
          firebaseDatabase,
          databasePlatform,
          pathComponents,
          pathComponents.isEmpty
              ? firebaseDatabase.ref()
              : firebaseDatabase.ref(pathComponents.join("/")),
        );

  @override
  DatabaseReferencePlatform child(String path) {
    return DatabaseReferenceWeb(_firebaseDatabase, database,
        List<String>.from(pathComponents)..addAll(path.split("/")));
  }

  @override
  DatabaseReferencePlatform? parent() {
    if (pathComponents.isEmpty) return null;
    return DatabaseReferenceWeb(_firebaseDatabase, database,
        List<String>.from(pathComponents)..removeLast());
  }

  @override
  DatabaseReferencePlatform root() {
    return DatabaseReferenceWeb(_firebaseDatabase, database, <String>[]);
  }

  @override
  String get key => pathComponents.last;

  @override
  DatabaseReferencePlatform push() {
    final String key = PushIdGenerator.generatePushChildName();
    final List<String> childPath = List<String>.from(pathComponents)..add(key);
    return DatabaseReferenceWeb(_firebaseDatabase, database, childPath);
  }

  @override
  Future<void> set(value, {priority}) {
    if (priority == null) {
      return _firebaseQuery.ref.set(value);
    } else {
      return _firebaseQuery.ref.setWithPriority(value, priority);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    return _firebaseQuery.ref.update(value);
  }

  @override
  Future<void> setPriority(priority) {
    return _firebaseQuery.ref.setPriority(priority);
  }

  @override
  Future<void> remove() {
    return set(null);
  }

  /// on the web, [timeout] parameter is ignored.
  /// transaction((_) => null) doesn't work when compiled to JS
  /// probably because of https://github.com/dart-lang/sdk/issues/24088
  @override
  Future<TransactionResultPlatform> runTransaction(
    transactionHandler, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final ref = _firebaseQuery.ref;
      final transaction = await ref.transaction(transactionHandler);

      return TransactionResultPlatform(
        null,
        transaction.committed,
        fromWebSnapshotToPlatformSnapShot(transaction.snapshot),
      );
    } on DatabaseErrorPlatform catch (e) {
      return TransactionResultPlatform(
        e,
        false,
        null,
      );
    }
  }

  @override
  OnDisconnectPlatform onDisconnect() {
    return OnDisconnectWeb._(_firebaseQuery.ref.onDisconnect(), database, this);
  }
}
