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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_FIELD_PATH_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_FIELD_PATH_H_

#include <initializer_list>
#include <iosfwd>
#include <string>
#include <vector>

namespace firebase {
namespace firestore {

#if !defined(__ANDROID__)

namespace model {
class FieldPath;
}  // namespace model

#else

class FieldPathPortable;

#endif  // !defined(__ANDROID__)

/**
 * @brief A FieldPath refers to a field in a document.
 *
 * The path may consist of a single field name (referring to a top level field
 * in the document) or a list of field names (referring to a nested field in the
 * document).
 */
class FieldPath final {
 public:
  /**
   * @brief Creates an invalid FieldPath that has to be reassigned before it can
   * be used.
   *
   * Calling any member function on an invalid FieldPath will be a no-op. If the
   * function returns a value, it will return a zero, empty, or invalid value,
   * depending on the type of the value.
   */
  FieldPath();

  /**
   * Creates a FieldPath from the provided field names. If more than one field
   * name is provided, the path will point to a nested field in a document.
   *
   * @param field_names A list of field names.
   */
  FieldPath(std::initializer_list<std::string> field_names);

  /**
   * Creates a FieldPath from the provided field names. If more than one field
   * name is provided, the path will point to a nested field in a document.
   *
   * @param field_names A vector of field names.
   */
  FieldPath(const std::vector<std::string>& field_names);

  /**
   * @brief Copy constructor.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `FieldPath` to copy from.
   */
  FieldPath(const FieldPath& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for `FieldPath`. After being moved
   * from, `FieldPath` is in a valid but unspecified state.
   *
   * @param[in] other `FieldPath` to move data from.
   */
  FieldPath(FieldPath&& other) noexcept;

  ~FieldPath();

  /**
   * @brief Copy assignment operator.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `FieldPath` to copy from.
   *
   * @return Reference to the destination `FieldPath`.
   */
  FieldPath& operator=(const FieldPath& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for `FieldPath`. After being moved
   * from, `FieldPath` is in a valid but unspecified state.
   *
   * @param[in] other `FieldPath` to move data from.
   *
   * @return Reference to the destination `FieldPath`.
   */
  FieldPath& operator=(FieldPath&& other) noexcept;

  /**
   * A special sentinel FieldPath to refer to the ID of a document. It can be
   * used in queries to sort or filter by the document ID.
   */
  static FieldPath DocumentId();

  /**
   * @brief Returns true if this `FieldPath` is valid, false if it is not valid.
   * An invalid `FieldPath` could be the result of:
   *   - Creating a `FieldPath` using the default constructor.
   *   - Moving from the `FieldPath`.
   *
   * @return true if this `FieldPath` is valid, false if this `FieldPath` is
   * invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

  /**
   * Returns a string representation of this `FieldPath` for
   * logging/debugging purposes.
   *
   * @note the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `FieldPath` to the given
   * stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out, const FieldPath& path);

 private:
  // The type of the internal object that implements the public interface.
#if !defined(SWIG)
#if !defined(__ANDROID__)
  using FieldPathInternal = ::firebase::firestore::model::FieldPath;
#else
  using FieldPathInternal = ::firebase::firestore::FieldPathPortable;
#endif  // !defined(__ANDROID__)
#endif  // !defined(SWIG)

  friend bool operator==(const FieldPath& lhs, const FieldPath& rhs);
  friend bool operator!=(const FieldPath& lhs, const FieldPath& rhs);
  friend struct std::hash<FieldPath>;

  friend class DocumentSnapshot;  // For access to `FromDotSeparatedString`
  friend class Query;
  friend class QueryInternal;
  friend class SetOptions;  // For access to `FromDotSeparatedString`
  friend class FieldPathConverter;
  friend struct ConverterImpl;

  explicit FieldPath(FieldPathInternal* internal);

  static FieldPathInternal* InternalFromSegments(
      std::vector<std::string> field_names);

  static FieldPath FromDotSeparatedString(const std::string& path);

  FieldPathInternal* internal_ = nullptr;
};

}  // namespace firestore
}  // namespace firebase

#if !defined(SWIG)
namespace std {
/**
 * A convenient specialization of std::hash for FieldPath.
 */
template <>
struct hash<firebase::firestore::FieldPath> {
  /**
   * Calculates the hash of the argument.
   *
   * Note: specialization of `std::hash` is provided for convenience only. The
   * implementation is subject to change.
   */
  size_t operator()(const firebase::firestore::FieldPath& field_path) const;
};
}  // namespace std
#endif  // !defined(SWIG)

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_FIELD_PATH_H_
