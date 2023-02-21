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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SNAPSHOT_METADATA_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SNAPSHOT_METADATA_H_

#include <iosfwd>
#include <string>

namespace firebase {
namespace firestore {

/** Metadata about a snapshot, describing the state of the snapshot. */
class SnapshotMetadata final {
 public:
  /**
   * Constructs a SnapshotMetadata that has all of its boolean members set to
   * false.
   */
  SnapshotMetadata() = default;

  /**
   * Constructs a SnapshotMetadata by providing boolean parameters that describe
   * the state of the snapshot.
   *
   * @param has_pending_writes Whether there is any pending write on the
   * snapshot.
   * @param is_from_cache Whether the snapshot is from cache instead of backend.
   */
  SnapshotMetadata(bool has_pending_writes, bool is_from_cache)
      : has_pending_writes_(has_pending_writes),
        is_from_cache_(is_from_cache) {}

  /**
   * @brief Copy constructor.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @note This class is currently trivially copyable, but it is not guaranteed
   * to stay that way, and code relying on this might be broken by a future
   * release.
   *
   * @param[in] other `SnapshotMetadata` to copy from.
   */
  SnapshotMetadata(const SnapshotMetadata& other) = default;

  /**
   * @brief Move constructor, equivalent to copying.
   *
   * After being moved from, `SnapshotMetadata` is in a valid but unspecified
   * state.
   *
   * @param[in] other `SnapshotMetadata` to move data from.
   */
  SnapshotMetadata(SnapshotMetadata&& other) = default;

  /**
   * @brief Copy assignment operator.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @note This class is currently trivially copyable, but it is not guaranteed
   * to stay that way, and code relying on this might be broken by a future
   * release.
   *
   * @param[in] other `SnapshotMetadata` to copy from.
   *
   * @return Reference to the destination `SnapshotMetadata`.
   */
  SnapshotMetadata& operator=(const SnapshotMetadata& other) = default;

  /**
   * @brief Move assignment operator, equivalent to copying.
   *
   * After being moved from, `SnapshotMetadata` is in a valid but unspecified
   * state.
   *
   * @param[in] other `SnapshotMetadata` to move data from.
   *
   * @return Reference to the destination `SnapshotMetadata`.
   */
  SnapshotMetadata& operator=(SnapshotMetadata&& other) = default;

  /**
   * Returns whether the snapshot contains the result of local writes.
   *
   * @return true if the snapshot contains the result of local writes (for
   * example, Set() or Update() calls) that have not yet been committed to the
   * backend. If your listener has opted into metadata updates (via
   * MetadataChanges::kInclude) you will receive another snapshot with
   * has_pending_writes() equal to false once the writes have been committed to
   * the backend.
   */
  bool has_pending_writes() const { return has_pending_writes_; }

  /**
   * Returns whether the snapshot was created from cached data.
   *
   * @return true if the snapshot was created from cached data rather than
   * guaranteed up-to-date server data. If your listener has opted into metadata
   * updates (via MetadataChanges::kInclude) you will receive another snapshot
   * with is_from_cache() equal to false once the client has received up-to-date
   * data from the backend.
   */
  bool is_from_cache() const { return is_from_cache_; }

  /**
   * Returns a string representation of this `SnapshotMetadata` for
   * logging/debugging purposes.
   *
   * @note the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `SnapshotMetadata` to the given
   * stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out,
                                  const SnapshotMetadata& metadata);

 private:
  bool has_pending_writes_ = false;
  bool is_from_cache_ = false;
};

/** Checks `lhs` and `rhs` for equality. */
inline bool operator==(const SnapshotMetadata& lhs,
                       const SnapshotMetadata& rhs) {
  return lhs.has_pending_writes() == rhs.has_pending_writes() &&
         lhs.is_from_cache() == rhs.is_from_cache();
}

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const SnapshotMetadata& lhs,
                       const SnapshotMetadata& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SNAPSHOT_METADATA_H_
