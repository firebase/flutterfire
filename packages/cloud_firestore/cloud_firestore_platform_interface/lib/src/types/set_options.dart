// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An options object that configures the behavior of set() calls in DocumentReference, WriteBatch and Transaction.
/// These calls can be configured to perform granular merges instead of overwriting the target documents in their
/// entirety by providing a SetOptions with merge: true.
class PlatformSetOptions {
  /// Constructor
  PlatformSetOptions({this.merge});

  /// Changes the behavior of a set() call to only replace the values specified in its data argument.
  /// Fields omitted from the set() call remain untouched.
  bool merge;

  Map<String, dynamic> asMap() {
    return <String, dynamic> {
      'merge': merge,
    };
  }
}
