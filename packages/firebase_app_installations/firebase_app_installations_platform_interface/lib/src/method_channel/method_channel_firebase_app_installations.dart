// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_installations_platform_interface/firebase_app_installations_platform_interface.dart';
import 'package:flutter/services.dart';

import '../pigeon/messages.pigeon.dart';
import 'utils/exception.dart';

class MethodChannelFirebaseAppInstallations
    extends FirebaseAppInstallationsPlatform {
  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAppInstallations get instance {
    return MethodChannelFirebaseAppInstallations._();
  }

  static final FirebaseAppInstallationsHostApi _api =
      FirebaseAppInstallationsHostApi();

  static final Map<String, StreamController<String>> _idTokenChangesListeners =
      <String, StreamController<String>>{};

  /// Creates a new [MethodChannelFirebaseAppInstallations] instance with an [app].
  MethodChannelFirebaseAppInstallations({required FirebaseApp app})
      : super(app) {
    final controller = _idTokenChangesListeners[app.name] =
        StreamController<String>.broadcast();

    _api.registerIdChangeListener(app.name).then((channelName) {
      final events = EventChannel(channelName);

      events
          .receiveGuardedBroadcastStream(onError: convertPlatformException)
          .listen(
            (Object? arguments) => controller.add((arguments as Map)['token']),
            onError: controller.addError,
          );
      // ignore: avoid_catches_without_on_clauses
    }).catchError((_) {
      // Silently ignore errors during listener registration.
      // This can happen in test environments where the host API is not set up.
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
      await _api.delete(app!.name);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String> getId() async {
    try {
      return await _api.getId(app!.name);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String> getToken(bool forceRefresh) async {
    try {
      return await _api.getToken(app!.name, forceRefresh);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Stream<String> get onIdChange {
    return _idTokenChangesListeners[app!.name]!.stream;
  }
}
