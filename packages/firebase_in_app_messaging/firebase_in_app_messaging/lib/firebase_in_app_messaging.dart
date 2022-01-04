// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';

class FirebaseInAppMessaging extends FirebasePluginPlatform {
  FirebaseInAppMessaging._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_in_app_messaging');

  /// The [FirebaseApp] for this current [FirebaseAnalytics] instance.
  final FirebaseApp app;

  // Cached and lazily loaded instance of [FirebaseInAppMessagingPlatform] to avoid
  // creating a [MethodChannelFirebaseInAppMessaging] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseInAppMessagingPlatform? _delegatePackingProperty;

  FirebaseInAppMessagingPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseInAppMessagingPlatform.instanceFor(app: app);
  }

  static final Map<String, FirebaseInAppMessaging> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseInAppMessaging get instance {
    return FirebaseInAppMessaging._instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseInAppMessaging _instanceFor({required FirebaseApp app}) {
    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name]!;
    }

    FirebaseInAppMessaging newInstance = FirebaseInAppMessaging._(app: app);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }

  /// Programmatically trigger a contextual trigger.
  Future<void> triggerEvent(String eventName) {
    return _delegate.triggerEvent(eventName);
  }

  /// Enable or disable suppression of Firebase In App Messaging messages.
  ///
  /// When enabled, no in app messages will be rendered until either you either
  /// disable suppression, or the app restarts, as this state is not preserved
  /// over app restarts.
  Future<void> setMessagesSuppressed(bool suppress) {
    return _delegate.setMessagesSuppressed(suppress);
  }

  /// Determine whether automatic data collection is enabled or not.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) {
    return _delegate.setAutomaticDataCollectionEnabled(enabled);
  }
}
