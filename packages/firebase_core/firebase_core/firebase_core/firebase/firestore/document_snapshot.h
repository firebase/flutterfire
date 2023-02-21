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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_SNAPSHOT_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_SNAPSHOT_H_

#include <iosfwd>
#include <string>

#include "firebase/firestore/map_field_value.h"
#include "firebase/firestore/snapshot_metadata.h"

namespace firebase {
namespace firestore {

class DocumentReference;
class DocumentSnapshotInternal;
class FieldPath;
class FieldValue;
class Firestore;

/**
 * @brief A DocumentSnapshot contains data read from a document in your
 * Firestore database.
 *
 * The data can be extracted with the GetData() method, or by using
 * Get() to access a specific field. For a DocumentSnapshot that points to
 * a non-existing document, any data access will cause a failed assertion. You
 * can use the exists() method to explicitly verify a document's existence.
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class DocumentSnapshot {
 public:
  /**
   * Controls the return value for server timestamps that have not yet been set
   * to their final value.
   */
  enum class ServerTimestampBehavior {
    /**
     * Return Null for server timestamps that have not yet been set to their
     * final value.
     */
    kNone = 0,

    /**
     * Return local estimates for server timestamps that have not yet been set
     * to their final value. This estimate will likely differ from the final
     * value and may cause these pending values to change once the server result
     * becomes available.
     */
    kEstimate,

    /**
     * Return the previous value for server timestamps that have not yet been
     * set to their final value.
     */
    kPrevious,

    /** The default behavior, which is equivalent to specifying kNone. */
    // <SWIG>
    // Note, SWIG renaming mechanism doesn't properly handle initializing an
    // enum constant with another enum constant (e.g., in expression `kFoo =
    // kBar` only `kFoo` will be renamed, leaving `kBar` as is, leading to
    // compilation errors).
    // </SWIG>
    kDefault = 0,
  };

  /**
   * @brief Creates an invalid DocumentSnapshot that has to be reassigned before
   * it can be used.
   *
   * Calling any member function on an invalid DocumentSnapshot will be a no-op.
   * If the function returns a value, it will return a zero, empty, or invalid
   * value, depending on the type of the value.
   */
  DocumentSnapshot();

  /**
   * @brief Copy constructor.
   *
   * `DocumentSnapshot` is immutable and can be efficiently copied (no deep copy
   * is performed).
   *
   * @param[in] other `DocumentSnapshot` to copy from.
   */
  DocumentSnapshot(const DocumentSnapshot& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `DocumentSnapshot`. After being
   * moved from, a `DocumentSnapshot` is equivalent to its default-constructed
   * state.
   *
   * @param[in] other `DocumentSnapshot` to move data from.
   */
  DocumentSnapshot(DocumentSnapshot&& other);

  virtual ~DocumentSnapshot();

  /**
   * @brief Copy assignment operator.
   *
   * `DocumentSnapshot` is immutable and can be efficiently copied (no deep copy
   * is performed).
   *
   * @param[in] other `DocumentSnapshot` to copy from.
   *
   * @return Reference to the destination `DocumentSnapshot`.
   */
  DocumentSnapshot& operator=(const DocumentSnapshot& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `DocumentSnapshot`. After being
   * moved from, a `DocumentSnapshot` is equivalent to its default-constructed
   * state.
   *
   * @param[in] other `DocumentSnapshot` to move data from.
   *
   * @return Reference to the destination `DocumentSnapshot`.
   */
  DocumentSnapshot& operator=(DocumentSnapshot&& other);

  /**
   * @brief Returns the string ID of the document for which this
   * DocumentSnapshot contains data.
   *
   * @return String ID of this document location.
   */
  virtual const std::string& id() const;

  /**
   * @brief Returns the document location for which this DocumentSnapshot
   * contains data.
   *
   * @return DocumentReference of this document location.
   */
  virtual DocumentReference reference() const;

  /**
   * @brief Returns the metadata about this snapshot concerning its source and
   * if it has local modifications.
   *
   * @return SnapshotMetadata about this snapshot.
   */
  virtual SnapshotMetadata metadata() const;

  /**
   * @brief Explicitly verify a document's existence.
   *
   * @return True if the document exists in this snapshot.
   */
  virtual bool exists() const;

  /**
   * @brief Retrieves all fields in the document as a map of FieldValues.
   *
   * @param stb Configures how server timestamps that have not yet
   * been set to their final value are returned from the snapshot (optional).
   *
   * @return A map containing all fields in the document, or an empty map if the
   * document doesn't exist.
   */
  virtual MapFieldValue GetData(
      ServerTimestampBehavior stb = ServerTimestampBehavior::kDefault) const;

  /**
   * @brief Retrieves a specific field from the document.
   *
   * @param field String ID of the field to retrieve. The pointer only needs to
   * be valid during this call.
   * @param stb Configures how server timestamps that have not yet been set to
   * their final value are returned from the snapshot (optional).
   *
   * @return The value contained in the field. If the field does not exist in
   * the document, then a `FieldValue` instance with `is_valid() == false` will
   * be returned.
   */
  virtual FieldValue Get(
      const char* field,
      ServerTimestampBehavior stb = ServerTimestampBehavior::kDefault) const;

  /**
   * @brief Retrieves a specific field from the document.
   *
   * @param field String ID of the field to retrieve.
   * @param stb Configures how server timestamps that have not yet been set to
   * their final value are returned from the snapshot (optional).
   *
   * @return The value contained in the field. If the field does not exist in
   * the document, then a `FieldValue` instance with `is_valid() == false` will
   * be returned.
   */
  virtual FieldValue Get(
      const std::string& field,
      ServerTimestampBehavior stb = ServerTimestampBehavior::kDefault) const;

  /**
   * @brief Retrieves a specific field from the document.
   *
   * @param field Path of the field to retrieve.
   * @param stb Configures how server timestamps that have not yet been set to
   * their final value are returned from the snapshot (optional).
   *
   * @return The value contained in the field. If the field does not exist in
   * the document, then a `FieldValue` instance with `is_valid() == false` will
   * be returned.
   */
  virtual FieldValue Get(
      const FieldPath& field,
      ServerTimestampBehavior stb = ServerTimestampBehavior::kDefault) const;

  /**
   * @brief Returns true if this `DocumentSnapshot` is valid, false if it is
   * not valid. An invalid `DocumentSnapshot` could be the result of:
   *   - Creating a `DocumentSnapshot` with the default constructor.
   *   - Moving from the `DocumentSnapshot`.
   *   - Deleting your Firestore instance, which will invalidate all the
   *     `DocumentSnapshot` instances associated with it.
   *
   * @return true if this `DocumentSnapshot` is valid, false if this
   * `DocumentSnapshot` is invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

  /**
   * Returns a string representation of this `DocumentSnapshot` for
   * logging/debugging purposes.
   *
   * @note the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `DocumentSnapshot` to the given
   * stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out,
                                  const DocumentSnapshot& document);

 private:
  std::size_t Hash() const;

  friend bool operator==(const DocumentSnapshot& lhs,
                         const DocumentSnapshot& rhs);
  friend std::size_t DocumentSnapshotHash(const DocumentSnapshot& snapshot);

  friend class DocumentChangeInternal;
  friend class EventListenerInternal;
  friend class FirestoreInternal;
  friend class QueryInternal;
  friend class TransactionInternal;
  friend class Wrapper;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit DocumentSnapshot(DocumentSnapshotInternal* internal);

  mutable DocumentSnapshotInternal* internal_ = nullptr;
};

/** Checks `lhs` and `rhs` for equality. */
bool operator==(const DocumentSnapshot& lhs, const DocumentSnapshot& rhs);

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const DocumentSnapshot& lhs,
                       const DocumentSnapshot& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_SNAPSHOT_H_
