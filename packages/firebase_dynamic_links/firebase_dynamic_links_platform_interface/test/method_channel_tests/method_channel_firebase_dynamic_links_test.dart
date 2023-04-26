// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_dynamic_links_platform_interface/src/method_channel/method_channel_firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

DynamicLinkParameters buildDynamicLinkParameters() {
  AndroidParameters android = AndroidParameters(
    fallbackUrl: Uri.parse('fallbackUrl'),
    minimumVersion: 1,
    packageName: 'test-package',
  );

  GoogleAnalyticsParameters google = const GoogleAnalyticsParameters(
    campaign: 'campaign',
    medium: 'medium',
    source: 'source',
    term: 'term',
    content: 'content',
  );

  IOSParameters ios = IOSParameters(
      appStoreId: 'appStoreId',
      bundleId: 'bundleId',
      customScheme: 'customScheme',
      fallbackUrl: Uri.parse('fallbackUrl'),
      ipadBundleId: 'ipadBundleId',
      ipadFallbackUrl: Uri.parse('ipadFallbackUrl'),
      minimumVersion: 'minimumVersion');

  ITunesConnectAnalyticsParameters itunes =
      const ITunesConnectAnalyticsParameters(
    affiliateToken: 'affiliateToken',
    campaignToken: 'campaignToken',
    providerToken: 'providerToken',
  );

  Uri link = Uri.parse('link');
  NavigationInfoParameters navigation =
      const NavigationInfoParameters(forcedRedirectEnabled: true);
  SocialMetaTagParameters social = SocialMetaTagParameters(
      description: 'description',
      imageUrl: Uri.parse('imageUrl'),
      title: 'title');

  String uriPrefix = 'https://';
  final longDynamicLink = Uri.parse(
      'https://reactnativefirebase.page.link?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=https://ofl-link.com');

  return DynamicLinkParameters(
    uriPrefix: uriPrefix,
    longDynamicLink: longDynamicLink,
    link: link,
    androidParameters: android,
    googleAnalyticsParameters: google,
    iosParameters: ios,
    itunesConnectAnalyticsParameters: itunes,
    navigationInfoParameters: navigation,
    socialMetaTagParameters: social,
  );
}

void main() {
  setupFirebaseDynamicLinksMocks();

  bool mockPlatformExceptionThrown = false;

  late FirebaseDynamicLinksPlatform dynamicLinks;
  final List<MethodCall> logger = <MethodCall>[];
  int getInitialLinkCall = 1;

  group('$MethodChannelFirebaseDynamicLinks', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        logger.add(call);

        if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }

        final Map<dynamic, dynamic> returnUrl = <dynamic, dynamic>{
          'url': 'google.com',
          'warnings': <dynamic>['This is only a test link'],
        };
        switch (call.method) {
          case 'FirebaseDynamicLinks#buildLink':
            return 'google.com';
          case 'FirebaseDynamicLinks#buildShortLink':
            return returnUrl;
          case 'FirebaseDynamicLink#onLinkSuccess':
            const String name = 'FirebaseDynamicLink#onLinkSuccess';
            handleEventChannel(name, logger);
            return name;
          case 'FirebaseDynamicLinks#getInitialLink':
            if (getInitialLinkCall == 3) {
              return null;
            }
            return <dynamic, dynamic>{
              'link': getInitialLinkCall == 2 ? null : 'https://google.com',
              'android': <dynamic, dynamic>{
                'clickTimestamp': 1234567,
                'minimumVersion': 12,
              },
              'ios': <dynamic, dynamic>{
                'minimumVersion': 'Version 12',
              },
            };
          case 'FirebaseDynamicLinks#getDynamicLink':
            return <dynamic, dynamic>{
              'link': 'https://google.com',
            };
          default:
            return null;
        }
      });

      dynamicLinks = MethodChannelFirebaseDynamicLinks(app: app);
    });

    setUp(() async {
      logger.clear();
    });

    tearDown(() async {
      mockPlatformExceptionThrown = false;
    });

    group('getInitialLink()', () {
      test('link can be parsed', () async {
        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data!.link, Uri.parse('https://google.com'));

        expect(data.android!.clickTimestamp, 1234567);
        expect(data.android!.minimumVersion, 12);

        expect(data.ios!.minimumVersion, 'Version 12');

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: {
              'appName': '[DEFAULT]',
            },
          )
        ]);
      });

      // Both iOS FIRDynamicLink.url and android PendingDynamicLinkData.getUrl()
      // might return null link. In such a case we want to ignore the deep-link.
      test('for null link, return null', () async {
        getInitialLinkCall = 2;
        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data, isNull);

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: {
              'appName': '[DEFAULT]',
            },
          )
        ]);
      });

      test('for null result, returns null', () async {
        getInitialLinkCall = 3;

        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data, isNull);

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: {
              'appName': '[DEFAULT]',
            },
          )
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(dynamicLinks.getInitialLink);
      });
    });

    group('getDynamicLink()', () {
      test('getDynamicLink', () async {
        final Uri argument = Uri.parse('short-link');
        final PendingDynamicLinkData? data =
            await dynamicLinks.getDynamicLink(argument);

        expect(data!.link.host, 'google.com');

        expect(logger, <Matcher>[
          isMethodCall('FirebaseDynamicLinks#getDynamicLink',
              arguments: <String, dynamic>{
                'url': argument.toString(),
                'appName': '[DEFAULT]',
              })
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        final Uri argument = Uri.parse('short-link');
        await testExceptionHandling(
            () => dynamicLinks.getDynamicLink(argument));
      });
    });

    group('buildLink()', () {
      test('buildLink', () async {
        await dynamicLinks.buildLink(buildDynamicLinkParameters());

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#buildLink',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'uriPrefix': 'https://',
              'longDynamicLink':
                  'https://reactnativefirebase.page.link?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=https://ofl-link.com',
              'link': 'link',
              'androidParameters': {
                'fallbackUrl': 'fallbackUrl',
                'minimumVersion': 1,
                'packageName': 'test-package'
              },
              'googleAnalyticsParameters': {
                'campaign': 'campaign',
                'content': 'content',
                'medium': 'medium',
                'source': 'source',
                'term': 'term'
              },
              'iosParameters': {
                'appStoreId': 'appStoreId',
                'bundleId': 'bundleId',
                'customScheme': 'customScheme',
                'fallbackUrl': 'fallbackUrl',
                'ipadBundleId': 'ipadBundleId',
                'ipadFallbackUrl': 'ipadFallbackUrl',
                'minimumVersion': 'minimumVersion',
              },
              'itunesConnectAnalyticsParameters': {
                'affiliateToken': 'affiliateToken',
                'campaignToken': 'campaignToken',
                'providerToken': 'providerToken',
              },
              'navigationInfoParameters': {
                'forcedRedirectEnabled': true,
              },
              'socialMetaTagParameters': {
                'description': 'description',
                'imageUrl': 'imageUrl',
                'title': 'title',
              },
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        DynamicLinkParameters options = buildDynamicLinkParameters();

        await testExceptionHandling(() => dynamicLinks.buildLink(options));
      });
    });

    group('onLink()', () {
      test('returns [Stream<PendingDynamicLinkData>]', () async {
        // Checks that `onLink` does not throw UnimplementedError
        expect(dynamicLinks.onLink, isNotNull);
      });

      test('listens to incoming changes', () async {
        // Stream<PendingDynamicLinkData?> stream =
        //     dynamicLinks.onLink().asBroadcastStream();
        //
        // await injectEventChannelResponse('FirebaseDynamicLink#onLinkSuccess', {
        //   'link': 'link',
        //   'ios': {'minimumVersion': 'minimumVersion'}
        // });
        // TODO find out why event isn't emitted. also catch error.
        // await expectLater(
        //   stream,
        //   emits(isA<PendingDynamicLinkData>()
        //       .having((r) => r.link, 'link', 'link')),
        // );
      });
    });
    group('buildShortLink()', () {
      test('buildShortLink', () async {
        DynamicLinkParameters options = buildDynamicLinkParameters();

        await dynamicLinks.buildShortLink(options);

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#buildShortLink',
            arguments: <String, dynamic>{
              'appName': '[DEFAULT]',
              'shortLinkType': ShortDynamicLinkType.short.index,
              'uriPrefix': 'https://',
              'longDynamicLink':
                  'https://reactnativefirebase.page.link?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=https://ofl-link.com',
              'link': 'link',
              'androidParameters': {
                'fallbackUrl': 'fallbackUrl',
                'minimumVersion': 1,
                'packageName': 'test-package'
              },
              'googleAnalyticsParameters': {
                'campaign': 'campaign',
                'content': 'content',
                'medium': 'medium',
                'source': 'source',
                'term': 'term'
              },
              'iosParameters': {
                'appStoreId': 'appStoreId',
                'bundleId': 'bundleId',
                'customScheme': 'customScheme',
                'fallbackUrl': 'fallbackUrl',
                'ipadBundleId': 'ipadBundleId',
                'ipadFallbackUrl': 'ipadFallbackUrl',
                'minimumVersion': 'minimumVersion',
              },
              'itunesConnectAnalyticsParameters': {
                'affiliateToken': 'affiliateToken',
                'campaignToken': 'campaignToken',
                'providerToken': 'providerToken',
              },
              'navigationInfoParameters': {
                'forcedRedirectEnabled': true,
              },
              'socialMetaTagParameters': {
                'description': 'description',
                'imageUrl': 'imageUrl',
                'title': 'title',
              },
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;
        DynamicLinkParameters options = buildDynamicLinkParameters();

        await testExceptionHandling(() => dynamicLinks.buildShortLink(options));
      });
    });
  });
}

class TestMethodChannelFirebaseDynamicLinks
    extends MethodChannelFirebaseDynamicLinks {
  TestMethodChannelFirebaseDynamicLinks(FirebaseApp app) : super(app: app);
}
