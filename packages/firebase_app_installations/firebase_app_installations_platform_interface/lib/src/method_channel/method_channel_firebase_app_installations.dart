// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations_platform_interface/firebase_app_installations_platform_interface.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

class MethodChannelFirebaseAppInstallations
    extends FirebaseAppInstallationsPlatform {
  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAppInstallations get instance {
    return MethodChannelFirebaseAppInstallations._();
  }

  /// The [MethodChannelFirebaseFunctions] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_app_installations',
  );

  static final Map<String, StreamController<String>> _idTokenChangesListeners =
      <String, StreamController<String>>{};

  /// Creates a new [MethodChannelFirebaseAppInstallations] instance with an [app].
  MethodChannelFirebaseAppInstallations({required FirebaseApp app})
      : super(app) {
    final controller = _idTokenChangesListeners[app.name] =
        StreamController<String>.broadcast();

    channel.invokeMethod<String>(
        'FirebaseInstallations#registerIdChangeListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);

      events
          .receiveGuardedBroadcastStream(onError: convertPlatformException)
          .listen(
            (Object? arguments) => controller.add((arguments as Map)['token']),
            onError: controller.addError,
          );
    });
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls a functions method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseAppInstallations._() : super(null);

  @override
  FirebaseAppInstallationsPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseAppInstallations(app: app);
  }

  @override
  Future<void> delete() async {
    try {
      await channel.invokeMethod('FirebaseInstallations#delete', {
        'appName': app!.name,
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String> getId() async {
    try {
      String? id =
          await channel.invokeMethod<String>('FirebaseInstallations#getId', {
        'appName': app!.name,
      });

      return id!;
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String> getToken(bool forceRefresh) async {
    try {
      String? id = await channel.invokeMethod<String>(
          'FirebaseInstallations#getToken',
          {'appName': app!.name, 'forceRefresh': forceRefresh});

      return id!;
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Stream<String> get onIdChange {
    return _idTokenChangesListeners[app!.name]!.stream;
  }
}
