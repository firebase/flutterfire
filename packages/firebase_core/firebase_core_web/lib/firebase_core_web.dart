// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js_util.dart' as js_util;

import 'src/firebase_js.dart';

/// The implementation of `firebase_core` for web.
class FirebaseCoreWeb extends FirebaseCorePlatform {
  /// Creates a new instance of [FirebaseCoreWeb].
  FirebaseCoreWeb() {
    if (firebase == null) {
      throw StateError('firebase.js has not been loaded');
    }
  }

  /// Registers that [FirebaseCoreWeb] is the platform implementation.
  static void registerWith(Registrar registrar) {
    FirebaseCorePlatform.instance = FirebaseCoreWeb();
  }

  @override
  Future<PlatformFirebaseApp> appNamed(String name) async {
    try {
      final App jsApp = firebase.app(name);
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
    firebase.initializeApp(_createFromFirebaseOptions(options), name);
  }

  @override
  Future<List<PlatformFirebaseApp>> allApps() async {
    final List<App> jsApps = firebase.apps;
    return jsApps.map<PlatformFirebaseApp>(_createFromJsApp).toList();
  }
}

/// Returns `true` if [e] is a `FirebaseError`.
bool _isFirebaseError(dynamic e) {
  return js_util.getProperty(e, 'name') == 'FirebaseError';
}

PlatformFirebaseApp _createFromJsApp(App jsApp) {
  return PlatformFirebaseApp(jsApp.name, _createFromJsOptions(jsApp.options));
}

FirebaseOptions _createFromJsOptions(Options options) {
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

Options _createFromFirebaseOptions(FirebaseOptions options) {
  return Options(
    apiKey: options.apiKey,
    measurementId: options.trackingID,
    messagingSenderId: options.gcmSenderID,
    projectId: options.projectID,
    appId: options.googleAppID,
    databaseURL: options.databaseURL,
    storageBucket: options.storageBucket,
  );
}
