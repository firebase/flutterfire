/*
 * Copyright 2016 Google LLC
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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_MUTEX_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_MUTEX_H_

#include "firebase/internal/platform.h"

#if FIREBASE_PLATFORM_WINDOWS
#include <windows.h>
#else
#include <pthread.h>
#endif  // FIREBASE_PLATFORM_WINDOWS

namespace firebase {

#if !defined(DOXYGEN)

/// @brief A simple synchronization lock. Only one thread at a time can Acquire.
class Mutex {
 public:
  // Bitfield that describes the mutex configuration.
  enum Mode {
    kModeNonRecursive = (0 << 0),
    kModeRecursive = (1 << 0),
  };

  Mutex() : Mutex(kModeRecursive) {}

  explicit Mutex(Mode mode);

  ~Mutex();

  // Acquires the lock for this mutex, blocking until it is available.
  void Acquire();

  // Releases the lock for this mutex acquired by a previous `Acquire()` call.
  void Release();

// Returns the implementation-defined native mutex handle.
// Used by firebase::Thread implementation.
#if FIREBASE_PLATFORM_WINDOWS
  HANDLE* native_handle() { return &synchronization_object_; }
#else
  pthread_mutex_t* native_handle() { return &mutex_; }
#endif  // FIREBASE_PLATFORM_WINDOWS

 private:
  Mutex(const Mutex&) = delete;
  Mutex& operator=(const Mutex&) = delete;

#if FIREBASE_PLATFORM_WINDOWS
  HANDLE synchronization_object_;
  Mode mode_;
#else
  pthread_mutex_t mutex_;
#endif  // FIREBASE_PLATFORM_WINDOWS
};

/// @brief Acquire and hold a /ref Mutex, while in scope.
///
/// Example usage:
///   \code{.cpp}
///   Mutex syncronization_mutex;
///   void MyFunctionThatRequiresSynchronization() {
///     MutexLock lock(syncronization_mutex);
///     // ... logic ...
///   }
///   \endcode
class MutexLock {
 public:
  explicit MutexLock(Mutex& mutex) : mutex_(&mutex) { mutex_->Acquire(); }
  ~MutexLock() { mutex_->Release(); }

 private:
  // Copy is disallowed.
  MutexLock(const MutexLock& rhs);  // NOLINT
  MutexLock& operator=(const MutexLock& rhs);

  Mutex* mutex_;
};

#endif  // !defined(DOXYGEN)

}  // namespace firebase

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_MUTEX_H_
