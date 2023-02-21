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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_COLLECTION_REFERENCE_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_COLLECTION_REFERENCE_H_

#include <string>

#include "firebase/firestore/map_field_value.h"
#include "firebase/firestore/query.h"

namespace firebase {

/// @cond FIREBASE_APP_INTERNAL
template <typename T>
class Future;
/// @endcond

namespace firestore {

class CollectionReferenceInternal;
class DocumentReference;

/**
 * @brief A CollectionReference can be used for adding documents, getting
 * document references, and querying for documents (using the methods inherited
 * from `Query`).
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class CollectionReference : public Query {
 public:
  /**
   * @brief Creates an invalid CollectionReference that has to be reassigned
   * before it can be used.
   *
   * Calling any member function on an invalid CollectionReference will be
   * a no-op. If the function returns a value, it will return a zero, empty, or
   * invalid value, depending on the type of the value.
   */
  CollectionReference();

  /**
   * @brief Copy constructor.
   *
   * `CollectionReference` can be efficiently copied because it simply refers to
   * a location in the database.
   *
   * @param[in] other `CollectionReference` to copy from.
   */
  CollectionReference(const CollectionReference& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `CollectionReference`. After
   * being moved from, a `CollectionReference` is equivalent to its
   * default-constructed state.
   *
   * @param[in] other `CollectionReference` to move data from.
   */
  CollectionReference(CollectionReference&& other);

  /**
   * @brief Copy assignment operator.
   *
   * `CollectionReference` can be efficiently copied because it simply refers to
   * a location in the database.
   *
   * @param[in] other `CollectionReference` to copy from.
   *
   * @return Reference to the destination `CollectionReference`.
   */
  CollectionReference& operator=(const CollectionReference& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `CollectionReference`. After
   * being moved from, a `CollectionReference` is equivalent to its
   * default-constructed state.
   *
   * @param[in] other `CollectionReference` to move data from.
   *
   * @return Reference to the destination `CollectionReference`.
   */
  CollectionReference& operator=(CollectionReference&& other);

  /**
   * @brief Gets the ID of the referenced collection.
   *
   * @return The ID as a std::string.
   */
  virtual const std::string& id() const;

  /**
   * @brief Returns the path of this collection (relative to the root of the
   * database) as a slash-separated string.
   *
   * @return The path as a std::string.
   */
  virtual std::string path() const;

  /**
   * @brief Gets a DocumentReference to the document that contains this
   * collection.
   *
   * @return The DocumentReference that contains this collection if this is a
   * subcollection. If this is a root collection, returns an invalid
   * DocumentReference (`DocumentReference::is_valid()` will return false).
   */
  virtual DocumentReference Parent() const;

  /**
   * @brief Returns a DocumentReference that points to a new document with an
   * auto-generated ID within this collection.
   *
   * @return A DocumentReference pointing to the new document.
   */
  virtual DocumentReference Document() const;

  /**
   * @brief Gets a DocumentReference instance that refers to the document at the
   * specified path within this collection.
   *
   * @param[in] document_path A slash-separated relative path to a document.
   * The pointer only needs to be valid during this call.
   *
   * @return The DocumentReference instance.
   */
  virtual DocumentReference Document(const char* document_path) const;

  /**
   * @brief Gets a DocumentReference instance that refers to the document at the
   * specified path within this collection.
   *
   * @param[in] document_path A slash-separated relative path to a document.
   *
   * @return The DocumentReference instance.
   */
  virtual DocumentReference Document(const std::string& document_path) const;

  /**
   * @brief Adds a new document to this collection with the specified data,
   * assigning it a document ID automatically.
   *
   * @param data A map containing the data for the new document.
   *
   * @return A Future that will be resolved with the DocumentReference of the
   * newly created document.
   */
  virtual Future<DocumentReference> Add(const MapFieldValue& data);

 private:
  friend class DocumentReference;
  friend class DocumentReferenceInternal;
  friend class FirestoreInternal;
  friend struct ConverterImpl;

  explicit CollectionReference(CollectionReferenceInternal* internal);

  CollectionReferenceInternal* internal() const;
};

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_COLLECTION_REFERENCE_H_
