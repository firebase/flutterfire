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

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_LISTENER_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_LISTENER_H_

#include "firebase/database/common.h"

namespace firebase {
namespace database {

class DataSnapshot;

/// Value listener interface. Subclasses of this listener class can be
/// used to receive events about data changes at a location. Attach
/// the listener to a location using
/// DatabaseReference::AddValueListener() or
/// Query::AddValueListener(), and OnValueChanged() will be called
/// once immediately, and again when the value changes.
class ValueListener {
 public:
  virtual ~ValueListener();

  /// This method will be called with a snapshot of the data at this
  /// location each time that data changes.
  ///
  /// @param[in] snapshot The current data at the location.
  virtual void OnValueChanged(const DataSnapshot& snapshot) = 0;

  /// @brief This method will be triggered in the event that this listener
  /// either failed at the server, or is removed as a result of the security and
  /// Firebase rules.
  ///
  /// @param[in] error A code corresponding to the error that occurred.
  /// @param[in] error_message A description of the error that occurred.
  virtual void OnCancelled(const Error& error, const char* error_message) = 0;
};

/// Child listener interface. Subclasses of this listener class can be
/// used to receive events about changes in the child locations of a
/// firebase::database::Query or
/// firebase::database::DatabaseReference. Attach the listener to a
/// location with Query::AddChildListener() or
/// DatabaseReference::AddChildListener() and the appropriate method
/// will be triggered when changes occur.
class ChildListener {
 public:
  virtual ~ChildListener();

  /// @brief This method is triggered when a new child is added to the location
  /// to which this listener was added.
  ///
  /// @param[in] snapshot An immutable snapshot of the data at the new data at
  /// the child location.
  /// @param[in] previous_sibling_key The key name of sibling location ordered
  /// before the child. This will be nullptr for the first child node of a
  /// location.
  virtual void OnChildAdded(const DataSnapshot& snapshot,
                            const char* previous_sibling_key) = 0;
  /// @brief This method is triggered when the data at a child location has
  /// changed.
  ///
  /// @param[in] snapshot An immutable snapshot of the data at the new data at
  /// the child location.
  /// @param[in] previous_sibling_key The key name of sibling location ordered
  /// before the child. This will be nullptr for the first child node of a
  /// location.
  virtual void OnChildChanged(const DataSnapshot& snapshot,
                              const char* previous_sibling_key) = 0;
  /// @brief This method is triggered when a child location's priority changes.
  /// See DatabaseReference::SetPriority() for more information on priorities
  /// and
  /// ordering data.
  ///
  /// @param[in] snapshot An immutable snapshot of the data at the new data at
  /// the child location.
  /// @param[in] previous_sibling_key The key name of sibling location ordered
  /// before the child. This will be nullptr for the first child node of a
  /// location.
  virtual void OnChildMoved(const DataSnapshot& snapshot,
                            const char* previous_sibling_key) = 0;
  /// @brief This method is triggered when a child is removed from the location
  /// to which this listener was added.
  ///
  /// @param[in] snapshot An immutable snapshot of the data at the new data at
  /// the child location.
  virtual void OnChildRemoved(const DataSnapshot& snapshot) = 0;

  /// @brief This method will be triggered in the event that this listener
  /// either failed at the server, or is removed as a result of the security and
  /// Firebase rules.
  ///
  /// @param[in] error A code corresponding to the error that occurred.
  /// @param[in] error_message A description of the error that occurred.
  virtual void OnCancelled(const Error& error, const char* error_message) = 0;
};

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_LISTENER_H_
