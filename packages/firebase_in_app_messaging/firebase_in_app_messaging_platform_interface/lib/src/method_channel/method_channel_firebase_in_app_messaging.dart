// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import 'package:flutter/services.dart';

import 'utils/exception.dart';

class MethodChannelFirebaseInAppMessaging
    extends FirebaseInAppMessagingPlatform {
  MethodChannelFirebaseInAppMessaging({FirebaseApp? app}) : super(app);

  /// Internal stub class initializer.
  ///
  /// When the user code calls a method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseInAppMessaging._() : super(null);

  /// The [MethodChannelFirebaseInAppMessaging] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_in_app_messaging',
  );

  static final pigeonChannel = pigeon.FirebaseInAppMessagingHostApi();

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseInAppMessaging get instance {
    return MethodChannelFirebaseInAppMessaging._();
  }

  @override
  FirebaseInAppMessagingPlatform delegateFor({FirebaseApp? app}) {
    return MethodChannelFirebaseInAppMessaging(app: app);
  }

  @override
  Future<void> triggerEvent(String eventName) async {
    try {
      await pigeonChannel.triggerEvent(app!.name, eventName);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setMessagesSuppressed(bool suppress) async {
    try {
      await pigeonChannel.setMessagesSuppressed(app!.name, suppress);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    try {
      await pigeonChannel.setAutomaticDataCollectionEnabled(app!.name, enabled);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
