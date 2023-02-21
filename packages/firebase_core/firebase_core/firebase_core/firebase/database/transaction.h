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

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_TRANSACTION_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_TRANSACTION_H_

#include "firebase/database/common.h"
#include "firebase/database/data_snapshot.h"
#include "firebase/database/mutable_data.h"
#include "firebase/internal/common.h"
#include "firebase/variant.h"

#if defined(FIREBASE_USE_STD_FUNCTION)
#include <functional>
#endif  // defined(FIREBASE_USE_STD_FUNCTION)

namespace firebase {
namespace database {

/// Specifies whether the transaction succeeded or not.
enum TransactionResult {
  /// The transaction was successful, the MutableData was updated.
  kTransactionResultSuccess,
  /// The transaction did not succeed. Any changes to the MutableData
  /// will be discarded.
  kTransactionResultAbort,
};

/// Your own transaction handler, which the Firebase Realtime Database library
/// may call multiple times to apply changes to the data, and should return
/// success or failure depending on whether it succeeds.

/// @note This version of the callback is no longer supported (unless you are
/// building for Android with stlport). You should use either one of
/// DoTransactionWithContext (a simple function pointer that accepts context
/// data) or DoTransactionFunction (based on std::function).
///
/// @see DoTransactionWithContext for more information.
typedef TransactionResult (*DoTransaction)(MutableData* data);

/// Your own transaction handler, which the Firebase Realtime Database library
/// may call multiple times to apply changes to the data, and should return
/// success or failure depending on whether it succeeds. The context you
/// specified to RunTransaction will be passed into this call.
///
/// This function will be called, _possibly multiple times_, with the current
/// data at this location. The function is responsible for inspecting that data
/// and modifying it as desired, then returning a TransactionResult specifying
/// either that the MutableData was modified to a desired new state, or that the
/// transaction should be aborted. Whenever this function is called, the
/// MutableData passed in must be modified from scratch.
///
/// Since this function may be called repeatedly for the same transaction, be
/// extremely careful of any side effects that may be triggered by this
/// function. In addition, this function is called from within the Firebase
/// Realtime Database library's run loop, so care is also required when
/// accessing data that may be in use by other threads in your application.
///
/// Best practices for this function are to ONLY rely on the data passed in.
///
/// @param[in] data Mutable data, which the callback can edit.
/// @param[in] context Context pointer, passed verbatim to the callback.
///
/// @returns The callback should return kTransactionResultSuccess if the data
/// was modified, or kTransactionResultAbort if it was unable to modify the
/// data. If the callback returns kTransactionResultAbort, the RunTransaction()
/// call will return the kErrorTransactionAbortedByUser error code.
///
/// @note If you want a callback to be triggered when the transaction is
/// finished, you can use the Future<DataSnapshot> value returned by the method
/// running the transaction, and call Future::OnCompletion() to register a
/// callback to be called when the transaction either succeeds or fails.
///
/// @see DoTransaction for more information.
typedef TransactionResult (*DoTransactionWithContext)(MutableData* data,
                                                      void* context);

#if defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)
/// Your own transaction handler function or lambda, which the Firebase Realtime
/// Database library may call multiple times to apply changes to the data, and
/// should return success or failure depending on whether it succeeds.
///
/// @see DoTransactionWithContext for more information.
typedef std::function<TransactionResult(MutableData* data)>
    DoTransactionFunction;
#endif  // defined(FIREBASE_USE_STD_FUNCTION) || defined(DOXYGEN)

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_TRANSACTION_H_
