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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_CHANGE_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_CHANGE_H_

#include <cstddef>

namespace firebase {
namespace firestore {

class DocumentChangeInternal;
class DocumentSnapshot;

/**
 * @brief A DocumentChange represents a change to the documents matching
 * a query.
 *
 * DocumentChange contains the document affected and the type of change that
 * occurred (added, modified, or removed).
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class DocumentChange {
 public:
  /**
   * An enumeration of snapshot diff types.
   */
  enum class Type {
    /**
     * Indicates a new document was added to the set of documents matching the
     * query.
     */
    kAdded,

    /**
     * Indicates a document within the query was modified.
     */
    kModified,

    /**
     * Indicates a document within the query was removed (either deleted or no
     * longer matches the query).
     */
    kRemoved,
  };

  /**
   * The sentinel index used as a return value to indicate no matches.
   */
#if defined(ANDROID)
  // Older NDK (r16b) fails to define this properly. Fix this when support for
  // the older NDK is removed.
  static const std::size_t npos;
#else
  static constexpr std::size_t npos = static_cast<std::size_t>(-1);
#endif  // defined(ANDROID)

  /**
   * @brief Creates an invalid DocumentChange that has to be reassigned before
   * it can be used.
   *
   * Calling any member function on an invalid DocumentChange will be a no-op.
   * If the function returns a value, it will return a zero, empty, or invalid
   * value, depending on the type of the value.
   */
  DocumentChange();

  /**
   * @brief Copy constructor.
   *
   * `DocumentChange` is immutable and can be efficiently copied (no deep copy
   * is performed).
   *
   * @param[in] other `DocumentChange` to copy from.
   */
  DocumentChange(const DocumentChange& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `DocumentChange`. After being
   * moved from, a `DocumentChange` is equivalent to its default-constructed
   * state.
   *
   * @param[in] other `DocumentChange` to move data from.
   */
  DocumentChange(DocumentChange&& other);

  virtual ~DocumentChange();

  /**
   * @brief Copy assignment operator.
   *
   * `DocumentChange` is immutable and can be efficiently copied (no deep copy
   * is performed).
   *
   * @param[in] other `DocumentChange` to copy from.
   *
   * @return Reference to the destination `DocumentChange`.
   */
  DocumentChange& operator=(const DocumentChange& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `DocumentChange`. After being
   * moved from, a `DocumentChange` is equivalent to its default-constructed
   * state.
   *
   * @param[in] other `DocumentChange` to move data from.
   *
   * @return Reference to the destination `DocumentChange`.
   */
  DocumentChange& operator=(DocumentChange&& other);

  /**
   * Returns the type of change that occurred (added, modified, or removed).
   */
  virtual Type type() const;

  /**
   * @brief The document affected by this change.
   *
   * Returns the newly added or modified document if this DocumentChange is for
   * an updated document. Returns the deleted document if this document change
   * represents a removal.
   */
  virtual DocumentSnapshot document() const;

  /**
   * The index of the changed document in the result set immediately prior to
   * this DocumentChange (that is, supposing that all prior DocumentChange
   * objects have been applied). Returns DocumentChange::npos for 'added'
   * events.
   */
  virtual std::size_t old_index() const;

  /**
   * The index of the changed document in the result set immediately after this
   * DocumentChange (that is, supposing that all prior DocumentChange objects
   * and the current DocumentChange object have been applied). Returns
   * DocumentChange::npos for 'removed' events.
   */
  virtual std::size_t new_index() const;

  /**
   * @brief Returns true if this `DocumentChange` is valid, false if it is
   * not valid. An invalid `DocumentChange` could be the result of:
   *   - Creating a `DocumentChange` using the default constructor.
   *   - Moving from the `DocumentChange`.
   *   - Deleting your Firestore instance, which will invalidate all the
   *     `DocumentChange` instances associated with it.
   *
   * @return true if this `DocumentChange` is valid, false if this
   * `DocumentChange` is invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

 private:
  std::size_t Hash() const;

  friend bool operator==(const DocumentChange& lhs, const DocumentChange& rhs);
  friend std::size_t DocumentChangeHash(const DocumentChange& change);

  friend class FirestoreInternal;
  friend class Wrapper;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit DocumentChange(DocumentChangeInternal* internal);

  mutable DocumentChangeInternal* internal_ = nullptr;
};

/** Checks `lhs` and `rhs` for equality. */
bool operator==(const DocumentChange& lhs, const DocumentChange& rhs);

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const DocumentChange& lhs, const DocumentChange& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_CHANGE_H_
