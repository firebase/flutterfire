/*
 * Copyright 2018 Google LLC
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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SET_OPTIONS_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SET_OPTIONS_H_

#include <string>
#include <unordered_set>
#include <vector>

#include "firebase/firestore/field_path.h"

namespace firebase {
namespace firestore {

/**
 * @brief An options object that configures the behavior of Set() calls.
 *
 * By providing the SetOptions objects returned by Merge(), the Set() methods in
 * DocumentReference, WriteBatch and Transaction can be configured to perform
 * granular merges instead of overwriting the target documents in their
 * entirety.
 */
class SetOptions final {
 public:
  /** The enumeration of all types of SetOptions. */
  enum class Type {
    /** Overwrites the whole document. */
    kOverwrite,

    /**
     * Replaces the values specified in the call parameter while leaves omitted
     * fields untouched.
     */
    kMergeAll,

    /**
     * Replaces the values of the fields explicitly specified in the call
     * parameter.
     */
    kMergeSpecific,
  };

  /**
   * Creates SetOptions with overwrite semantics.
   */
  SetOptions() = default;

  /**
   * @brief Copy constructor.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `SetOptions` to copy from.
   */
  SetOptions(const SetOptions& other) = default;

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for `SetOptions`. After being moved
   * from, `SetOptions` is in a valid but unspecified state.
   *
   * @param[in] other `SetOptions` to move data from.
   */
  SetOptions(SetOptions&& other) = default;

  ~SetOptions();

  /**
   * @brief Copy assignment operator.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `SetOptions` to copy from.
   *
   * @return Reference to the destination `SetOptions`.
   */
  SetOptions& operator=(const SetOptions& other) = default;

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for `SetOptions`. After being moved
   * from, `SetOptions` is in a valid but unspecified state.
   *
   * @param[in] other `SetOptions` to move data from.
   *
   * @return Reference to the destination `SetOptions`.
   */
  SetOptions& operator=(SetOptions&& other) = default;

  /**
   * Returns an instance that can be used to change the behavior of Set() calls
   * to only replace the values specified in its data argument. Fields omitted
   * from the Set() call will remain untouched.
   */
  static SetOptions Merge();

  /**
   * Returns an instance that can be used to change the behavior of Set() calls
   * to only replace the given fields. Any field that is not specified in
   * `fields` is ignored and remains untouched.
   *
   * It is an error to pass a SetOptions object to a Set() call that is missing
   * a value for any of the fields specified here.
   *
   * @param fields The list of fields to merge. Fields can contain dots to
   * reference nested fields within the document.
   */
  static SetOptions MergeFields(const std::vector<std::string>& fields);

  /**
   * Returns an instance that can be used to change the behavior of Set() calls
   * to only replace the given fields. Any field that is not specified in
   * `fields` is ignored and remains untouched.
   *
   * It is an error to pass a SetOptions object to a Set() call that is missing
   * a value for any of the fields specified here in its to data argument.
   *
   * @param fields The list of fields to merge.
   */
  static SetOptions MergeFieldPaths(const std::vector<FieldPath>& fields);

 private:
  friend bool operator==(const SetOptions& lhs, const SetOptions& rhs);
  friend class SetOptionsInternal;

  SetOptions(Type type, std::unordered_set<FieldPath> fields);

  Type type_ = Type::kOverwrite;
  std::unordered_set<FieldPath> fields_;
};

/** Checks `lhs` and `rhs` for equality. */
inline bool operator==(const SetOptions& lhs, const SetOptions& rhs) {
  return lhs.type_ == rhs.type_ && lhs.fields_ == rhs.fields_;
}

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const SetOptions& lhs, const SetOptions& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SET_OPTIONS_H_
