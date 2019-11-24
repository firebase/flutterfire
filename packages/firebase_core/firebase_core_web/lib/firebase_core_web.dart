// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/firebase_js.dart' as firebase;

/// The implementation of `firebase_core` for web.
class FirebaseCoreWeb extends FirebaseCorePlatform {
  FirebaseCoreWeb() {
    if (!js.context.hasProperty('firebase')) {
      throw StateError('firebase.js has not been loaded');
    }
  }

  static void registerWith(Registrar registrar) {
    FirebaseCorePlatform.instance = FirebaseCoreWeb();
  }

  @override
  Future<PlatformFirebaseApp> appNamed(String name) async {
    try {
      final firebase.App jsApp = firebase.app(name);
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
    final List<firebase.App> jsApps = firebase.apps;
    return jsApps.map<PlatformFirebaseApp>(_createFromJsApp).toList();
  }
}

/// Returns `true` if [e] is a `FirebaseError`.
bool _isFirebaseError(dynamic e) {
  return js_util.getProperty(e, 'name') == 'FirebaseError';
}

PlatformFirebaseApp _createFromJsApp(firebase.App jsApp) {
  return PlatformFirebaseApp(jsApp.name, _createFromJsOptions(jsApp.options));
}

FirebaseOptions _createFromJsOptions(firebase.Options options) {
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

firebase.Options _createFromFirebaseOptions(FirebaseOptions options) {
  return firebase.Options(
    apiKey: options.apiKey,
    measurementId: options.trackingID,
    messagingSenderId: options.gcmSenderID,
    projectId: options.projectID,
    appId: options.googleAppID,
    databaseURL: options.databaseURL,
    storageBucket: options.storageBucket,
  );
}
