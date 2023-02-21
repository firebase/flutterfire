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

#ifndef FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_CONTROLLER_H_
#define FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_CONTROLLER_H_

#include "firebase/storage/storage_reference.h"

namespace firebase {
namespace storage {

/// @cond FIREBASE_APP_INTERNAL
namespace internal {
class ControllerInternal;
class ListenerInternal;
class RestOperation;
}  // namespace internal
/// @endcond

/// @brief Controls an ongoing operation, allowing the caller to Pause, Resume
/// or Cancel an ongoing download or upload.
///
/// An instance of Controller can be constructed and passed to
/// StorageReference::GetBytes(), StorageReference::GetFile(),
/// StorageReference::PutBytes(), or StorageReference::PutFile() to become
/// associated with it. Each Controller can only be associated with one
/// operation at a time.
///
/// A Controller is also passed as an argument to Listener's callbacks. The
/// Controller passed to a StorageReference operation is not the same object
/// passed to Listener callbacks (though it refers to the same operation), so
/// there are no restrictions on the lifetime of the Controller the user creates
/// (but the Controller passed into a Listener callbacks should only be used
/// from within that callback).
///
/// This class is currently not thread safe and can only be called on the main
/// thread.
class Controller {
 public:
  /// @brief Default constructor.
  ///
  /// You may construct your own Controller to pass into various
  /// StorageReference operations.
  Controller();

  /// @brief Destructor.
  ~Controller();

  /// @brief Copy constructor.
  ///
  /// @param[in] other Controller to copy from.
  Controller(const Controller& other);

  /// @brief Copy assignment operator.
  ///
  /// @param[in] other Controller to copy from.
  ///
  /// @returns Reference to the destination Controller.
  Controller& operator=(const Controller& other);

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
  /// @brief Move constructor. Moving is an efficient operation for
  /// Controller instances.
  ///
  /// @param[in] other Controller to move from.
  Controller(Controller&& other);

  /// @brief Move assignment operator. Moving is an efficient operation for
  /// Controller instances.
  ///
  /// @param[in] other Controller to move from.
  ///
  /// @returns Reference to the destination Controller.
  Controller& operator=(Controller&& other);
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// @brief Pauses the operation currently in progress.
  ///
  /// @returns True if the operation was successfully paused, false otherwise.
  bool Pause();

  /// @brief Resumes the operation that is paused.
  ///
  /// @returns True if the operation was successfully resumed, false otherwise.
  bool Resume();

  /// @brief Cancels the operation currently in progress.
  ///
  /// @returns True if the operation was successfully canceled, false otherwise.
  bool Cancel();

  /// @brief Returns true if the operation is paused.
  bool is_paused() const;

  /// @brief Returns the number of bytes transferred so far.
  ///
  /// @returns The number of bytes transferred so far.
  int64_t bytes_transferred() const;

  /// @brief Returns the total bytes to be transferred.
  ///
  /// @returns The total bytes to be transferred.  This will return -1 if
  /// the size of the transfer is unknown.
  int64_t total_byte_count() const;

  /// @brief Returns the StorageReference associated with this Controller.
  ///
  /// @returns The StorageReference associated with this Controller.
  StorageReference GetReference() const;

  /// @brief Returns true if this Controller is valid, false if it is not
  /// valid. An invalid Controller is one that is not associated with an
  /// operation.
  ///
  /// @returns true if this Controller is valid, false if this Controller is
  /// invalid.
  bool is_valid() const;

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class internal::StorageReferenceInternal;
  friend class internal::ControllerInternal;
  friend class internal::ListenerInternal;
  friend class internal::RestOperation;

  Controller(internal::ControllerInternal* internal);

  internal::ControllerInternal* internal_;
  /// @endcond
};

}  // namespace storage
}  // namespace firebase

#endif  // FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_CONTROLLER_H_
