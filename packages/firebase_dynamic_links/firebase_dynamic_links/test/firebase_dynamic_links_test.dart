// ignore_for_file: require_trailing_commas
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';


MockFirebaseDynamicLinks mockDynamicLinksPlatform = MockFirebaseDynamicLinks();

int kMockClickTimestamp = 1234567;
int kMockMinimumVersionAndroid = 12;
String kMockMinimumVersionIOS = 'ios minimum version';
Uri kMockUri = Uri(scheme: 'mock-scheme');

void main() {
  setupFirebaseDynamicLinksMocks();

  late FirebaseDynamicLinks dynamicLinks;
  late FirebaseApp appInstance;

  group('$FirebaseDynamicLinks', () {
    var testCount = 0;

    setUp(() async {
      FirebaseDynamicLinksPlatform.instance = mockDynamicLinksPlatform  = MockFirebaseDynamicLinks();

      // Each test uses a unique FirebaseApp instance to avoid sharing state
      appInstance = await Firebase.initializeApp(
        name: '$testCount',
        options: const FirebaseOptions(
          apiKey: '',
          appId: '',
          messagingSenderId: '',
          projectId: '',
        ),
      );

      dynamicLinks = FirebaseDynamicLinks.instanceFor(app: appInstance);
    });

    // incremented after tests completed, in case a test may want to use this
    // value for an assertion (toString)
    tearDown(() => testCount++);

    group('getInitialLink', () {
      test('link can be parsed', () async {
        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data!.link.scheme, kMockUri.scheme);

        expect(data.android!.clickTimestamp, kMockClickTimestamp);
        expect(data.android!.minimumVersion, kMockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, kMockMinimumVersionIOS);

        verify(mockDynamicLinksPlatform.getInitialLink());
      });

      // Both iOS FIRDynamicLink.url and android PendingDynamicLinkData.getUrl()
      // might return null link. In such a case we want to ignore the deep-link.
    //   test('for null link, returns null', () async {
    //     FirebaseDynamicLinks.channel
    //         .setMockMethodCallHandler((MethodCall methodCall) async {
    //       log.add(methodCall);
    //       switch (methodCall.method) {
    //         case 'FirebaseDynamicLinks#getInitialLink':
    //           return <dynamic, dynamic>{
    //             'link': null,
    //             'android': <dynamic, dynamic>{
    //               'clickTimestamp': 1234567,
    //               'minimumVersion': 12,
    //             },
    //             'ios': <dynamic, dynamic>{
    //               'minimumVersion': 'Version 12',
    //             },
    //           };
    //         default:
    //           return null;
    //       }
    //     });
    //
    //     final PendingDynamicLinkData? data =
    //         await FirebaseDynamicLinks.instance.getInitialLink();
    //
    //     expect(data, isNull);
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'FirebaseDynamicLinks#getInitialLink',
    //         arguments: null,
    //       )
    //     ]);
    //   });
    //
    //   test('for null result, returns null', () async {
    //     FirebaseDynamicLinks.channel
    //         .setMockMethodCallHandler((MethodCall methodCall) async {
    //       log.add(methodCall);
    //       switch (methodCall.method) {
    //         case 'FirebaseDynamicLinks#getInitialLink':
    //           return null;
    //         default:
    //           return null;
    //       }
    //     });
    //
    //     final PendingDynamicLinkData? data =
    //         await FirebaseDynamicLinks.instance.getInitialLink();
    //
    //     expect(data, isNull);
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'FirebaseDynamicLinks#getInitialLink',
    //         arguments: null,
    //       )
    //     ]);
    //   });
    // });
    //
    // test('getDynamicLink', () async {
    //   final Uri argument = Uri.parse('short-link');
    //   final PendingDynamicLinkData? data =
    //       await FirebaseDynamicLinks.instance.getDynamicLink(argument);
    //
    //   expect(data!.link.host, 'google.com');
    //
    //   expect(log, <Matcher>[
    //     isMethodCall('FirebaseDynamicLinks#getDynamicLink',
    //         arguments: <String, dynamic>{
    //           'url': argument.toString(),
    //         })
    //   ]);
    // });
    //
    // group('$DynamicLinkBuilder', () {
    //   test('shortenUrl', () async {
    //     final Uri url = Uri.parse('google.com');
    //     final DynamicLinkParametersOptions options =
    //         DynamicLinkParametersOptions(
    //             shortDynamicLinkPathLength:
    //                 ShortDynamicLinkPathLength.unguessable);
    //
    //     await DynamicLinkBuilder.shortenUrl(url, options);
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#shortenUrl',
    //         arguments: <String, dynamic>{
    //           'url': url.toString(),
    //           'dynamicLinkParametersOptions': <String, dynamic>{
    //             'shortDynamicLinkPathLength':
    //                 ShortDynamicLinkPathLength.unguessable.index,
    //           },
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$AndroidParameters', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       androidParameters: AndroidParameters(
    //         fallbackUrl: Uri.parse('test-url'),
    //         minimumVersion: 1,
    //         packageName: 'test-package',
    //       ),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': <String, dynamic>{
    //             'fallbackUrl': 'test-url',
    //             'minimumVersion': 1,
    //             'packageName': 'test-package',
    //           },
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': <String, dynamic>{
    //             'fallbackUrl': 'test-url',
    //             'minimumVersion': 1,
    //             'packageName': 'test-package',
    //           },
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$DynamicLinkParametersOptions', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       dynamicLinkParametersOptions: DynamicLinkParametersOptions(
    //           shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': <String, dynamic>{
    //             'shortDynamicLinkPathLength':
    //                 ShortDynamicLinkPathLength.short.index,
    //           },
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': <String, dynamic>{
    //             'shortDynamicLinkPathLength':
    //                 ShortDynamicLinkPathLength.short.index,
    //           },
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$ShortDynamicLinkPathLength', () {
    //     expect(ShortDynamicLinkPathLength.unguessable.index, 0);
    //     expect(ShortDynamicLinkPathLength.short.index, 1);
    //   });
    //
    //   test('$GoogleAnalyticsParameters', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       googleAnalyticsParameters: GoogleAnalyticsParameters(
    //         campaign: 'where',
    //         content: 'is',
    //         medium: 'my',
    //         source: 'cat',
    //         term: 'friend',
    //       ),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': <String, dynamic>{
    //             'campaign': 'where',
    //             'content': 'is',
    //             'medium': 'my',
    //             'source': 'cat',
    //             'term': 'friend',
    //           },
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': <String, dynamic>{
    //             'campaign': 'where',
    //             'content': 'is',
    //             'medium': 'my',
    //             'source': 'cat',
    //             'term': 'friend',
    //           },
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$IosParameters', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       iosParameters: IosParameters(
    //         appStoreId: 'is',
    //         bundleId: 'this',
    //         customScheme: 'the',
    //         fallbackUrl: Uri.parse('place'),
    //         ipadBundleId: 'to',
    //         ipadFallbackUrl: Uri.parse('find'),
    //         minimumVersion: 'potatoes',
    //       ),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': <String, dynamic>{
    //             'appStoreId': 'is',
    //             'bundleId': 'this',
    //             'customScheme': 'the',
    //             'fallbackUrl': 'place',
    //             'ipadBundleId': 'to',
    //             'ipadFallbackUrl': 'find',
    //             'minimumVersion': 'potatoes',
    //           },
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': <String, dynamic>{
    //             'appStoreId': 'is',
    //             'bundleId': 'this',
    //             'customScheme': 'the',
    //             'fallbackUrl': 'place',
    //             'ipadBundleId': 'to',
    //             'ipadFallbackUrl': 'find',
    //             'minimumVersion': 'potatoes',
    //           },
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$ItunesConnectAnalyticsParameters', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
    //         affiliateToken: 'hello',
    //         campaignToken: 'mister',
    //         providerToken: 'rose',
    //       ),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': <String, dynamic>{
    //             'affiliateToken': 'hello',
    //             'campaignToken': 'mister',
    //             'providerToken': 'rose',
    //           },
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': <String, dynamic>{
    //             'affiliateToken': 'hello',
    //             'campaignToken': 'mister',
    //             'providerToken': 'rose',
    //           },
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$NavigationInfoParameters', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       navigationInfoParameters:
    //           NavigationInfoParameters(forcedRedirectEnabled: true),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': <String, dynamic>{
    //             'forcedRedirectEnabled': true,
    //           },
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': <String, dynamic>{
    //             'forcedRedirectEnabled': true,
    //           },
    //           'socialMetaTagParameters': null,
    //         },
    //       ),
    //     ]);
    //   });
    //
    //   test('$SocialMetaTagParameters', () async {
    //     final DynamicLinkBuilder components = DynamicLinkBuilder(
    //       uriPrefix: 'https://test-domain/',
    //       link: Uri.parse('test-link.com'),
    //       socialMetaTagParameters: SocialMetaTagParameters(
    //         description: 'describe',
    //         imageUrl: Uri.parse('thisimage'),
    //         title: 'bro',
    //       ),
    //     );
    //
    //     await components.buildUrl();
    //     await components.buildShortLink();
    //
    //     expect(log, <Matcher>[
    //       isMethodCall(
    //         'DynamicLinkParameters#buildUrl',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': <String, dynamic>{
    //             'description': 'describe',
    //             'imageUrl': 'thisimage',
    //             'title': 'bro',
    //           },
    //         },
    //       ),
    //       isMethodCall(
    //         'DynamicLinkParameters#buildShortLink',
    //         arguments: <String, dynamic>{
    //           'androidParameters': null,
    //           'uriPrefix': 'https://test-domain/',
    //           'dynamicLinkParametersOptions': null,
    //           'googleAnalyticsParameters': null,
    //           'iosParameters': null,
    //           'itunesConnectAnalyticsParameters': null,
    //           'link': 'test-link.com',
    //           'navigationInfoParameters': null,
    //           'socialMetaTagParameters': <String, dynamic>{
    //             'description': 'describe',
    //             'imageUrl': 'thisimage',
    //             'title': 'bro',
    //           },
    //         },
    //       ),
    //     ]);
    //   });
    // });
    //
    // group('onLink', () {
    //   OnLinkSuccessCallback? onSuccess;
    //   OnLinkErrorCallback? onError;
    //   final List<PendingDynamicLinkData?> successLog =
    //       <PendingDynamicLinkData?>[];
    //   final List<OnLinkErrorException> errorLog = <OnLinkErrorException>[];
    //   setUp(() {
    //     onSuccess = (linkData) async {
    //       successLog.add(linkData);
    //     };
    //     onError = (error) async {
    //       errorLog.add(error);
    //     };
    //     successLog.clear();
    //     errorLog.clear();
    //   });
    //
    //   Future<void> callMethodHandler(String method, dynamic arguments) {
    //     const channel = FirebaseDynamicLinks.channel;
    //     final methodCall = MethodCall(method, arguments);
    //     final data = channel.codec.encodeMethodCall(methodCall);
    //     final Completer<void> completer = Completer<void>();
    //     channel.binaryMessenger.handlePlatformMessage(
    //       channel.name,
    //       data,
    //       (data) {
    //         completer.complete(null);
    //       },
    //     );
    //     return completer.future;
    //   }
    //
    //   test('onSuccess', () async {
    //     FirebaseDynamicLinks.instance
    //         .onLink(onSuccess: onSuccess, onError: onError);
    //     await callMethodHandler('onLinkSuccess', <dynamic, dynamic>{
    //       'link': 'https://google.com',
    //       'android': <dynamic, dynamic>{
    //         'clickTimestamp': 1234567,
    //         'minimumVersion': 12,
    //       },
    //       'ios': <dynamic, dynamic>{
    //         'minimumVersion': 'Version 12',
    //       },
    //     });
    //
    //     expect(successLog, hasLength(1));
    //     expect(errorLog, hasLength(0));
    //     final success = successLog[0]!;
    //
    //     expect(success.link, Uri.parse('https://google.com'));
    //
    //     expect(success.android!.clickTimestamp, 1234567);
    //     expect(success.android!.minimumVersion, 12);
    //
    //     expect(success.ios!.minimumVersion, 'Version 12');
    //   });
    //
    //   test('onSuccess with null link', () async {
    //     FirebaseDynamicLinks.instance
    //         .onLink(onSuccess: onSuccess, onError: onError);
    //     await callMethodHandler('onLinkSuccess', <dynamic, dynamic>{
    //       'link': null,
    //       'android': <dynamic, dynamic>{
    //         'clickTimestamp': 1234567,
    //         'minimumVersion': 12,
    //       },
    //       'ios': <dynamic, dynamic>{
    //         'minimumVersion': 'Version 12',
    //       },
    //     });
    //
    //     expect(successLog, hasLength(1));
    //     expect(errorLog, hasLength(0));
    //     final success = successLog[0];
    //
    //     expect(success, isNull);
    //   });
    //
    //   test('onSuccess with null', () async {
    //     FirebaseDynamicLinks.instance
    //         .onLink(onSuccess: onSuccess, onError: onError);
    //     await callMethodHandler('onLinkSuccess', null);
    //
    //     expect(successLog, hasLength(1));
    //     expect(errorLog, hasLength(0));
    //     final success = successLog[0];
    //
    //     expect(success, isNull);
    //   });
    //
    //   test('onError', () async {
    //     FirebaseDynamicLinks.instance
    //         .onLink(onSuccess: onSuccess, onError: onError);
    //     await callMethodHandler('onLinkError', <dynamic, dynamic>{
    //       'code': 'code',
    //       'message': 'message',
    //       'details': 'details',
    //     });
    //
    //     expect(successLog, hasLength(0));
    //     expect(errorLog, hasLength(1));
    //     final failure = errorLog[0];
    //     expect(failure.code, 'code');
    //     expect(failure.message, 'message');
    //     expect(failure.details, 'details');
    //   });
    });
  });
}

// FirebaseDynamicLinks.channel
//     .setMockMethodCallHandler((MethodCall methodCall) async {
// log.add(methodCall);
// final Map<dynamic, dynamic> returnUrl = <dynamic, dynamic>{
//   'url': 'google.com',
//   'warnings': <dynamic>['This is only a test link'],
// };
// switch (methodCall.method) {
// case 'DynamicLinkParameters#buildUrl':
// return 'google.com';
// case 'DynamicLinkParameters#buildShortLink':
// return returnUrl;
// case 'DynamicLinkParameters#shortenUrl':
// return returnUrl;
// case 'FirebaseDynamicLinks#getInitialLink':
// return <dynamic, dynamic>{
// 'link': 'https://google.com',
// 'android': <dynamic, dynamic>{
// 'clickTimestamp': 1234567,
// 'minimumVersion': 12,
// },
// 'ios': <dynamic, dynamic>{
// 'minimumVersion': 'Version 12',
// },
// };
// case 'FirebaseDynamicLinks#getDynamicLink':
// return <dynamic, dynamic>{
// 'link': 'https://google.com',
// };
// default:
// return null;
// }
// });

class TestPendingDynamicLinkData extends PendingDynamicLinkData {
  TestPendingDynamicLinkData() : super(kMockUri,PendingDynamicLinkDataAndroid(kMockClickTimestamp, kMockMinimumVersionAndroid), PendingDynamicLinkDataIOS(kMockMinimumVersionIOS));
}

class MockFirebaseDynamicLinks extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebaseDynamicLinksPlatform {

  @override
  Future<PendingDynamicLinkData?> getInitialLink() {
    return super.noSuchMethod(
      Invocation.method(#getInitialLink, []),
      returnValue: Future.value(TestPendingDynamicLinkData()),
      returnValueForMissingStub: Future.value(TestPendingDynamicLinkData()),
    );
  }

  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return super.noSuchMethod(
        Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: MockFirebaseDynamicLinks(appInstance),
      returnValueForMissingStub: MockFirebaseDynamicLinks(),
    );
  }

}

class TestFirebaseDynamicLinksPlatform extends FirebaseDynamicLinksPlatform {
  TestFirebaseDynamicLinksPlatform() : super();

  void instanceFor({
    FirebaseApp? app,
  }) {}

  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return this;
  }
}
