/*
 * Copyright 2022, the Chromium project authors.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage

import androidx.annotation.Nullable
import com.google.firebase.storage.StorageException

internal object FlutterFirebaseStorageException {
  @JvmStatic
  fun parserExceptionToFlutter(@Nullable nativeException: Exception?): FlutterError {
    if (nativeException == null) {
      return FlutterError(
        "UNKNOWN",
        "An unknown error occurred",
        null
      )
    }

    var code = "UNKNOWN"
    var message = "An unknown error occurred:" + nativeException.message
    var codeNumber: Int

    if (nativeException is StorageException) {
      codeNumber = nativeException.errorCode
      code = getCode(codeNumber)
      message = getMessage(codeNumber)
    }

    return FlutterError(code, message, null)
  }

  @JvmStatic
  fun getCode(codeNumber: Int): String {
    return when (codeNumber) {
      StorageException.ERROR_OBJECT_NOT_FOUND -> "object-not-found"
      StorageException.ERROR_BUCKET_NOT_FOUND -> "bucket-not-found"
      StorageException.ERROR_PROJECT_NOT_FOUND -> "project-not-found"
      StorageException.ERROR_QUOTA_EXCEEDED -> "quota-exceeded"
      StorageException.ERROR_NOT_AUTHENTICATED -> "unauthenticated"
      StorageException.ERROR_NOT_AUTHORIZED -> "unauthorized"
      StorageException.ERROR_RETRY_LIMIT_EXCEEDED -> "retry-limit-exceeded"
      StorageException.ERROR_INVALID_CHECKSUM -> "invalid-checksum"
      StorageException.ERROR_CANCELED -> "canceled"
      StorageException.ERROR_UNKNOWN -> "unknown"
      else -> "unknown"
    }
  }

  @JvmStatic
  fun getMessage(codeNumber: Int): String {
    return when (codeNumber) {
      StorageException.ERROR_OBJECT_NOT_FOUND -> "No object exists at the desired reference."
      StorageException.ERROR_BUCKET_NOT_FOUND -> "No bucket is configured for Firebase Storage."
      StorageException.ERROR_PROJECT_NOT_FOUND -> "No project is configured for Firebase Storage."
      StorageException.ERROR_QUOTA_EXCEEDED -> "Quota on your Firebase Storage bucket has been exceeded."
      StorageException.ERROR_NOT_AUTHENTICATED -> "User is unauthenticated. Authenticate and try again."
      StorageException.ERROR_NOT_AUTHORIZED -> "User is not authorized to perform the desired action."
      StorageException.ERROR_RETRY_LIMIT_EXCEEDED -> "The maximum time limit on an operation (upload, download, delete, etc.) has been exceeded."
      StorageException.ERROR_INVALID_CHECKSUM -> "File on the client does not match the checksum of the file received by the server."
      StorageException.ERROR_CANCELED -> "User cancelled the operation."
      StorageException.ERROR_UNKNOWN -> "An unknown error occurred"
      else -> "An unknown error occurred"
    }
  }
}


