// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../platform_interface/platform_interface_crashlytics.dart';
import './utils/exception.dart';

/// The entry point for accessing a method channel based Crashlytics instance.
///
/// You can get an instance by calling [MethodChannelFirebaseCrashlytics.instance].
class MethodChannelFirebaseCrashlytics extends FirebaseCrashlyticsPlatform {
  /// Create an instance of [MethodChannelFirebaseCrashlytics].
  MethodChannelFirebaseCrashlytics({required FirebaseApp app})
      : super(appInstance: app);

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_crashlytics',
  );

  /// The analytics [MethodChannel] for sending fatal errors to the crashlytic's service
  static MethodChannel _analyticsChannel =
      const MethodChannel('plugins.flutter.io/firebase_analytics');

  bool? _isCrashlyticsCollectionEnabled;
  String _FATAL_FLAG = 'com.firebase.crashlytics.flutterfire.fatal';

  @override
  bool get isCrashlyticsCollectionEnabled {
    return _isCrashlyticsCollectionEnabled!;
  }

  @override
  MethodChannelFirebaseCrashlytics setInitialValues({
    required bool isCrashlyticsCollectionEnabled,
  }) {
    _isCrashlyticsCollectionEnabled = isCrashlyticsCollectionEnabled;
    return this;
  }

  @override
  Future<bool> checkForUnsentReports() async {
    try {
      Map<String, dynamic>? data =
          await channel.invokeMapMethod<String, dynamic>(
              'Crashlytics#checkForUnsentReports');

      return data!['unsentReports'];
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> crash() async {
    try {
      await channel.invokeMethod<void>('Crashlytics#crash');
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> deleteUnsentReports() async {
    try {
      await channel.invokeMethod<void>('Crashlytics#deleteUnsentReports');
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    try {
      Map<String, dynamic>? data =
          await channel.invokeMapMethod<String, dynamic>(
              'Crashlytics#didCrashOnPreviousExecution');

      return data!['didCrashOnPreviousExecution'];
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> recordError({
    required String exception,
    required String information,
    required String reason,
    bool fatal = false,
    List<Map<String, String>>? stackTraceElements,
  }) async {
    print("QQQQQQ");
    try {
      if (fatal) {
        try {
          num currentUnixTimeSeconds =
              (DateTime.now().millisecondsSinceEpoch / 1000).floorToDouble();
    print("SSSSSS");

          await setCustomKey(_FATAL_FLAG, '$currentUnixTimeSeconds');
    print("YYYYYY");
          await _analyticsChannel.invokeMethod('logEvent', <String, dynamic>{
            'name': '_ae', // '_ae' is a reserved analytics value for firebase
            'parameters': {
              'fatal': 1, // as in firebase-android-sdk
              'timestamp':
                  currentUnixTimeSeconds, // 'long timestamp', is that current UNIX time?
            },
          });

          //set custom key
          //call analytics method
        } on MissingPluginException catch (error) {
          print("WWWWW: " + e.toString());
          // TODO: warn user that analytics isn't initialised?

        }
      }

      await channel
          .invokeMethod<void>('Crashlytics#recordError', <String, dynamic>{
        'exception': exception,
        'information': information,
        'reason': reason,
        'stackTraceElements': stackTraceElements ?? [],
      });
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await channel.invokeMethod<void>('Crashlytics#log', <String, dynamic>{
        'message': message,
      });
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> sendUnsentReports() async {
    try {
      await channel.invokeMethod<void>('Crashlytics#sendUnsentReports');
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      Map<String, dynamic>? data = await channel
          .invokeMapMethod<String, dynamic>(
              'Crashlytics#setCrashlyticsCollectionEnabled', <String, dynamic>{
        'enabled': enabled,
      });

      _isCrashlyticsCollectionEnabled = data!['isCrashlyticsCollectionEnabled'];
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await channel.invokeMethod<void>(
          'Crashlytics#setUserIdentifier', <String, dynamic>{
        'identifier': identifier,
      });
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<void> setCustomKey(String key, String value) async {
    try {
      await channel
          .invokeMethod<void>('Crashlytics#setCustomKey', <String, dynamic>{
        'key': key,
        'value': value,
      });
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }
}
