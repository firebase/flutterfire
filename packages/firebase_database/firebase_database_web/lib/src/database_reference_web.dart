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
    DatabasePlatform _database,
    this._delegate,
  ) : super(_database, _delegate);

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
  String? get key => _delegate.key;

  @override
  DatabaseReferencePlatform push() {
    return DatabaseReferenceWeb(_database, _delegate.push());
  }

  @override
  Future<void> set(Object? value) async {
    try {
      await _delegate.set(value);
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) async {
    try {
      await _delegate.setWithPriority(value, priority);
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> value) async {
    try {
      await _delegate.update(value);
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> setPriority(priority) async {
    try {
      await _delegate.setPriority(priority);
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> remove() {
    return set(null);
  }

  @override
  Future<TransactionResultPlatform> runTransaction(
    TransactionHandler transactionHandler, {
    bool applyLocally = true,
  }) async {
    try {
      return TransactionResultWeb._(
          this, await _delegate.transaction(transactionHandler, applyLocally));
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  OnDisconnectPlatform onDisconnect() {
    return OnDisconnectWeb._(_delegate.onDisconnect(), database, this);
  }
}
