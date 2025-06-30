// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:flutter/services.dart';

import './utils/exception.dart';
import '../platform_interface/platform_interface_crashlytics.dart';

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

  bool? _isCrashlyticsCollectionEnabled;
  final _api = CrashlyticsHostApi();

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
      Map<String, dynamic>? data = await _api.checkForUnsentReports();

      return data['unsentReports'];
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> crash() async {
    try {
      await _api.crash();
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> deleteUnsentReports() async {
    try {
      await _api.deleteUnsentReports();
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    try {
      Map<String, dynamic>? data = await _api.didCrashOnPreviousExecution();

      return data['didCrashOnPreviousExecution'];
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> recordError({
    required String exception,
    required String information,
    required String? reason,
    bool fatal = false,
    String? buildId,
    List<String> loadingUnits = const [],
    List<Map<String, String>>? stackTraceElements,
  }) async {
    try {
      await _api.recordError(<String, dynamic>{
        'exception': exception,
        'information': information,
        'reason': reason,
        'fatal': fatal,
        'buildId': buildId ?? '',
        'loadingUnits': loadingUnits,
        'stackTraceElements': stackTraceElements ?? [],
      });
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await _api.log(<String, dynamic>{
        'message': message,
      });
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> sendUnsentReports() async {
    try {
      await _api.sendUnsentReports();
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      Map<String, dynamic>? data =
          await _api.setCrashlyticsCollectionEnabled(<String, bool>{
        'enabled': enabled,
      });

      _isCrashlyticsCollectionEnabled = data!['isCrashlyticsCollectionEnabled'];
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await _api.setUserIdentifier(<String, dynamic>{
        'identifier': identifier,
      });
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setCustomKey(String key, String value) async {
    try {
      await _api.setCustomKey(<String, dynamic>{
        'key': key,
        'value': value,
      });
    } on PlatformException catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
