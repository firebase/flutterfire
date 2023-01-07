// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';

import '../firebase_database.dart' show DataSnapshot, DatabaseEvent, Query;
import 'utils/stream_subscriber_mixin.dart';

typedef ChildCallback = void Function(int index, DataSnapshot snapshot);
typedef ChildMovedCallback = void Function(
  int fromIndex,
  int toIndex,
  DataSnapshot snapshot,
);
typedef ValueCallback = void Function(DataSnapshot snapshot);
typedef ErrorCallback = void Function(FirebaseException error);

/// Sorts the results of `query` on the client side using `DataSnapshot.key`.
class FirebaseList extends ListBase<DataSnapshot>
    with
        // ignore: prefer_mixin
        StreamSubscriberMixin<DatabaseEvent> {
  FirebaseList({
    required this.query,
    this.onChildAdded,
    this.onChildRemoved,
    this.onChildChanged,
    this.onChildMoved,
    this.onValue,
    this.onError,
  }) {
    if (onChildAdded != null) {
      listen(query.onChildAdded, _onChildAdded, onError: _onError);
    }
    if (onChildRemoved != null) {
      listen(query.onChildRemoved, _onChildRemoved, onError: _onError);
    }
    if (onChildChanged != null) {
      listen(query.onChildChanged, _onChildChanged, onError: _onError);
    }
    if (onChildMoved != null) {
      listen(query.onChildMoved, _onChildMoved, onError: _onError);
    }
    if (onValue != null) {
      listen(query.onValue, _onValue, onError: _onError);
    }
  }

  /// Database query used to populate the list
  final Query query;

  /// Called when the child has been added
  final ChildCallback? onChildAdded;

  /// Called when the child has been removed
  final ChildCallback? onChildRemoved;

  /// Called when the child has changed
  final ChildCallback? onChildChanged;

  /// Called when the child has moved
  final ChildMovedCallback? onChildMoved;

  /// Called when the data of the list has finished loading
  final ValueCallback? onValue;

  /// Called when an error is reported (e.g. permission denied)
  final ErrorCallback? onError;

  // ListBase implementation
  final List<DataSnapshot> _snapshots = <DataSnapshot>[];

  @override
  int get length => _snapshots.length;

  @override
  set length(int value) {
    throw UnsupportedError('List cannot be modified.');
  }

  @override
  DataSnapshot operator [](int index) => _snapshots[index];

  @override
  void operator []=(int index, DataSnapshot value) {
    throw UnsupportedError('List cannot be modified.');
  }

  @override
  void clear() {
    cancelSubscriptions();

    // Do not call super.clear(), it will set the length, it's unsupported.
  }

  int _indexForKey(String key) {
    for (int index = 0; index < _snapshots.length; index++) {
      if (key == _snapshots[index].key) {
        return index;
      }
    }

    throw UnsupportedError('Key not found: $key');
  }

  void _onChildAdded(DatabaseEvent event) {
    int index = 0;
    if (event.previousChildKey != null) {
      index = _indexForKey(event.previousChildKey!) + 1;
    }
    _snapshots.insert(index, event.snapshot);
    onChildAdded!(index, event.snapshot);
  }

  void _onChildRemoved(DatabaseEvent event) {
    final index = _indexForKey(event.snapshot.key!);
    _snapshots.removeAt(index);
    onChildRemoved!(index, event.snapshot);
  }

  void _onChildChanged(DatabaseEvent event) {
    final index = _indexForKey(event.snapshot.key!);
    _snapshots[index] = event.snapshot;
    onChildChanged!(index, event.snapshot);
  }

  void _onChildMoved(DatabaseEvent event) {
    final fromIndex = _indexForKey(event.snapshot.key!);
    _snapshots.removeAt(fromIndex);

    int toIndex = 0;
    if (event.previousChildKey != null) {
      final prevIndex = _indexForKey(event.previousChildKey!);
      toIndex = prevIndex + 1;
    }
    _snapshots.insert(toIndex, event.snapshot);
    onChildMoved!(fromIndex, toIndex, event.snapshot);
  }

  void _onValue(DatabaseEvent event) {
    onValue!(event.snapshot);
  }

  void _onError(Object o) {
    onError?.call(o as FirebaseException);
  }
}
