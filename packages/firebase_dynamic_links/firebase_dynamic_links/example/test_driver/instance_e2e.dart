// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';

void runInstanceTests() {
  group('$FirebaseDynamicLinks', () {
    late FirebaseDynamicLinks dynamicLinks;

    setUpAll(() async {
      dynamicLinks = FirebaseDynamicLinks.instance;
    });

    group('instance', () {
      test('instance', () {
        expect(dynamicLinks, isA<FirebaseDynamicLinks>());
        expect(dynamicLinks.app, isA<FirebaseApp>());
      });
    });

    group('buildLink', () {
      test('build normal dynamic links', () async {
        FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
        const String androidPackageName =
            'io.flutter.plugins.firebase.dynamiclinksexample';
        const String iosBundleId =
            'com.google.FirebaseCppDynamicLinksTestApp.dev';
        const String urlHost = 'reactnativefirebase.page.link';
        const String link = 'https://invertase.io';

        final DynamicLinkParameters parameters = DynamicLinkParameters(
          uriPrefix: 'https://$urlHost',
          link: Uri.parse(link),
          androidParameters: const AndroidParameters(
            packageName: androidPackageName,
            minimumVersion: 1,
          ),
          iosParameters: const IOSParameters(
            bundleId: iosBundleId,
            minimumVersion: '2',
          ),
        );

        final Uri uri = await dynamicLinks.buildLink(parameters);

        // androidParameters.minimumVersion
        expect(
          uri.queryParameters['amv'],
          '1',
        );
        // iosParameters.minimumVersion
        expect(
          uri.queryParameters['imv'],
          '2',
        );
        // androidParameters.packageName
        expect(
          uri.queryParameters['apn'],
          androidPackageName,
        );
        // iosParameters.bundleId
        expect(
          uri.queryParameters['ibi'],
          iosBundleId,
        );
        // link
        expect(
          uri.queryParameters['link'],
          Uri.encodeFull(link),
        );
        // uriPrefix
        expect(
          uri.host,
          urlHost,
        );
      });
    });

    group('buildShortLink', () {
      test('build a short dynamic link', () async {
        FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
        const String androidPackageName =
            'io.flutter.plugins.firebase.dynamiclinksexample';
        const String iosBundleId =
            'io.flutter.plugins.firebase.dynamiclinksexample';
        const String urlHost = 'reactnativefirebase.page.link';
        const String link = 'https://invertase.io';

        final DynamicLinkParameters parameters = DynamicLinkParameters(
          uriPrefix: 'https://$urlHost',
          link: Uri.parse(link),
          androidParameters: const AndroidParameters(
            packageName: androidPackageName,
            minimumVersion: 1,
          ),
          iosParameters: const IOSParameters(
            bundleId: iosBundleId,
            minimumVersion: '2',
          ),
        );

        final ShortDynamicLink uri =
            await dynamicLinks.buildShortLink(parameters);

        // androidParameters.minimumVersion
        expect(
          uri.shortUrl.host,
          urlHost,
        );

        expect(
          uri.shortUrl.pathSegments.length,
          equals(1),
        );

        expect(
          uri.shortUrl.path.length,
          lessThanOrEqualTo(18),
        );
      });
    });

    group('getInitialLink', () {
      test('initial link', () async {
        PendingDynamicLinkData? pendingLink =
            await FirebaseDynamicLinks.instance.getInitialLink();

        expect(pendingLink, isNull);
      });
    });
  });

  group('getDynamicLink', () {
    test('dynamic link using uri', () async {
      Uri uri = Uri.parse('');
      PendingDynamicLinkData? pendingLink =
          await FirebaseDynamicLinks.instance.getDynamicLink(uri);

      expect(pendingLink, isNull);
    });
  });

  group('onLink', () {
    test('test multiple times', () async {
      StreamSubscription<PendingDynamicLinkData?> _onListenSubscription;
      StreamSubscription<PendingDynamicLinkData?> _onListenSubscriptionSecond;

      _onListenSubscription =
          FirebaseDynamicLinks.instance.onLink.listen((event) {});
      _onListenSubscriptionSecond =
          FirebaseDynamicLinks.instance.onLink.listen((event) {});

      await _onListenSubscription.cancel();
      await _onListenSubscriptionSecond.cancel();

      _onListenSubscription =
          FirebaseDynamicLinks.instance.onLink.listen((event) {});
      _onListenSubscriptionSecond =
          FirebaseDynamicLinks.instance.onLink.listen((event) {});

      await _onListenSubscription.cancel();
      await _onListenSubscriptionSecond.cancel();
    });
  });
}
