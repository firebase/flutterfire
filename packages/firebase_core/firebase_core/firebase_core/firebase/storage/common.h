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

#ifndef FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_COMMON_H_
#define FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_COMMON_H_

namespace firebase {
namespace storage {

/// Error code returned by Cloud Storage C++ functions.
enum Error {
  /// The operation was a success, no error occurred.
  kErrorNone = 0,
  /// An unknown error occurred.
  kErrorUnknown,
  /// No object exists at the desired reference.
  kErrorObjectNotFound,
  /// No bucket is configured for Cloud Storage.
  kErrorBucketNotFound,
  /// No project is configured for Cloud Storage.
  kErrorProjectNotFound,
  /// Quota on your Cloud Storage bucket has been exceeded.
  kErrorQuotaExceeded,
  /// User is unauthenticated.
  kErrorUnauthenticated,
  /// User is not authorized to perform the desired action.
  kErrorUnauthorized,
  /// The maximum time limit on an operation (upload, download, delete, etc.)
  /// has been exceeded.
  kErrorRetryLimitExceeded,
  /// File on the client does not match the checksum of the file received by the
  /// server.
  kErrorNonMatchingChecksum,
  /// Size of the downloaded file exceeds the amount of memory allocated for the
  /// download.
  kErrorDownloadSizeExceeded,
  /// User cancelled the operation.
  kErrorCancelled,
};

/// @brief Get the human-readable error message corresponding to an error code.
///
/// @param[in] error Error code to get the error message for.
///
/// @returns Statically-allocated string describing the error.
const char* GetErrorMessage(Error error);

}  // namespace storage
}  // namespace firebase

#endif  // FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_COMMON_H_
