// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String affiliateToken = 'affiliateToken';
  String campaignToken = 'campaignToken';
  String providerToken = 'providerToken';

  group('$ITunesConnectAnalyticsParameters', () {
    ITunesConnectAnalyticsParameters itunesParams =
        ITunesConnectAnalyticsParameters(
      affiliateToken: affiliateToken,
      campaignToken: campaignToken,
      providerToken: providerToken,
    );

    group('Constructor', () {
      test('returns an instance of [ItunesConnectAnalyticsParameters]', () {
        expect(itunesParams, isA<ITunesConnectAnalyticsParameters>());
        expect(itunesParams.affiliateToken, affiliateToken);
        expect(itunesParams.campaignToken, campaignToken);
        expect(itunesParams.providerToken, providerToken);
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = itunesParams.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(result['affiliateToken'], itunesParams.affiliateToken);
          expect(result['campaignToken'], itunesParams.campaignToken);
          expect(result['providerToken'], itunesParams.providerToken);
        });
      });

      test('toString', () {
        expect(
          itunesParams.toString(),
          equals('$ITunesConnectAnalyticsParameters(${itunesParams.asMap})'),
        );
      });
    });
  });
}
