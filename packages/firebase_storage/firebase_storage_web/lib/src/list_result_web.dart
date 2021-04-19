// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

/// The web implementation of a ListResultPlatform object
class ListResultWeb extends ListResultPlatform {
  /// Build a ListResultWeb instance from a list of items and prefixes.
  ListResultWeb(
    FirebaseStoragePlatform storage, {
    String? nextPageToken,
    List<String>? items,
    List<String>? prefixes,
  })  : _items = items ?? [],
        _prefixes = prefixes ?? [],
        super(storage, nextPageToken);

  List<String> _items;

  List<String> _prefixes;

  @override
  List<ReferencePlatform> get items {
    return _items.map(storage!.ref).toList();
  }

  @override
  List<ReferencePlatform> get prefixes {
    return _prefixes.map(storage!.ref).toList();
  }
}
