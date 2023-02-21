// Copyright 2018 Google LLC
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

#ifndef FIREBASE_FUNCTIONS_SRC_INCLUDE_FIREBASE_FUNCTIONS_CALLABLE_RESULT_H_
#define FIREBASE_FUNCTIONS_SRC_INCLUDE_FIREBASE_FUNCTIONS_CALLABLE_RESULT_H_

#include "firebase/functions/common.h"
#include "firebase/variant.h"

namespace firebase {
namespace functions {

/// @cond FIREBASE_APP_INTERNAL
namespace internal {
class HttpsCallableReferenceInternal;
}
/// @endcond

/// An HttpsCallableResult contains the result of calling an HttpsCallable.
class HttpsCallableResult {
 public:
  /// @brief Creates an HttpsCallableResult with null data.
  HttpsCallableResult() {}

  ~HttpsCallableResult() {}

  /// @brief Copy constructor. Copying is as efficient as copying a Variant.
  ///
  /// @param[in] other HttpsCallableResult to copy data from.
  HttpsCallableResult(const HttpsCallableResult& other) : data_(other.data_) {}

  /// @brief Assignment operator. Copying is as efficient as copying a Variant.
  ///
  /// @param[in] other HttpsCallableResult to copy data from.
  ///
  /// @returns Reference to the destination HttpsCallableResult.
  HttpsCallableResult& operator=(const HttpsCallableResult& other) {
    data_ = other.data_;
    return *this;
  }

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
  /// @brief Move constructor. Moving is an efficient operation for
  /// HttpsCallableResult instances.
  ///
  /// @param[in] other HttpsCallableResult to move data from.
  HttpsCallableResult(HttpsCallableResult&& other) {
    data_ = std::move(other.data_);
  }

  /// @brief Move assignment operator. Moving is an efficient operation for
  /// HttpsCallableResult instances.
  ///
  /// @param[in] other HttpsCallableResult to move data from.
  ///
  /// @returns Reference to the destination HttpsCallableResult.
  HttpsCallableResult& operator=(HttpsCallableResult&& other) {
    data_ = std::move(other.data_);
    return *this;
  }

#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// @brief Returns the data that is the result of a Call.
  ///
  /// @returns The variant containing the data.
  const Variant& data() const { return data_; }

 private:
  /// @cond FIREBASE_APP_INTERNAL
  // Only functions are allowed to construct results.
  friend class ::firebase::functions::internal::HttpsCallableReferenceInternal;
  HttpsCallableResult(const Variant& data) : data_(data) {}
#if defined(FIREBASE_USE_MOVE_OPERATORS)
  HttpsCallableResult(Variant&& data) : data_(std::move(data)) {}
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS)

  Variant data_;
  /// @endcond
};

}  // namespace functions
}  // namespace firebase

#endif  // FIREBASE_FUNCTIONS_SRC_INCLUDE_FIREBASE_FUNCTIONS_CALLABLE_RESULT_H_
