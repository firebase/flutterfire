/*
 * Copyright 2021 Google LLC
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
#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_LOAD_BUNDLE_TASK_PROGRESS_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_LOAD_BUNDLE_TASK_PROGRESS_H_

#include <stdint.h>

namespace firebase {
namespace firestore {

class LoadBundleTaskProgressInternal;

/** Represents a progress update or the final state from loading bundles. */
class LoadBundleTaskProgress {
 public:
  /**
   * Represents the state of bundle loading tasks.
   *
   * Both `kSuccess` and `kError` are final states: the task will abort
   * or complete and there will be no more updates after they are reported.
   */
  enum class State { kError, kInProgress, kSuccess };

  LoadBundleTaskProgress() = default;
  /** Construct a LoadBundleTaskProgress with specific state. **/
  LoadBundleTaskProgress(int32_t documents_loaded,
                         int32_t total_documents,
                         int64_t bytes_loaded,
                         int64_t total_bytes,
                         State state);

  /** Returns how many documents have been loaded. */
  int32_t documents_loaded() const { return documents_loaded_; }

  /**
   * Returns the total number of documents in the bundle. Returns 0 if the
   * bundle failed to parse.
   */
  int32_t total_documents() const { return total_documents_; }

  /** Returns how many bytes have been loaded. */
  int64_t bytes_loaded() const { return bytes_loaded_; }

  /**
   * Returns the total number of bytes in the bundle. Returns 0 if the bundle
   * failed to parse.
   */
  int64_t total_bytes() const { return total_bytes_; }

  /** Returns the current state of the loading progress. */
  State state() const { return state_; }

 private:
  friend class EventListenerInternal;
  friend class LoadBundleTaskProgressInternal;
  friend struct ConverterImpl;

#if defined(__ANDROID__)
  explicit LoadBundleTaskProgress(LoadBundleTaskProgressInternal* internal);
#endif  // defined(__ANDROID__)

  int32_t documents_loaded_ = 0;
  int32_t total_documents_ = 0;
  int64_t bytes_loaded_ = 0;
  int64_t total_bytes_ = 0;
  State state_ = State::kInProgress;
};

/** LoadBundleTaskProgress == comparison operator. **/
inline bool operator==(const LoadBundleTaskProgress& lhs,
                       const LoadBundleTaskProgress& rhs) {
  return lhs.state() == rhs.state() &&
         lhs.bytes_loaded() == rhs.bytes_loaded() &&
         lhs.documents_loaded() == rhs.documents_loaded() &&
         lhs.total_bytes() == rhs.total_bytes() &&
         lhs.total_documents() == rhs.total_documents();
}

/** LoadBundleTaskProgress != comparison operator. **/
inline bool operator!=(const LoadBundleTaskProgress& lhs,
                       const LoadBundleTaskProgress& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_LOAD_BUNDLE_TASK_PROGRESS_H_
