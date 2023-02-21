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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_LISTENER_REGISTRATION_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_LISTENER_REGISTRATION_H_

namespace firebase {
namespace firestore {

class FirestoreInternal;
class ListenerRegistrationInternal;

/** Represents a listener that can be removed by calling Remove(). */
class ListenerRegistration {
 public:
  /**
   * @brief Creates an invalid ListenerRegistration that has to be reassigned
   * before it can be used.
   *
   * Calling Remove() on an invalid ListenerRegistration is a no-op.
   */
  ListenerRegistration();

  /**
   * @brief Copy constructor.
   *
   * `ListenerRegistration` can be efficiently copied because it simply refers
   * to the same underlying listener. If there is more than one copy of
   * a `ListenerRegistration`, after calling `Remove` on one of them, the
   * listener is removed, and calling `Remove` on any other copies will be
   * a no-op.
   *
   * @param[in] other `ListenerRegistration` to copy from.
   */
  ListenerRegistration(const ListenerRegistration& other);

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for a `ListenerRegistration`. After
   * being moved from, a `ListenerRegistration` is equivalent to its
   * default-constructed state.
   *
   * @param[in] other `ListenerRegistration` to move data from.
   */
  ListenerRegistration(ListenerRegistration&& other);

  virtual ~ListenerRegistration();

  /**
   * @brief Copy assignment operator.
   *
   * `ListenerRegistration` can be efficiently copied because it simply refers
   * to the same underlying listener. If there is more than one copy of
   * a `ListenerRegistration`, after calling `Remove` on one of them, the
   * listener is removed, and calling `Remove` on any other copies will be
   * a no-op.
   *
   * @param[in] other `ListenerRegistration` to copy from.
   *
   * @return Reference to the destination `ListenerRegistration`.
   */
  ListenerRegistration& operator=(const ListenerRegistration& other);

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for a `ListenerRegistration`. After
   * being moved from, a `ListenerRegistration` is equivalent to its
   * default-constructed state.
   *
   * @param[in] other `ListenerRegistration` to move data from.
   *
   * @return Reference to the destination `ListenerRegistration`.
   */
  ListenerRegistration& operator=(ListenerRegistration&& other);

  /**
   * Removes the listener being tracked by this ListenerRegistration. After the
   * initial call, subsequent calls have no effect.
   */
  virtual void Remove();

  /**
   * @brief Returns true if this `ListenerRegistration` is valid, false if it is
   * not valid. An invalid `ListenerRegistration` could be the result of:
   *   - Creating a `ListenerRegistration` using the default constructor.
   *   - Moving from the `ListenerRegistration`.
   *   - Deleting your Firestore instance, which will invalidate all the
   *     `ListenerRegistration` instances associated with it.
   *
   * @return true if this `ListenerRegistration` is valid, false if this
   * `ListenerRegistration` is invalid.
   */
  bool is_valid() const { return internal_ != nullptr; }

 private:
  friend class DocumentReferenceInternal;
  friend class FirestoreInternal;
  friend class ListenerRegistrationInternal;
  friend class QueryInternal;
  friend struct ConverterImpl;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  explicit ListenerRegistration(ListenerRegistrationInternal* internal);

  void Cleanup();

  FirestoreInternal* firestore_ = nullptr;
  mutable ListenerRegistrationInternal* internal_ = nullptr;
};

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_LISTENER_REGISTRATION_H_
