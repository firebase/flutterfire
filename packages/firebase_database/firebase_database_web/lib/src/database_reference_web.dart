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
    this._database,
    this._delegate,
  ) : super(_database, _delegate);

  final DatabasePlatform _database;

  final database_interop.DatabaseReference _delegate;

  @override
  DatabaseReferencePlatform child(String path) {
    return DatabaseReferenceWeb(_database, _delegate.child(path));
  }

  @override
  DatabaseReferencePlatform? get parent {
    database_interop.DatabaseReference? parent = _delegate.parent;

    if (parent == null) {
      return null;
    }

    return DatabaseReferenceWeb(_database, parent);
  }

  @override
  DatabaseReferencePlatform root() {
    return DatabaseReferenceWeb(_database, _delegate.root);
  }

  @override
  String get key => _delegate.key;

  @override
  DatabaseReferencePlatform push() {
    return DatabaseReferenceWeb(_database, _delegate.push());
  }

  @override
  Future<void> set(Object? value, {Object? priority}) {
    if (priority == null) {
      return _delegate.set(value);
    } else {
      return _delegate.setWithPriority(value, priority);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    return _delegate.update(value);
  }

  @override
  Future<void> setPriority(priority) {
    return _delegate.setPriority(priority);
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
    bool applyLocally = true,
  }) async {
    // TODO This needs a TransactionResultWeb (I think)
    // return TransactionResultPlatform(await _delegate.transaction(transactionHandler, applyLocally));


    // OLD CODE
    // try {
    //   final ref = _firebaseQuery.ref;
    //   final transaction = await ref.transaction(transactionHandler);
    //
    //   return TransactionResultPlatform(
    //     transaction.committed,
    //     fromWebSnapshotToPlatformSnapShot(transaction.snapshot),
    //   );
    // } catch (e) {
    //   if (e is DatabaseErrorPlatform) rethrow;
    //
    //   final error = DatabaseErrorPlatform({
    //     'code': 'unknown',
    //     'message': 'An unknown error occurred',
    //   });
    //
    //   throw error;
    // }
  }

  @override
  OnDisconnectPlatform onDisconnect() {
    return OnDisconnectWeb._(_delegate.onDisconnect(), database, this);
  }
}
