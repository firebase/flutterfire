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

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_DATA_SNAPSHOT_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_DATA_SNAPSHOT_H_

#include <stddef.h>

#include <string>

#include "firebase/internal/common.h"
#include "firebase/variant.h"

namespace firebase {
namespace database {
namespace internal {
class Callbacks;
class ChildEventRegistration;
class DataSnapshotInternal;
class DatabaseInternal;
class DatabaseInternalTestMatcherTest;
class DatabaseReferenceInternal;
class QueryInternal;
class Repo;
class ValueEventRegistration;
}  // namespace internal

class Database;
class DatabaseReference;

#ifndef SWIG
/// A DataSnapshot instance contains data from a Firebase Database location. Any
/// time you read Database data, you receive the data as a DataSnapshot. These
/// are efficiently-generated and cannot be changed. To modify data,
/// use DatabaseReference::SetValue() or DatabaseReference::RunTransaction().
#endif  // SWIG
class DataSnapshot {
 public:
  /// @brief Default constructor.
  ///
  /// This DataSnapshot contains nothing and is considered invalid (i.e.
  /// is_valid() == false). Use this to construct an empty DataSnapshot that you
  /// will later populate with data from a database callback.
  DataSnapshot() : internal_(nullptr) {}

#ifdef INTERNAL_EXPERIMENTAL
  explicit DataSnapshot(internal::DataSnapshotInternal* internal);
#endif

  /// @brief Copy constructor. DataSnapshots are immutable, so they can be
  /// efficiently copied.
  ///
  /// @param[in] snapshot DataSnapshot to copy.
  DataSnapshot(const DataSnapshot& snapshot);

  /// @brief Copy assignment operator. DataSnapshots are immutable, so they can
  /// be efficiently copied.
  ///
  /// @param[in] snapshot DataSnapshot to copy.
  ///
  /// @returns Reference to the destination DataSnapshot.
  DataSnapshot& operator=(const DataSnapshot& snapshot);

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
  /// @brief Move constructor. DataSnapshots are immutable, so they can be
  /// efficiently moved.
  ///
  /// @param[in] snapshot DataSnapshot to move into this one.
  DataSnapshot(DataSnapshot&& snapshot);

  /// @brief Move assignment operator. DataSnapshots are immutable, so they can
  /// be efficiently moved.
  ///
  /// @param[in] snapshot DataSnapshot to move into this one.
  ///
  /// @returns Reference to this destination DataSnapshot.
  DataSnapshot& operator=(DataSnapshot&& snapshot);
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// Destructor.
  ~DataSnapshot();

  /// @brief Returns true if the data is non-empty.
  bool exists() const;

  /// @brief Get a DataSnapshot for the location at the specified relative path.
  ///
  /// @param[in] path Path relative to this snapshot's location.
  /// It only needs to be valid during this call.
  ///
  /// @returns A DataSnapshot corresponding to specified child location.
  DataSnapshot Child(const char* path) const;

  /// @brief Get a DataSnapshot for the location at the specified relative path.
  ///
  /// @param[in] path Path relative to this snapshot's location.
  ///
  /// @returns A DataSnapshot corresponding to specified child location.
  DataSnapshot Child(const std::string& path) const;

  /// @brief Get all the immediate children of this location.
  ///
  /// @returns The immediate children of this snapshot.
  std::vector<DataSnapshot> children() const;

  /// @brief Get the number of children of this location.
  ///
  /// @returns The number of immediate children of this snapshot.
  size_t children_count() const;

  /// @brief Does this DataSnapshot have any children at all?
  ///
  /// @returns True if the snapshot has any children, false otherwise.
  bool has_children() const;

  /// @brief Get the key name of the source location of this snapshot.
  ///
  /// @note The returned pointer is only guaranteed to be valid while the
  /// DataSnapshot is still in memory.
  ///
  /// @returns Key name of the source location of this snapshot.
  const char* key() const;

  /// @brief Get the key name of the source location of this snapshot.
  ///
  /// @returns Key name of the source location of this snapshot.
  std::string key_string() const;

  /// @brief Get the value of the data contained in this snapshot.
  ///
  /// @returns The value of the data contained in this location.
  Variant value() const;

  /// @brief Get the priority of the data contained in this snapshot.
  ///
  /// @returns The value of this location's Priority relative to its siblings.
  Variant priority() const;

  /// @brief Obtain a DatabaseReference to the source location for this
  /// snapshot.
  ///
  /// @returns A DatabaseReference corresponding to same location as
  /// this snapshot.
  DatabaseReference GetReference() const;

  /// @brief Does this DataSnapshot have data at a particular location?
  ///
  /// @param[in] path Path relative to this snapshot's location.
  /// The pointer only needs to be valid during this call.
  ///
  /// @returns True if the snapshot has data at the specified location, false if
  /// not.
  bool HasChild(const char* path) const;

  /// @brief Does this DataSnapshot have data at a particular location?
  ///
  /// @param[in] path Path relative to this snapshot's location.
  ///
  /// @returns True if the snapshot has data at the specified location, false if
  /// not.
  bool HasChild(const std::string& path) const;

  /// @brief Returns true if this snapshot is valid, false if it is not
  /// valid. An invalid snapshot could be returned by a transaction where an
  /// error has occurred.
  ///
  /// @returns true if this snapshot is valid, false if this snapshot is
  /// invalid.
  bool is_valid() const;

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class internal::Callbacks;
  friend class internal::ChildEventRegistration;
  friend class internal::DataSnapshotInternal;
  friend class internal::DatabaseInternal;
  friend class internal::DatabaseInternalTestMatcherTest;
  friend class internal::DatabaseReferenceInternal;
  friend class internal::QueryInternal;
  friend class internal::Repo;
  friend class internal::ValueEventRegistration;
  /// @endcond

#ifndef INTERNAL_EXPERIMENTAL
  explicit DataSnapshot(internal::DataSnapshotInternal* internal);
#endif

  internal::DataSnapshotInternal* internal_;
};

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_DATA_SNAPSHOT_H_
