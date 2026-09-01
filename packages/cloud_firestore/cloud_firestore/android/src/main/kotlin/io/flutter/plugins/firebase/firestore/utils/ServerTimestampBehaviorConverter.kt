/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import com.google.firebase.firestore.DocumentSnapshot

object ServerTimestampBehaviorConverter {
  fun toServerTimestampBehavior(
      serverTimestampBehavior: String?
  ): DocumentSnapshot.ServerTimestampBehavior {
    if (serverTimestampBehavior == null) {
      return DocumentSnapshot.ServerTimestampBehavior.NONE
    }
    return when (serverTimestampBehavior) {
      "estimate" -> DocumentSnapshot.ServerTimestampBehavior.ESTIMATE
      "previous" -> DocumentSnapshot.ServerTimestampBehavior.PREVIOUS
      "none" -> DocumentSnapshot.ServerTimestampBehavior.NONE
      else -> DocumentSnapshot.ServerTimestampBehavior.NONE
    }
  }
}
