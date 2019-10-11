// Copyright 2017 The Chromium Authors & Daniel Szasz. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// Metadata for a [ListResult]. ListResult stores page token, items and
/// prefixes which are returned by list all results.

class ListResult {
  ListResult({
    this.pageToken,
    this.items,
    this.prefixes,
  });

  ListResult._fromMap(Map<String, dynamic> map)
      : pageToken = map['pageToken'],
        items = map['items'].cast<String, ListResultItem>(),
        prefixes = map['prefixes'].cast<String, ListResultPrefix>();

  final String pageToken;
  final Map<String, ListResultItem> items;
  final Map<String, ListResultPrefix> prefixes;
}
