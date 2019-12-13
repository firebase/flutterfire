// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Converts [Source] to [String]
String _getSourceString(Source source) {
  assert(source != null);
  if (source == Source.server) {
    return 'server';
  }
  if (source == Source.cache) {
    return 'cache';
  }
  return 'default';
}
