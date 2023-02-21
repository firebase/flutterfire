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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_QUERY_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_QUERY_H_

#include <cstddef>
#include <cstdint>
#include <functional>
#include <string>
#include <vector>

#include "firebase/internal/common.h"

#include "firebase/firestore/firestore_errors.h"
#include "firebase/firestore/metadata_changes.h"
#include "firebase/firestore/source.h"

namespace firebase {
/// @cond FIREBASE_APP_INTERNAL
template <typename T>
class Future;
/// @endcond

namespace firestore {

class DocumentSnapshot;
template <typename T>
class EventListener;
class FieldPath;
class FieldValue;
class ListenerRegistration;
class Firestore;
class QueryInternal;
class QuerySnapshot;

/**
 * @brief A Query which you can read or listen to.
 *
 * You can also construct refined Query objects by adding filters and ordering.
 *
 * You cannot construct a valid Query directly; use CollectionReference
 * methods that return a Query instead.
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class Query {
 public:
  /**
   * An enum for the direction of a sort.
   */
  enum class Direction {
    kAscending,
    kDescending,
  };

  /**
   * @brief Creates an invalid Query that has to be reassigned before it can be
   * used.
   *
   * Calling any member function on an invalid Query will be a no-op. If the
   * function returns a value, it will return a zero, empty, or invalid value,
   * depending on the type of the value.
   */
  Query();

  /**
   * @brief Copy constructor.
   *
   * `Query` is immutable and can be efficiently copied (no deep copy is
   * performed).
   *
   * @param[in] other `Query` to copy from.
   */
  Query(const Query& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `Query`. After being moved
   * from, a `Query` is equivalent to its default-constructed state.
   *
   * @param[in] other `Query` to move data from.
   */
  Query(Query&& other);

  virtual ~Query();

  /**
   * @brief Copy assignment operator.
   *
   * `Query` is immutable and can be efficiently copied (no deep copy is
   * performed).
   *
   * @param[in] other `Query` to copy from.
   *
   * @return Reference to the destination `Query`.
   */
  Query& operator=(const Query& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `Query`. After being moved
   * from, a `Query` is equivalent to its default-constructed state.
   *
   * @param[in] other `Query` to move data from.
   *
   * @return Reference to the destination `Query`.
   */
  Query& operator=(Query&& other);

  /**
   * @brief Returns the Firestore instance associated with this query.
   *
   * The pointer will remain valid indefinitely.
   *
   * @return Firebase Firestore instance that this Query refers to.
   */
  virtual const Firestore* firestore() const;

  /**
   * @brief Returns the Firestore instance associated with this query.
   *
   * The pointer will remain valid indefinitely.
   *
   * @return Firebase Firestore instance that this Query refers to.
   */
  virtual Firestore* firestore();

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be equal to
   * the specified value.
   *
   * @param[in] field The name of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereEqualTo(const std::string& field,
                             const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be equal to
   * the specified value.
   *
   * @param[in] field The path of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereEqualTo(const FieldPath& field,
                             const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value does not equal the
   * specified value.
   *
   * A Query can have only one `WhereNotEqualTo()` filter, and it cannot be
   * combined with `WhereNotIn()`.
   *
   * @param[in] field The name of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereNotEqualTo(const std::string& field,
                                const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value does not equal the
   * specified value.
   *
   * A Query can have only one `WhereNotEqualTo()` filter, and it cannot be
   * combined with `WhereNotIn()`.
   *
   * @param[in] field The path of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereNotEqualTo(const FieldPath& field,
                                const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be less
   * than the specified value.
   *
   * @param[in] field The name of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereLessThan(const std::string& field,
                              const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be less
   * than the specified value.
   *
   * @param[in] field The path of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereLessThan(const FieldPath& field,
                              const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be less
   * than or equal to the specified value.
   *
   * @param[in] field The name of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereLessThanOrEqualTo(const std::string& field,
                                       const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be less
   * than or equal to the specified value.
   *
   * @param[in] field The path of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereLessThanOrEqualTo(const FieldPath& field,
                                       const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be greater
   * than the specified value.
   *
   * @param[in] field The name of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereGreaterThan(const std::string& field,
                                 const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be greater
   * than the specified value.
   *
   * @param[in] field The path of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereGreaterThan(const FieldPath& field,
                                 const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be greater
   * than or equal to the specified value.
   *
   * @param[in] field The name of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereGreaterThanOrEqualTo(const std::string& field,
                                          const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value should be greater
   * than or equal to the specified value.
   *
   * @param[in] field The path of the field to compare.
   * @param[in] value The value for comparison.
   *
   * @return The created Query.
   */
  virtual Query WhereGreaterThanOrEqualTo(const FieldPath& field,
                                          const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field, the value must be an array, and
   * that the array must contain the provided value.
   *
   * A Query can have only one `WhereArrayContains()` filter and it cannot be
   * combined with `WhereArrayContainsAny()` or `WhereIn()`.
   *
   * @param[in] field The name of the field containing an array to search.
   * @param[in] value The value that must be contained in the array.
   *
   * @return The created Query.
   */
  virtual Query WhereArrayContains(const std::string& field,
                                   const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field, the value must be an array, and
   * that the array must contain the provided value.
   *
   * A Query can have only one `WhereArrayContains()` filter and it cannot be
   * combined with `WhereArrayContainsAny()` or `WhereIn()`.
   *
   * @param[in] field The path of the field containing an array to search.
   * @param[in] value The value that must be contained in the array.
   *
   * @return The created Query.
   */
  virtual Query WhereArrayContains(const FieldPath& field,
                                   const FieldValue& value) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field, the value must be an array, and
   * that the array must contain at least one value from the provided list.
   *
   * A Query can have only one `WhereArrayContainsAny()` filter and it cannot be
   * combined with `WhereArrayContains()` or `WhereIn()`.
   *
   * @param[in] field The name of the field containing an array to search.
   * @param[in] values The list that contains the values to match.
   *
   * @return The created Query.
   */
  virtual Query WhereArrayContainsAny(
      const std::string& field, const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field, the value must be an array, and
   * that the array must contain at least one value from the provided list.
   *
   * A Query can have only one `WhereArrayContainsAny()` filter and it cannot be
   * combined with` WhereArrayContains()` or `WhereIn()`.
   *
   * @param[in] field The path of the field containing an array to search.
   * @param[in] values The list that contains the values to match.
   *
   * @return The created Query.
   */
  virtual Query WhereArrayContainsAny(
      const FieldPath& field, const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value must equal one of
   * the values from the provided list.
   *
   * A Query can have only one `WhereIn()` filter and it cannot be
   * combined with `WhereArrayContainsAny()`.
   *
   * @param[in] field The name of the field containing an array to search.
   * @param[in] values The list that contains the values to match.
   *
   * @return The created Query.
   */
  virtual Query WhereIn(const std::string& field,
                        const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value must equal one of
   * the values from the provided list.
   *
   * A Query can have only one `WhereIn()` filter and it cannot be
   * combined with `WhereArrayContainsAny()`.
   *
   * @param[in] field The path of the field containing an array to search.
   * @param[in] values The list that contains the values to match.
   *
   * @return The created Query.
   */
  virtual Query WhereIn(const FieldPath& field,
                        const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value must not equal any
   * of the values from the provided list.
   *
   * One special case is that `WhereNotIn` cannot match `FieldValue::Null()`
   * values. To query for documents where a field exists and is
   * `FieldValue::Null()`, use `WhereNotEqualTo`, which can handle this special
   * case.
   *
   * A `Query` can have only one `WhereNotIn()` filter, and it cannot be
   * combined with `WhereArrayContains()`, `WhereArrayContainsAny()`,
   * `WhereIn()`, or `WhereNotEqualTo()`.
   *
   * @param[in] field The name of the field containing an array to search.
   * @param[in] values The list that contains the values to match.
   *
   * @return The created Query.
   */
  virtual Query WhereNotIn(const std::string& field,
                           const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query with the additional filter that
   * documents must contain the specified field and the value must not equal any
   * of the values from the provided list.
   *
   * One special case is that `WhereNotIn` cannot match `FieldValue::Null()`
   * values. To query for documents where a field exists and is
   * `FieldValue::Null()`, use `WhereNotEqualTo`, which can handle this special
   * case.
   *
   * A `Query` can have only one `WhereNotIn()` filter, and it cannot be
   * combined with `WhereArrayContains()`, `WhereArrayContainsAny()`,
   * `WhereIn()`, or `WhereNotEqualTo()`.
   *
   * @param[in] field The path of the field containing an array to search.
   * @param[in] values The list that contains the values to match.
   *
   * @return The created Query.
   */
  virtual Query WhereNotIn(const FieldPath& field,
                           const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query that's additionally sorted by the
   * specified field.
   *
   * @param[in] field The field to sort by.
   * @param[in] direction The direction to sort (optional). If not specified,
   * order will be ascending.
   *
   * @return The created Query.
   */
  virtual Query OrderBy(const std::string& field,
                        Direction direction = Direction::kAscending) const;

  /**
   * @brief Creates and returns a new Query that's additionally sorted by the
   * specified field.
   *
   * @param[in] field The field to sort by.
   * @param[in] direction The direction to sort (optional). If not specified,
   * order will be ascending.
   *
   * @return The created Query.
   */
  virtual Query OrderBy(const FieldPath& field,
                        Direction direction = Direction::kAscending) const;

  /**
   * @brief Creates and returns a new Query that only returns the first matching
   * documents up to the specified number.
   *
   * @param[in] limit A non-negative integer to specify the maximum number of
   * items to return.
   *
   * @return The created Query.
   */
  virtual Query Limit(int32_t limit) const;

  /**
   * @brief Creates and returns a new Query that only returns the last matching
   * documents up to the specified number.
   *
   * @param[in] limit A non-negative integer to specify the maximum number of
   * items to return.
   *
   * @return The created Query.
   */
  virtual Query LimitToLast(int32_t limit) const;

  /**
   * @brief Creates and returns a new Query that starts at the provided document
   * (inclusive). The starting position is relative to the order of the query.
   * The document must contain all of the fields provided in the order by of
   * this query.
   *
   * @param[in] snapshot The snapshot of the document to start at.
   *
   * @return The created Query.
   */
  virtual Query StartAt(const DocumentSnapshot& snapshot) const;

  /**
   * @brief Creates and returns a new Query that starts at the provided fields
   * relative to the order of the query. The order of the field values must
   * match the order of the order by clauses of the query.
   *
   * @param[in] values The field values to start this query at, in order of the
   * query's order by.
   *
   * @return The created Query.
   */
  virtual Query StartAt(const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query that starts after the provided
   * document (inclusive). The starting position is relative to the order of the
   * query. The document must contain all of the fields provided in the order by
   * of this query.
   *
   * @param[in] snapshot The snapshot of the document to start after.
   *
   * @return The created Query.
   */
  virtual Query StartAfter(const DocumentSnapshot& snapshot) const;

  /**
   * @brief Creates and returns a new Query that starts after the provided
   * fields relative to the order of the query. The order of the field values
   * must match the order of the order by clauses of the query.
   *
   * @param[in] values The field values to start this query after, in order of
   * the query's order by.
   *
   * @return The created Query.
   */
  virtual Query StartAfter(const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query that ends before the provided
   * document (inclusive). The end position is relative to the order of the
   * query. The document must contain all of the fields provided in the order by
   * of this query.
   *
   * @param[in] snapshot The snapshot of the document to end before.
   *
   * @return The created Query.
   */
  virtual Query EndBefore(const DocumentSnapshot& snapshot) const;

  /**
   * @brief Creates and returns a new Query that ends before the provided fields
   * relative to the order of the query. The order of the field values must
   * match the order of the order by clauses of the query.
   *
   * @param[in] values The field values to end this query before, in order of
   * the query's order by.
   *
   * @return The created Query.
   */
  virtual Query EndBefore(const std::vector<FieldValue>& values) const;

  /**
   * @brief Creates and returns a new Query that ends at the provided document
   * (inclusive). The end position is relative to the order of the query. The
   * document must contain all of the fields provided in the order by of this
   * query.
   *
   * @param[in] snapshot The snapshot of the document to end at.
   *
   * @return The created Query.
   */
  virtual Query EndAt(const DocumentSnapshot& snapshot) const;

  /**
   * @brief Creates and returns a new Query that ends at the provided fields
   * relative to the order of the query. The order of the field values must
   * match the order of the order by clauses of the query.
   *
   * @param[in] values The field values to end this query at, in order of the
   * query's order by.
   *
   * @return The created Query.
   */
  virtual Query EndAt(const std::vector<FieldValue>& values) const;

  /**
   * @brief Executes the query and returns the results as a QuerySnapshot.
   *
   * By default, Get() attempts to provide up-to-date data when possible by
   * waiting for data from the server, but it may return cached data or fail if
   * you are offline and the server cannot be reached. This behavior can be
   * altered via the Source parameter.
   *
   * @param[in] source A value to configure the get behavior (optional).
   *
   * @return A Future that will be resolved with the results of the Query.
   */
  virtual Future<QuerySnapshot> Get(Source source = Source::kDefault) const;

  /**
   * @brief Starts listening to the QuerySnapshot events referenced by this
   * query.
   *
   * @param[in] callback The std::function to call. When this function is
   * called, snapshot value is valid if and only if error is Error::kErrorOk.
   * The std::string is an error message; the value may be empty if an error
   * message is not available.
   *
   * @return A registration object that can be used to remove the listener.
   */
  virtual ListenerRegistration AddSnapshotListener(
      std::function<void(const QuerySnapshot&, Error, const std::string&)>
          callback);

  /**
   * @brief Starts listening to the QuerySnapshot events referenced by this
   * query.
   *
   * @param[in] metadata_changes Indicates whether metadata-only changes (that
   * is, only DocumentSnapshot::metadata() changed) should trigger snapshot
   * events.
   * @param[in] callback The std::function to call. When this function is
   * called, snapshot value is valid if and only if error is Error::kErrorOk.
   * The std::string is an error message; the value may be empty if an error
   * message is not available.
   *
   * @return A registration object that can be used to remove the listener.
   */
  virtual ListenerRegistration AddSnapshotListener(
      MetadataChanges metadata_changes,
      std::function<void(const QuerySnapshot&, Error, const std::string&)>
          callback);

  /**
   * @brief Returns true if this `Query` is valid, false if it is not valid. An
   * invalid `Query` could be the result of:
   *   - Creating a `Query` using the default constructor.
   *   - Moving from the `Query`.
   *   - Deleting your Firestore instance, which will invalidate all the `Query`
   *     instances associated with it.
   *
   * @return true if this `Query` is valid, false if this `Query` is invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

 private:
  size_t Hash() const;

  friend bool operator==(const Query& lhs, const Query& rhs);
  friend size_t QueryHash(const Query& query);

  friend class FirestoreInternal;
  friend class QueryInternal;
  friend class QuerySnapshotInternal;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;
  // For access to the constructor and to `internal_`.
  friend class CollectionReference;

  explicit Query(QueryInternal* internal);

  mutable QueryInternal* internal_ = nullptr;
};

/** Checks `lhs` and `rhs` for equality. */
bool operator==(const Query& lhs, const Query& rhs);

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const Query& lhs, const Query& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_QUERY_H_
