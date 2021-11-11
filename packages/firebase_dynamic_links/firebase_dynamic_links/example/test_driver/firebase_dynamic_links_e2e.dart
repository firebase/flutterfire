// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('DynamicLinks', () {
    test('buildUrl', () async {
      FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
      const String androidPackageName =
          'io.flutter.plugins.firebasedynamiclinksexample';
      const String iosBundleId =
          'com.google.FirebaseCppDynamicLinksTestApp.dev';
      const String urlHost = 'cx4k7.app.goo.gl';
      const String link = 'https://dynamic.link.example/helloworld';

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://$urlHost',
        link: Uri.parse(link),
        androidParameters: const AndroidParameters(
          packageName: androidPackageName,
          minimumVersion: 1,
        ),
        dynamicLinkParametersOptions: const DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        ),
        iosParameters: const IosParameters(
          bundleId: iosBundleId,
          minimumVersion: '2',
        ),
      );

      final Uri uri = await dynamicLinks.buildUrl(parameters);

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
