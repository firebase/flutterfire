// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final int lastFetchTime = 1520618753782;
  Map<String, dynamic> getDefaultInstance() {
    return <String, dynamic>{
      'lastFetchTime': lastFetchTime,
      'lastFetchStatus': 'success',
      'inDebugMode': true,
      'parameters': <String, dynamic>{
        'param1': <String, dynamic>{
          'source': 'static',
          'value': <int>[118, 97, 108, 49], // UTF-8 encoded 'val1'
        },
      },
    };
  }

  group('$MethodChannelFirebaseRemoteConfig', () {
    final List<MethodCall> log = <MethodCall>[];
    final MethodChannelFirebaseRemoteConfig remoteConfig =
        MethodChannelFirebaseRemoteConfig();

    setUp(() async {
      MethodChannelFirebaseRemoteConfig.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'RemoteConfig#instance':
            return getDefaultInstance();
          case 'RemoteConfig#setConfigSettings':
            return null;
          case 'RemoteConfig#fetch':
            return <String, dynamic>{
              'lastFetchTime': lastFetchTime,
              'lastFetchStatus': 'success',
            };
          case 'RemoteConfig#activate':
            return <String, dynamic>{
              'parameters': <String, dynamic>{
                'param1': <String, dynamic>{
                  'source': 'remote',
                  'value': <int>[118, 97, 108, 49], // UTF-8 encoded 'val1'
                },
                'param2': <String, dynamic>{
                  'source': 'remote',
                  'value': <int>[49, 50, 51, 52, 53], // UTF-8 encoded '12345'
                },
                'param3': <String, dynamic>{
                  'source': 'default',
                  'value': <int>[51, 46, 49, 52], // UTF-8 encoded '3.14'
                },
                'param4': <String, dynamic>{
                  'source': 'remote',
                  'value': <int>[116, 114, 117, 101], // UTF-8 encoded 'true'
                },
                'param5': <String, dynamic>{
                  'source': 'default',
                  'value': <int>[
                    102,
                    97,
                    108,
                    115,
                    101
                  ], // UTF-8 encoded 'false'
                },
                'param6': <String, dynamic>{'source': 'default', 'value': null}
              },
              'newConfig': true,
            };
          case 'RemoteConfig#setDefaults':
            return null;
          default:
            return true;
        }
      });
      log.clear();
    });

    test('getRemoteConfigInstance', () async {
      await remoteConfig.getRemoteConfigInstance();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#instance',
            arguments: null,
          ),
        ],
      );
    });

    test('setConfigSettings', () async {
      final RemoteConfigSettings remoteConfigSettings =
          RemoteConfigSettings(debugMode: false);
      await remoteConfig.setConfigSettings(remoteConfigSettings);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#setConfigSettings',
            arguments: <String, dynamic>{
              'debugMode': false,
            },
          ),
        ],
      );
    });

    test('fetch', () async {
      await remoteConfig.fetch(expiration: const Duration(hours: 1));
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#fetch',
            arguments: <String, dynamic>{
              'expiration': 3600,
            },
          ),
        ],
      );
    });

    test('activateFetched', () async {
      final bool newConfig = await remoteConfig.activateFetched();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#activate',
            arguments: null,
          ),
        ],
      );

      expect(newConfig, true);
      expect(remoteConfig.getString('param1'), 'val1');
      expect(remoteConfig.getInt('param2'), 12345);
      expect(remoteConfig.getDouble('param3'), 3.14);
      expect(remoteConfig.getBool('param4'), true);
      expect(remoteConfig.getBool('param5'), false);
      expect(remoteConfig.getInt('param6'), 0);

      remoteConfig.getAll().forEach((String key, RemoteConfigValue value) {
        switch (key) {
          case 'param1':
            expect(value.asString(), 'val1');
            break;
          case 'param2':
            expect(value.asInt(), 12345);
            break;
          case 'param3':
            expect(value.asDouble(), 3.14);
            break;
          case 'param4':
            expect(value.asBool(), true);
            break;
          case 'param5':
            expect(value.asBool(), false);
            break;
          case 'param6':
            expect(value.asInt(), 0);
            break;
          default:
        }
      });

      final Map<String, ValueSource> resultAllSources = remoteConfig
          .getAll()
          .map((String key, RemoteConfigValue value) =>
              MapEntry<String, ValueSource>(key, value.source));
      expect(resultAllSources, <String, ValueSource>{
        'param1': ValueSource.valueRemote,
        'param2': ValueSource.valueRemote,
        'param3': ValueSource.valueDefault,
        'param4': ValueSource.valueRemote,
        'param5': ValueSource.valueDefault,
        'param6': ValueSource.valueDefault,
      });
    });

    test('setDefaults', () async {
      await remoteConfig.setDefaults(<String, dynamic>{
        'foo': 'bar',
      });
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#setDefaults',
            arguments: <String, dynamic>{
              'defaults': <String, dynamic>{
                'foo': 'bar',
              },
            },
          ),
        ],
      );
    });
  });
}
