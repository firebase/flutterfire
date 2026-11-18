// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

/// This class remembers what SettableMetadata has already been set, so values
/// left out of a later call are not lost.
class SettableMetadataCache {
  SettableMetadata _cache = SettableMetadata();

  /// Stores every non-null value in the internal cache.
  ///
  /// If `overwrite` is set to true, it'll replace the whole contents of the
  /// cache with the `incoming` object (this can delete data).
  /// If `overwrite` is set to false (default), non-null values of `incoming`
  /// replace the cached ones, and cached values are kept for the rest.
  ///
  /// The `customMetadata` property is also merged. New values win over older
  /// ones.
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
      ...?_cache.customMetadata,
      ...?incoming.customMetadata,
    };

    return _cache = SettableMetadata(
      cacheControl: incoming.cacheControl ?? _cache.cacheControl,
      contentDisposition:
          incoming.contentDisposition ?? _cache.contentDisposition,
      contentEncoding: incoming.contentEncoding ?? _cache.contentEncoding,
      contentLanguage: incoming.contentLanguage ?? _cache.contentLanguage,
      contentType: incoming.contentType ?? _cache.contentType,
      customMetadata: newMetadata.isEmpty ? null : newMetadata,
    );
  }
}
