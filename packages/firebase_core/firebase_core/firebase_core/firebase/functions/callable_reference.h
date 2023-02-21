// Copyright 2017 Google LLC
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

#ifndef FIREBASE_FUNCTIONS_SRC_INCLUDE_FIREBASE_FUNCTIONS_CALLABLE_REFERENCE_H_
#define FIREBASE_FUNCTIONS_SRC_INCLUDE_FIREBASE_FUNCTIONS_CALLABLE_REFERENCE_H_

#include <string>
#include <vector>

#include "firebase/future.h"
#include "firebase/internal/common.h"

namespace firebase {
class Variant;

namespace functions {
class Functions;
class HttpsCallableResult;

/// @cond FIREBASE_APP_INTERNAL
namespace internal {
class HttpsCallableReferenceInternal;
}  // namespace internal
/// @endcond

#ifndef SWIG
/// Represents a reference to a Cloud Functions object.
/// Developers can call HTTPS Callable Functions.
#endif  // SWIG
class HttpsCallableReference {
 public:
  /// @brief Default constructor. This creates an invalid
  /// HttpsCallableReference. Attempting to perform any operations on this
  /// reference will fail unless a valid HttpsCallableReference has been
  /// assigned to it.
  HttpsCallableReference() : internal_(nullptr) {}

  ~HttpsCallableReference();

  /// @brief Copy constructor. It's totally okay (and efficient) to copy
  /// HttpsCallableReference instances, as they simply point to the same
  /// location.
  ///
  /// @param[in] reference HttpsCallableReference to copy from.
  HttpsCallableReference(const HttpsCallableReference& reference);

  /// @brief Copy assignment operator. It's totally okay (and efficient) to copy
  /// HttpsCallableReference instances, as they simply point to the same
  /// location.
  ///
  /// @param[in] reference HttpsCallableReference to copy from.
  ///
  /// @returns Reference to the destination HttpsCallableReference.
  HttpsCallableReference& operator=(const HttpsCallableReference& reference);

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
  /// @brief Move constructor. Moving is an efficient operation for
  /// HttpsCallableReference instances.
  ///
  /// @param[in] other HttpsCallableReference to move data from.
  HttpsCallableReference(HttpsCallableReference&& other);

  /// @brief Move assignment operator. Moving is an efficient operation for
  /// HttpsCallableReference instances.
  ///
  /// @param[in] other HttpsCallableReference to move data from.
  ///
  /// @returns Reference to the destination HttpsCallableReference.
  HttpsCallableReference& operator=(HttpsCallableReference&& other);
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// @brief Gets the firebase::functions::Functions instance to which we refer.
  ///
  /// The pointer will remain valid indefinitely.
  ///
  /// @returns The firebase::functions::Functions instance that this
  /// HttpsCallableReference refers to.
  Functions* functions();

  /// @brief Calls the function.
  ///
  /// @returns The result of the call;
  Future<HttpsCallableResult> Call();

  /// @brief Calls the function.
  ///
  /// @param[in] data The params to pass to the function.
  /// @returns The result of the call;
  Future<HttpsCallableResult> Call(const Variant& data);

  /// @brief Returns true if this HttpsCallableReference is valid, false if it
  /// is not valid. An invalid HttpsCallableReference indicates that the
  /// reference is uninitialized (created with the default constructor) or that
  /// there was an error retrieving the reference.
  ///
  /// @returns true if this HttpsCallableReference is valid, false if this
  /// HttpsCallableReference is invalid.
  bool is_valid() const;

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class Functions;

  HttpsCallableReference(internal::HttpsCallableReferenceInternal* internal);

  internal::HttpsCallableReferenceInternal* internal_;
  /// @endcond
};

}  // namespace functions
}  // namespace firebase

#endif  // FIREBASE_FUNCTIONS_SRC_INCLUDE_FIREBASE_FUNCTIONS_CALLABLE_REFERENCE_H_
