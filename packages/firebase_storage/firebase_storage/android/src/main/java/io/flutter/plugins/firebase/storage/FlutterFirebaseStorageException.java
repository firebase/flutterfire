/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.storage;

import androidx.annotation.Nullable;
import com.google.firebase.storage.StorageException;

class FlutterFirebaseStorageException {
  static GeneratedAndroidFirebaseStorage.FlutterError parserExceptionToFlutter(
      @Nullable Exception nativeException) {
    if (nativeException == null) {
      return new GeneratedAndroidFirebaseStorage.FlutterError(
          "UNKNOWN", "An unknown error occurred", null);
    }
    String code = "UNKNOWN";
    String message = "An unknown error occurred:" + nativeException.getMessage();
    int codeNumber;

    if (nativeException instanceof StorageException) {
      codeNumber = ((StorageException) nativeException).getErrorCode();
      code = getCode(codeNumber);
      message = getMessage(codeNumber);
    }

    return new GeneratedAndroidFirebaseStorage.FlutterError(code, message, null);
  }

  public static String getCode(int codeNumber) {
    switch (codeNumber) {
      case StorageException.ERROR_OBJECT_NOT_FOUND:
        return "object-not-found";
      case StorageException.ERROR_BUCKET_NOT_FOUND:
        return "bucket-not-found";
      case StorageException.ERROR_PROJECT_NOT_FOUND:
        return "project-not-found";
      case StorageException.ERROR_QUOTA_EXCEEDED:
        return "quota-exceeded";
      case StorageException.ERROR_NOT_AUTHENTICATED:
        return "unauthenticated";
      case StorageException.ERROR_NOT_AUTHORIZED:
        return "unauthorized";
      case StorageException.ERROR_RETRY_LIMIT_EXCEEDED:
        return "retry-limit-exceeded";
      case StorageException.ERROR_INVALID_CHECKSUM:
        return "invalid-checksum";
      case StorageException.ERROR_CANCELED:
        return "canceled";
      case StorageException.ERROR_UNKNOWN:
      default:
        {
          return "unknown";
        }
    }
  }

  public static String getMessage(int codeNumber) {
    switch (codeNumber) {
      case StorageException.ERROR_OBJECT_NOT_FOUND:
        return "No object exists at the desired reference.";
      case StorageException.ERROR_BUCKET_NOT_FOUND:
        return "No bucket is configured for Firebase Storage.";
      case StorageException.ERROR_PROJECT_NOT_FOUND:
        return "No project is configured for Firebase Storage.";
      case StorageException.ERROR_QUOTA_EXCEEDED:
        return "Quota on your Firebase Storage bucket has been exceeded.";
      case StorageException.ERROR_NOT_AUTHENTICATED:
        return "User is unauthenticated. Authenticate and try again.";
      case StorageException.ERROR_NOT_AUTHORIZED:
        return "User is not authorized to perform the desired action.";
      case StorageException.ERROR_RETRY_LIMIT_EXCEEDED:
        return "The maximum time limit on an operation (upload, download, delete, etc.) has been exceeded.";
      case StorageException.ERROR_INVALID_CHECKSUM:
        return "File on the client does not match the checksum of the file received by the server.";
      case StorageException.ERROR_CANCELED:
        return "User cancelled the operation.";
      case StorageException.ERROR_UNKNOWN:
      default:
        {
          return "An unknown error occurred";
        }
    }
  }
}
