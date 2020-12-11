// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core_web;

/// Register callback for each plugin (if set in "registerWith" method). This updates plugin specific constants
/// i.e. "firebase_auth" ought to have language code and current user available for each app
typedef Future<Map<String, dynamic>> PluginConstantInitializor(
    FirebaseAppWeb app);

/// The entry point for accessing Firebase.
///
/// You can get an instance by calling [FirebaseCore.instance].
class FirebaseCoreWeb extends FirebasePlatform {
  static Map<String, PluginConstantInitializor> _pluginConstantInitializors =
      {};

  /// Registers that [FirebaseCoreWeb] is the platform implementation.
  static void registerWith(Registrar registrar) {
    FirebasePlatform.instance = FirebaseCoreWeb();
  }

  static void setPluginConstantInitializor(
      String methodChannelName, PluginConstantInitializor callback) {
    _pluginConstantInitializors[methodChannelName] = callback;
  }

  /// Returns all created [FirebaseAppPlatform] instances.
  @override
  List<FirebaseAppPlatform> get apps {
    return firebase.apps.map(_createFromJsApp).toList(growable: false);
  }

  Future<void> _initializeCore() async {
    await Future.forEach<FirebaseAppPlatform>(
        apps, _getPluginConstantsForFirebaseApp);
  }

  void _getPluginConstantsForFirebaseApp(FirebaseAppPlatform app) async {
    await Future.forEach(_pluginConstantInitializors.keys,
        (String methodChannelName) async {
      PluginConstantInitializor getPluginConstantsInitializor =
          _pluginConstantInitializors[methodChannelName];
      Map<String, dynamic> constants = await getPluginConstantsInitializor(app);

      FirebasePluginPlatform.setConstantsForPluginApps(
          app.name, methodChannelName, constants);
    });
  }

  /// Initializes a new [FirebaseAppPlatform] instance by [name] and [options] and returns
  /// the created app. This method should be called before any usage of FlutterFire plugins.
  ///
  /// The default app instance cannot be initialized here and should be created
  /// using the platform Firebase integration.
  @override
  Future<FirebaseAppPlatform> initializeApp(
      {String name, FirebaseOptions options}) async {
    firebase.App app;

    if (name == defaultFirebaseAppName) {
      throw noDefaultAppInitialization();
    }

    if (name == null) {
      try {
        app = firebase.app();
      } catch (e) {
        // TODO(ehesp): Catch JsNotLoadedError error once firebase-dart supports
        // it. See https://github.com/FirebaseExtended/firebase-dart/issues/97
        if (e.toString().contains("Cannot read property 'app' of undefined")) {
          throw coreNotInitialized();
        }

        rethrow;
      }

      if (app == null) {
        throw coreNotInitialized();
      }
    } else {
      assert(options != null,
          "FirebaseOptions cannot be null when creating a secondary Firebase app.");

      try {
        app = firebase.initializeApp(
          name: name,
          apiKey: options.apiKey,
          authDomain: options.authDomain,
          databaseURL: options.databaseURL,
          projectId: options.projectId,
          storageBucket: options.storageBucket,
          messagingSenderId: options.messagingSenderId,
          appId: options.appId,
          measurementId: options.measurementId,
        );
      } catch (e) {
        // TODO(ehesp): Catch JsNotLoadedError error once firebase-dart supports
        // it. See https://github.com/FirebaseExtended/firebase-dart/issues/97
        if (e
            .toString()
            .contains("Cannot read property 'initializeApp' of undefined")) {
          throw coreNotInitialized();
        }

        if (_getJSErrorCode(e) == 'app/duplicate-app') {
          throw duplicateApp(name);
        }

        throw _catchJSError(e);
      }
    }
    await _initializeCore();

    return _createFromJsApp(app);
  }

  /// Returns a [FirebaseAppPlatform] instance.
  ///
  /// If no name is provided, the default app instance is returned.
  /// Throws if the app does not exist.
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    firebase.App app;

    try {
      app = firebase.app(name);
    } catch (e) {
      // TODO(ehesp): Catch JsNotLoadedError error once firebase-dart supports
      // it. See https://github.com/FirebaseExtended/firebase-dart/issues/97

      if (e.toString().contains("Cannot read property 'app' of undefined")) {
        throw coreNotInitialized();
      }

      if (_getJSErrorCode(e) == 'app/no-app') {
        throw noAppExists(name);
      }

      throw _catchJSError(e);
    }

    return _createFromJsApp(app);
  }
}
