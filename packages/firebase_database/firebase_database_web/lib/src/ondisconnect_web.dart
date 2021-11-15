// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [OnDisconnectPlatform]
class OnDisconnectWeb extends OnDisconnectPlatform {
  final database_interop.OnDisconnect _delegate;

  OnDisconnectWeb._(
    this._delegate,
    DatabasePlatform database,
    DatabaseReferencePlatform ref,
  ) : super(database: database, ref: ref);

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
  Future<void> remove() async {
    try {
      await _delegate.remove();
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _delegate.cancel();
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    try {
      await _delegate.update(value);
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }
}
