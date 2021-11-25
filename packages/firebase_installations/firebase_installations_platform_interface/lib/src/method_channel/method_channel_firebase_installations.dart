// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_installations_platform_interface/firebase_installations_platform_interface.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

class MethodChannelFirebaseInstallations extends FirebaseInstallationsPlatform {
  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseInstallations get instance {
    return MethodChannelFirebaseInstallations._();
  }

  /// The [MethodChannelFirebaseFunctions] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_installations',
  );

  static final Map<String, StreamController<String>> _idTokenChangesListeners =
      <String, StreamController<String>>{};

  /// Creates a new [MethodChannelFirebaseInstallations] instance with an [app].
  MethodChannelFirebaseInstallations({required FirebaseApp app}) : super(app) {
    _idTokenChangesListeners[app.name] = StreamController<String>.broadcast();

    channel
        .invokeMethod<String>('FirebaseInstallations#registerIdTokenListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);
      events.receiveBroadcastStream().listen(
        (arguments) {
          _handleIdTokenChangesListener(app.name, arguments);
        },
      );
    });
  }

  /// Handle any incoming events from Event Channel and forward on to the user.
  Future<void> _handleIdTokenChangesListener(
      String appName, Map<dynamic, dynamic> arguments) async {
    final StreamController<String> controller =
        _idTokenChangesListeners[appName]!;
    controller.add(arguments['token']);
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls a functions method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseInstallations._() : super(null);

  @override
  FirebaseInstallationsPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseInstallations(app: app);
  }

  @override
  Future<void> delete() async {
    try {
      await channel.invokeMethod('FirebaseInstallations#delete', {
        'appName': app!.name,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
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
      throw convertPlatformException(e, s);
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
      throw convertPlatformException(e, s);
    }
  }

  @override
  Stream<String> get idTokenChanges {
    return _idTokenChangesListeners[app!.name]!.stream;
  }
}
