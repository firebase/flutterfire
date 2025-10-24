/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.DatabaseException
import java.util.*

class FlutterFirebaseDatabaseException
  @JvmOverloads
  constructor(
    @NonNull val code: String,
    @NonNull val errorMessage: String,
    @Nullable additionalData: Map<String, Any>? = null,
  ) : Exception(errorMessage) {
    companion object {
      const val UNKNOWN_ERROR_CODE = "unknown"
      const val UNKNOWN_ERROR_MESSAGE = "An unknown error occurred"
      private const val MODULE = "firebase_database"

      fun fromDatabaseError(e: DatabaseError): FlutterFirebaseDatabaseException {
        val errorCode = e.code

        val (code, message) =
          when (errorCode) {
            DatabaseError.DATA_STALE -> "data-stale" to "The transaction needs to be run again with current data."
            DatabaseError.OPERATION_FAILED -> "failure" to "The server indicated that this operation failed."
            DatabaseError.PERMISSION_DENIED -> "permission-denied" to "Client doesn't have permission to access the desired data."
            DatabaseError.DISCONNECTED -> "disconnected" to "The operation had to be aborted due to a network disconnect."
            DatabaseError.EXPIRED_TOKEN -> "expired-token" to "The supplied auth token has expired."
            DatabaseError.INVALID_TOKEN -> "invalid-token" to "The supplied auth token was invalid."
            DatabaseError.MAX_RETRIES -> "max-retries" to "The transaction had too many retries."
            DatabaseError.OVERRIDDEN_BY_SET -> "overridden-by-set" to "The transaction was overridden by a subsequent set."
            DatabaseError.UNAVAILABLE -> "unavailable" to "The service is unavailable."
            DatabaseError.NETWORK_ERROR -> "network-error" to "The operation could not be performed due to a network error."
            DatabaseError.WRITE_CANCELED -> "write-cancelled" to "The write was canceled by the user."
            else -> UNKNOWN_ERROR_CODE to UNKNOWN_ERROR_MESSAGE
          }

        if (code == UNKNOWN_ERROR_CODE) {
          return unknown(e.message ?: UNKNOWN_ERROR_MESSAGE)
        }

        val additionalData = mutableMapOf<String, Any>()
        val errorDetails = e.details
        additionalData[Constants.ERROR_DETAILS] = errorDetails
        return FlutterFirebaseDatabaseException(code, message, additionalData)
      }

      fun fromDatabaseException(e: DatabaseException): FlutterFirebaseDatabaseException {
        val error = DatabaseError.fromException(e)
        return fromDatabaseError(error)
      }

      fun fromException(e: Exception?): FlutterFirebaseDatabaseException =
        if (e == null) unknown() else unknown(e.message ?: UNKNOWN_ERROR_MESSAGE)

      fun unknown(): FlutterFirebaseDatabaseException = unknown(null)

      fun unknown(errorMessage: String?): FlutterFirebaseDatabaseException {
        val details = mutableMapOf<String, Any>()
        var code = UNKNOWN_ERROR_CODE

        var message = errorMessage

        if (errorMessage == null) {
          message = UNKNOWN_ERROR_MESSAGE
        }

        when {
          message?.contains("Index not defined, add \".indexOn\"") == true -> {
            // No known error code for this in DatabaseError, so we manually have to
            // detect it.
            code = "index-not-defined"
            message = message?.replaceFirst("java.lang.Exception: ", "") ?: UNKNOWN_ERROR_MESSAGE
          }
          message?.contains("Permission denied") == true || message?.contains("Client doesn't have permission") == true -> {
            // Permission denied when using Firebase emulator does not correctly come
            // through as a DatabaseError.
            code = "permission-denied"
            message = "Client doesn't have permission to access the desired data."
          }
        }

        return FlutterFirebaseDatabaseException(code, message ?: UNKNOWN_ERROR_MESSAGE, details)
      }
    }

    val additionalData: Map<String, Any> =
      additionalData?.toMutableMap()?.apply {
        put(Constants.ERROR_CODE, code)
        put(Constants.ERROR_MESSAGE, errorMessage)
      } ?: mutableMapOf<String, Any>().apply {
        put(Constants.ERROR_CODE, code)
        put(Constants.ERROR_MESSAGE, errorMessage)
      }
  }
