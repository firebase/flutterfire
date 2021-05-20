// @dart = 2.9
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  group('DynamicLinks', () {
    test('buildUrl', () async {
      const String androidPackageName =
          'io.flutter.plugins.firebasedynamiclinksexample';
      const String iosBundleId =
          'com.google.FirebaseCppDynamicLinksTestApp.dev';
      const String urlHost = 'cx4k7.app.goo.gl';
      const String link = 'https://dynamic.link.example/helloworld';

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://$urlHost',
        link: Uri.parse(link),
        androidParameters: AndroidParameters(
          packageName: androidPackageName,
          minimumVersion: 1,
        ),
        dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        ),
        iosParameters: IosParameters(
          bundleId: iosBundleId,
          minimumVersion: '2',
        ),
      );

      final Uri uri = await parameters.buildUrl();

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
}

void main() => drive.main(testsMain);
