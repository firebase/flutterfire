// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_remote_config_platform_interface/src/method_channel/method_channel_firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  test('parses native throttled fetch status', () {
    final remoteConfig = MethodChannelFirebaseRemoteConfig.instance
        .setInitialValues(
          remoteConfigValues: <String, Object?>{'lastFetchStatus': 'throttled'},
        );

    expect(remoteConfig.lastFetchStatus, RemoteConfigFetchStatus.throttle);
  });

  group('onConfigUpdated', () {
    const EventChannel channel = EventChannel(
      'plugins.flutter.io/firebase_remote_config_updated',
    );

    late FirebaseApp app;

    setUpAll(() async {
      app = await Firebase.initializeApp();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, null);
    });

    /// Replays [send] to the stream, the way the Android and iOS plugins
    /// report realtime events.
    void mockNativeEvents(void Function(MockStreamHandlerEventSink) send) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(
            channel,
            MockStreamHandler.inline(
              onListen:
                  (Object? arguments, MockStreamHandlerEventSink events) =>
                      send(events),
            ),
          );
    }

    Matcher isRealtimeError(String code, String message) {
      return isA<FirebaseException>()
          .having((e) => e.plugin, 'plugin', 'firebase_remote_config')
          .having((e) => e.code, 'code', code)
          .having((e) => e.message, 'message', message);
    }

    test(
      'reports realtime errors as FirebaseExceptions with their code',
      () async {
        const List<String> codes = <String>[
          'config-update-stream-error',
          'config-update-message-invalid',
          'config-update-not-fetched',
          'config-update-unavailable',
          'unknown',
        ];
        mockNativeEvents((events) {
          for (final String code in codes) {
            events.error(
              code: 'firebase_remote_config',
              message: 'native message',
              details: <String, String>{'code': code, 'message': 'msg $code'},
            );
          }
        });

        final remoteConfig = MethodChannelFirebaseRemoteConfig(app: app);

        await expectLater(
          remoteConfig.onConfigUpdated,
          emitsInOrder(<Matcher>[
            for (final String code in codes)
              emitsError(isRealtimeError(code, 'msg $code')),
          ]),
        );
      },
    );

    test('keeps the stream open after a realtime error', () async {
      mockNativeEvents((events) {
        events.error(
          code: 'firebase_remote_config',
          message:
              'Unable to connect to the server. Try again in a few '
              'minutes. HTTP status code: 503',
          details: <String, String>{
            'code': 'config-update-stream-error',
            'message':
                'Unable to connect to the server. Try again in a few '
                'minutes. HTTP status code: 503',
          },
        );
        events.success(<String>['welcome_message']);
      });

      final remoteConfig = MethodChannelFirebaseRemoteConfig(app: app);

      await expectLater(
        remoteConfig.onConfigUpdated,
        emitsInOrder(<Matcher>[
          emitsError(
            isRealtimeError(
              'config-update-stream-error',
              'Unable to connect to the server. Try again in a few minutes. '
                  'HTTP status code: 503',
            ),
          ),
          isA<RemoteConfigUpdate>().having(
            (update) => update.updatedKeys,
            'updatedKeys',
            <String>{'welcome_message'},
          ),
        ]),
      );
    });

    test('reports a realtime error without details as unknown', () async {
      mockNativeEvents((events) {
        events.error(
          code: 'firebase_remote_config',
          message: 'The server is temporarily unavailable.',
        );
      });

      final remoteConfig = MethodChannelFirebaseRemoteConfig(app: app);

      await expectLater(
        remoteConfig.onConfigUpdated,
        emitsError(
          isRealtimeError('unknown', 'The server is temporarily unavailable.'),
        ),
      );
    });
  });
}
