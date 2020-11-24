// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'notification_interop.dart' as notification_interop;

class WindowNotification {
  static Future<String> requestPermission() {
    return handleThenable(
        notification_interop.NotificationJsImpl.requestPermission());
  }

  static String get permission {
    return notification_interop.NotificationJsImpl.permission;
  }
}
