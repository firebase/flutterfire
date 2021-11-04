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
  Future<void> set(Object? value, {Object? priority}) {
    // TODO how do you set a null priority value?
    if (priority == null) return _delegate.set(value);
    return _delegate.setWithPriority(value, priority);
  }

  @override
  Future<void> remove() {
    return _delegate.remove();
  }

  @override
  Future<void> cancel() {
    return _delegate.cancel();
  }

  @override
  Future<void> update(Map<String, Object?> value) {
    return _delegate.update(value);
  }
}
