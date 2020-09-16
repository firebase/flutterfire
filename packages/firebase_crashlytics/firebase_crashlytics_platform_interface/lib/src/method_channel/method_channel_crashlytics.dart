// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import './utils/exception.dart';
import '../platform_interface/platform_interface_crashlytics.dart';

/// The entry point for accessing a method channel based Crashlytics instance.
///
/// You can get an instance by calling [MethodChannelFirebaseCrashlytics.instance].
class MethodChannelFirebaseCrashlytics extends FirebaseCrashlyticsPlatform {
  /// Create an instance of [MethodChannelFirebaseCrashlytics].
  MethodChannelFirebaseCrashlytics({FirebaseApp app}) : super(appInstance: app);

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_crashlytics',
  );

  bool _isCrashlyticsCollectionEnabled;

  @override
  bool get isCrashlyticsCollectionEnabled {
    return _isCrashlyticsCollectionEnabled;
  }

  @override
  MethodChannelFirebaseCrashlytics setInitialValues({
    bool isCrashlyticsCollectionEnabled,
  }) {
    this._isCrashlyticsCollectionEnabled = isCrashlyticsCollectionEnabled;
    return this;
  }

  @override
  Future<bool> checkForUnsentReports() async {
    Map<String, dynamic> data = await channel
        .invokeMapMethod<String, dynamic>('Crashlytics#checkForUnsentReports')
        .catchError(catchPlatformException);

    return data['unsentReports'];
  }

  @override
  Future<void> crash() {
    return channel
        .invokeMethod<void>('Crashlytics#crash')
        .catchError(catchPlatformException);
  }

  @override
  Future<void> deleteUnsentReports() {
    return channel
        .invokeMethod<void>('Crashlytics#deleteUnsentReports')
        .catchError(catchPlatformException);
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    Map<String, dynamic> data = await channel
        .invokeMapMethod<String, dynamic>(
            'Crashlytics#didCrashOnPreviousExecution')
        .catchError(catchPlatformException);

    return data['didCrashOnPreviousExecution'];
  }

  @override
  Future<void> recordError({
    String exception,
    String context,
    String information,
    List<Map<String, String>> stackTraceElements,
  }) {
    return channel
        .invokeMethod<void>('Crashlytics#recordError', <String, dynamic>{
      'exception': exception,
      'context': context,
      'information': information,
      'stackTraceElements': stackTraceElements ?? [],
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> log(String message) {
    return channel.invokeMethod<void>('Crashlytics#log', <String, dynamic>{
      'message': message,
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> sendUnsentReports() {
    return channel
        .invokeMethod<void>('Crashlytics#sendUnsentReports')
        .catchError(catchPlatformException);
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Crashlytics#setCrashlyticsCollectionEnabled', <String, dynamic>{
      'enabled': enabled,
    }).catchError(catchPlatformException);
    _isCrashlyticsCollectionEnabled = data['isCrashlyticsCollectionEnabled'];
  }

  @override
  Future<void> setUserIdentifier(String identifier) {
    return channel
        .invokeMethod<void>('Crashlytics#setUserIdentifier', <String, dynamic>{
      'identifier': identifier,
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> setCustomKey(String key, String value) {
    return channel
        .invokeMethod<void>('Crashlytics#setCustomKey', <String, dynamic>{
      'key': key,
      'value': value,
    }).catchError(catchPlatformException);
  }
}
