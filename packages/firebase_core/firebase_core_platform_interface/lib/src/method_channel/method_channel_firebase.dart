// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../../firebase_core_platform_interface.dart';

/// The [FirebasePlatform] implementation that delegates to a [MethodChannel].
class MethodChannelFirebase extends FirebasePlatform {
  /// Tracks local [MethodChannelFirebaseApp] instances.
  @visibleForTesting
  static Map<String, MethodChannelFirebaseApp> appInstances = {};

  /// Keeps track of whether users have initialized core.
  @visibleForTesting
  static bool isCoreInitialized = false;

  /// Keeps track of whether users have initialized core.
  @visibleForTesting
  static FirebaseCoreHostApi api = FirebaseCoreHostApi();

  /// Calls the native Firebase#initializeCore method.
  ///
  /// Before any plugins can be consumed, any platforms using the [MethodChannel]
  /// can use initializeCore method to return any initialization data, such as
  /// any Firebase apps created natively and any constants which are required
  /// for a plugin to function correctly before usage.
  Future<void> _initializeCore() async {
    List<CoreInitializeResponse> apps = await api.initializeCore();

    apps.cast<CoreInitializeResponse>().forEach(_initializeFirebaseAppFromMap);
    isCoreInitialized = true;
  }

  /// Creates and attaches a new [MethodChannelFirebaseApp] to the [MethodChannelFirebase]
  /// and adds any constants to the [FirebasePlugin] class.
  void _initializeFirebaseAppFromMap(CoreInitializeResponse response) {
    MethodChannelFirebaseApp methodChannelFirebaseApp =
        MethodChannelFirebaseApp(
      response.name,
      FirebaseOptions.fromPigeon(response.options),
      isAutomaticDataCollectionEnabled:
          response.isAutomaticDataCollectionEnabled,
    );

    appInstances[methodChannelFirebaseApp.name] = methodChannelFirebaseApp;

    FirebasePlugin._constantsForPluginApps[methodChannelFirebaseApp.name] =
        response.pluginConstants;
  }

  CoreInitializeResponse _preserveRecaptchaSiteKey(
    CoreInitializeResponse response,
    FirebaseOptions options,
  ) {
    if (response.options.recaptchaSiteKey != null ||
        options.recaptchaSiteKey == null) {
      return response;
    }

    return CoreInitializeResponse(
      name: response.name,
      options: CoreFirebaseOptions(
        apiKey: response.options.apiKey,
        appId: response.options.appId,
        messagingSenderId: response.options.messagingSenderId,
        projectId: response.options.projectId,
        authDomain: response.options.authDomain,
        databaseURL: response.options.databaseURL,
        storageBucket: response.options.storageBucket,
        measurementId: response.options.measurementId,
        trackingId: response.options.trackingId,
        deepLinkURLScheme: response.options.deepLinkURLScheme,
        androidClientId: response.options.androidClientId,
        iosClientId: response.options.iosClientId,
        iosBundleId: response.options.iosBundleId,
        appGroupId: response.options.appGroupId,
        recaptchaSiteKey: options.recaptchaSiteKey,
      ),
      isAutomaticDataCollectionEnabled:
          response.isAutomaticDataCollectionEnabled,
      pluginConstants: response.pluginConstants,
    );
  }

  /// Returns the created [FirebaseAppPlatform] instances.
  @override
  List<FirebaseAppPlatform> get apps {
    return appInstances.values.toList(growable: false);
  }

  /// Initializes a Firebase app instance.
  ///
  /// Internally initializes core if it is not yet ready.
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    // Ensure that core has been initialized on the first usage of
    // initializeApp
    if (!isCoreInitialized) {
      await _initializeCore();
    }

    // If no name is provided, attempt to get the default Firebase app instance.
    // If no instance is available, the user has not set up Firebase correctly for
    // their platform.
    if (name == null || name == defaultFirebaseAppName) {
      MethodChannelFirebaseApp? defaultApp =
          appInstances[defaultFirebaseAppName];
      FirebaseOptions? _options = options;
      // If no default app and no options are provided then
      // attempt to read options from native resources on Android,
      // e.g. this calls to `FirebaseOptions.fromResource(context)`.
      if (defaultTargetPlatform == TargetPlatform.android &&
          defaultApp == null &&
          _options == null) {
        final options = await api.optionsFromResource();
        _options = FirebaseOptions.fromPigeon(options);
      }

      // If no options are present & no default app has been setup, the user is
      // trying to initialize default from Dart
      if (defaultApp == null && _options != null) {
        _initializeFirebaseAppFromMap(_preserveRecaptchaSiteKey(
            await api.initializeApp(
                defaultFirebaseAppName,
                CoreFirebaseOptions(
                  apiKey: _options.apiKey,
                  appId: _options.appId,
                  messagingSenderId: _options.messagingSenderId,
                  projectId: _options.projectId,
                  authDomain: _options.authDomain,
                  databaseURL: _options.databaseURL,
                  storageBucket: _options.storageBucket,
                  measurementId: _options.measurementId,
                  trackingId: _options.trackingId,
                  deepLinkURLScheme: _options.deepLinkURLScheme,
                  androidClientId: _options.androidClientId,
                  iosClientId: _options.iosClientId,
                  iosBundleId: _options.iosBundleId,
                  appGroupId: _options.appGroupId,
                  recaptchaSiteKey: _options.recaptchaSiteKey,
                )),
            _options));
        defaultApp = appInstances[defaultFirebaseAppName];
      }

      // If there is no native default app and the user didn't provide options to
      // create one, throw.
      if (defaultApp == null && _options == null) {
        throw coreNotInitialized();
      }

      // If there is a native default app and the user provided options do a soft
      // check to see if options are roughly identical (so we don't unnecessarily
      // throw on minor differences such as platform specific keys missing
      // e.g. hot reloads/restarts).
      if (defaultApp != null && _options != null) {
        if (_options.apiKey != defaultApp.options.apiKey ||
            (_options.databaseURL != null &&
                _options.databaseURL != defaultApp.options.databaseURL) ||
            (_options.storageBucket != null &&
                _options.storageBucket != defaultApp.options.storageBucket)) {
          // Options are different; throw.
          throw duplicateApp(defaultFirebaseAppName);
        }
        // Options are roughly the same; so we'll return the existing app.
      }

      return appInstances[defaultFirebaseAppName]!;
    }

    assert(
      options != null,
      'FirebaseOptions cannot be null when creating a secondary Firebase app.',
    );

    // Check whether the app has already been initialized
    if (appInstances.containsKey(name)) {
      final existingApp = appInstances[name]!;
      if (options!.apiKey != existingApp.options.apiKey ||
          (options.databaseURL != null &&
              options.databaseURL != existingApp.options.databaseURL) ||
          (options.storageBucket != null &&
              options.storageBucket != existingApp.options.storageBucket)) {
        // Options are different; throw.
        throw duplicateApp(name);
      } else {
        return existingApp;
      }
    }

    _initializeFirebaseAppFromMap(_preserveRecaptchaSiteKey(
        await api.initializeApp(
            name,
            CoreFirebaseOptions(
              apiKey: options!.apiKey,
              appId: options.appId,
              messagingSenderId: options.messagingSenderId,
              projectId: options.projectId,
              authDomain: options.authDomain,
              databaseURL: options.databaseURL,
              storageBucket: options.storageBucket,
              measurementId: options.measurementId,
              trackingId: options.trackingId,
              deepLinkURLScheme: options.deepLinkURLScheme,
              androidClientId: options.androidClientId,
              iosClientId: options.iosClientId,
              iosBundleId: options.iosBundleId,
              appGroupId: options.appGroupId,
              recaptchaSiteKey: options.recaptchaSiteKey,
            )),
        options));
    return appInstances[name]!;
  }

  /// Returns a [FirebaseAppPlatform] by [name].
  ///
  /// Returns the default Firebase app if no [name] is provided and throws a
  /// [FirebaseException] if no app with the [name] has been created.
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (appInstances.containsKey(name)) {
      return appInstances[name]!;
    }

    throw noAppExists(name);
  }
}
