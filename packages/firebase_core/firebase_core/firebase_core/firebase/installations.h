// Copyright 2020 Google LLC
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

#ifndef FIREBASE_INSTALLATIONS_SRC_INCLUDE_FIREBASE_INSTALLATIONS_H_
#define FIREBASE_INSTALLATIONS_SRC_INCLUDE_FIREBASE_INSTALLATIONS_H_

#include <cstdint>
#include <string>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"

/// @brief Namespace that encompasses all Firebase APIs.
namespace firebase {

namespace installations {

/// Installations error codes.
enum Error {
  kErrorNone = 0,
  /// An unknown error occurred.
  kErrorUnknown,
  /// Installations service cannot be accessed.
  kErrorNoAccess,
  /// Some of the parameters of the request were invalid.
  kErrorInvalidConfiguration,
};

namespace internal {
// Implementation specific data for an Installation.
class InstallationsInternal;
}  // namespace internal

/// @brief Installations provides a unique identifier for each app instance and
/// a mechanism to authenticate and authorize actions (for example, sending an
/// FCM message).
///
/// Provides a unique identifier for a Firebase installation.
/// Provides an auth token for a Firebase installation.
/// Provides a API to perform data deletion for a Firebase
/// installation.
class Installations {
 public:
  ~Installations();

  /// @brief Get the App this object is connected to.
  ///
  /// @return App this object is connected to.
  App* app() const { return app_; }

  /// @brief Returns the Installations object for an App creating the
  /// Installations if required.
  ///
  /// @param[in] app The App to create an Installations object from.
  ///
  /// @return Installations object if successful, nullptr otherwise.
  static Installations* GetInstance(App* app);

  /// @brief Returns a stable identifier that uniquely identifies the app
  /// installation.
  ///
  /// @return Unique identifier for the app installation.
  Future<std::string> GetId();

  /// @brief Get the results of the most recent call to @ref GetId.
  Future<std::string> GetIdLastResult();

  /// @brief Call to delete this Firebase app installation from the Firebase
  /// backend.
  Future<void> Delete();

  /// @brief Get the results of the most recent call to @ref Delete.
  Future<void> DeleteLastResult();

  /// @brief Returns a token that authorizes an Entity to perform an action on
  /// behalf of the application identified by installations.
  ///
  /// This is similar to an OAuth2 token except it applies to the
  /// application instance instead of a user.
  ///
  /// For example, to get a token that can be used to send messages to an
  /// application via Firebase Cloud Messaging, set entity to the
  /// sender ID, and set scope to "FCM".
  ///
  /// @param forceRefresh If set true, will always return a new token.
  ///
  /// @return Returns a valid authentication token for the Firebase
  /// installation.
  Future<std::string> GetToken(bool forceRefresh);

  /// @brief Get the results of the most recent call to @ref GetToken.
  Future<std::string> GetTokenLastResult();

 private:
  explicit Installations(App* app);

  static Installations* FindInstallations(App* app);
  // Installations internal initialize.
  bool InitInternal();
  // Clean up Installations instance.
  void DeleteInternal();

  App* app_;
  internal::InstallationsInternal* installations_internal_;
};

}  // namespace installations

}  // namespace firebase

#endif  // FIREBASE_INSTALLATIONS_SRC_INCLUDE_FIREBASE_INSTALLATIONS_H_
