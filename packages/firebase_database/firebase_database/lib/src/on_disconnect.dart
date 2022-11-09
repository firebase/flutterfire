// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// The onDisconnect class allows you to write or clear data when your client
/// disconnects from the Database server. These updates occur whether your
/// client disconnects cleanly or not, so you can rely on them to clean up data
/// even if a connection is dropped or a client crashes.
///
/// The onDisconnect class is most commonly used to manage presence in
/// applications where it is useful to detect how many clients are connected
/// and when other clients disconnect.
///
/// To avoid problems when a connection is dropped before the requests can be
/// transferred to the Database server, these functions should be called before
/// writing any data.
///
/// Note that onDisconnect operations are only triggered once. If you want an
/// operation to occur each time a disconnect occurs, you'll need to
/// re-establish the onDisconnect operations each time you reconnect.
class OnDisconnect {
  OnDisconnectPlatform _delegate;

  OnDisconnect._(this._delegate) {
    OnDisconnectPlatform.verify(_delegate);
  }

  /// Ensures the data at this location is set to the specified value when the
  /// client is disconnected (due to closing the browser, navigating to a new
  /// page, or network issues).
  Future<void> set(Object? value) {
    return _delegate.set(value);
  }

  /// Ensures the data at this location is set with a priority to the specified
  /// value when the client is disconnected (due to closing the browser,
  /// navigating to a new page, or network issues).
  Future<void> setWithPriority(Object? value, Object? priority) {
    return _delegate.setWithPriority(value, priority);
  }

  /// Ensures the data at this location is deleted when the client is
  /// disconnected (due to closing the browser, navigating to a new page,
  /// or network issues).
  Future<void> remove() => set(null);

  /// Cancels all previously queued onDisconnect() set or update events for
  /// this location and all children.
  Future<void> cancel() {
    return _delegate.cancel();
  }

  /// Writes multiple values at this location when the client is disconnected
  /// (due to closing the browser, navigating to a new page, or network issues).
  Future<void> update(Map<String, Object?> value) {
    return _delegate.update(value);
  }
}
