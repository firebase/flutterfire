// Copyright 2016 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_COMMON_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_COMMON_H_

#include "firebase/variant.h"

namespace firebase {
namespace database {

/// Error code returned by Firebase Realtime Database C++ functions.
enum Error {
  /// The operation was a success, no error occurred.
  kErrorNone = 0,
  /// The operation had to be aborted due to a network disconnect.
  kErrorDisconnected,
  /// The supplied auth token has expired.
  kErrorExpiredToken,
  /// The specified authentication token is invalid.
  kErrorInvalidToken,
  /// The transaction had too many retries.
  kErrorMaxRetries,
  /// The operation could not be performed due to a network error.
  kErrorNetworkError,
  /// The server indicated that this operation failed.
  kErrorOperationFailed,
  /// The transaction was overridden by a subsequent set.
  kErrorOverriddenBySet,
  /// This client does not have permission to perform this operation.
  kErrorPermissionDenied,
  /// The service is unavailable.
  kErrorUnavailable,
  /// An unknown error occurred.
  kErrorUnknownError,
  /// The write was canceled locally.
  kErrorWriteCanceled,
  /// You specified an invalid Variant type for a field. For example,
  /// a DatabaseReference's Priority and the keys of a Map must be of
  /// scalar type (MutableString, StaticString, Int64, Double).
  kErrorInvalidVariantType,
  /// An operation that conflicts with this one is already in progress. For
  /// example, calling SetValue and SetValueAndPriority on a DatabaseReference
  /// is not allowed.
  kErrorConflictingOperationInProgress,
  /// The transaction was aborted, because the user's DoTransaction function
  /// returned kTransactionResultAbort instead of kTransactionResultSuccess.
  kErrorTransactionAbortedByUser,
};

/// @brief Get the human-readable error message corresponding to an error code.
///
/// @param[in] error Error code to get the error message for.
///
/// @returns Statically-allocated string describing the error.
extern const char* GetErrorMessage(Error error);

/// @brief Get a server-populated value corresponding to the current
/// timestamp.
///
/// When inserting values into the database, you can use the special value
/// firebase::database::ServerTimestamp() to have the server auto-populate the
/// current timestamp, which is represented as millieconds since the Unix epoch,
/// into the field.
///
/// @returns A special value that tells the server to use the current timestamp.
const Variant& ServerTimestamp();

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_COMMON_H_
