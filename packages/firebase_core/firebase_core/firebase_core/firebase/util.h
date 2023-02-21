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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_UTIL_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_UTIL_H_

#include "firebase/app.h"
#include "firebase/future.h"

namespace firebase {

struct ModuleInitializerData;

/// @brief Utility class to help with initializing Firebase modules.
///
/// This optional class handles a basic Firebase C++ SDK code pattern: attempt
/// to initialize a Firebase module, and if the initialization fails on Android
/// due to Google Play services being unavailable, prompt the user to
/// update/enable Google Play services on their device.
///
/// If the developer wants more advanced behavior (for example, wait to prompt
/// the user to update or enable Google Play services until later, or opt not to
/// use Firebase modules), they can still initialize each Firebase module
/// individually, and use google_play_services::MakeAvailable() directly if any
/// initializations fail.
class ModuleInitializer {
 public:
  /// @brief Initialization function, which should initialize a single Firebase
  /// module and return the InitResult.
  typedef InitResult (*InitializerFn)(App* app, void* context);

  ModuleInitializer();
  virtual ~ModuleInitializer();

  /// @brief Initialize Firebase modules by calling one or more user-supplied
  /// functions, each of which must initialize at most one library, and should
  /// return the InitResult of the initialization.
  ///
  /// This function will run the initializers in order, checking the return
  /// value of each. On Android, if the InitResult returned is
  /// kInitResultFailedMissingDependency, this indicates that Google Play
  /// services is not available and a Firebase module requires it. This function
  /// will attempt to fix Google Play services, and will retry initializations
  /// where it left off, beginning with the one that failed.
  ///
  /// @returns A future result. When all of the initializers are completed, the
  /// Future will be completed with Error() = 0. If an initializer fails and the
  /// situation cannot be fixed, the Future will be completed with Error() equal
  /// to the number of initializers that did not succeed (since they are run in
  /// order, this tells you which ones failed).
  ///
  /// @param[in] app The firebase::App that will be passed to the initializers,
  /// as well as used to fix Google Play services on Android if needed.
  ///
  /// @param[in] context User-defined context, which will be passed to the
  /// initializer functions. If you don't need this, you can use nullptr.
  ///
  /// @param[in] init_fns Your initialization functions to call, in an array. At
  /// their simplest, these will each simply call a single Firebase module's
  /// Initialize(app) and return the result, but you can perform more complex
  /// logic if you prefer.
  ///
  /// @param[in] init_fns_count Number of initialization functions in the
  /// supplied array.
  ///
  /// @note If a pending Initialize() is already running, this function will
  /// return the existing Future rather than adding any new functions to the
  /// initializer list.
  Future<void> Initialize(App* app, void* context,
                          const InitializerFn* init_fns, size_t init_fns_count);

  /// @brief Initialize one Firebase module by calling a single user-supplied
  /// function that should initialize a Firebase module and return the
  /// InitResult. @see Initialize(::firebase::App*, void*, const InitializerFn*)
  /// for more information.
  Future<void> Initialize(App* app, void* context, InitializerFn init_fn);

  /// @brief Get the result of the most recent call to @see Initialize().
  Future<void> InitializeLastResult();

 private:
  ModuleInitializerData* data_;
};

// NOLINTNEXTLINE - allow namespace overridden
}  // namespace firebase

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_UTIL_H_
