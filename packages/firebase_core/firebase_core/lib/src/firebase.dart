// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../firebase_core.dart';

/// The entry point for accessing Firebase.
class Firebase {
  // Ensures end-users cannot initialize the class.
  Firebase._();

  // Cached & lazily loaded instance of [FirebasePlatform].
  // Avoids a [MethodChannelFirebase] being initialized until the user
  // starts using Firebase.
  // The property is visible for testing to allow tests to set a mock
  // instance directly as a static property since the class is not initialized.
  @visibleForTesting
  // ignore: public_member_api_docs
  static FirebasePlatform? delegatePackingProperty;

  static FirebasePlatform get _delegate {
    return delegatePackingProperty ??= FirebasePlatform.instance;
  }

  /// Returns a list of all [FirebaseApp] instances that have been created.
  static List<FirebaseApp> get apps {
    return _delegate.apps.map(FirebaseApp._).toList(growable: false);
  }

  /// Initializes a new [FirebaseApp] instance by [name] and [options] and
  /// returns the created app. This method should be called before any usage of
  /// FlutterFire plugins.
  ///
  /// If a [demoProjectId] is provided, a new [FirebaseApp] instance will be
  /// initialized with a set of default options for demo projects, overriding
  /// the [options] argument. If no [name] is provided alongside a
  /// [demoProjectId], the [demoProjectId] will be used as the app name. By
  /// convention, the [demoProjectId] should begin with "demo-".
  ///
  /// The default app instance can be initialized here simply by passing no "name" as an argument
  /// in both Dart & manual initialization flows.
  /// If you have a `google-services.json` file in your android project or a `GoogleService-Info.plist` file in your iOS+ project,
  /// it will automatically create a default (named "[DEFAULT]") app instance on the native platform. However, you will still need to call this method
  /// before using any FlutterFire plugins.
  static Future<FirebaseApp> initializeApp({
    String? name,
    FirebaseOptions? options,
    String? demoProjectId,
  }) async {
    if (demoProjectId != null) {
      late final String platformString;
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformString = 'android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        platformString = 'ios';
      } else {
        // We use 'web' as the default platform for unknown platforms.
        platformString = 'web';
      }
      // A name must be set, otherwise [DEFAULT] will be used and the options
      // we've provided will be ignored if any platform specific configuration
      // files exist (i.e. GoogleService-Info.plist for iOS).
      name ??= demoProjectId;
      // The user should not set any options if they specify a demo project
      // id, but it was allowed when this API was first added, so we allow it
      // for backwards compatibility and simply override the user-provided
      // options.
      options = FirebaseOptions(
        apiKey: '12345',
        appId: '1:1:$platformString:1',
        messagingSenderId: '',
        projectId: demoProjectId,
      );
      // Now fall through to the normal initialization logic.
    }
    FirebaseAppPlatform app = await _delegate.initializeApp(
      name: name,
      options: options,
    );

    return FirebaseApp._(app);
  }

  /// Returns a [FirebaseApp] instance.
  ///
  /// If no name is provided, the default app instance is returned.
  /// Throws if the app does not exist.
  static FirebaseApp app([String name = defaultFirebaseAppName]) {
    FirebaseAppPlatform app = _delegate.app(name);

    return FirebaseApp._(app);
  }

  // TODO(rrousselGit): remove ==/hashCode
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Firebase) return false;
    return other.hashCode == hashCode;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => toString().hashCode;

  @override
  String toString() => '$Firebase';
}
