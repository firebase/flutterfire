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

#ifndef FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_H_
#define FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_H_

#include "firebase/app.h"
#include "firebase/database/common.h"
#include "firebase/database/data_snapshot.h"
#include "firebase/database/database_reference.h"
#include "firebase/database/disconnection.h"
#include "firebase/database/listener.h"
#include "firebase/database/mutable_data.h"
#include "firebase/database/query.h"
#include "firebase/database/transaction.h"
#include "firebase/internal/common.h"
#include "firebase/log.h"

namespace firebase {

/// Namespace for the Firebase Realtime Database C++ SDK.
namespace database {

namespace internal {
class DatabaseInternal;
}  // namespace internal

class DatabaseReference;

#ifndef SWIG
/// @brief Entry point for the Firebase Realtime Database C++ SDK.
///
/// To use the SDK, call firebase::database::Database::GetInstance() to obtain
/// an instance of Database, then use GetReference() to obtain references to
/// child paths within the database. From there you can set data via
/// Query::SetValue(), get data via Query::GetValue(), attach listeners, and
/// more.
#endif  // SWIG
class Database {
 public:
  /// @brief Get an instance of Database corresponding to the given App.
  ///
  /// Firebase Realtime Database uses firebase::App to communicate with Firebase
  /// Authentication to authenticate users to the Database server backend.
  ///
  /// If you call GetInstance() multiple times with the same App, you will get
  /// the same instance of Database.
  ///
  /// @param[in] app Your instance of firebase::App. Firebase Realtime Database
  /// will use this to communicate with Firebase Authentication.
  /// @param[out] init_result_out Optional: If provided, write the init result
  /// here. Will be set to kInitResultSuccess if initialization succeeded, or
  /// kInitResultFailedMissingDependency on Android if Google Play services is
  /// not available on the current device.
  ///
  /// @returns An instance of Database corresponding to the given App.
  static Database* GetInstance(::firebase::App* app,
                               InitResult* init_result_out = nullptr);

  /// @brief Gets an instance of FirebaseDatabase for the specified URL.
  ///
  /// If you call GetInstance() multiple times with the same App and URL, you
  /// will get the same instance of Database.
  ///
  /// @param[in] app Your instance of firebase::App. Firebase Realtime Database
  /// will use this to communicate with Firebase Authentication.
  /// @param[in] url The URL of your Firebase Realtime Database. This overrides
  /// any url specified in the App options.
  /// @param[out] init_result_out Optional: If provided, write the init result
  /// here. Will be set to kInitResultSuccess if initialization succeeded, or
  /// kInitResultFailedMissingDependency on Android if Google Play services is
  /// not available on the current device.
  ///
  /// @returns An instance of Database corresponding to the given App and URL.
  static Database* GetInstance(::firebase::App* app, const char* url,
                               InitResult* init_result_out = nullptr);

  /// @brief Destructor for the Database object.
  ///
  /// When deleted, this instance will be removed from the cache of Database
  /// objects. If you call GetInstance() in the future with the same App, a new
  /// Database instance will be created.
  ~Database();

  /// @brief Get the firebase::App that this Database was created with.
  ///
  /// @returns The firebase::App this Database was created with.
  App* app() const;

  /// @brief Get the URL that this Database was created with.
  ///
  /// @returns The URL this Database was created with, or an empty string if
  /// this Database was created with default parameters. This string will remain
  /// valid in memory for the lifetime of this Database.
  const char* url() const;

  /// @brief Get a DatabaseReference to the root of the database.
  ///
  /// @returns A DatabaseReference to the root of the database.
  DatabaseReference GetReference() const;
  /// @brief Get a DatabaseReference for the specified path.
  ///
  /// @returns A DatabaseReference to the specified path in the database.
  /// If you specified an invalid path, the reference's
  /// DatabaseReference::IsValid() will return false.
  DatabaseReference GetReference(const char* path) const;
  /// @brief Get a DatabaseReference for the provided URL, which must belong to
  /// the database URL this instance is already connected to.
  ///
  /// @returns A DatabaseReference to the specified path in the database.
  /// If you specified an invalid path, the reference's
  /// DatabaseReference::IsValid() will return false.
  DatabaseReference GetReferenceFromUrl(const char* url) const;

  /// @brief Shuts down the connection to the Firebase Realtime Database
  /// backend until GoOnline() is called.
  void GoOffline();

  /// @brief Resumes the connection to the Firebase Realtime Database backend
  /// after a previous GoOffline() call.
  void GoOnline();

  /// @brief Purge all pending writes to the Firebase Realtime Database server.
  ///
  /// The Firebase Realtime Database client automatically queues writes and
  /// sends them to the server at the earliest opportunity, depending on network
  /// connectivity. In some cases (e.g. offline usage) there may be a large
  /// number of writes waiting to be sent. Calling this method will purge all
  /// outstanding writes so they are abandoned. All writes will be purged,
  /// including transactions and onDisconnect() writes. The writes will be
  /// rolled back locally, perhaps triggering events for affected event
  /// listeners, and the client will not (re-)send them to the Firebase backend.
  void PurgeOutstandingWrites();

  /// @brief Sets whether pending write data will persist between application
  /// exits.
  ///
  /// The Firebase Database client will cache synchronized data and keep track
  /// of all writes you've initiated while your application is running. It
  /// seamlessly handles intermittent network connections and re-sends write
  /// operations when the network connection is restored. However by default
  /// your write operations and cached data are only stored in-memory and will
  /// be lost when your app restarts. By setting this value to `true`, the data
  /// will be persisted to on-device (disk) storage and will thus be available
  /// again when the app is restarted (even when there is no network
  /// connectivity at that time).
  ///
  /// @note SetPersistenceEnabled should be called before creating any instances
  /// of DatabaseReference, and only needs to be called once per application.
  ///
  /// @param[in] enabled Set this to true to persist write data to on-device
  /// (disk) storage, or false to discard pending writes when the app exists.
  void set_persistence_enabled(bool enabled);

  /// Set the log verbosity of this Database instance.
  ///
  /// The log filtering is cumulative with Firebase App. That is, this library's
  /// log messages will only be displayed if they are not filtered out by this
  /// library's log level setting and by Firebase App's log level setting.
  ///
  /// @note On Android this can only be set before any operations have been
  /// performed with the object.
  ///
  /// @param[in] log_level Log level, by default this is set to kLogLevelInfo.
  void set_log_level(LogLevel log_level);

  /// Get the log verbosity of this Database instance.
  ///
  /// @return Get the currently configured logging verbosity.
  LogLevel log_level() const;

 private:
  friend Database* GetDatabaseInstance(::firebase::App* app, const char* url,
                                       InitResult* init_result_out);
  Database(::firebase::App* app, internal::DatabaseInternal* internal);
  Database(const Database& src);
  Database& operator=(const Database& src);

  // Delete the internal_ data.
  void DeleteInternal();

  internal::DatabaseInternal* internal_;
};

}  // namespace database
}  // namespace firebase

#endif  // FIREBASE_DATABASE_SRC_INCLUDE_FIREBASE_DATABASE_H_
