// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_messaging;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

export 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    show
        RemoteMessageHandler,
        IOSAuthorizationStatus,
        // ignore: deprecated_member_use
        IosNotificationSettings,
        AndroidNotificationPriority,
        AndroidNotificationVisibility,
        RemoteMessage;

part 'src/messaging.dart';
