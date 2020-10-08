// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// Converts an [int] into it's [AndroidNotificationPriority] representation.
AndroidNotificationPriority convertToAndroidNotificationPriority(int priority) {
  switch (priority) {
    case -2:
      return AndroidNotificationPriority.minimumPriority;
    case -1:
      return AndroidNotificationPriority.lowPriority;
    case 0:
      return AndroidNotificationPriority.defaultPriority;
    case 1:
      return AndroidNotificationPriority.highPriority;
    case 2:
      return AndroidNotificationPriority.maximumPriority;
    default:
      return AndroidNotificationPriority.defaultPriority;
  }
}

/// Converts an [AndroidNotificationPriority] into it's [int] representation.
int convertFromAndroidNotificationPriority(
    AndroidNotificationPriority priority) {
  switch (priority) {
    case AndroidNotificationPriority.minimumPriority:
      return -2;
    case AndroidNotificationPriority.lowPriority:
      return -1;
    case AndroidNotificationPriority.defaultPriority:
      return 0;
    case AndroidNotificationPriority.highPriority:
      return 1;
    case AndroidNotificationPriority.maximumPriority:
      return 2;
    default:
      return 0;
  }
}

AndroidNotificationVisibility convertToAndroidNotificationVisibility(
    int visibility) {
  switch (visibility) {
    case -1:
      return AndroidNotificationVisibility.secret;
    case 0:
      return AndroidNotificationVisibility.private;
    case 1:
      return AndroidNotificationVisibility.public;
    default:
      return AndroidNotificationVisibility.private;
  }
}

/// Converts an [int] into it's [AndroidNotificationVisibility] representation.
int convertFromAndroidNotificationVisibility(
    AndroidNotificationVisibility visibility) {
  switch (visibility) {
    case AndroidNotificationVisibility.secret:
      return -1;
    case AndroidNotificationVisibility.private:
      return 0;
    case AndroidNotificationVisibility.public:
      return 1;
    default:
      return 0;
  }
}

/// Converts an [int] into it's [IOSAuthorizationStatus] representation.
IOSAuthorizationStatus convertToIOSAuthorizationStatus(int status) {
  switch (status) {
    case -1:
      return IOSAuthorizationStatus.notDetermined;
    case 0:
      return IOSAuthorizationStatus.denied;
    case 1:
      return IOSAuthorizationStatus.authorized;
    case 2:
      return IOSAuthorizationStatus.provisional;
    default:
      return IOSAuthorizationStatus.notDetermined;
  }
}
