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
  // TODO: reinstate once analytics plugin is part of recording fatal error crashes.
  // static MethodChannel _analyticsChannel =
  //     const MethodChannel('plugins.flutter.io/firebase_analytics');

  bool? _isCrashlyticsCollectionEnabled;

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
    if (isCrashlyticsCollectionEnabled) {
      throw StateError(
          "Crashlytics#setCrashlyticsCollectionEnabled has been set to 'true', all reports are automatically sent.");
    }

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
    try {
      /// "fatal" is an optional parameter that we're using to signal to the Crashlytic's service that this particular
      /// error was a fatal one.  The below if statement is Firebase's prescribed method of signalling a fatal error.
      if (fatal) {
        try {
          num currentUnixTimeSeconds =
              (DateTime.now().millisecondsSinceEpoch / 1000).ceil();

          await setCustomKey('com.firebase.crashlytics.flutter.fatal',
              '$currentUnixTimeSeconds');

          // TODO: once confirmation on the event name is received, reinstate analytics.logEvent below.
          // await _analyticsChannel.invokeMethod('logEvent', <String, dynamic>{
          //   'name': '_ae',
          //   'parameters': {
          //     'fatal': 1,
          //     'timestamp': '$currentUnixTimeSeconds',
          //   },
          // });
        } on MissingPluginException {
          // noop - User ought to install firebase_analytics plugin
        } on PlatformException catch (e, s) {
          throw platformExceptionToFirebaseException(e, s);
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
