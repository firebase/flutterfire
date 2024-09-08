// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:collection' show Queue;

/// Simple object to restrict simultaneous accesses to a resource.
///
/// Cooperating code should acquire a lock on the mutex using [acquire],
/// and only use a guarded resource while they have that lock (from the
/// returned future completing with a [Lock] to calling [Lock.release]
/// on that lock.)
///
/// At most one active [Lock] object can exist for each [Mutex] at any time.
class Mutex {
  /// Queue of pending lock acquisitions, and the current active lock.
  ///
  /// The already completed completer of the currently active lock
  /// is reatined at the head of the queue, and is removed when the
  /// lock is released.
  final Queue<Completer<Lock>> _pending = Queue();

  /// Acquire a lock on the mutex.
  ///
  /// The future will complete with an active [Lock] object
  /// after all prior calls to `acquire` have completed with an acquired lock,
  /// and [Lock.release] has been called on each of those locks.
  Future<Lock> acquire() {
    final completer = Completer<Lock>();
    _pending.add(completer);
    if (_pending.length == 1) {
      // Is next in line to acquire lock.
      completer.complete(Lock._(this));
    }
    return completer.future;
  }

  void _release() {
    assert(_pending.isNotEmpty);
    assert(_pending.first.isCompleted);
    _pending.removeFirst();
    if (_pending.isNotEmpty) {
      _pending.first.complete(Lock._(this));
    }
  }
}

/// A lock acquired against a [Mutex].
///
/// Can be released *once*.
class Lock {
  Mutex? _mutex;
  Lock._(this._mutex);

  /// Release the lock on the mutex.
  ///
  /// The lock object no longer holds a lock on the mutex.
  void release() {
    final mutex = _mutex;
    if (mutex == null) throw StateError('Already released');
    _mutex = null;
    mutex._release();
  }
}
