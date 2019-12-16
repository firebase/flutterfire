// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO: this needs to be more precise
class PlatformQuerySnapshot {
  PlatformQuerySnapshot({this.data});
  Map<dynamic, dynamic> data;

  Map<dynamic, dynamic> asMap() => data;
}
