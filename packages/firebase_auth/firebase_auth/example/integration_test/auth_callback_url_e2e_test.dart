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

/// The scheme the native SDK redirects with when the reversed client ID is not
/// registered.
String _appIdScheme(FirebaseOptions options) =>
    'app-${options.appId.replaceAll(':', '-')}';

/// The scheme the native SDK redirects with when the reversed client ID is
/// registered, as the example's Info.plist does.
String? _reversedClientIdScheme(FirebaseOptions options) =>
    options.iosClientId?.split('.').reversed.join('.');

/// What the reCAPTCHA, MFA and OAuth redirects open the app with.
Uri _authCallbackUri(String scheme) => Uri.parse(
  '$scheme://firebaseauth/link?deep_link_id='
  '${Uri.encodeQueryComponent('https://flutterfire-e2e-tests.firebaseapp.com/__/auth/callback?authType=signInViaRedirect&eventId=1234')}',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth callback URLs', () {
    late _DeepLinkRecorder deepLinks;
    var controlCount = 0;

    setUp(() {
      deepLinks = _DeepLinkRecorder();
      WidgetsBinding.instance.addObserver(deepLinks);
    });

    tearDown(() {
      WidgetsBinding.instance.removeObserver(deepLinks);
    });

    /// Opens a URL that deep linking must still receive, then checks it is
    /// the only URL pushed.
    ///
    /// The engine does not promise to push deep links in the order they were
    /// opened, so an Auth URL opened earlier may still be on its way when the
    /// control URL arrives. Waiting a little longer gives it the time to
    /// arrive and fail the test.
    Future<void> expectOnlyControlDeepLinkArrives() async {
      final control = Uri.parse(
        '${_appIdScheme(Firebase.app().options)}://example/control/'
        '${controlCount++}',
      );
      await _channel.invokeMethod('openThroughScene', {
        'url': control.toString(),
      });
      await deepLinks.waitFor(control);
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(deepLinks.uris, [control]);
    }

    final schemes = <String, String? Function(FirebaseOptions)>{
      'app ID': _appIdScheme,
      'reversed client ID': _reversedClientIdScheme,
    };

    for (final MapEntry(key: name, value: schemeFor) in schemes.entries) {
      group('with the $name scheme', () {
        /// The callback URL for the [DEFAULT] app, or null after marking the
        /// test skipped when its options have no such scheme.
        Uri? authCallbackUri() {
          final scheme = schemeFor(Firebase.app().options);
          if (scheme == null) {
            markTestSkipped(
              'The [DEFAULT] app has no iOS client ID, so the SDK has no '
              'reversed client ID scheme to redirect with.',
            );
            return null;
          }
          return _authCallbackUri(scheme);
        }

        testWidgets(
          'opened through the app delegate are claimed by the plugin',
          (tester) async {
            final uri = authCallbackUri();
            if (uri == null) return;
            // Deep links wait for the first frame.
            await tester.pumpWidget(const SizedBox());

            final handled = await _channel.invokeMethod<bool>(
              'openThroughAppDelegate',
              {'url': uri.toString()},
            );

            // Only `handled` carries this test. The example uses UIScene, so
            // FlutterAppDelegate has no root view controller and never
            // pushes what it opens, claimed or not: the deep link check
            // below cannot fail here.
            expect(handled, isTrue);
            await expectOnlyControlDeepLinkArrives();
          },
        );

        testWidgets('opened through the scene do not reach deep linking', (
          tester,
        ) async {
          final uri = authCallbackUri();
          if (uri == null) return;
          await tester.pumpWidget(const SizedBox());

          await _channel.invokeMethod('openThroughScene', {
            'url': uri.toString(),
          });

          await expectOnlyControlDeepLinkArrives();
        });
      });
    }

    group('when there is no [DEFAULT] app', () {
      late FirebaseApp namedApp;
      late Uri authCallbackUri;

      setUp(() async {
        // A client ID only this app has, so the URL is matched through it.
        namedApp = await Firebase.initializeApp(
          name: 'auth-callback-url-test',
          options: Firebase.app().options.copyWith(
            iosClientId:
                '123456789012-authcallbackurltest.apps.googleusercontent.com',
          ),
        );
        authCallbackUri = _authCallbackUri(
          _reversedClientIdScheme(namedApp.options)!,
        );
      });

      tearDown(() async {
        await namedApp.delete();
      });

      // The channel makes `FirebaseApp.app()` return nil while it opens the
      // URL, as in an app that only calls `Firebase.initializeApp(name:)`.
      testWidgets(
        'opened through the app delegate are claimed for a named app',
        (tester) async {
          await tester.pumpWidget(const SizedBox());

          final handled = await _channel.invokeMethod<bool>(
            'openThroughAppDelegate',
            {'url': authCallbackUri.toString(), 'withoutDefaultApp': true},
          );

          expect(handled, isTrue);
        },
      );

      testWidgets(
        'opened through the scene do not reach deep linking for a named app',
        (tester) async {
          await tester.pumpWidget(const SizedBox());

          await _channel.invokeMethod('openThroughScene', {
            'url': authCallbackUri.toString(),
            'withoutDefaultApp': true,
          });

          await expectOnlyControlDeepLinkArrives();
        },
      );
    });
  }, skip: kIsWeb || defaultTargetPlatform != TargetPlatform.iOS);
}
