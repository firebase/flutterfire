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

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_DISCONNECTION_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_DISCONNECTION_H_

#include "firebase/future.h"
#include "firebase/internal/common.h"
#include "firebase/variant.h"

namespace firebase {
namespace database {
namespace internal {
class DatabaseReferenceInternal;
class DisconnectionHandlerInternal;
}  // namespace internal

/// Allows you to register server-side actions to occur when the client
/// disconnects. Each method you call (with the exception of Cancel) will queue
/// up an action on the data that will be performed by the server in the event
/// the client disconnects. To reset this queue, call Cancel().
///
/// A DisconnectionHandler is associated with a specific location in the
/// database, as they are obtained by calling DatabaseReference::OnDisconnect().
class DisconnectionHandler {
 public:
  ~DisconnectionHandler();

  /// @brief Cancel any Disconnection operations that are queued up by this
  /// handler.  When the Future returns, if its Error is kErrorNone, the queue
  /// has been cleared on the server.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> Cancel();
  /// @brief Get the result of the most recent call to Cancel().
  ///
  /// @returns Result of the most recent call to Cancel().
  Future<void> CancelLastResult();

  /// @brief Remove the value at the current location when the client
  /// disconnects. When the Future returns, if its Error is kErrorNone, the
  /// RemoveValue operation has been successfully queued up on the server.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> RemoveValue();
  /// @brief Get the result of the most recent call to RemoveValue().
  ///
  /// @returns Result of the most recent call to RemoveValue().
  Future<void> RemoveValueLastResult();

  /// @brief Set the value of the data at the current location when the client
  /// disconnects. When the Future returns, if its Error is kErrorNone, the
  /// SetValue operation has been successfully queued up on the server.
  ///
  /// @param[in] value The value to set this location to when the client
  /// disconnects. For information on how the Variant types are used,
  /// see firebase::database::DatabaseReference::SetValue().
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> SetValue(Variant value);
  /// Get the result of the most recent call to SetValue().
  ///
  /// @returns Result of the most recent call to SetValue().
  Future<void> SetValueLastResult();

  /// @brief Set the value and priority of the data at the current location when
  /// the client disconnects. When the Future returns, if its Error is
  /// kErrorNone, the SetValue operation has been successfully queued up on the
  /// server.
  ///
  /// @param[in] value The value to set this location to when the client
  /// disconnects. For information on how the Variant types are used,
  /// see firebase::database::DatabaseReference::SetValue().
  /// @param[in] priority The priority to set this location to when the client
  /// disconnects. The Variant types accepted are Null, Int64, Double, and
  /// String. For information about how priority is used, see
  /// firebase::database::DatabaseReference::SetPriority().
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> SetValueAndPriority(Variant value, Variant priority);
  /// @brief Get the result of the most recent call to SetValueAndPriority().
  ///
  /// @returns Result of the most recent call to SetValueAndPriority().
  Future<void> SetValueAndPriorityLastResult();

  /// @brief Updates the specified child keys to the given values when the
  /// client disconnects. When the Future returns, if its Error is kErrorNone,
  /// the UpdateChildren operation has been successfully queued up by the
  /// server.
  ///
  /// @param[in] values A variant of type Map. The keys are the paths to update
  /// and must be of type String (or Int64/Double which are converted to
  /// String). The values can be any Variant type. A value of Variant type Null
  /// will delete the child.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> UpdateChildren(Variant values);
  /// @brief Updates the specified child keys to the given values when the
  /// client disconnects. When the Future returns, if its Error is kErrorNone,
  /// the UpdateChildren operation has been successfully queued up by the
  /// server.
  ///
  /// @param[in] values The paths to update, and their new child values. A value
  /// of type Null will delete that particular child.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> UpdateChildren(const std::map<std::string, Variant>& values) {
    return UpdateChildren(Variant(values));
  }
  /// @brief Gets the result of the most recent call to either version of
  /// UpdateChildren().
  ///
  /// @returns Result of the most recent call to UpdateChildren().
  Future<void> UpdateChildrenLastResult();

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class internal::DatabaseReferenceInternal;
  friend class internal::DisconnectionHandlerInternal;
  /// @endcond

  /// Call DatabaseReference::OnDisconnect() to get an instance of this class.
  explicit DisconnectionHandler(
      internal::DisconnectionHandlerInternal* internal);

  /// You can only get the DisconnectHandler for a given reference.
  internal::DisconnectionHandlerInternal* internal_;
};

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_DISCONNECTION_H_
