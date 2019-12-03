// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js_util.dart' as js_util;

/// The implementation of `firebase_core` for web.
class FirebaseCoreWeb extends FirebaseCorePlatform {
  /// Registers that [FirebaseCoreWeb] is the platform implementation.
  static void registerWith(Registrar registrar) {
    FirebaseCorePlatform.instance = FirebaseCoreWeb();
  }

  @override
  Future<PlatformFirebaseApp> appNamed(String name) async {
    try {
      final fb.App jsApp = fb.app(name);
      if (jsApp == null) {
        return null;
      }
      return _createFromJsApp(jsApp);
    } catch (e) {
      if (_isFirebaseError(e)) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> configure(String name, FirebaseOptions options) async {
    return fb.initializeApp(
      name: name,
      apiKey: options.apiKey,
      databaseURL: options.databaseURL,
      projectId: options.projectID,
      storageBucket: options.storageBucket,
      messagingSenderId: options.gcmSenderID,
      measurementId: options.trackingID,
      appId: options.googleAppID,
    );
  }

  @override
  Future<List<PlatformFirebaseApp>> allApps() async {
    final List<fb.App> jsApps = fb.apps;
    return jsApps.map<PlatformFirebaseApp>(_createFromJsApp).toList();
  }
}

/// Returns `true` if [e] is a `FirebaseError`.
bool _isFirebaseError(dynamic e) {
  return js_util.getProperty(e, 'name') == 'FirebaseError';
}

PlatformFirebaseApp _createFromJsApp(fb.App jsApp) {
  return PlatformFirebaseApp(jsApp.name, _createFromJsOptions(jsApp.options));
}

FirebaseOptions _createFromJsOptions(fb.FirebaseOptions options) {
  return FirebaseOptions(
    apiKey: options.apiKey,
    trackingID: options.measurementId,
    gcmSenderID: options.messagingSenderId,
    projectID: options.projectId,
    googleAppID: options.appId,
    databaseURL: options.databaseURL,
    storageBucket: options.storageBucket,
  );
}
