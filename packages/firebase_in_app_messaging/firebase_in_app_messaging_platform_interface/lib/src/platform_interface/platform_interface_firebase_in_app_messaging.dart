// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_in_app_messaging.dart';

abstract class FirebaseInAppMessagingPlatform extends PlatformInterface {
  /// Create an instance using an [app].
  FirebaseInAppMessagingPlatform(this.app) : super(token: _token);

  static final Object _token = Object();

  static FirebaseInAppMessagingPlatform? _instance;

  /// The [FirebaseApp] this instance was initialized with
  final FirebaseApp? app;

  /// Create an instance using [app] using the existing implementation
  factory FirebaseInAppMessagingPlatform.instanceFor({
    required FirebaseApp app,
  }) {
    return FirebaseInAppMessagingPlatform.instance.delegateFor(app: app);
  }

  /// The current default [FirebaseInAppMessagingPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseInAppMessaging]
  /// if no other implementation was provided.
  static FirebaseInAppMessagingPlatform get instance {
    return _instance ??= MethodChannelFirebaseInAppMessaging.instance;
  }

  /// Sets the [FirebaseInAppMessagingPlatform.instance]
  static set instance(FirebaseInAppMessagingPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance or region is required by the user.
  @protected
  FirebaseInAppMessagingPlatform delegateFor({FirebaseApp? app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Programmatically trigger a contextual trigger.
  Future<void> triggerEvent(String eventName) {
    throw UnimplementedError('triggerEvent() is not implemented');
  }

  /// Enable or disable suppression of Firebase In App Messaging messages.
  ///
  /// When enabled, no in app messages will be rendered until either you either
  /// disable suppression, or the app restarts, as this state is not preserved
  /// over app restarts.
  Future<void> setMessagesSuppressed(bool suppress) {
    throw UnimplementedError('setMessagesSuppressed() is not implemented');
  }

  /// Determine whether automatic data collection is enabled or not.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) {
    throw UnimplementedError(
      'setAutomaticDataCollectionEnabled() is not implemented',
    );
  }
}
