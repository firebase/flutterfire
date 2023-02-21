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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_TRANSACTION_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_TRANSACTION_H_

#include <string>

#include "firebase/firestore/firestore_errors.h"
#include "firebase/firestore/map_field_value.h"
#include "firebase/firestore/set_options.h"

namespace firebase {
namespace firestore {

class DocumentReference;
class DocumentSnapshot;
class TransactionInternal;

/**
 * @brief Transaction provides methods to read and write data within
 * a transaction.
 *
 * You cannot create a `Transaction` directly; use `Firestore::RunTransaction()`
 * function instead.
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class Transaction {
 public:
  /** Destructor. */
  virtual ~Transaction();

  /**
   * @brief Deleted copy constructor.
   *
   * A `Transaction` object is only valid for the duration of the callback you
   * pass to `Firestore::RunTransaction()` and cannot be copied.
   */
  Transaction(const Transaction& other) = delete;

  /**
   * @brief Deleted copy assignment operator.
   *
   * A `Transaction` object is only valid for the duration of the callback you
   * pass to `Firestore::RunTransaction()` and cannot be copied.
   */
  Transaction& operator=(const Transaction& other) = delete;

  /**
   * @brief Writes to the document referred to by the provided reference.
   *
   * If the document does not yet exist, it will be created. If you pass
   * SetOptions, the provided data can be merged into an existing document.
   *
   * @param[in] document The DocumentReference to overwrite.
   * @param[in] data A map of the fields and values to write to the document.
   * @param[in] options An object to configure the Set() behavior (optional).
   */
  virtual void Set(const DocumentReference& document,
                   const MapFieldValue& data,
                   const SetOptions& options = SetOptions());

  /**
   * Updates fields in the document referred to by the provided reference. If no
   * document exists yet, the update will fail.
   *
   * @param[in] document The DocumentReference to update.
   * @param[in] data A map of field / value pairs to update. Fields can contain
   * dots to reference nested fields within the document.
   */
  virtual void Update(const DocumentReference& document,
                      const MapFieldValue& data);

  /**
   * Updates fields in the document referred to by the provided reference. If no
   * document exists yet, the update will fail.
   *
   * @param[in] document The DocumentReference to update.
   * @param[in] data A map from FieldPath to FieldValue to update.
   */
  virtual void Update(const DocumentReference& document,
                      const MapFieldPathValue& data);

  /**
   * Deletes the document referred to by the provided reference.
   *
   * @param[in] document The DocumentReference to delete.
   */
  virtual void Delete(const DocumentReference& document);

  /**
   * Reads the document referred by the provided reference.
   *
   * @param[in] document The DocumentReference to read.
   * @param[out] error_code An out parameter to capture an error, if one
   * occurred.
   * @param[out] error_message An out parameter to capture error message, if
   * any.
   * @return The contents of the document at this DocumentReference or invalid
   * DocumentSnapshot if there is any error.
   */
  virtual DocumentSnapshot Get(const DocumentReference& document,
                               Error* error_code,
                               std::string* error_message);

 protected:
  /**
   * Default constructor, to be used only for mocking a `Transaction`.
   */
  Transaction() = default;

 private:
  friend class FirestoreInternal;
  friend class TransactionInternal;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit Transaction(TransactionInternal* internal);

  mutable TransactionInternal* internal_ = nullptr;
};

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_TRANSACTION_H_
