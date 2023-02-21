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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_QUERY_SNAPSHOT_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_QUERY_SNAPSHOT_H_

#include <cstddef>
#include <vector>

#include "firebase/firestore/metadata_changes.h"
#include "firebase/firestore/snapshot_metadata.h"

namespace firebase {
namespace firestore {

class DocumentChange;
class DocumentSnapshot;
class Query;
class QuerySnapshotInternal;

/**
 * @brief A QuerySnapshot contains zero or more DocumentSnapshot objects.
 *
 * QuerySnapshot can be iterated using a range-based for loop, and its size can
 * be inspected with empty() and size().
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class QuerySnapshot {
 public:
  /**
   * @brief Creates an invalid QuerySnapshot that has to be reassigned before it
   * can be used.
   *
   * Calling any member function on an invalid QuerySnapshot will be a no-op. If
   * the function returns a value, it will return a zero, empty, or invalid
   * value, depending on the type of the value.
   */
  QuerySnapshot();

  /**
   * @brief Copy constructor.
   *
   * `QuerySnapshot` is immutable and can be efficiently copied (no deep copy is
   * performed).
   *
   * @param[in] other `QuerySnapshot` to copy from.
   */
  QuerySnapshot(const QuerySnapshot& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `QuerySnapshot`. After being
   * moved from, a `QuerySnapshot` is equivalent to its default-constructed
   * state.
   *
   * @param[in] other `QuerySnapshot` to move data from.
   */
  QuerySnapshot(QuerySnapshot&& other);

  virtual ~QuerySnapshot();

  /**
   * @brief Copy assignment operator.
   *
   * `QuerySnapshot` is immutable and can be efficiently copied (no deep copy is
   * performed).
   *
   * @param[in] other `QuerySnapshot` to copy from.
   *
   * @return Reference to the destination `QuerySnapshot`.
   */
  QuerySnapshot& operator=(const QuerySnapshot& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `QuerySnapshot`. After being
   * moved from, a `QuerySnapshot` is equivalent to its default-constructed
   * state.
   *
   * @param[in] other `QuerySnapshot` to move data from.
   *
   * @return Reference to the destination `QuerySnapshot`.
   */
  QuerySnapshot& operator=(QuerySnapshot&& other);

  /**
   * @brief The query from which you got this QuerySnapshot.
   */
  virtual Query query() const;

  /**
   * @brief Metadata about this snapshot, concerning its source and if it has
   * local modifications.
   *
   * @return The metadata for this document snapshot.
   */
  virtual SnapshotMetadata metadata() const;

  /**
   * @brief The list of documents that changed since the last snapshot.
   *
   * If it's the first snapshot, all documents will be in the list as added
   * changes. Documents with changes only to their metadata will not be
   * included.
   *
   * @param[in] metadata_changes Indicates whether metadata-only changes (that
   * is, only QuerySnapshot::metadata() changed) should be included.
   *
   * @return The list of document changes since the last snapshot.
   */
  virtual std::vector<DocumentChange> DocumentChanges(
      MetadataChanges metadata_changes = MetadataChanges::kExclude) const;

  /**
   * @brief The list of documents in this QuerySnapshot in order of the query.
   *
   * @return The list of documents.
   */
  virtual std::vector<DocumentSnapshot> documents() const;

  /**
   * @brief Checks the emptiness of the QuerySnapshot.
   *
   * @return True if there are no documents in the QuerySnapshot.
   */
  bool empty() const { return size() == 0; }

  /**
   * @brief Checks the size of the QuerySnapshot.
   *
   * @return The number of documents in the QuerySnapshot.
   */
  virtual std::size_t size() const;

  /**
   * @brief Returns true if this `QuerySnapshot` is valid, false if it is not
   * valid. An invalid `QuerySnapshot` could be the result of:
   *   - Creating a `QuerySnapshot` using the default constructor.
   *   - Moving from the `QuerySnapshot`.
   *   - Deleting your Firestore instance, which will invalidate all the
   *     `QuerySnapshot` instances associated with it.
   *
   * @return true if this `QuerySnapshot` is valid, false if this
   * `QuerySnapshot` is invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

 private:
  std::size_t Hash() const;

  friend bool operator==(const QuerySnapshot& lhs, const QuerySnapshot& rhs);
  friend std::size_t QuerySnapshotHash(const QuerySnapshot& snapshot);

  friend class EventListenerInternal;
  friend class FirestoreInternal;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit QuerySnapshot(QuerySnapshotInternal* internal);

  mutable QuerySnapshotInternal* internal_ = nullptr;
};

/** Checks `lhs` and `rhs` for equality. */
bool operator==(const QuerySnapshot& lhs, const QuerySnapshot& rhs);

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const QuerySnapshot& lhs, const QuerySnapshot& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_QUERY_SNAPSHOT_H_
