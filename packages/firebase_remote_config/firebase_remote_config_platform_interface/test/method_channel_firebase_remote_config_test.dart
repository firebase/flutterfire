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
      await remoteConfig.activateFetched();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'RemoteConfig#activate',
            arguments: null,
          ),
        ],
      );
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
