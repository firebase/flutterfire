// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core_web;

class FirebaseWebService {
  String module;

  FirebaseWebService(this.module);
}

/// The entry point for accessing Firebase.
///
/// You can get an instance by calling [FirebaseCore.instance].
class FirebaseCoreWeb extends FirebasePlatform {
  static Map<String, FirebaseWebService> _services = {};

  /// Internally registers a Firebase Service to be initialized.
  static void registerService(FirebaseWebService service) {
    _services.putIfAbsent(service.module, () => service);
  }

  /// Registers that [FirebaseCoreWeb] is the platform implementation.
  static void registerWith(Registrar registrar) {
    FirebasePlatform.instance = FirebaseCoreWeb();
  }

  /// Injects a script into the <head> of the current document.
  Future<void> _injectScript(String src) async {
    ScriptElement script = ScriptElement();
    script.type = 'text/javascript';
    script.src = src;
    script.async = true;
    document.body!.append(script);
    await script.onLoad.first;
  }

  Future<void> _initializeCore() async {
    print(context['firebase']);
    // If Firebase is already available, core has already been initialized
    // (or the user has added the scripts to their html file).
    if (context['firebase'] != null) {
      return;
    }

    ScriptElement script = ScriptElement();
    script.type = 'text/javascript';
    script.innerHtml = '''
      require.config({
        paths: {
          '@firebase/app': 'https://www.gstatic.com/firebasejs/8.6.1/firebase-app',
          '@firebase/firestore': 'https://www.gstatic.com/firebasejs/8.6.1/firebase-firestore',
        }
      });

      require(['@firebase/app', '@firebase/firestore'], (app) => {
        window.firebase = app;
      });
    ''';

    document.head!.append(script);

    Completer completer = Completer();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (context['firebase'] != null) {
        timer.cancel();
        completer.complete();
      }
    });

    await completer.future;

    String version = context['flutterfire_sdk_version'] ?? '8.6.1';

    // // This must come first
    // await _injectScript(
    //     'https://www.gstatic.com/firebasejs/$version/firebase-app.js');
    //
    // await Future.wait(_services.values.map((service) {
    //   return _injectScript(
    //       'https://www.gstatic.com/firebasejs/$version/firebase-${service.module}.js');
    // }));
  }

  /// Returns all created [FirebaseAppPlatform] instances.
  @override
  List<FirebaseAppPlatform> get apps {
    return firebase.apps.map(_createFromJsApp).toList(growable: false);
  }

  /// Initializes a new [FirebaseAppPlatform] instance by [name] and [options] and returns
  /// the created app. This method should be called before any usage of FlutterFire plugins.
  ///
  /// The default app instance cannot be initialized here and should be created
  /// using the platform Firebase integration.
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    await _initializeCore();
    print('Core initied!');
    firebase.App? app;

    if (name == null || name == defaultFirebaseAppName) {
      assert(() {
        try {
          if (firebase.SDK_VERSION != supportedFirebaseJsSdkVersion) {
            // ignore: avoid_print
            print(
              'WARNING: FlutterFire for Web is explicitly tested against Firebase JS SDK version "$supportedFirebaseJsSdkVersion" '
              'but your currently imported Firebase JS SDKs in your web/index.html file are using version "${firebase.SDK_VERSION}" '
              '- this may lead to unexpected issues in your application. It is recommended that you upgrade the versions of all the '
              'Firebase JS SDK scripts in your web/index.html file to use version "$supportedFirebaseJsSdkVersion", e.g.; \n'
              'change:\n'
              '  <script src="https://www.gstatic.com/firebasejs/${firebase.SDK_VERSION}/firebase-app.js"></script> \n'
              'to: \n'
              '  <script src="https://www.gstatic.com/firebasejs/$supportedFirebaseJsSdkVersion/firebase-app.js"></script> \n',
            );
          }
        } catch (e) {
          // TODO(ehesp): Better way of catching this in interop?
          if (e
              .toString()
              .contains("Cannot read property 'SDK_VERSION' of undefined")) {
            throw coreNotInitialized();
          }
        }

        return true;
      }());

      try {
        app = firebase.app();

        if (options != null) {
          // If there is a default app already and the user provided options do a soft
          // check to see if options are roughly identical (so we don't unnecessarily
          // throw on minor differences such as platform specific keys missing,
          // e.g. hot reloads/restarts).
          if (options.apiKey != app.options.apiKey ||
              options.databaseURL != app.options.databaseURL ||
              options.storageBucket != app.options.storageBucket) {
            // Options are different; throw.
            throw duplicateApp(defaultFirebaseAppName);
          }
          // Options are roughly the same; so we'll return the existing app.
        }
      } catch (e) {
        print(e);
        // If the options check failed
        if (e is FirebaseException) {
          rethrow;
        }

        // TODO(ehesp): Better way of catching this in interop?
        if (e.toString().contains('Cannot read properties of undefined')) {
          throw coreNotInitialized();
        }

        // If there is no firebase default app, but the user provided options,
        // create it.
        // ignore: invariant_booleans
        if (app == null && options != null) {
          app = firebase.initializeApp(
            apiKey: options.apiKey,
            authDomain: options.authDomain,
            databaseURL: options.databaseURL,
            projectId: options.projectId,
            storageBucket: options.storageBucket,
            messagingSenderId: options.messagingSenderId,
            appId: options.appId,
            measurementId: options.measurementId,
          );
        } else {
          rethrow;
        }
      }
    } else {
      assert(
        options != null,
        'FirebaseOptions cannot be null when creating a secondary Firebase app.',
      );

      try {
        app = firebase.initializeApp(
          name: name,
          apiKey: options!.apiKey,
          authDomain: options.authDomain,
          databaseURL: options.databaseURL,
          projectId: options.projectId,
          storageBucket: options.storageBucket,
          messagingSenderId: options.messagingSenderId,
          appId: options.appId,
          measurementId: options.measurementId,
        );
      } catch (e) {
        // TODO(ehesp): Better way of catching this in interop?
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
