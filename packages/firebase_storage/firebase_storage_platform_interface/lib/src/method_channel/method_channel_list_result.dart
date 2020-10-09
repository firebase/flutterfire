// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'method_channel_reference.dart';

/// Implementation for a [ListResultPlatform].
class MethodChannelListResult extends ListResultPlatform {
  // ignore: public_member_api_docs
  MethodChannelListResult(
    FirebaseStoragePlatform storage, {
    String nextPageToken,
    List<String> items,
    List<String> prefixes,
  })  : _items = items ?? [],
        _prefixes = prefixes ?? [],
        super(storage, nextPageToken);

  List<String> _items;

  List<String> _prefixes;

  @override
  List<ReferencePlatform> get items {
    return _items.map((path) => MethodChannelReference(storage, path)).toList();
  }

  @override
  List<ReferencePlatform> get prefixes {
    return _prefixes
        .map((path) => MethodChannelReference(storage, path))
        .toList();
  }
}
