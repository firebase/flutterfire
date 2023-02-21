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

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_QUERY_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_QUERY_H_

#include <string>

#include "firebase/database/listener.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"

namespace firebase {
namespace database {
namespace internal {
class QueryInternal;
}  // namespace internal

class DatabaseReference;

#ifndef SWIG
/// The Query class is used for reading data. Listeners can be attached, which
/// will be triggered when the data changes.
#endif  // SWIG
class Query {
 public:
  /// Default constructor. This creates an invalid Query. Attempting to perform
  /// any operations on this reference will fail unless a valid Query has been
  /// assigned to it.
  Query() : internal_(nullptr) {}

  /// Copy constructor. Queries can be copied. Copies exist independently of
  /// each other.
  Query(const Query& query);

  /// Copy assignment operator. Queries can be copied. Copies exist
  /// independently of each other.
  Query& operator=(const Query& query);

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
  /// Move constructor.
  Query(Query&& query);
  /// Move assignment operator.
  Query& operator=(Query&& query);
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// @brief Required virtual destructor.
  virtual ~Query();

  /// @brief Gets the value of the query for the given location a single time.
  ///
  /// This is an asynchronous operation which takes time to execute, and uses
  /// firebase::Future to return its result.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. On this Future's completion, if its Error is
  /// kErrorNone, the operation succeeded, and the DataSnapshot contains the
  /// data in this location.
  Future<DataSnapshot> GetValue();
  /// @brief Gets the result of the most recent call to GetValue().
  ///
  /// @returns Result of the most recent call to GetValue().
  Future<DataSnapshot> GetValueLastResult();

  /// @brief Adds a listener that will be called immediately and then again any
  /// time the data changes.
  ///
  /// @param[in] listener A ValueListener instance, which must remain in memory
  /// until you remove the listener from the Query.
  void AddValueListener(ValueListener* listener);

  /// @brief Removes a listener that was previously added with
  /// AddValueListener().
  ///
  /// @param[in] listener A ValueListener instance to remove from the
  /// Query. After it is removed, you can delete it or attach it to a new
  /// location.
  ///
  /// @note You can remove a ValueListener from a different Query than you added
  /// it to, as long as the two Query instances are equivalent.
  void RemoveValueListener(ValueListener* listener);

  /// @brief Removes all value listeners that were added with
  /// AddValueListener().
  ///
  /// @note You can remove ValueListeners from a different Query than you added
  /// them to, as long as the two Query instances are equivalent.
  void RemoveAllValueListeners();

  /// @brief Adds a listener that will be called any time a child is added,
  /// removed, modified, or reordered.
  ///
  /// @param[in] listener A ChildListener instance, which must remain in memory
  /// until you remove the listener from the Query.
  void AddChildListener(ChildListener* listener);

  /// @brief Removes a listener that was previously added with
  /// AddChildListener().
  ///
  /// @param[in] listener A ChildListener instance to remove from the
  /// Query. After it is removed, you can delete it or attach it to a new
  /// location.
  ///
  /// @note You can remove a ChildListener from a different Query than you added
  /// it to, as long as the two Query instances are equivalent.
  void RemoveChildListener(ChildListener* listener);

  /// @brief Removes all child listeners that were added by AddChildListener().
  ///
  /// @note You can remove ChildListeners from a different Query than you added
  /// them to, as long as the two Query instances are equivalent.
  void RemoveAllChildListeners();

  /// @brief Gets a DatabaseReference corresponding to the given location.
  ///
  /// @returns A DatabaseReference corresponding to the same location as the
  /// Query, but without any of the ordering or filtering parameters.
  DatabaseReference GetReference() const;

  /// @brief Sets whether this location's data should be kept in sync even if
  /// there are no active Listeners.
  ///
  /// By calling SetKeepSynchronized(true) on a given database location, the
  /// data for that location will automatically be downloaded and kept in sync,
  /// even when no listeners are attached for that location. Additionally, while
  /// a location is kept synced, it will not be evicted from the persistent disk
  /// cache.
  ///
  /// @param[in] keep_sync If true, set this location to be synchronized. If
  /// false, set it to not be synchronized.
  void SetKeepSynchronized(bool keep_sync);

  // The OrderBy* functions are used for two purposes:
  // 1. Order the data when getting the list of children.
  // 2. When filtering the data using the StartAt* and EndAt* functions further
  //    below, use the specified ordering.

  /// @brief Gets a query in which child nodes are ordered by the values of the
  /// specified path. Any previous OrderBy directive will be replaced in the
  /// returned Query.
  ///
  /// @param[in] path Path to a child node. The value of this node will be used
  /// for sorting this query. The pointer you pass in need not remain valid
  /// after the call completes.
  ///
  /// @returns A Query in this same location, with the children are sorted by
  /// the value of their own child specified here.
  Query OrderByChild(const char* path);
  /// @brief Gets a query in which child nodes are ordered by the values of the
  /// specified path. Any previous OrderBy directive will be replaced in the
  /// returned Query.
  ///
  /// @param[in] path Path to a child node. The value of this node will be used
  /// for sorting this query.
  ///
  /// @returns A Query in this same location, with the children are sorted by
  /// the value of their own child specified here.
  Query OrderByChild(const std::string& path);
  /// @brief Gets a query in which child nodes are ordered by their keys. Any
  /// previous OrderBy directive will be replaced in the returned Query.
  ///
  /// @returns A Query in this same location, with the children are sorted by
  /// their key.
  Query OrderByKey();
  /// @brief Gets a query in which child nodes are ordered by their priority.
  /// Any previous OrderBy directive will be replaced in the returned Query.
  ///
  /// @returns A Query in this same location, with the children are sorted by
  /// their priority.
  Query OrderByPriority();
  /// @brief Create a query in which nodes are ordered by their value.
  ///
  /// @returns A Query in this same location, with the children are sorted by
  /// their value.
  Query OrderByValue();

  // The StartAt, EndAt, and EqualTo functions are used to limit which child
  // nodes are returned when iterating through the current location.

  /// @brief Get a Query constrained to nodes with the given sort value or
  /// higher.
  ///
  /// This method is used to generate a reference to a limited view of the data
  /// at this location. The Query returned will only refer to child nodes with a
  /// value greater than or equal to the given value, using the given OrderBy
  /// directive (or priority as the default).
  ///
  /// @param[in] order_value The lowest sort value the Query should include.
  ///
  /// @returns A Query in this same location, filtering out child nodes that
  /// have a lower sort value than the sort value specified.
  Query StartAt(Variant order_value);
  /// @brief Get a Query constrained to nodes with the given sort value or
  /// higher, and the given key or higher.
  ///
  /// This method is used to generate a reference to a limited view of the data
  /// at this location. The Query returned will only refer to child nodes with a
  /// value greater than or equal to the given value, using the given OrderBy
  /// directive (or priority as default), and additionally only child nodes with
  /// a key greater than or equal to the given key.
  ///
  /// <b>Known issue</b> This currently does not work properly on all platforms.
  /// Please use StartAt(Variant order_value) instead.
  ///
  /// @param[in] order_value The lowest sort value the Query should include.
  /// @param[in] child_key The lowest key the Query should include.
  ///
  /// @returns A Query in this same location, filtering out child nodes that
  /// have a lower sort value than the sort value specified, or a lower key than
  /// the key specified.
  Query StartAt(Variant order_value, const char* child_key);

  /// @brief Get a Query constrained to nodes with the given sort value or
  /// lower.
  ///
  /// This method is used to generate a reference to a limited view of the data
  /// at this location. The Query returned will only refer to child nodes with a
  /// value less than or equal to the given value, using the given OrderBy
  /// directive (or priority as default).
  ///
  /// @param[in] order_value The highest sort value the Query should refer
  /// to.
  ///
  /// @returns A Query in this same location, filtering out child nodes that
  /// have a higher sort value or key than the sort value or key specified.
  Query EndAt(Variant order_value);
  /// @brief Get a Query constrained to nodes with the given sort value or
  /// lower, and the given key or lower.
  ///
  /// This method is used to generate a reference to a limited view of
  /// the data at this location. The Query returned will only refer to child
  /// nodes with a value less than or equal to the given value, using the given
  /// OrderBy directive (or priority as default), and additionally only child
  /// nodes with a key less than or equal to the given key.
  ///
  /// <b>Known issue</b> This currently does not work properly on all platforms.
  /// Please use EndAt(Variant order_value) instead.
  ///
  /// @param[in] order_value The highest sort value the Query should include.
  /// @param[in] child_key The highest key the Query should include.
  ///
  /// @returns A Query in this same location, filtering out child nodes that
  /// have a higher sort value than the sort value specified, or a higher key
  /// than the key specified.
  Query EndAt(Variant order_value, const char* child_key);

  /// @brief Get a Query constrained to nodes with the exact given sort value.
  ///
  /// This method is used to create a query constrained to only return child
  /// nodes with the given value, using the given OrderBy directive (or priority
  /// as default).
  ///
  /// @param[in] order_value The exact sort value the Query should include.
  ///
  /// @returns A Query in this same location, filtering out child nodes that
  /// have a different sort value than the sort value specified.
  Query EqualTo(Variant order_value);

  /// @brief Get a Query constrained to nodes with the exact given sort value,
  /// and the exact given key.
  ///
  /// This method is used to create a query constrained to only return the child
  /// node with the given value, using the given OrderBy directive (or priority
  /// as default), and the given key. Note that there is at most one such child
  /// as child key names are unique.
  ///
  /// <b>Known issue</b> This currently does not work properly on iOS, tvOS and
  /// desktop. Please use EqualTo(Variant order_value) instead.
  ///
  /// @param[in] order_value The exact sort value the Query should include.
  /// @param[in] child_key The exact key the Query should include.
  ///
  /// @returns A Query in this same location, filtering out child nodes that
  /// have a different sort value than the sort value specified, and containing
  /// at most one child with the exact key specified.
  Query EqualTo(Variant order_value, const char* child_key);

  // The LimitTo* functions are used to limit how many child nodes are returned
  // when iterating through the current location.

  /// @brief Gets a Query limited to only the first results.
  ///
  /// Limits the query to reference only the first N child nodes, using the
  /// given OrderBy directive (or priority as default).
  ///
  /// @param[in] limit Number of children to limit the Query to.
  ///
  /// @returns A Query in this same location, limited to the specified number of
  /// children (taken from the beginning of the sorted list).
  Query LimitToFirst(size_t limit);
  /// @brief Gets a Query limited to only the last results.
  ///
  /// @param[in] limit Number of children to limit the Query to.
  ///
  /// @returns A Query in this same location, limited to the specified number of
  /// children (taken from the end of the sorted list).
  Query LimitToLast(size_t limit);

  /// @brief Returns true if this query is valid, false if it is not valid. An
  /// invalid query could be returned by, say, attempting to OrderBy two
  /// different items, or calling OrderByChild() with an empty path, or by
  /// constructing a Query with the default constructor. If a Query
  /// is invalid, attempting to add more constraints will also result in an
  /// invalid Query.
  ///
  /// @returns true if this query is valid, false if this query is
  /// invalid.
  virtual bool is_valid() const;

 protected:
  /// @cond FIREBASE_APP_INTERNAL
  explicit Query(internal::QueryInternal* internal);
  void SetInternal(internal::QueryInternal* internal);
  void RegisterCleanup();
  void UnregisterCleanup();
  /// @endcond

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend bool operator==(const Query& lhs, const Query& rhs);
  /// @endcond

  internal::QueryInternal* internal_;
};

/// @brief Compares two Query instances.
///
/// Two Query instances on the same database, in the same location, with the
/// same parameters (OrderBy*, StartAt, EndAt, EqualTo, Limit*) are considered
/// equivalent.
///
/// Equivalent Queries have a shared pool of ValueListeners and
/// ChildListeners. When listeners are added or removed from one Query
/// instance, it affects all equivalent Query instances.
///
/// @param[in] lhs The Query to compare against.
/// @param[in] rhs The Query to compare against.
///
/// @returns True if the Query instances have the same database, the same
/// path, and the same parameters, determined by StartAt(), EndAt(),
/// EqualTo(), and the OrderBy and LimitTo methods. False otherwise.
bool operator==(const Query& lhs, const Query& rhs);

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_QUERY_H_
