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
Map<String, String> partsFromHttpUrl(String url) {
  assert(url.startsWith('http'));
  String decodedUrl = _decodeHttpUrl(url);
  if (decodedUrl == null) {
    return null;
  }

  RegExp exp = RegExp(r"\/b\/(.*)\/o\/([a-zA-Z0-9.\/\-_]+)(.*)");
  Iterable<RegExpMatch> matches = exp.allMatches(decodedUrl);

  if (matches.isEmpty) {
    return null;
  }

  RegExpMatch firstElement = matches.first;
  if (firstElement.groupCount < 1) {
    return null;
  }

  return {
    'bucket': firstElement.group(1),
    'path': firstElement.group(2) ?? '/',
  };
}

String _decodeHttpUrl(String url) {
  try {
    return Uri.decodeFull(url);
  } catch (_) {
    return null;
  }
}
