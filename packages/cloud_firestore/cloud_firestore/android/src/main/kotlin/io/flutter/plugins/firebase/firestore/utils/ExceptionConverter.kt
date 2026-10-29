/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import android.util.Log
import com.google.firebase.firestore.FirebaseFirestoreException
import io.flutter.plugins.firebase.firestore.FlutterError
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreException
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.Companion.DEFAULT_ERROR_CODE

object ExceptionConverter {
  fun createDetails(exception: Exception?): Map<String, String> {
    val details = HashMap<String, String>()

    if (exception == null) {
      return details
    }

    var firestoreException: FlutterFirebaseFirestoreException? = null

    if (exception is FirebaseFirestoreException) {
      firestoreException = FlutterFirebaseFirestoreException(exception, exception.cause)
    } else if (exception.cause is FirebaseFirestoreException) {
      val firestoreCause = exception.cause as FirebaseFirestoreException
      firestoreException =
          FlutterFirebaseFirestoreException(firestoreCause, firestoreCause.cause ?: firestoreCause)
    }

    if (firestoreException != null) {
      val code = firestoreException.code
      val message = firestoreException.message
      if (code != null) {
        details["code"] = code
      }
      if (message != null) {
        details["message"] = message
      }
    }

    if (details["code"] == "unknown") {
      Log.e("FLTFirebaseFirestore", "An unknown error occurred", exception)
    }

    return details
  }

  fun <T> sendErrorToFlutter(callback: (Result<T>) -> Unit, exception: Exception?) {
    callback(
        Result.failure(
            FlutterError(DEFAULT_ERROR_CODE, exception?.message, createDetails(exception))))
  }
}
