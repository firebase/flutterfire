// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

/// This class remembers what SettableMetadata has already been set, so it can't be overwritten.
class SettableMetadataCache {
  SettableMetadata _cache = SettableMetadata();

  /// Stores every non-null value in the internal cache.
  ///
  /// If `overwrite` is set to true, it'll replace the whole contents of the
  /// cache with the `incoming` object (this can delete data).
  /// If `overwrite` is set to false (default), it'll only write values that
  /// are not already present in the cache.
  ///
  /// The `customMetadata` property is also merged. Older values are preserved.
  ///
  /// Returns an updated SettableMetadata object, after merging the current cache
  /// with `incoming`.
  SettableMetadata store(SettableMetadata? incoming, {bool overwrite = false}) {
    if (overwrite) {
      // Prevent the internal cache from becoming null when store
      // is called with incoming = null and overwrite = true.
      return _cache = incoming ?? SettableMetadata();
    }

    if (incoming == null) {
      return _cache;
    }

    final newMetadata = <String, String>{
      ...?incoming.customMetadata,
      ...?_cache.customMetadata,
    };

    return _cache = SettableMetadata(
      cacheControl: _cache.cacheControl ?? incoming.cacheControl,
      contentDisposition:
          _cache.contentDisposition ?? incoming.contentDisposition,
      contentEncoding: _cache.contentEncoding ?? incoming.contentEncoding,
      contentLanguage: _cache.contentLanguage ?? incoming.contentLanguage,
      contentType: _cache.contentType ?? incoming.contentType,
      customMetadata: newMetadata.isEmpty ? null : newMetadata,
    );
  }
}
