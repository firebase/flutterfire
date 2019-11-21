import 'dart:async';
import 'dart:html' as html;

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/firebase_js.dart';

const String _firebaseAppJs =
    'https://www.gstatic.com/firebasejs/7.4.0/firebase-app.js';

class FirebaseCoreWeb extends FirebaseCorePlatform {
  static void registerWith(Registrar registrar) {
    FirebaseCorePlatform.instance = FirebaseCoreWeb();
  }

  FirebaseCoreWeb() {
    _isInitialized = _initJs();
  }

  Future<void> _isInitialized;

  Future<void> _initJs() {
    final html.ScriptElement script = html.ScriptElement()
      ..async = true
      ..defer = true
      ..src = _firebaseAppJs;
    Completer<void> _scriptLoaded = Completer<void>();
    script.onLoad.first.then((_) {
      _scriptLoaded.complete();
    });
    html.document.head.append(script);
    return _scriptLoaded.future;
  }

  @override
  Future<PlatformFirebaseApp> appNamed(String name) async {
    await _isInitialized;

    final App jsApp = app(name);
    return _createFromJsApp(jsApp);
  }

  @override
  Future<void> configure(String name, FirebaseOptions options) async {
    await _isInitialized;

    final App jsApp = initializeApp(_createFromFirebaseOptions(options), name);
  }

  @override
  Future<List<PlatformFirebaseApp>> allApps() async {
    await _isInitialized;

    List<App> jsApps = apps;
    return jsApps.map<PlatformFirebaseApp>(_createFromJsApp).toList();
  }
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
