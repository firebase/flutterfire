/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseException;
import java.util.HashMap;
import java.util.Map;

public class FlutterFirebaseDatabaseException extends Exception {
  public static final String UNKNOWN_ERROR_CODE = "unknown";
  public static final String UNKNOWN_ERROR_MESSAGE = "An unknown error occurred";
  private static final String MODULE = "firebase_database";
  private final String code;
  private final String message;
  private final Map<String, Object> additionalData;

  public FlutterFirebaseDatabaseException(
      @NonNull String code, @NonNull String message, @Nullable Map<String, Object> additionalData) {
    this.code = code;
    this.message = message;

    if (additionalData != null) {
      this.additionalData = additionalData;
    } else {
      this.additionalData = new HashMap<>();
    }

    this.additionalData.put(Constants.ERROR_CODE, code);
    this.additionalData.put(Constants.ERROR_MESSAGE, message);
  }

  static FlutterFirebaseDatabaseException fromDatabaseError(DatabaseError e) {
    final int errorCode = e.getCode();

    String code = UNKNOWN_ERROR_CODE;
    String message = UNKNOWN_ERROR_MESSAGE;

    switch (errorCode) {
      case DatabaseError.DATA_STALE:
        code = "data-stale";
        message = "The transaction needs to be run again with current data.";
        break;
      case DatabaseError.OPERATION_FAILED:
        code = "failure";
        message = "The server indicated that this operation failed.";
        break;
      case DatabaseError.PERMISSION_DENIED:
        code = "permission-denied";
        message = "Client doesn't have permission to access the desired data.";
        break;
      case DatabaseError.DISCONNECTED:
        code = "disconnected";
        message = "The operation had to be aborted due to a network disconnect.";
        break;
      case DatabaseError.EXPIRED_TOKEN:
        code = "expired-token";
        message = "The supplied auth token has expired.";
        break;
      case DatabaseError.INVALID_TOKEN:
        code = "invalid-token";
        message = "The supplied auth token was invalid.";
        break;
      case DatabaseError.MAX_RETRIES:
        code = "max-retries";
        message = "The transaction had too many retries.";
        break;
      case DatabaseError.OVERRIDDEN_BY_SET:
        code = "overridden-by-set";
        message = "The transaction was overridden by a subsequent set.";
        break;
      case DatabaseError.UNAVAILABLE:
        code = "unavailable";
        message = "The service is unavailable.";
        break;
      case DatabaseError.NETWORK_ERROR:
        code = "network-error";
        message = "The operation could not be performed due to a network error.";
        break;
      case DatabaseError.WRITE_CANCELED:
        code = "write-cancelled";
        message = "The write was canceled by the user.";
        break;
    }

    if (code.equals(UNKNOWN_ERROR_CODE)) {
      return unknown(e.getMessage());
    }

    final Map<String, Object> additionalData = new HashMap<>();
    final String errorDetails = e.getDetails();
    additionalData.put(Constants.ERROR_DETAILS, errorDetails);
    return new FlutterFirebaseDatabaseException(code, message, additionalData);
  }

  static FlutterFirebaseDatabaseException fromDatabaseException(DatabaseException e) {
    final DatabaseError error = DatabaseError.fromException(e);
    return fromDatabaseError(error);
  }

  static FlutterFirebaseDatabaseException fromException(@Nullable Exception e) {
    if (e == null) return unknown();
    return unknown(e.getMessage());
  }

  static FlutterFirebaseDatabaseException unknown() {
    return unknown(null);
  }

  static FlutterFirebaseDatabaseException unknown(@Nullable String errorMessage) {
    final Map<String, Object> details = new HashMap<>();
    String code = UNKNOWN_ERROR_CODE;

    String message = errorMessage;

    if (errorMessage == null) {
      message = UNKNOWN_ERROR_MESSAGE;
    }

    if (message.contains("Index not defined, add \".indexOn\"")) {
      // No known error code for this in DatabaseError, so we manually have to
      // detect it.
      code = "index-not-defined";
      message = message.replaceFirst("java.lang.Exception: ", "");
    } else if (message.contains("Permission denied")) {
      // Permission denied when using Firebase emulator does not correctly come
      // through as a DatabaseError.
      code = "permission-denied";
      message = "Client doesn't have permission to access the desired data.";
    }

    return new FlutterFirebaseDatabaseException(code, message, details);
  }

  public String getCode() {
    return code;
  }

  public String getMessage() {
    return message;
  }

  public Map<String, Object> getAdditionalData() {
    return additionalData;
  }
}
