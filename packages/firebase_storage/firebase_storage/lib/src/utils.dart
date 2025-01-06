// ignore_for_file: require_trailing_commas
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

const String _firebaseStorageHost = 'firebasestorage.googleapis.com';
const String _cloudStorageHost =
    '(?:storage.googleapis.com|storage.cloud.google.com)';
const String _bucketDomain = r'([A-Za-z0-9.\-_]+)';
const String _version = 'v[A-Za-z0-9_]+';
const String _firebaseStoragePath = r'(/([^?#]*).*)?$';
// Matches the implementation in the Web SDK:
// https://github.com/firebase/firebase-js-sdk/blob/main/packages/storage/src/implementation/location.ts#L101
const String _cloudStoragePath = '([^?#]*)';
const String _optionalPort = r'(?::\d+)?';

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

  // firebase storage url
  // 10.0.2.2 is for Android when using firebase emulator
  if (decodedUrl.contains(_firebaseStorageHost) ||
      decodedUrl.contains('localhost') ||
      decodedUrl.contains('10.0.2.2')) {
    String origin;
    if (decodedUrl.contains('localhost') || decodedUrl.contains('10.0.2.2')) {
      Uri uri = Uri.parse(url);
      origin = '^http?://${uri.host}:${uri.port}';
    } else {
      origin = '^https?://$_firebaseStorageHost';
    }

    RegExp firebaseStorageRegExp = RegExp(
      '$origin$_optionalPort/$_version/b/$_bucketDomain/o$_firebaseStoragePath',
      caseSensitive: false,
    );

    RegExpMatch? match = firebaseStorageRegExp.firstMatch(decodedUrl);

    if (match == null) {
      return null;
    }

    return {
      'bucket': match.group(1),
      'path': match.group(3),
    };
    // google cloud storage url
  } else {
    RegExp cloudStorageRegExp = RegExp(
      '^https?://$_cloudStorageHost$_optionalPort/$_bucketDomain/$_cloudStoragePath',
      caseSensitive: false,
    );

    RegExpMatch? match = cloudStorageRegExp.firstMatch(decodedUrl);

    if (match == null) {
      return null;
    }

    return {
      'bucket': match.group(1),
      'path': match.group(2),
    };
  }
}

String? _decodeHttpUrl(String url) {
  try {
    return Uri.decodeFull(url);
  } catch (_) {
    return null;
  }
}
