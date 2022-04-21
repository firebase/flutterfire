// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The match type of the Dynamic Link.
/// https://firebase.google.com/docs/reference/ios/firebasedynamiclinks/api/reference/Enums/FIRDLMatchType.html
enum MatchType {
  ///  The match has not been achieved.
  none,

  /// The match between the Dynamic Link and this device may not be perfect, hence you should
  /// not reveal any personal information related to the Dynamic Link.
  weak,

  /// The match between the Dynamic Link and this device has high confidence but small possibility
  /// of error still exist.
  high,

  /// The match between the Dynamic Link and this device is exact, hence you may reveal personal
  /// information related to the Dynamic Link.
  unique,
}
