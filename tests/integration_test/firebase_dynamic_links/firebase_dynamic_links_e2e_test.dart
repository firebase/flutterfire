// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_dynamic_links',
    () {
      const String androidPackageName = 'io.flutter.plugins.firebase.tests';
      const String iosBundleId = 'io.flutter.plugins.firebase.tests';
      const String urlHost = 'flutterfiretests.page.link';
      const String link = 'https://firebase.flutter.dev';

      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      group('buildLink', () {
        test('build dynamic links', () async {
          FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
          const String oflLink = 'https://ofl-link.com';
          final Uri dynamicLink = Uri.parse(
            'https://$urlHost/?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=$oflLink',
          );
          final DynamicLinkParameters parameters = DynamicLinkParameters(
            uriPrefix: 'https://$urlHost',
            longDynamicLink: dynamicLink,
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
        test('build short dynamic links', () async {
          FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
          const String oflLink = 'https://ofl-link.com';
          final Uri dynamicLink = Uri.parse(
            'https://$urlHost?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.flutter.plugins.firebase.tests&imv=0&link=https%3A%2F%2Fapp-test%2Fhelloworld&ofl=$oflLink',
          );
          final DynamicLinkParameters parameters = DynamicLinkParameters(
            uriPrefix: 'https://$urlHost',
            longDynamicLink: dynamicLink,
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

      group('getDynamicLink', () {
        test('dynamic link using uri created on Firebase console', () async {
          // Link created in Firebase console
          Uri uri = Uri.parse('https://flutterfiretests.page.link/iho8');
          PendingDynamicLinkData? pendingLink =
              await FirebaseDynamicLinks.instance.getDynamicLink(uri);
          expect(pendingLink, isA<PendingDynamicLinkData>());
          expect(pendingLink?.link.toString(), 'https://example/helloworld');
        });

        test(
          'Universal link error for URL that cannot be parsed',
          () async {
            Uri uri = Uri.parse('');
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              await expectLater(
                FirebaseDynamicLinks.instance.getDynamicLink(uri),
                throwsA(
                  isA<FirebaseException>().having(
                    (e) => e.message,
                    'message',
                    contains('could not be parsed'),
                  ),
                ),
              );
            } else if (defaultTargetPlatform == TargetPlatform.android) {
              // TODO - android returns normally. Throw error to keep consistent with iOS or catch on iOS and return `null`.
              // Internal ticket created: https://linear.app/invertase/issue/FF-44/dynamic-link-univeral-link-cannot-be-parsed
              await expectLater(
                FirebaseDynamicLinks.instance.getDynamicLink(uri),
                completes,
              );
            }
          },
        );
      });

      group('onLink', () {
        test('test multiple times', () async {
          StreamSubscription<PendingDynamicLinkData?> _onListenSubscription;
          StreamSubscription<PendingDynamicLinkData?>
              _onListenSubscriptionSecond;

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
    },
    // Only supported on Android & iOS.
    // TODO temporarily skipping tests on Android while we figure out CI issues.
    //      mainly we're using the google_atd Android emulators since they're more reliable,
    //      however they do not contain necessary APIs for Dynamic Links.
    skip: kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android,
  );
}
