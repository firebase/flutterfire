// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_messaging;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

export 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    show
        BackgroundMessageHandler,
        AppleShowPreviewSetting,
        AppleNotification,
        AppleNotificationSetting,
        AppleNotificationSound,
        AuthorizationStatus,
        NotificationSettings,
        // ignore: deprecated_member_use, deprecated_member_use_from_same_package
        IosNotificationSettings,
        AndroidNotification,
        AndroidNotificationPriority,
        AndroidNotificationVisibility,
        RemoteMessage,
        RemoteNotification;

part 'src/messaging.dart';
