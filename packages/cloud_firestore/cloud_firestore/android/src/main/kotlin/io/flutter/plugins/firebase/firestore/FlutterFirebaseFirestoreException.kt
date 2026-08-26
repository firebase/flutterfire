// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore

import com.google.firebase.firestore.FirebaseFirestoreException
import java.util.regex.Pattern

class FlutterFirebaseFirestoreException(
    nativeException: FirebaseFirestoreException?,
    cause: Throwable?
) : Exception(nativeException?.message ?: "", cause) {
  val code: String?
  private val exceptionMessage: String?

  init {
    var parsedCode: String? = null
    var parsedMessage: String? = null

    if (cause?.message != null && cause.message!!.contains(":")) {
      val causeMessage = cause.message!!
      val matcher = Pattern.compile("([A-Z_]{3,25}):\\s(.*)").matcher(causeMessage)

      if (matcher.find()) {
        val foundCode = matcher.group(1)!!.trim()
        val foundMessage = matcher.group(2)!!.trim()
        when (foundCode) {
          "ABORTED" -> {
            parsedCode = "aborted"
            parsedMessage = ERROR_ABORTED
          }
          "ALREADY_EXISTS" -> {
            parsedCode = "already-exists"
            parsedMessage = ERROR_ALREADY_EXISTS
          }
          "CANCELLED" -> {
            parsedCode = "cancelled"
            parsedMessage = ERROR_CANCELLED
          }
          "DATA_LOSS" -> {
            parsedCode = "data-loss"
            parsedMessage = ERROR_DATA_LOSS
          }
          "DEADLINE_EXCEEDED" -> {
            parsedCode = "deadline-exceeded"
            parsedMessage = ERROR_DEADLINE_EXCEEDED
          }
          "FAILED_PRECONDITION" -> {
            parsedCode = "failed-precondition"
            parsedMessage =
                if (foundMessage.contains("index")) {
                  foundMessage
                } else {
                  ERROR_FAILED_PRECONDITION
                }
          }
          "INTERNAL" -> {
            parsedCode = "internal"
            parsedMessage = ERROR_INTERNAL
          }
          "INVALID_ARGUMENT" -> {
            parsedCode = "invalid-argument"
            parsedMessage = ERROR_INVALID_ARGUMENT
          }
          "NOT_FOUND" -> {
            parsedCode = "not-found"
            parsedMessage = ERROR_NOT_FOUND
          }
          "OUT_OF_RANGE" -> {
            parsedCode = "out-of-range"
            parsedMessage = ERROR_OUT_OF_RANGE
          }
          "PERMISSION_DENIED" -> {
            parsedCode = "permission-denied"
            parsedMessage = ERROR_PERMISSION_DENIED
          }
          "RESOURCE_EXHAUSTED" -> {
            parsedCode = "resource-exhausted"
            parsedMessage = ERROR_RESOURCE_EXHAUSTED
          }
          "UNAUTHENTICATED" -> {
            parsedCode = "unauthenticated"
            parsedMessage = ERROR_UNAUTHENTICATED
          }
          "UNAVAILABLE" -> {
            parsedCode = "unavailable"
            parsedMessage = ERROR_UNAVAILABLE
          }
          "UNIMPLEMENTED" -> {
            parsedCode = "unimplemented"
            parsedMessage = ERROR_UNIMPLEMENTED
          }
          "UNKNOWN" -> {
            parsedCode = "unknown"
            parsedMessage = ERROR_UNKNOWN
          }
        }
      }
    }

    if (parsedCode == null && nativeException != null) {
      when (nativeException.code) {
        FirebaseFirestoreException.Code.ABORTED -> {
          parsedCode = "aborted"
          parsedMessage = ERROR_ABORTED
        }
        FirebaseFirestoreException.Code.ALREADY_EXISTS -> {
          parsedCode = "already-exists"
          parsedMessage = ERROR_ALREADY_EXISTS
        }
        FirebaseFirestoreException.Code.CANCELLED -> {
          parsedCode = "cancelled"
          parsedMessage = ERROR_CANCELLED
        }
        FirebaseFirestoreException.Code.DATA_LOSS -> {
          parsedCode = "data-loss"
          parsedMessage = ERROR_DATA_LOSS
        }
        FirebaseFirestoreException.Code.DEADLINE_EXCEEDED -> {
          parsedCode = "deadline-exceeded"
          parsedMessage = ERROR_DEADLINE_EXCEEDED
        }
        FirebaseFirestoreException.Code.FAILED_PRECONDITION -> {
          parsedCode = "failed-precondition"
          parsedMessage =
              if (nativeException.message != null &&
                  (nativeException.message!!.contains("query requires an index") ||
                      nativeException.message!!.contains("ensure it has been indexed"))) {
                nativeException.message
              } else {
                ERROR_FAILED_PRECONDITION
              }
        }
        FirebaseFirestoreException.Code.INTERNAL -> {
          parsedCode = "internal"
          parsedMessage = ERROR_INTERNAL
        }
        FirebaseFirestoreException.Code.INVALID_ARGUMENT -> {
          parsedCode = "invalid-argument"
          parsedMessage = ERROR_INVALID_ARGUMENT
        }
        FirebaseFirestoreException.Code.NOT_FOUND -> {
          parsedCode = "not-found"
          parsedMessage = ERROR_NOT_FOUND
        }
        FirebaseFirestoreException.Code.OUT_OF_RANGE -> {
          parsedCode = "out-of-range"
          parsedMessage = ERROR_OUT_OF_RANGE
        }
        FirebaseFirestoreException.Code.PERMISSION_DENIED -> {
          parsedCode = "permission-denied"
          parsedMessage = ERROR_PERMISSION_DENIED
        }
        FirebaseFirestoreException.Code.RESOURCE_EXHAUSTED -> {
          parsedCode = "resource-exhausted"
          parsedMessage = ERROR_RESOURCE_EXHAUSTED
        }
        FirebaseFirestoreException.Code.UNAUTHENTICATED -> {
          parsedCode = "unauthenticated"
          parsedMessage = ERROR_UNAUTHENTICATED
        }
        FirebaseFirestoreException.Code.UNAVAILABLE -> {
          parsedCode = "unavailable"
          parsedMessage = ERROR_UNAVAILABLE
        }
        FirebaseFirestoreException.Code.UNIMPLEMENTED -> {
          parsedCode = "unimplemented"
          parsedMessage = ERROR_UNIMPLEMENTED
        }
        FirebaseFirestoreException.Code.UNKNOWN -> {
          parsedCode = "unknown"
          parsedMessage = "Unknown error or an error from a different error domain."
        }
        else -> {
          parsedCode = "unknown"
          parsedMessage = "An unknown error occurred"
        }
      }
    }

    if (nativeException?.message != null && nativeException.message!!.isNotEmpty()) {
      parsedMessage = nativeException.message
    }

    code = parsedCode
    exceptionMessage = parsedMessage
  }

  override val message: String?
    get() = exceptionMessage

  companion object {
    private const val ERROR_ABORTED =
        "The operation was aborted, typically due to a concurrency issue like transaction aborts," +
            " etc."
    private const val ERROR_ALREADY_EXISTS =
        "Some document that we attempted to create already exists."
    private const val ERROR_CANCELLED = "The operation was cancelled (typically by the caller)."
    private const val ERROR_DATA_LOSS = "Unrecoverable data loss or corruption."
    private const val ERROR_DEADLINE_EXCEEDED =
        "Deadline expired before operation could complete. For operations that change the state of" +
            " the system, this error may be returned even if the operation has completed" +
            " successfully. For example, a successful response from a server could have been" +
            " delayed long enough for the deadline to expire."
    private const val ERROR_FAILED_PRECONDITION =
        "Operation was rejected because the system is not in a state required for the operation's" +
            " execution. If performing a query, ensure it has been indexed via the Firebase" +
            " console."
    private const val ERROR_INTERNAL =
        "Internal errors. Means some invariants expected by underlying system has been broken. If you" +
            " see one of these errors, something is very broken."
    private const val ERROR_INVALID_ARGUMENT =
        "Client specified an invalid argument. Note that this differs from failed-precondition." +
            " invalid-argument indicates arguments that are problematic regardless of the state of" +
            " the system (e.g., an invalid field name)."
    private const val ERROR_NOT_FOUND = "Some requested document was not found."
    private const val ERROR_OUT_OF_RANGE = "Operation was attempted past the valid range."
    private const val ERROR_PERMISSION_DENIED =
        "The caller does not have permission to execute the specified operation."
    private const val ERROR_RESOURCE_EXHAUSTED =
        "Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file" +
            " system is out of space."
    private const val ERROR_UNAUTHENTICATED =
        "The request does not have valid authentication credentials for the operation."
    private const val ERROR_UNAVAILABLE =
        "The service is currently unavailable. This is a most likely a transient condition and may be" +
            " corrected by retrying with a backoff."
    private const val ERROR_UNIMPLEMENTED = "Operation is not implemented or not supported/enabled."
    private const val ERROR_UNKNOWN = "Operation is not implemented or not supported/enabled."
  }
}
