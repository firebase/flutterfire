// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Returns a bucket from a given `gs://` URL.
String bucketFromGoogleStorageUrl(String url) {
  assert(url.startsWith('gs://'));
  int stopIndex = url.indexOf('/', 5);
  int stop = stopIndex == -1 ? url.length : stopIndex;
  return url.substring(5, stop);
}

/// Returns a path from a given `gs://` URL.
///
/// If no path exists, the root path will be returned.
String pathFromGoogleStorageUrl(String url) {
  assert(url.startsWith('gs://'));
  int stopIndex = url.indexOf('/', 5);
  if (stopIndex == -1) return '/';
  return url.substring(stopIndex + 1, url.length);
}

/// Returns a path from a given `http://` or `https://` URL.
///
/// If url fails to parse, null is returned
/// If no path exists, the root path will be returned.
Map<String, String?>? partsFromHttpUrl(String url) {
  assert(url.startsWith('http'));
  String? decodedUrl = _decodeHttpUrl(url);
  if (decodedUrl == null) {
    return null;
  }

  Uri uri = Uri.parse(decodedUrl);

  if (uri.pathSegments.length <= 3 ||
      uri.pathSegments[0] != 'v0' ||
      uri.pathSegments[1] != 'b') {
    return null;
  }

  String bucketName = uri.pathSegments[2];
  String path = uri.pathSegments.getRange(4, uri.pathSegments.length).join('/');

  return {
    'bucket': bucketName,
    'path': path,
  };
}

String? _decodeHttpUrl(String url) {
  try {
    return Uri.decodeFull(url);
  } catch (_) {
    return null;
  }
}
