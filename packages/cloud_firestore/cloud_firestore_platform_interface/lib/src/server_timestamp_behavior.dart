// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum ServerTimestampBehavior {
  /// Return null for [FieldValue.serverTimestamp()] values that have not yet
  none,

  /// Return local estimates for [FieldValue.serverTimestamp()] values that have not yet been set to their final value.
  estimate,

  /// Return the previous value for [FieldValue.serverTimestamp()] values that have not yet been set to their final value.
  previous,
}

String getServerTimestampBehaviorString(
  ServerTimestampBehavior serverTimestampBehavior,
) {
  switch (serverTimestampBehavior) {
    case ServerTimestampBehavior.none:
      return 'none';
    case ServerTimestampBehavior.estimate:
      return 'estimate';
    case ServerTimestampBehavior.previous:
      return 'previous';
  }
}
