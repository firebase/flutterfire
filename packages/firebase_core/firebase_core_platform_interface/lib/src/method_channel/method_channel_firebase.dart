// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core_platform_interface;

/// The [FirebasePlatform] implementation that delegates to a [MethodChannel].
class MethodChannelFirebase extends FirebasePlatform {
  /// Tracks local [MethodChannelFirebaseApp] instances.
  @visibleForTesting
  static Map<String, MethodChannelFirebaseApp> appInstances = {};

  /// Keeps track of whether users have initialized core.
  @visibleForTesting
  static bool isCoreInitialized = false;

  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  /// Calls the native Firebase#initializeCore method.
  ///
  /// Before any plugins can be consumed, any platforms using the [MethodChannel]
  /// can use initializeCore method to return any initialization data, such as
  /// any Firebase apps created natively and any constants which are required
  /// for a plugin to function correctly before usage.
  Future<void> _initializeCore() async {
    List<Map> apps = (await channel.invokeListMethod<Map>(
      'Firebase#initializeCore',
    ))!;

    apps.forEach(_initializeFirebaseAppFromMap);
    isCoreInitialized = true;
  }

  /// Creates and attaches a new [MethodChannelFirebaseApp] to the [MethodChannelFirebase]
  /// and adds any constants to the [FirebasePluginPlatform] class.
  void _initializeFirebaseAppFromMap(Map<dynamic, dynamic> map) {
    MethodChannelFirebaseApp methodChannelFirebaseApp =
        MethodChannelFirebaseApp(
      map['name'],
      FirebaseOptions.fromMap(map['options']),
      isAutomaticDataCollectionEnabled: map['isAutomaticDataCollectionEnabled'],
    );

    MethodChannelFirebase.appInstances[methodChannelFirebaseApp.name] =
        methodChannelFirebaseApp;

    FirebasePluginPlatform
            ._constantsForPluginApps[methodChannelFirebaseApp.name] =
        map['pluginConstants'];
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
    if (name == defaultFirebaseAppName) {
      throw noDefaultAppInitialization();
    }

    // Ensure that core has been initialized on the first usage of
    // initializeApp
    if (!isCoreInitialized) {
      await _initializeCore();
    }

    // If no name is provided, attempt to get the default Firebase app instance.
    // If no instance is available, the user has not set up Firebase correctly for
    // their platform.
    if (name == null) {
      MethodChannelFirebaseApp? defaultApp =
          appInstances[defaultFirebaseAppName];

      if (defaultApp == null) {
        throw coreNotInitialized();
      }

      return appInstances[defaultFirebaseAppName]!;
    }

    assert(
      options != null,
      'FirebaseOptions cannot be null when creating a secondary Firebase app.',
    );

    // Check whether the app has already been initialized
    if (appInstances.containsKey(name)) {
      throw duplicateApp(name);
    }

    _initializeFirebaseAppFromMap((await channel.invokeMapMethod(
      'Firebase#initializeApp',
      <String, dynamic>{'appName': name, 'options': options!.asMap},
    ))!);

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
