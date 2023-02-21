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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_WRITE_BATCH_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_WRITE_BATCH_H_

#include "firebase/firestore/map_field_value.h"
#include "firebase/firestore/set_options.h"

namespace firebase {

/// @cond FIREBASE_APP_INTERNAL
template <typename T>
class Future;
/// @endcond

namespace firestore {

class DocumentReference;
class WriteBatchInternal;

/**
 * @brief A write batch is used to perform multiple writes as a single atomic
 * unit.
 *
 * A WriteBatch object provides methods for adding writes to the write batch.
 * None of the writes will be committed (or visible locally) until Commit() is
 * called.
 *
 * Unlike transactions, write batches are persisted offline and therefore are
 * preferable when you don't need to condition your writes on read data.
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class WriteBatch {
 public:
  /**
   * @brief Creates an invalid WriteBatch that has to be reassigned before it
   * can be used.
   *
   * Calling any member function on an invalid WriteBatch will be a no-op. If
   * the function returns a value, it will return a zero, empty, or invalid
   * value, depending on the type of the value.
   */
  WriteBatch();

  /**
   * @brief Copy constructor.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `WriteBatch` to copy from.
   */
  WriteBatch(const WriteBatch& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `WriteBatch`. After being moved
   * from, a `WriteBatch` is equivalent to its default-constructed state.
   *
   * @param[in] other `WriteBatch` to move data from.
   */
  WriteBatch(WriteBatch&& other);

  virtual ~WriteBatch();

  /**
   * @brief Copy assignment operator.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `WriteBatch` to copy from.
   *
   * @return Reference to the destination `WriteBatch`.
   */
  WriteBatch& operator=(const WriteBatch& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `WriteBatch`. After being moved
   * from, a `WriteBatch` is equivalent to its default-constructed state.
   *
   * @param[in] other `WriteBatch` to move data from.
   *
   * @return Reference to the destination `WriteBatch`.
   */
  WriteBatch& operator=(WriteBatch&& other);

  /**
   * @brief Writes to the document referred to by the provided reference.
   *
   * If the document does not yet exist, it will be created. If you pass
   * SetOptions, the provided data can be merged into an existing document.
   *
   * @param document The DocumentReference to write to.
   * @param data A map of the fields and values to write to the document.
   * @param[in] options An object to configure the Set() behavior (optional).
   *
   * @return This WriteBatch instance. Used for chaining method calls.
   */
  virtual WriteBatch& Set(const DocumentReference& document,
                          const MapFieldValue& data,
                          const SetOptions& options = SetOptions());

  /**
   * Updates fields in the document referred to by the provided reference. If no
   * document exists yet, the update will fail.
   *
   * @param document The DocumentReference to update.
   * @param data A map of field / value pairs to update. Fields can contain dots
   * to reference nested fields within the document.
   * @return This WriteBatch instance. Used for chaining method calls.
   */
  virtual WriteBatch& Update(const DocumentReference& document,
                             const MapFieldValue& data);

  /**
   * Updates fields in the document referred to by the provided reference. If no
   * document exists yet, the update will fail.
   *
   * @param document The DocumentReference to update.
   * @param data A map from FieldPath to FieldValue to update.
   * @return This WriteBatch instance. Used for chaining method calls.
   */
  virtual WriteBatch& Update(const DocumentReference& document,
                             const MapFieldPathValue& data);

  /**
   * Deletes the document referred to by the provided reference.
   *
   * @param document The DocumentReference to delete.
   * @return This WriteBatch instance. Used for chaining method calls.
   */
  virtual WriteBatch& Delete(const DocumentReference& document);

  /**
   * Commits all of the writes in this write batch as a single atomic unit.
   *
   * @return A Future that will be resolved when the write finishes.
   */
  virtual Future<void> Commit();

  /**
   * @brief Returns true if this `WriteBatch` is valid, false if it is not
   * valid. An invalid `WriteBatch` could be the result of:
   *   - Creating a `WriteBatch` using the default constructor.
   *   - Moving from the `WriteBatch`.
   *   - Deleting your Firestore instance, which will invalidate all the
   *     `WriteBatch` instances associated with it.
   *
   * @return true if this `WriteBatch` is valid, false if this `WriteBatch` is
   * invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

 private:
  friend class FirestoreInternal;
  friend class WriteBatchInternal;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit WriteBatch(WriteBatchInternal* internal);

  mutable WriteBatchInternal* internal_ = nullptr;
};

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_WRITE_BATCH_H_
