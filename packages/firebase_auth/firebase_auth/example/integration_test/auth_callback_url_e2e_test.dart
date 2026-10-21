// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Implemented by `example/ios/Runner/AuthCallbackURLTestChannel.m`.
const _channel = MethodChannel('tests/auth_callback_url');

/// Records the URLs Flutter deep linking pushes to the app.
class _DeepLinkRecorder with WidgetsBindingObserver {
  final List<Uri> uris = [];

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    uris.add(routeInformation.uri);
    return SynchronousFuture(true);
  }

  /// Completes once [uri] has been pushed.
  Future<void> waitFor(Uri uri) async {
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (!uris.contains(uri)) {
      if (DateTime.now().isAfter(deadline)) {
        fail('$uri was never pushed. Pushed: $uris');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Auth callback URLs',
    () {
      late _DeepLinkRecorder deepLinks;
      late String callbackScheme;
      var controlCount = 0;

      setUp(() {
        deepLinks = _DeepLinkRecorder();
        WidgetsBinding.instance.addObserver(deepLinks);
        // The scheme the native SDK uses for redirects when the reversed
        // client ID is not registered.
        final appId = Firebase.app().options.appId;
        callbackScheme = 'app-${appId.replaceAll(':', '-')}';
      });

      tearDown(() {
        WidgetsBinding.instance.removeObserver(deepLinks);
      });

      // What the reCAPTCHA, MFA and OAuth redirects open the app with.
      Uri authCallbackUri() => Uri.parse(
            '$callbackScheme://firebaseauth/link?deep_link_id='
            '${Uri.encodeQueryComponent('https://flutterfire-e2e-tests.firebaseapp.com/__/auth/callback?authType=signInViaRedirect&eventId=1234')}',
          );

      // A URL for the app, which deep linking must still receive. Deep links
      // are delivered in order, so once it arrives, any earlier one has too.
      Future<void> expectOnlyLaterDeepLinkArrives() async {
        final control =
            Uri.parse('$callbackScheme://example/control/${controlCount++}');
        await _channel.invokeMethod('openThroughScene', {
          'url': control.toString(),
        });
        await deepLinks.waitFor(control);
        expect(deepLinks.uris, [control]);
      }

      testWidgets(
        'opened through the app delegate are claimed by the plugin',
        (tester) async {
          // Deep links wait for the first frame.
          await tester.pumpWidget(const SizedBox());

          final handled = await _channel.invokeMethod<bool>(
            'openThroughAppDelegate',
            {'url': authCallbackUri().toString()},
          );

          expect(handled, isTrue);
          await expectOnlyLaterDeepLinkArrives();
        },
      );

      testWidgets(
        'opened through the scene do not reach deep linking',
        (tester) async {
          await tester.pumpWidget(const SizedBox());

          await _channel.invokeMethod('openThroughScene', {
            'url': authCallbackUri().toString(),
          });

          await expectOnlyLaterDeepLinkArrives();
        },
      );
    },
    skip: kIsWeb || defaultTargetPlatform != TargetPlatform.iOS,
  );
}
