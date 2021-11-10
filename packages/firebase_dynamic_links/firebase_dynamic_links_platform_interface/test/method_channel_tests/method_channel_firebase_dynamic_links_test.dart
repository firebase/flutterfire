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

void main() {
  setupFirebaseDynamicLinksMocks();
  late TestMethodChannelFirebaseDynamicLinks? mockDynamicLinks;
  late FirebaseDynamicLinksPlatform? dynamicLinks;
  final List<MethodCall> logger = <MethodCall>[];
  int getInitialLinkCall = 1;

  group('$MethodChannelFirebaseDynamicLinks', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        logger.add(call);
        final Map<dynamic, dynamic> returnUrl = <dynamic, dynamic>{
          'url': 'google.com',
          'warnings': <dynamic>['This is only a test link'],
        };
        switch (call.method) {
          case 'DynamicLinkParameters#buildUrl':
            return 'google.com';
          case 'DynamicLinkParameters#buildShortLink':
            return returnUrl;
          case 'DynamicLinkParameters#shortenUrl':
            return returnUrl;
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
      mockDynamicLinks = TestMethodChannelFirebaseDynamicLinks(app);
    });

    setUp(() async {
      logger.clear();
    });

    group('getInitialLink', () {
      test('link can be parsed', () async {
        final PendingDynamicLinkData? data =
            await mockDynamicLinks!.getInitialLink();

        expect(data!.link, Uri.parse('https://google.com'));

        expect(data.android!.clickTimestamp, 1234567);
        expect(data.android!.minimumVersion, 12);

        expect(data.ios!.minimumVersion, 'Version 12');

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: null,
          )
        ]);
      });

      // Both iOS FIRDynamicLink.url and android PendingDynamicLinkData.getUrl()
      // might return null link. In such a case we want to ignore the deep-link.
      test('for null link, returns null', () async {
        getInitialLinkCall = 2;
        final PendingDynamicLinkData? data =
            await mockDynamicLinks!.getInitialLink();

        expect(data, isNull);

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: null,
          )
        ]);
      });

      test('for null result, returns null', () async {
        getInitialLinkCall = 3;

        final PendingDynamicLinkData? data =
            await mockDynamicLinks!.getInitialLink();

        expect(data, isNull);

        expect(logger, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: null,
          )
        ]);
      });
    });

    group('getDynamicLink()', () {
      test('getDynamicLink', () async {
        final Uri argument = Uri.parse('short-link');
        final PendingDynamicLinkData? data =
            await dynamicLinks!.getDynamicLink(argument);

        expect(data!.link.host, 'google.com');

        expect(logger, <Matcher>[
          isMethodCall('FirebaseDynamicLinks#getDynamicLink',
              arguments: <String, dynamic>{
                'url': argument.toString(),
              })
        ]);
      });
    });
    group('shortenUrl()', () {
      test('shortenUrl', () async {
        final Uri url = Uri.parse('google.com');
        const DynamicLinkParametersOptions options =
            DynamicLinkParametersOptions(
                shortDynamicLinkPathLength:
                    ShortDynamicLinkPathLength.unguessable);

        await dynamicLinks!.shortenUrl(url, options);

        expect(logger, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#shortenUrl',
            arguments: <String, dynamic>{
              'url': url.toString(),
              'appName': '[DEFAULT]',
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.unguessable.index,
              },
            },
          ),
        ]);
      });

      test('buildUrl()', () async {
        // TODO upto here
      });
    });
  });
}

class TestMethodChannelFirebaseDynamicLinks
    extends MethodChannelFirebaseDynamicLinks {
  TestMethodChannelFirebaseDynamicLinks(FirebaseApp app) : super(app: app);
}
