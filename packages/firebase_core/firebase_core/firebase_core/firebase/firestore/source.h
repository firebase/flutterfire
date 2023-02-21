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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SOURCE_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SOURCE_H_

namespace firebase {
namespace firestore {

/**
 * @brief Configures the behavior of DocumentReference::Get() and Query::Get().
 *
 * By providing a Source value, these methods can be configured to fetch results
 * only from the server, only from the local cache, or attempt to fetch results
 * from the server and fall back to the cache (which is the default).
 */
enum class Source {
  /**
   * Causes Firestore to try to retrieve an up-to-date (server-retrieved)
   * snapshot, but fall back to returning cached data if the server can't be
   * reached.
   */
  kDefault,

  /**
   * Causes Firestore to avoid the cache, generating an error if the server
   * cannot be reached. Note that the cache will still be updated if the server
   * request succeeds. Also note that latency-compensation still takes effect,
   * so any pending write operations will be visible in the returned data
   * (merged into the server-provided data).
   */
  kServer,

  /**
   * Causes Firestore to immediately return a value from the cache, ignoring the
   * server completely (implying that the returned value may be stale with
   * respect to the value on the server). If there is no data in the cache to
   * satisfy the DocumentReference::Get() call will return an error and
   * Query::Get() will return an empty QuerySnapshot with no documents.
   */
  kCache,
};

}  // namespace firestore
}  // namespace firebase
#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SOURCE_H_
