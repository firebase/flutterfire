/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils;

import static io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.DEFAULT_ERROR_CODE;

import android.util.Log;
import com.google.firebase.firestore.FirebaseFirestoreException;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreException;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class ExceptionConverter {

  public static Map<String, String> createDetails(Exception exception) {
    Map<String, String> details = new HashMap<>();

    if (exception == null) {
      return details;
    }

    FlutterFirebaseFirestoreException firestoreException = null;

    if (exception instanceof FirebaseFirestoreException) {
      firestoreException =
          new FlutterFirebaseFirestoreException(
              (FirebaseFirestoreException) exception, exception.getCause());
    } else if (exception.getCause() != null
        && exception.getCause() instanceof FirebaseFirestoreException) {
      firestoreException =
          new FlutterFirebaseFirestoreException(
              (FirebaseFirestoreException) exception.getCause(),
              exception.getCause().getCause() != null
                  ? exception.getCause().getCause()
                  : exception.getCause());
    }

    if (firestoreException != null) {
      details.put("code", firestoreException.getCode());
      details.put("message", firestoreException.getMessage());
    }

    if (details.containsKey("code")
        && Objects.requireNonNull(details.get("code")).equals("unknown")) {
      Log.e("FLTFirebaseFirestore", "An unknown error occurred", exception);
    }

    return details;
  }

  public static void sendErrorToFlutter(
      GeneratedAndroidFirebaseFirestore.Result result, Exception exception) {
    Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
    result.error(
        new GeneratedAndroidFirebaseFirestore.FlutterError(
            DEFAULT_ERROR_CODE,
            exception != null ? exception.getMessage() : null,
            exceptionDetails));
  }
}
