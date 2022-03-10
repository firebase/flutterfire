// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AndroidParameters androidParams = AndroidParameters(
    fallbackUrl: Uri.parse('test-url'),
    minimumVersion: 1,
    packageName: 'test-package',
  );

  GoogleAnalyticsParameters googleParams = const GoogleAnalyticsParameters(
    campaign: 'campaign',
    medium: 'medium',
    source: 'source',
    term: 'term',
    content: 'content',
  );

  IOSParameters iosParams = IOSParameters(
    appStoreId: 'appStoreId',
    bundleId: 'bundleId',
    customScheme: 'customScheme',
    fallbackUrl: Uri.parse('fallbackUrl'),
    ipadBundleId: 'ipadBundleId',
    ipadFallbackUrl: Uri.parse('ipadFallbackUrl'),
    minimumVersion: 'minimumVersion',
  );

  ITunesConnectAnalyticsParameters itunesParams =
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
    title: 'title',
  );

  String uriPrefix = 'https://';

  const String oflLink = 'https://ofl-link.com';
  final longDynamicLink = Uri.parse(
    'https://reactnativefirebase.page.link?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=$oflLink',
  );

  group('$DynamicLinkParameters', () {
    DynamicLinkParameters dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: link,
      longDynamicLink: longDynamicLink,
      androidParameters: androidParams,
      googleAnalyticsParameters: googleParams,
      iosParameters: iosParams,
      itunesConnectAnalyticsParameters: itunesParams,
      navigationInfoParameters: navigation,
      socialMetaTagParameters: social,
    );
    group('Constructor', () {
      test('returns an instance of [DynamicLinkParameters]', () {
        expect(dynamicLinkParams, isA<DynamicLinkParameters>());
        expect(dynamicLinkParams.androidParameters, androidParams);
        expect(dynamicLinkParams.uriPrefix, uriPrefix);
        expect(dynamicLinkParams.link, link);
        expect(dynamicLinkParams.googleAnalyticsParameters, googleParams);
        expect(dynamicLinkParams.iosParameters, iosParams);
        expect(
          dynamicLinkParams.itunesConnectAnalyticsParameters,
          itunesParams,
        );
        expect(dynamicLinkParams.navigationInfoParameters, navigation);
        expect(dynamicLinkParams.socialMetaTagParameters, social);
        expect(dynamicLinkParams.longDynamicLink, longDynamicLink);
      });
    });
    group('asMap', () {
      test('returns the current instance as a [Map]', () {
        final result = dynamicLinkParams.asMap();

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result['androidParameters']['fallbackUrl'],
          dynamicLinkParams.androidParameters?.fallbackUrl.toString(),
        );
        expect(
          result['androidParameters']['minimumVersion'],
          dynamicLinkParams.androidParameters?.minimumVersion,
        );
        expect(
          result['androidParameters']['packageName'],
          dynamicLinkParams.androidParameters?.packageName,
        );
        expect(result['uriPrefix'], dynamicLinkParams.uriPrefix);
        expect(
          result['longDynamicLink'],
          dynamicLinkParams.longDynamicLink.toString(),
        );
        expect(
          result['googleAnalyticsParameters']['campaign'],
          dynamicLinkParams.googleAnalyticsParameters?.campaign,
        );
        expect(
          result['googleAnalyticsParameters']['content'],
          dynamicLinkParams.googleAnalyticsParameters?.content,
        );
        expect(
          result['googleAnalyticsParameters']['medium'],
          dynamicLinkParams.googleAnalyticsParameters?.medium,
        );
        expect(
          result['googleAnalyticsParameters']['source'],
          dynamicLinkParams.googleAnalyticsParameters?.source,
        );
        expect(
          result['googleAnalyticsParameters']['term'],
          dynamicLinkParams.googleAnalyticsParameters?.term,
        );
        expect(
          result['iosParameters']['appStoreId'],
          dynamicLinkParams.iosParameters?.appStoreId,
        );
        expect(
          result['iosParameters']['bundleId'],
          dynamicLinkParams.iosParameters?.bundleId,
        );
        expect(
          result['iosParameters']['customScheme'],
          dynamicLinkParams.iosParameters?.customScheme,
        );
        expect(
          result['iosParameters']['fallbackUrl'],
          dynamicLinkParams.iosParameters?.fallbackUrl.toString(),
        );
        expect(
          result['iosParameters']['ipadBundleId'],
          dynamicLinkParams.iosParameters?.ipadBundleId,
        );
        expect(
          result['iosParameters']['ipadFallbackUrl'],
          dynamicLinkParams.iosParameters?.ipadFallbackUrl.toString(),
        );
        expect(
          result['iosParameters']['minimumVersion'],
          dynamicLinkParams.iosParameters?.minimumVersion,
        );
        expect(
          result['itunesConnectAnalyticsParameters']['affiliateToken'],
          dynamicLinkParams.itunesConnectAnalyticsParameters?.affiliateToken,
        );
        expect(
          result['itunesConnectAnalyticsParameters']['providerToken'],
          dynamicLinkParams.itunesConnectAnalyticsParameters?.providerToken,
        );
        expect(
          result['itunesConnectAnalyticsParameters']['campaignToken'],
          dynamicLinkParams.itunesConnectAnalyticsParameters?.campaignToken,
        );
        expect(result['link'], dynamicLinkParams.link.toString());
        expect(
          result['navigationInfoParameters']['forcedRedirectEnabled'],
          dynamicLinkParams.navigationInfoParameters?.forcedRedirectEnabled,
        );
        expect(
          result['socialMetaTagParameters']['description'],
          dynamicLinkParams.socialMetaTagParameters?.description,
        );
        expect(
          result['socialMetaTagParameters']['imageUrl'],
          dynamicLinkParams.socialMetaTagParameters?.imageUrl.toString(),
        );
        expect(
          result['socialMetaTagParameters']['title'],
          dynamicLinkParams.socialMetaTagParameters?.title,
        );
      });
    });

    test('toString', () {
      expect(
        dynamicLinkParams.toString(),
        equals('$DynamicLinkParameters(${dynamicLinkParams.asMap()})'),
      );
    });
  });
}
