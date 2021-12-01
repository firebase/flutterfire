// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

Map<String, Object?> mapKeysToString(Map value) {
  Map<String, Object?> newMap = {};
  value.forEach((key, value) {
    newMap[key.toString()] = transformValue(value);
  });
  return newMap;
}

Object? transformValue(Object? value) {
  if (value is Map) {
    return mapKeysToString(value);
  }

  if (value is List) {
    return value.map(transformValue).toList();
  }

  return value;
}
