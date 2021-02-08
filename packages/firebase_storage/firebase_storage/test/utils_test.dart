// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bucketFromGoogleStorageUrl()', () {
    test('returns bucket from specified url', () {
      String url = 'gs://test-bucket/foo/bar';

      final result = bucketFromGoogleStorageUrl(url);

      expect(result, 'test-bucket');
    });
  });

  group('pathFromGoogleStorageUrl()', () {
    test('returns path from specified url', () {
      String url = 'gs://test-bucket/foo/bar';

      final result = pathFromGoogleStorageUrl(url);

      expect(result, 'foo/bar');
    });

    test('returns root path if no path exists ', () {
      String url = 'gs://test-bucket';

      final result = pathFromGoogleStorageUrl(url);

      expect(result, '/');
    });
  });

  group('partsFromHttpUrl()', () {
    test('returns null if url is invalid', () {
      String url = 'http://invalid-url';

      final result = partsFromHttpUrl(url);

      expect(result, isNull);
    });

    test('parses a http url', () {
      String url =
          'http://firebasestorage.googleapis.com/v0/b/valid-url.appspot.com/o/path';

      final result = partsFromHttpUrl(url)!;

      expect(result['bucket'], 'valid-url.appspot.com');
      expect(result['path'], 'path');
    });

    test('parses a https url with host "firebasestorage.googleapis.com"', () {
      String url =
          'https://firebasestorage.googleapis.com/v0/b/valid-url.appspot.com/o/path';

      final result = partsFromHttpUrl(url)!;

      expect(result['bucket'], 'valid-url.appspot.com');
      expect(result['path'], 'path');
    });

    test('parses a https url with host "storage.cloud.google.com"', () {
      String url =
          'https://storage.cloud.google.com/v0/b/valid-url.appspot.com/o/path';

      final result = partsFromHttpUrl(url)!;

      expect(result['bucket'], 'valid-url.appspot.com');
      expect(result['path'], 'path');
    });

    test('parses a encoded https url', () {
      String url =
          'https%3A%2F%2Ffirebasestorage.googleapis.com%2Fv0%2Fb%2Freact-native-firebase-testing.appspot.com%2Fo%2F1mbTestFile.gif%3Falt%3Dmedia';

      final result = partsFromHttpUrl(url)!;

      expect(result['bucket'], 'react-native-firebase-testing.appspot.com');
      expect(result['path'], '1mbTestFile.gif');
    });

    // TODO(helenaford): regexp can't handle no paths
    // test('sets path to default if null', () {
    //   String url =
    //       'https://firebasestorage.googleapis.com/v0/b/valid-url.appspot.com';

    //   final result = partsFromHttpUrl(url);

    //   expect(result, isA<Map<String, String>>());
    //   expect(result['bucket'], 'valid-url.appspot.com');
    //   expect(result['path'], '/');
    // });
  });
}
