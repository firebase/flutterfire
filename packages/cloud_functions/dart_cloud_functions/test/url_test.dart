// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:dart_cloud_functions/src/context.dart';
import 'package:dart_cloud_functions/src/url.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _throwsCode(String code) {
  return throwsA(
    isA<DartFirebaseFunctionsException>().having((e) => e.code, 'code', code),
  );
}

void main() {
  group('callableUrl', () {
    test('resolves a name against production', () {
      final url = callableUrl(
        projectId: 'my-project',
        region: 'europe-west1',
        name: 'listFruit',
      );

      expect(
        url.toString(),
        'https://europe-west1-my-project.cloudfunctions.net/listFruit',
      );
    });

    test('resolves a name against the emulator origin', () {
      final url = callableUrl(
        projectId: 'my-project',
        region: 'us-central1',
        name: 'listFruit',
        origin: 'http://localhost:5001',
      );

      expect(
        url.toString(),
        'http://localhost:5001/my-project/us-central1/listFruit',
      );
    });

    test('uses an explicit URI as is, even with an emulator origin', () {
      final uri = Uri.parse('https://listfruits-abc123-uc.a.run.app');

      final url = callableUrl(
        projectId: 'my-project',
        region: 'us-central1',
        uri: uri,
        origin: 'http://localhost:5001',
      );

      expect(url, uri);
    });

    test('throws without a name or a URI', () {
      expect(
        () => callableUrl(projectId: 'my-project', region: 'us-central1'),
        throwsArgumentError,
      );
    });

    test('resolves a name against a custom domain given as the region', () {
      final url = callableUrl(
        projectId: 'my-project',
        region: 'https://example.com',
        name: 'listFruit',
      );

      expect(url.toString(), 'https://example.com/listFruit');
    });

    test('keeps a custom domain path and drops its trailing slash', () {
      final url = callableUrl(
        projectId: 'my-project',
        region: 'https://example.com/api/',
        name: 'listFruit',
      );

      expect(url.toString(), 'https://example.com/api/listFruit');
    });

    test(
      'prefers the emulator over a custom domain, with the default region',
      () {
        final url = callableUrl(
          projectId: 'my-project',
          region: 'https://example.com',
          name: 'listFruit',
          origin: 'http://localhost:5001',
        );

        expect(
          url.toString(),
          'http://localhost:5001/my-project/us-central1/listFruit',
        );
      },
    );
  });

  group('checkTokenTransport', () {
    const withToken = CallableContext(authToken: 'id-token');

    void check(String url, [CallableContext context = withToken]) =>
        checkTokenTransport(Uri.parse(url), context);

    test('allows tokens over HTTPS', () {
      expect(() => check('https://example.com/listFruit'), returnsNormally);
    });

    for (final host in ['localhost', '127.0.0.1', '[::1]', '10.0.2.2']) {
      test('allows tokens over HTTP to $host', () {
        expect(() => check('http://$host:5001/listFruit'), returnsNormally);
      });
    }

    test('refuses tokens over HTTP to any other host', () {
      expect(
        () => check('http://192.168.1.20:5001/listFruit'),
        _throwsCode('unauthenticated'),
      );
    });

    test('refuses an App Check token over HTTP to any other host', () {
      expect(
        () => check(
          'http://192.168.1.20:5001/listFruit',
          const CallableContext(appCheckToken: 'app-check-token'),
        ),
        _throwsCode('unauthenticated'),
      );
    });

    test('allows calls without tokens over HTTP to any host', () {
      expect(
        () => check('http://example.com/listFruit', const CallableContext()),
        returnsNormally,
      );
    });

    test('allows tokens over HTTP to any host with allowInsecure', () {
      expect(
        () => checkTokenTransport(
          Uri.parse('http://192.168.1.20:5001/listFruit'),
          withToken,
          allowInsecure: true,
        ),
        returnsNormally,
      );
    });
  });
}
