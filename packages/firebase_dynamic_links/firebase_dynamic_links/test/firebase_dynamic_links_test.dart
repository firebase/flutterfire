// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';

MockFirebaseDynamicLinks mockDynamicLinksPlatform = MockFirebaseDynamicLinks();

DynamicLinkParameters buildDynamicLinkParameters() {
  AndroidParameters android = AndroidParameters(
    fallbackUrl: Uri.parse('test-url'),
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
    minimumVersion: 'minimumVersion',
  );

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
    title: 'title',
  );

  String uriPrefix = 'https://';

  return DynamicLinkParameters(
    uriPrefix: uriPrefix,
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

  late FirebaseDynamicLinks dynamicLinks;

  group('$FirebaseDynamicLinks', () {
    setUpAll(() async {
      FirebaseDynamicLinksPlatform.instance = mockDynamicLinksPlatform;

      await Firebase.initializeApp();

      dynamicLinks = FirebaseDynamicLinks.instance;
    });

    group('getInitialLink', () {
      test('link can be parsed', () async {
        const mockClickTimestamp = 1234567;
        const mockMinimumVersionAndroid = 12;
        const mockMinimumVersionIOS = 'ios minimum version';
        const mockMatchTypeIOS = MatchType.high;
        Uri mockUri = Uri.parse('mock-scheme');

        when(dynamicLinks.getInitialLink()).thenAnswer(
          (_) async => TestPendingDynamicLinkData(
            mockUri,
            mockClickTimestamp,
            mockMinimumVersionAndroid,
            mockMinimumVersionIOS,
            mockMatchTypeIOS,
          ),
        );

        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data!.link.scheme, mockUri.scheme);

        expect(data.android!.clickTimestamp, mockClickTimestamp);
        expect(data.android!.minimumVersion, mockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, mockMinimumVersionIOS);

        verify(dynamicLinks.getInitialLink());
      });

      test('for null result, returns null', () async {
        when(dynamicLinks.getInitialLink()).thenAnswer((_) async => null);

        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data, isNull);

        verify(dynamicLinks.getInitialLink());
      });
    });

    group('getDynamicLink', () {
      test('getDynamicLink', () async {
        final Uri mockUri = Uri.parse('short-link');
        const mockClickTimestamp = 38947390875;
        const mockMinimumVersionAndroid = 21;
        const mockMinimumVersionIOS = 'min version';
        const mockMatchTypeIOS = MatchType.weak;

        when(dynamicLinks.getDynamicLink(mockUri)).thenAnswer(
          (_) async => TestPendingDynamicLinkData(
            mockUri,
            mockClickTimestamp,
            mockMinimumVersionAndroid,
            mockMinimumVersionIOS,
            mockMatchTypeIOS,
          ),
        );

        final PendingDynamicLinkData? data =
            await dynamicLinks.getDynamicLink(mockUri);

        expect(data!.link.scheme, mockUri.scheme);

        expect(data.android!.clickTimestamp, mockClickTimestamp);
        expect(data.android!.minimumVersion, mockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, mockMinimumVersionIOS);

        verify(dynamicLinks.getDynamicLink(mockUri));
      });
    });

    group('onLink', () {
      test('onLink', () async {
        final Uri mockUri = Uri.parse('on-link');
        const mockClickTimestamp = 239058435;
        const mockMinimumVersionAndroid = 33;
        const mockMinimumVersionIOS = 'on-link version';
        const mockMatchTypeIOS = MatchType.unique;
        when(dynamicLinks.onLink).thenAnswer(
          (_) => Stream.value(
            TestPendingDynamicLinkData(
              mockUri,
              mockClickTimestamp,
              mockMinimumVersionAndroid,
              mockMinimumVersionIOS,
              mockMatchTypeIOS,
            ),
          ),
        );

        final PendingDynamicLinkData data = await dynamicLinks.onLink.first;
        expect(data.link.scheme, mockUri.scheme);

        expect(data.android!.clickTimestamp, mockClickTimestamp);
        expect(data.android!.minimumVersion, mockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, mockMinimumVersionIOS);

        verify(dynamicLinks.onLink);
      });
    });

    group('buildLink', () {
      test('buildLink', () async {
        final Uri mockUri = Uri.parse('buildLink');
        DynamicLinkParameters params =
            DynamicLinkParameters(uriPrefix: 'uriPrefix', link: mockUri);

        when(dynamicLinks.buildLink(params)).thenAnswer((_) async => mockUri);

        final shortDynamicLink = await dynamicLinks.buildLink(params);

        expect(shortDynamicLink, mockUri);
        expect(shortDynamicLink.scheme, mockUri.scheme);
        expect(shortDynamicLink.path, mockUri.path);

        verify(dynamicLinks.buildLink(params));
      });

      test("buildLink with full 'DynamicLinkParameters' options", () async {
        final Uri mockUri = Uri.parse('buildLink');
        DynamicLinkParameters params = buildDynamicLinkParameters();

        when(dynamicLinks.buildLink(params)).thenAnswer((_) async => mockUri);

        final shortDynamicLink = await dynamicLinks.buildLink(params);

        expect(shortDynamicLink, mockUri);
        expect(shortDynamicLink.scheme, mockUri.scheme);
        expect(shortDynamicLink.path, mockUri.path);

        verify(dynamicLinks.buildLink(params));
      });
    });

    group('buildShortLink', () {
      test('buildShortLink', () async {
        final Uri mockUri = Uri.parse('buildShortLink');
        final Uri previewLink = Uri.parse('previewLink');
        List<String> warnings = ['warning'];
        DynamicLinkParameters params =
            DynamicLinkParameters(uriPrefix: 'uriPrefix', link: mockUri);
        final shortLink = ShortDynamicLink(
          type: ShortDynamicLinkType.short,
          shortUrl: mockUri,
          warnings: warnings,
          previewLink: previewLink,
        );

        when(dynamicLinks.buildShortLink(params)).thenAnswer(
          (_) async => ShortDynamicLink(
            type: ShortDynamicLinkType.short,
            shortUrl: mockUri,
            warnings: warnings,
            previewLink: previewLink,
          ),
        );

        final shortDynamicLink = await dynamicLinks.buildShortLink(params);

        expect(shortDynamicLink.warnings, shortLink.warnings);
        expect(shortDynamicLink.shortUrl, shortLink.shortUrl);
        expect(shortDynamicLink.previewLink, shortLink.previewLink);

        verify(dynamicLinks.buildShortLink(params));
      });

      test("buildShortLink with full 'DynamicLinkParameters' options",
          () async {
        final Uri mockUri = Uri.parse('buildShortLink');
        final Uri previewLink = Uri.parse('previewLink');
        List<String> warnings = ['warning'];
        DynamicLinkParameters params = buildDynamicLinkParameters();
        final shortLink = ShortDynamicLink(
          type: ShortDynamicLinkType.short,
          shortUrl: mockUri,
          warnings: warnings,
          previewLink: previewLink,
        );

        when(dynamicLinks.buildShortLink(params)).thenAnswer(
          (_) async => ShortDynamicLink(
            type: ShortDynamicLinkType.short,
            shortUrl: mockUri,
            warnings: warnings,
            previewLink: previewLink,
          ),
        );

        final shortDynamicLink = await dynamicLinks.buildShortLink(params);

        expect(shortDynamicLink.warnings, shortLink.warnings);
        expect(shortDynamicLink.shortUrl, shortLink.shortUrl);
        expect(shortDynamicLink.previewLink, shortLink.previewLink);

        verify(dynamicLinks.buildShortLink(params));
      });
    });
  });
}

class TestPendingDynamicLinkData extends PendingDynamicLinkData {
  TestPendingDynamicLinkData(
    mockUri,
    mockClickTimestamp,
    mockMinimumVersionAndroid,
    mockMinimumVersionIOS,
    mockMatchTypeIOS,
  ) : super(
          link: mockUri,
          android: PendingDynamicLinkDataAndroid(
            clickTimestamp: mockClickTimestamp,
            minimumVersion: mockMinimumVersionAndroid,
          ),
          ios: PendingDynamicLinkDataIOS(
            minimumVersion: mockMinimumVersionIOS,
            matchType: mockMatchTypeIOS,
          ),
        );
}

final testData =
    TestPendingDynamicLinkData(Uri.parse('uri'), null, null, null, null);

Future<PendingDynamicLinkData?> testFutureData() {
  return Future.value(testData);
}

Uri uri = Uri.parse('mock');

class MockFirebaseDynamicLinks extends Mock
    with
        MockPlatformInterfaceMixin
    implements
// ignore: avoid_implementing_value_types
        TestFirebaseDynamicLinksPlatform {
  @override
  Future<PendingDynamicLinkData?> getInitialLink() {
    return super.noSuchMethod(
      Invocation.method(#getInitialLink, []),
      returnValue: testFutureData(),
      returnValueForMissingStub: testFutureData(),
    );
  }

  @override
  Future<PendingDynamicLinkData?> getDynamicLink(Uri uri) {
    return super.noSuchMethod(
      Invocation.method(#getDynamicLink, [], {#uri: uri}),
      returnValue: testFutureData(),
      returnValueForMissingStub: testFutureData(),
    );
  }

  @override
  Future<Uri> buildLink(DynamicLinkParameters parameters) {
    return super.noSuchMethod(
      Invocation.method(#buildLink, [parameters]),
      returnValue: Future.value(Uri.parse('buildLink')),
      returnValueForMissingStub: Future.value(Uri.parse('buildLink')),
    );
  }

  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: MockFirebaseDynamicLinks(),
      returnValueForMissingStub: MockFirebaseDynamicLinks(),
    );
  }

  @override
  Future<ShortDynamicLink> buildShortLink(
    DynamicLinkParameters parameters, {
    ShortDynamicLinkType shortLinkType = ShortDynamicLinkType.short,
  }) {
    return super.noSuchMethod(
      Invocation.method(#buildShortLink, [parameters]),
      returnValue: Future.value(
        ShortDynamicLink(
          type: ShortDynamicLinkType.short,
          shortUrl: uri,
          warnings: ['warning'],
          previewLink: Uri.parse('preview'),
        ),
      ),
      returnValueForMissingStub: Future.value(
        ShortDynamicLink(
          type: ShortDynamicLinkType.short,
          shortUrl: uri,
          warnings: ['warning'],
          previewLink: Uri.parse('preview'),
        ),
      ),
    );
  }

  @override
  Stream<PendingDynamicLinkData> get onLink {
    return super.noSuchMethod(
      Invocation.getter(#onLink),
      returnValue: Stream.value(testData),
      returnValueForMissingStub: Stream.value(testData),
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
