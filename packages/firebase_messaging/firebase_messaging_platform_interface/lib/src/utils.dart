// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

NotificationPriority convertToNotificationPriority(int priority) {
  switch (priority) {
    case 0:
      return NotificationPriority.def;
    case 1:
      return NotificationPriority.high;
    case -1:
      return NotificationPriority.low;
    case 2:
      return NotificationPriority.max;
    case -2:
      return NotificationPriority.min;
    default:
      return NotificationPriority.def;
  }
}

int convertFromNotificationPriority(NotificationPriority priority) {
  switch (priority) {
    case NotificationPriority.def:
      return 0;
    case NotificationPriority.high:
      return 1;
    case NotificationPriority.low:
      return -1;
    case NotificationPriority.max:
      return 2;
    case NotificationPriority.min:
      return -2;
    default:
      return 0;
  }
}

NotificationVisibility convertToNotificationVisibility(int visibility) {
  switch (visibility) {
    case 0:
      return NotificationVisibility.private;
    case 1:
      return NotificationVisibility.public;
    case -1:
      return NotificationVisibility.secret;
    default:
      return NotificationVisibility.private;
  }
}

int convertFromNotificationVisibility(NotificationVisibility visibility) {
  switch (visibility) {
    case NotificationVisibility.private:
      return 0;
    case NotificationVisibility.public:
      return 1;
    case NotificationVisibility.secret:
      return -1;
    default:
      return 0;
  }
}
