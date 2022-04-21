// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uri link = Uri.parse('pending-link');
  int minimumVersion = 12;
  MatchType matchType = MatchType.high;
  String minimumVersionIos = 'minimum version';
  int clickTimestamp = 12345345;
  PendingDynamicLinkDataAndroid androidData = PendingDynamicLinkDataAndroid(
    minimumVersion: minimumVersion,
    clickTimestamp: clickTimestamp,
  );
  PendingDynamicLinkDataIOS iosData = PendingDynamicLinkDataIOS(
    minimumVersion: minimumVersionIos,
    matchType: matchType,
  );

  group('$PendingDynamicLinkData', () {
    PendingDynamicLinkData pendingDynamicLinkData =
        PendingDynamicLinkData(link: link, android: androidData, ios: iosData);

    group('Constructor', () {
      test('returns an instance of [PendingDynamicLinkData]', () {
        expect(pendingDynamicLinkData, isA<PendingDynamicLinkData>());
        expect(pendingDynamicLinkData.link, link);
        expect(
          pendingDynamicLinkData.android?.clickTimestamp,
          androidData.clickTimestamp,
        );
        expect(
          pendingDynamicLinkData.android?.minimumVersion,
          androidData.minimumVersion,
        );
        expect(
          pendingDynamicLinkData.ios?.minimumVersion,
          iosData.minimumVersion,
        );
      });

      group('asMap', () {
        test('returns the current instance as a [Map]', () {
          final result = pendingDynamicLinkData.asMap();

          expect(result, isA<Map<String, dynamic>>());
          expect(
            result['android']['clickTimestamp'],
            pendingDynamicLinkData.android?.clickTimestamp,
          );
          expect(
            result['android']['minimumVersion'],
            pendingDynamicLinkData.android?.minimumVersion,
          );
          expect(
            result['ios']['minimumVersion'],
            pendingDynamicLinkData.ios?.minimumVersion,
          );
          expect(
            result['ios']['matchType'],
            pendingDynamicLinkData.ios?.matchType?.index,
          );
          expect(result['link'], pendingDynamicLinkData.link.toString());
        });
      });

      test('toString', () {
        expect(
          pendingDynamicLinkData.toString(),
          equals('$PendingDynamicLinkData(${pendingDynamicLinkData.asMap()})'),
        );
      });
    });
  });
}
