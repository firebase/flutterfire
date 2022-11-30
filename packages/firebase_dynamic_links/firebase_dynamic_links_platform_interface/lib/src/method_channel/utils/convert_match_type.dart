// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../match_type.dart';

MatchType? convertMatchType(int? matchType) {
  switch (matchType) {
    case 0:
      return MatchType.none;
    case 1:
      return MatchType.weak;
    case 2:
      return MatchType.high;
    case 3:
      return MatchType.unique;
    default:
      return null;
  }
}
