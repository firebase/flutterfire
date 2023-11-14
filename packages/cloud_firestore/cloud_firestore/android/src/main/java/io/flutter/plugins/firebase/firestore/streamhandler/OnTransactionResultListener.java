/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.List;

/** callback when a transaction result has been computed. */
public interface OnTransactionResultListener {
  void receiveTransactionResponse(
      GeneratedAndroidFirebaseFirestore.PigeonTransactionResult resultType,
      List<GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand> commands);
}
