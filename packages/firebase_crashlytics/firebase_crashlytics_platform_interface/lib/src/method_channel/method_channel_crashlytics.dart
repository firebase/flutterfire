// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;

import './utils/exception.dart';
import '../platform_interface/platform_interface_crashlytics.dart';

/// The entry point for accessing a method channel based Crashlytics instance.
///
/// You can get an instance by calling [MethodChannelFirebaseCrashlytics.instance].
class MethodChannelFirebaseCrashlytics extends FirebaseCrashlyticsPlatform {
  /// Create an instance of [MethodChannelFirebaseCrashlytics].
  MethodChannelFirebaseCrashlytics({required FirebaseApp app})
      : super(appInstance: app);

  static final pigeon.FirebaseCrashlyticsHostApi pigeonChannel =
      pigeon.FirebaseCrashlyticsHostApi();

  late bool _isCrashlyticsCollectionEnabled;

  @override
  bool get isCrashlyticsCollectionEnabled {
    return _isCrashlyticsCollectionEnabled;
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
      return await pigeonChannel.checkForUnsentReports();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> crash() async {
    try {
      await pigeonChannel.crash();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> deleteUnsentReports() async {
    try {
      await pigeonChannel.deleteUnsentReports();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    try {
      return await pigeonChannel.didCrashOnPreviousExecution();
    } catch (e, s) {
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
      await pigeonChannel.recordError(
        pigeon.RecordErrorRequest(
          exception: exception,
          information: information,
          reason: reason,
          fatal: fatal,
          buildId: buildId ?? '',
          loadingUnits: loadingUnits,
          stackTraceElements: (stackTraceElements ?? [])
              .map(
                (element) => pigeon.CrashlyticsStackFrame(
                  className: element['class'],
                  method: element['method'] ?? '',
                  file: element['file'] ?? '',
                  line: element['line'] ?? '0',
                ),
              )
              .toList(),
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await pigeonChannel.log(message);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> sendUnsentReports() async {
    try {
      await pigeonChannel.sendUnsentReports();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      _isCrashlyticsCollectionEnabled =
          await pigeonChannel.setCrashlyticsCollectionEnabled(enabled);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await pigeonChannel.setUserIdentifier(identifier);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setCustomKey(String key, String value) async {
    try {
      await pigeonChannel.setCustomKey(key, value);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
