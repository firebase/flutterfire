/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_FIRESTORE_ERRORS_H_
#define FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_FIRESTORE_ERRORS_H_

namespace firebase {
namespace firestore {

/**
 * Error codes used by Cloud Firestore.
 *
 * The codes are in sync across Firestore SDKs on various platforms.
 */
enum Error {
  /** The operation completed successfully. */
  // Note: NSError objects will never have a code with this value.
  kErrorOk = 0,

  kErrorNone = 0,

  /** The operation was cancelled (typically by the caller). */
  kErrorCancelled = 1,

  /** Unknown error or an error from a different error domain. */
  kErrorUnknown = 2,

  /**
   * Client specified an invalid argument. Note that this differs from
   * FailedPrecondition. InvalidArgument indicates arguments that are
   * problematic regardless of the state of the system (e.g., an invalid field
   * name).
   */
  kErrorInvalidArgument = 3,

  /**
   * Deadline expired before operation could complete. For operations that
   * change the state of the system, this error may be returned even if the
   * operation has completed successfully. For example, a successful response
   * from a server could have been delayed long enough for the deadline to
   * expire.
   */
  kErrorDeadlineExceeded = 4,

  /** Some requested document was not found. */
  kErrorNotFound = 5,

  /** Some document that we attempted to create already exists. */
  kErrorAlreadyExists = 6,

  /** The caller does not have permission to execute the specified operation. */
  kErrorPermissionDenied = 7,

  /**
   * Some resource has been exhausted, perhaps a per-user quota, or perhaps the
   * entire file system is out of space.
   */
  kErrorResourceExhausted = 8,

  /**
   * Operation was rejected because the system is not in a state required for
   * the operation's execution.
   */
  kErrorFailedPrecondition = 9,

  /**
   * The operation was aborted, typically due to a concurrency issue like
   * transaction aborts, etc.
   */
  kErrorAborted = 10,

  /** Operation was attempted past the valid range. */
  kErrorOutOfRange = 11,

  /** Operation is not implemented or not supported/enabled. */
  kErrorUnimplemented = 12,

  /**
   * Internal errors. Means some invariants expected by underlying system has
   * been broken. If you see one of these errors, something is very broken.
   */
  kErrorInternal = 13,

  /**
   * The service is currently unavailable. This is a most likely a transient
   * condition and may be corrected by retrying with a backoff.
   */
  kErrorUnavailable = 14,

  /** Unrecoverable data loss or corruption. */
  kErrorDataLoss = 15,

  /**
   * The request does not have valid authentication credentials for the
   * operation.
   */
  kErrorUnauthenticated = 16
};

}  // namespace firestore
}  // namespace firebase

#endif  // FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_FIRESTORE_ERRORS_H_
