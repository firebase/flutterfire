// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config_platform_interface;

/// The method channel implementation of [FirebaseRemoteConfigPlatform].
class MethodChannelFirebaseRemoteConfig extends FirebaseRemoteConfigPlatform {
  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/firebase_remote_config');

  @override
  Future<Map<String, dynamic>> getRemoteConfigInstance() async {
    return _channel.invokeMapMethod<String, dynamic>('RemoteConfig#instance');
  }

  @override
  Future<void> setConfigSettings(bool debugMode) async {
    return _channel
        .invokeMethod<void>('RemoteConfig#setConfigSettings', <String, dynamic>{
      'debugMode': debugMode,
    });
  }

  @override
  Future<Map<String, dynamic>> fetch(
      {Duration expiration = const Duration(hours: 12)}) async {
    return _channel.invokeMapMethod<String, dynamic>('RemoteConfig#fetch',
        <dynamic, dynamic>{'expiration': expiration.inSeconds});
  }

  @override
  Future<Map<String, dynamic>> activateFetched() async {
    return _channel.invokeMapMethod<String, dynamic>('RemoteConfig#activate');
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    return _channel.invokeMethod<void>(
        'RemoteConfig#setDefaults', <String, dynamic>{'defaults': defaults});
  }
}
