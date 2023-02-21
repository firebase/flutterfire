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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_REFERENCE_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_REFERENCE_H_

#include <functional>
#include <iosfwd>
#include <string>

#include "firebase/internal/common.h"

#include "firebase/firestore/firestore_errors.h"
#include "firebase/firestore/map_field_value.h"
#include "firebase/firestore/metadata_changes.h"
#include "firebase/firestore/set_options.h"
#include "firebase/firestore/source.h"

namespace firebase {

/// @cond FIREBASE_APP_INTERNAL
template <typename T>
class Future;
/// @endcond

namespace firestore {

class CollectionReference;
class DocumentReferenceInternal;
class DocumentSnapshot;
template <typename T>
class EventListener;
class Firestore;
class ListenerRegistration;

/**
 * @brief A DocumentReference refers to a document location in a Firestore
 * database and can be used to write, read, or listen to the location.
 *
 * There may or may not exist a document at the referenced location.
 * A DocumentReference can also be used to create a CollectionReference to
 * a subcollection.
 *
 * Create a DocumentReference via `Firestore::Document(const std::string&
 * path)`.
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class DocumentReference {
 public:
  /**
   * @brief Creates an invalid DocumentReference that has to be reassigned
   * before it can be used.
   *
   * Calling any member function on an invalid DocumentReference will be
   * a no-op. If the function returns a value, it will return a zero, empty, or
   * invalid value, depending on the type of the value.
   */
  DocumentReference();

  /**
   * @brief Copy constructor.
   *
   * `DocumentReference` can be efficiently copied because it simply refers to
   * a location in the database.
   *
   * @param[in] other `DocumentReference` to copy from.
   */
  DocumentReference(const DocumentReference& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `DocumentReference`. After
   * being moved from, a `DocumentReference` is equivalent to its
   * default-constructed state.
   *
   * @param[in] other `DocumentReference` to move data from.
   */
  DocumentReference(DocumentReference&& other);

  virtual ~DocumentReference();

  /**
   * @brief Copy assignment operator.
   *
   * `DocumentReference` can be efficiently copied because it simply refers to
   * a location in the database.
   *
   * @param[in] other `DocumentReference` to copy from.
   *
   * @return Reference to the destination `DocumentReference`.
   */
  DocumentReference& operator=(const DocumentReference& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `DocumentReference`. After
   * being moved from, a `DocumentReference` is equivalent to its
   * default-constructed state.
   *
   * @param[in] other `DocumentReference` to move data from.
   *
   * @return Reference to the destination `DocumentReference`.
   */
  DocumentReference& operator=(DocumentReference&& other);

  /**
   * @brief Returns the Firestore instance associated with this document
   * reference.
   *
   * The pointer will remain valid indefinitely.
   *
   * @return Firebase Firestore instance that this DocumentReference refers to.
   */
  virtual const Firestore* firestore() const;

  /**
   * @brief Returns the Firestore instance associated with this document
   * reference.
   *
   * The pointer will remain valid indefinitely.
   *
   * @return Firebase Firestore instance that this DocumentReference refers to.
   */
  virtual Firestore* firestore();

  /**
   * @brief Returns the string ID of this document location.
   *
   * @return String ID of this document location.
   */
  virtual const std::string& id() const;

  /**
   * @brief Returns the path of this document (relative to the root of the
   * database) as a slash-separated string.
   *
   * @return String path of this document location.
   */
  virtual std::string path() const;

  /**
   * @brief Returns a CollectionReference to the collection that contains this
   * document.
   */
  virtual CollectionReference Parent() const;

  /**
   * @brief Returns a CollectionReference instance that refers to the
   * subcollection at the specified path relative to this document.
   *
   * @param[in] collection_path A slash-separated relative path to a
   * subcollection. The pointer only needs to be valid during this call.
   *
   * @return The CollectionReference instance.
   */
  virtual CollectionReference Collection(const char* collection_path) const;

  /**
   * @brief Returns a CollectionReference instance that refers to the
   * subcollection at the specified path relative to this document.
   *
   * @param[in] collection_path A slash-separated relative path to a
   * subcollection.
   *
   * @return The CollectionReference instance.
   */
  virtual CollectionReference Collection(
      const std::string& collection_path) const;

  /**
   * @brief Reads the document referenced by this DocumentReference.
   *
   * By default, Get() attempts to provide up-to-date data when possible by
   * waiting for data from the server, but it may return cached data or fail if
   * you are offline and the server cannot be reached. This behavior can be
   * altered via the Source parameter.
   *
   * @param[in] source A value to configure the get behavior (optional).
   *
   * @return A Future that will be resolved with the contents of the Document at
   * this DocumentReference.
   */
  virtual Future<DocumentSnapshot> Get(Source source = Source::kDefault) const;

  /**
   * @brief Writes to the document referred to by this DocumentReference.
   *
   * If the document does not yet exist, it will be created. If you pass
   * SetOptions, the provided data can be merged into an existing document.
   *
   * @param[in] data A map of the fields and values to write to the document.
   * @param[in] options An object to configure the Set() behavior (optional).
   *
   * @return A Future that will be resolved when the write finishes.
   */
  virtual Future<void> Set(const MapFieldValue& data,
                           const SetOptions& options = SetOptions());

  /**
   * @brief Updates fields in the document referred to by this
   * DocumentReference.
   *
   * If no document exists yet, the update will fail.
   *
   * @param[in] data A map of field / value pairs to update. Fields can contain
   * dots to reference nested fields within the document.
   *
   * @return A Future that will be resolved when the client is online and the
   * commit has completed against the server. The future will not resolve when
   * the device is offline, though local changes will be visible immediately.
   */
  virtual Future<void> Update(const MapFieldValue& data);

  /**
   * @brief Updates fields in the document referred to by this
   * DocumentReference.
   *
   * If no document exists yet, the update will fail.
   *
   * @param[in] data A map from FieldPath to FieldValue to update.
   *
   * @return A Future that will be resolved when the client is online and the
   * commit has completed against the server. The future will not resolve when
   * the device is offline, though local changes will be visible immediately.
   */
  virtual Future<void> Update(const MapFieldPathValue& data);

  /**
   * @brief Removes the document referred to by this DocumentReference.
   *
   * @return A Future that will be resolved when the delete completes.
   */
  virtual Future<void> Delete();

  /**
   * @brief Starts listening to the document referenced by this
   * DocumentReference.
   *
   * @param[in] callback The std::function to call. When this function is
   * called, snapshot value is valid if and only if error is Error::kErrorOk.
   * The std::string is an error message; the value may be empty if an error
   * message is not available.
   *
   * @return A registration object that can be used to remove the listener.
   */
  virtual ListenerRegistration AddSnapshotListener(
      std::function<void(const DocumentSnapshot&, Error, const std::string&)>
          callback);

  /**
   * @brief Starts listening to the document referenced by this
   * DocumentReference.
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
      std::function<void(const DocumentSnapshot&, Error, const std::string&)>
          callback);

  /**
   * @brief Returns true if this `DocumentReference` is valid, false if it is
   * not valid. An invalid `DocumentReference` could be the result of:
   *   - Creating a `DocumentReference` using the default constructor.
   *   - Moving from the `DocumentReference`.
   *   - Calling `CollectionReference::Parent()` on a `CollectionReference` that
   *     is not a subcollection.
   *   - Deleting your Firestore instance, which will invalidate all the
   *     `DocumentReference` instances associated with it.
   *
   * @return true if this `DocumentReference` is valid, false if this
   * `DocumentReference` is invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

  /**
   * Returns a string representation of this `DocumentReference` for
   * logging/debugging purposes.
   *
   * @note the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `DocumentReference` to the given
   * stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out,
                                  const DocumentReference& reference);

 private:
  friend bool operator==(const DocumentReference& lhs,
                         const DocumentReference& rhs);

  friend class CollectionReferenceInternal;
  friend class DocumentSnapshotInternal;
  friend class FieldValueInternal;
  friend class FirestoreInternal;
  friend class TransactionInternal;
  friend class WriteBatchInternal;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit DocumentReference(DocumentReferenceInternal* internal);

  mutable DocumentReferenceInternal* internal_ = nullptr;
};

/** Checks `lhs` and `rhs` for equality. */
bool operator==(const DocumentReference& lhs, const DocumentReference& rhs);

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const DocumentReference& lhs,
                       const DocumentReference& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_DOCUMENT_REFERENCE_H_
