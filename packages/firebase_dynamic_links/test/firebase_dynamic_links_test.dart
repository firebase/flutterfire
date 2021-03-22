// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseDynamicLinks', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      FirebaseDynamicLinks.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        final Map<dynamic, dynamic> returnUrl = <dynamic, dynamic>{
          'url': 'google.com',
          'warnings': <dynamic>['This is only a test link'],
        };
        switch (methodCall.method) {
          case 'DynamicLinkParameters#buildUrl':
            return 'google.com';
          case 'DynamicLinkParameters#buildShortLink':
            return returnUrl;
          case 'DynamicLinkParameters#shortenUrl':
            return returnUrl;
          case 'FirebaseDynamicLinks#getInitialLink':
            return <dynamic, dynamic>{
              'link': 'https://google.com',
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
      log.clear();
    });

    group('getInitialLink', () {
      test('link can be parsed', () async {
        final PendingDynamicLinkData data =
            await FirebaseDynamicLinks.instance.getInitialLink();

        expect(data.link, Uri.parse('https://google.com'));

        expect(data.android.clickTimestamp, 1234567);
        expect(data.android.minimumVersion, 12);

        expect(data.ios.minimumVersion, 'Version 12');

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: null,
          )
        ]);
      });

      // Both iOS FIRDynamicLink.url and android PendingDynamicLinkData.getUrl()
      // might return null link. In such a case we want to ignore the deep-link.
      test('for null link, returns null', () async {
        FirebaseDynamicLinks.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'FirebaseDynamicLinks#getInitialLink':
              return <dynamic, dynamic>{
                'link': null,
                'android': <dynamic, dynamic>{
                  'clickTimestamp': 1234567,
                  'minimumVersion': 12,
                },
                'ios': <dynamic, dynamic>{
                  'minimumVersion': 'Version 12',
                },
              };
            default:
              return null;
          }
        });

        final PendingDynamicLinkData data =
            await FirebaseDynamicLinks.instance.getInitialLink();

        expect(data, isNull);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: null,
          )
        ]);
      });

      test('for null result, returns null', () async {
        FirebaseDynamicLinks.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'FirebaseDynamicLinks#getInitialLink':
              return null;
            default:
              return null;
          }
        });

        final PendingDynamicLinkData data =
            await FirebaseDynamicLinks.instance.getInitialLink();

        expect(data, isNull);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseDynamicLinks#getInitialLink',
            arguments: null,
          )
        ]);
      });
    });

    test('getDynamicLink', () async {
      final Uri argument = Uri.parse('short-link');
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getDynamicLink(argument);

      expect(data.link.host, 'google.com');

      expect(log, <Matcher>[
        isMethodCall('FirebaseDynamicLinks#getDynamicLink',
            arguments: <String, dynamic>{
              'url': argument.toString(),
            })
      ]);
    });

    group('$DynamicLinkParameters', () {
      test('shortenUrl', () async {
        final Uri url = Uri.parse('google.com');
        final DynamicLinkParametersOptions options =
            DynamicLinkParametersOptions(
                shortDynamicLinkPathLength:
                    ShortDynamicLinkPathLength.unguessable);

        await DynamicLinkParameters.shortenUrl(url, options);

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#shortenUrl',
            arguments: <String, dynamic>{
              'url': url.toString(),
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.unguessable.index,
              },
            },
          ),
        ]);
      });

      test('$AndroidParameters', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          androidParameters: AndroidParameters(
            fallbackUrl: Uri.parse('test-url'),
            minimumVersion: 1,
            packageName: 'test-package',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': <String, dynamic>{
                'fallbackUrl': 'test-url',
                'minimumVersion': 1,
                'packageName': 'test-package',
              },
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': <String, dynamic>{
                'fallbackUrl': 'test-url',
                'minimumVersion': 1,
                'packageName': 'test-package',
              },
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$DynamicLinkParametersOptions', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          dynamicLinkParametersOptions: DynamicLinkParametersOptions(
              shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.short.index,
              },
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': <String, dynamic>{
                'shortDynamicLinkPathLength':
                    ShortDynamicLinkPathLength.short.index,
              },
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$ShortDynamicLinkPathLength', () {
        expect(ShortDynamicLinkPathLength.unguessable.index, 0);
        expect(ShortDynamicLinkPathLength.short.index, 1);
      });

      test('$GoogleAnalyticsParameters', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          googleAnalyticsParameters: GoogleAnalyticsParameters(
            campaign: 'where',
            content: 'is',
            medium: 'my',
            source: 'cat',
            term: 'friend',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': <String, dynamic>{
                'campaign': 'where',
                'content': 'is',
                'medium': 'my',
                'source': 'cat',
                'term': 'friend',
              },
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': <String, dynamic>{
                'campaign': 'where',
                'content': 'is',
                'medium': 'my',
                'source': 'cat',
                'term': 'friend',
              },
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$IosParameters', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          iosParameters: IosParameters(
            appStoreId: 'is',
            bundleId: 'this',
            customScheme: 'the',
            fallbackUrl: Uri.parse('place'),
            ipadBundleId: 'to',
            ipadFallbackUrl: Uri.parse('find'),
            minimumVersion: 'potatoes',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': <String, dynamic>{
                'appStoreId': 'is',
                'bundleId': 'this',
                'customScheme': 'the',
                'fallbackUrl': 'place',
                'ipadBundleId': 'to',
                'ipadFallbackUrl': 'find',
                'minimumVersion': 'potatoes',
              },
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': <String, dynamic>{
                'appStoreId': 'is',
                'bundleId': 'this',
                'customScheme': 'the',
                'fallbackUrl': 'place',
                'ipadBundleId': 'to',
                'ipadFallbackUrl': 'find',
                'minimumVersion': 'potatoes',
              },
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$ItunesConnectAnalyticsParameters', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
            affiliateToken: 'hello',
            campaignToken: 'mister',
            providerToken: 'rose',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': <String, dynamic>{
                'affiliateToken': 'hello',
                'campaignToken': 'mister',
                'providerToken': 'rose',
              },
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': <String, dynamic>{
                'affiliateToken': 'hello',
                'campaignToken': 'mister',
                'providerToken': 'rose',
              },
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$NavigationInfoParameters', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          navigationInfoParameters:
              NavigationInfoParameters(forcedRedirectEnabled: true),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': <String, dynamic>{
                'forcedRedirectEnabled': true,
              },
              'socialMetaTagParameters': null,
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': <String, dynamic>{
                'forcedRedirectEnabled': true,
              },
              'socialMetaTagParameters': null,
            },
          ),
        ]);
      });

      test('$SocialMetaTagParameters', () async {
        final DynamicLinkParameters components = DynamicLinkParameters(
          uriPrefix: 'https://test-domain/',
          link: Uri.parse('test-link.com'),
          socialMetaTagParameters: SocialMetaTagParameters(
            description: 'describe',
            imageUrl: Uri.parse('thisimage'),
            title: 'bro',
          ),
        );

        await components.buildUrl();
        await components.buildShortLink();

        expect(log, <Matcher>[
          isMethodCall(
            'DynamicLinkParameters#buildUrl',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': <String, dynamic>{
                'description': 'describe',
                'imageUrl': 'thisimage',
                'title': 'bro',
              },
            },
          ),
          isMethodCall(
            'DynamicLinkParameters#buildShortLink',
            arguments: <String, dynamic>{
              'androidParameters': null,
              'uriPrefix': 'https://test-domain/',
              'dynamicLinkParametersOptions': null,
              'googleAnalyticsParameters': null,
              'iosParameters': null,
              'itunesConnectAnalyticsParameters': null,
              'link': 'test-link.com',
              'navigationInfoParameters': null,
              'socialMetaTagParameters': <String, dynamic>{
                'description': 'describe',
                'imageUrl': 'thisimage',
                'title': 'bro',
              },
            },
          ),
        ]);
      });
    });

    group('onLink', () {
      OnLinkSuccessCallback onSuccess;
      OnLinkErrorCallback onError;
      final List<PendingDynamicLinkData> successLog =
          <PendingDynamicLinkData>[];
      final List<OnLinkErrorException> errorLog = <OnLinkErrorException>[];
      setUp(() {
        onSuccess = (linkData) async {
          successLog.add(linkData);
        };
        onError = (error) async {
          errorLog.add(error);
        };
        successLog.clear();
        errorLog.clear();
      });

      Future<void> callMethodHandler(String method, dynamic arguments) {
        final channel = FirebaseDynamicLinks.channel;
        final methodCall = MethodCall(method, arguments);
        final data = channel.codec.encodeMethodCall(methodCall);
        final Completer<void> completer = Completer<void>();
        channel.binaryMessenger.handlePlatformMessage(
          channel.name,
          data,
          (data) {
            completer.complete(null);
          },
        );
        return completer.future;
      }

      test('onSuccess', () async {
        FirebaseDynamicLinks.instance
            .onLink(onSuccess: onSuccess, onError: onError);
        await callMethodHandler('onLinkSuccess', <dynamic, dynamic>{
          'link': 'https://google.com',
          'android': <dynamic, dynamic>{
            'clickTimestamp': 1234567,
            'minimumVersion': 12,
          },
          'ios': <dynamic, dynamic>{
            'minimumVersion': 'Version 12',
          },
        });

        expect(successLog, hasLength(1));
        expect(errorLog, hasLength(0));
        final success = successLog[0];

        expect(success.link, Uri.parse('https://google.com'));

        expect(success.android.clickTimestamp, 1234567);
        expect(success.android.minimumVersion, 12);

        expect(success.ios.minimumVersion, 'Version 12');
      });

      test('onSuccess with null link', () async {
        FirebaseDynamicLinks.instance
            .onLink(onSuccess: onSuccess, onError: onError);
        await callMethodHandler('onLinkSuccess', <dynamic, dynamic>{
          'link': null,
          'android': <dynamic, dynamic>{
            'clickTimestamp': 1234567,
            'minimumVersion': 12,
          },
          'ios': <dynamic, dynamic>{
            'minimumVersion': 'Version 12',
          },
        });

        expect(successLog, hasLength(1));
        expect(errorLog, hasLength(0));
        final success = successLog[0];

        expect(success, isNull);
      });

      test('onSuccess with null', () async {
        FirebaseDynamicLinks.instance
            .onLink(onSuccess: onSuccess, onError: onError);
        await callMethodHandler('onLinkSuccess', null);

        expect(successLog, hasLength(1));
        expect(errorLog, hasLength(0));
        final success = successLog[0];

        expect(success, isNull);
      });

      test('onError', () async {
        FirebaseDynamicLinks.instance
            .onLink(onSuccess: onSuccess, onError: onError);
        await callMethodHandler('onLinkError', <dynamic, dynamic>{
          'code': 'code',
          'message': 'message',
          'details': 'details',
        });

        expect(successLog, hasLength(0));
        expect(errorLog, hasLength(1));
        final failure = errorLog[0];
        expect(failure.code, 'code');
        expect(failure.message, 'message');
        expect(failure.details, 'details');
      });
    });
  });
}
