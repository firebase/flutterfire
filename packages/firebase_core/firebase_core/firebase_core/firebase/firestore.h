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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_H_

#include <functional>
#include <string>

#include "firebase/internal/common.h"

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/log.h"
// Include *all* the public headers to make sure including just "firestore.h" is
// sufficient for users.
#include "firebase/firestore/collection_reference.h"
#include "firebase/firestore/document_change.h"
#include "firebase/firestore/document_reference.h"
#include "firebase/firestore/document_snapshot.h"
#include "firebase/firestore/field_path.h"
#include "firebase/firestore/field_value.h"
#include "firebase/firestore/firestore_errors.h"
#include "firebase/firestore/geo_point.h"
#include "firebase/firestore/listener_registration.h"
#include "firebase/firestore/load_bundle_task_progress.h"
#include "firebase/firestore/map_field_value.h"
#include "firebase/firestore/metadata_changes.h"
#include "firebase/firestore/query.h"
#include "firebase/firestore/query_snapshot.h"
#include "firebase/firestore/set_options.h"
#include "firebase/firestore/settings.h"
#include "firebase/firestore/snapshot_metadata.h"
#include "firebase/firestore/source.h"
#include "firebase/firestore/timestamp.h"
#include "firebase/firestore/transaction.h"
#include "firebase/firestore/transaction_options.h"
#include "firebase/firestore/write_batch.h"

namespace firebase {
/**
 * @brief Cloud Firestore API.
 *
 * Cloud Firestore is a flexible, scalable database for mobile, web, and server
 * development from Firebase and Google Cloud Platform.
 */
namespace firestore {

class FirestoreInternal;

namespace csharp {

class ApiHeaders;
class TransactionManager;

}  // namespace csharp

/**
 * @brief Entry point for the Firebase Firestore C++ SDK.
 *
 * To use the SDK, call firebase::firestore::Firestore::GetInstance() to obtain
 * an instance of Firestore, then use Collection() or Document() to obtain
 * references to child paths within the database. From there, you can set data
 * via CollectionReference::Add() and DocumentReference::Set(), or get data via
 * CollectionReference::Get() and DocumentReference::Get(), attach listeners,
 * and more.
 *
 * @note Firestore classes are not meant to be subclassed except for use in test
 * mocks. Subclassing is not supported in production code and new SDK releases
 * may break code that does so.
 */
class Firestore {
 public:
  /**
   * @brief Returns an instance of Firestore corresponding to the given App.
   *
   * Firebase Firestore uses firebase::App to communicate with Firebase
   * Authentication to authenticate users to the Firestore server backend.
   *
   * If you call GetInstance() multiple times with the same App, you will get
   * the same instance of Firestore.
   *
   * @param[in] app Your instance of firebase::App. Firebase Firestore will use
   * this to communicate with Firebase Authentication.
   * @param[out] init_result_out If provided, the initialization result will be
   * written here. Will be set to firebase::kInitResultSuccess if initialization
   * succeeded, or firebase::kInitResultFailedMissingDependency on Android if
   * Google Play services is not available on the current device.
   *
   * @return An instance of Firestore corresponding to the given App.
   */
  static Firestore* GetInstance(::firebase::App* app,
                                InitResult* init_result_out = nullptr);

  /**
   * @brief Returns an instance of Firestore corresponding to the default App.
   *
   * Firebase Firestore uses the default App to communicate with Firebase
   * Authentication to authenticate users to the Firestore server backend.
   *
   * If you call GetInstance() multiple times, you will get the same instance.
   *
   * @param[out] init_result_out If provided, the initialization result will be
   * written here. Will be set to firebase::kInitResultSuccess if initialization
   * succeeded, or firebase::kInitResultFailedMissingDependency on Android if
   * Google Play services is not available on the current device.
   *
   * @return An instance of Firestore corresponding to the default App.
   */
  static Firestore* GetInstance(InitResult* init_result_out = nullptr);

  /**
   * @brief Destructor for the Firestore object.
   *
   * When deleted, this instance will be removed from the cache of Firestore
   * objects. If you call GetInstance() in the future with the same App, a new
   * Firestore instance will be created.
   */
  virtual ~Firestore();

  /**
   * Deleted copy constructor; Firestore must be created with
   * Firestore::GetInstance().
   */
  Firestore(const Firestore& src) = delete;

  /**
   * Deleted copy assignment operator; Firestore must be created with
   * Firestore::GetInstance().
   */
  Firestore& operator=(const Firestore& src) = delete;

  /**
   * @brief Returns the firebase::App that this Firestore was created with.
   *
   * @return The firebase::App this Firestore was created with.
   */
  virtual const App* app() const;

  /**
   * @brief Returns the firebase::App that this Firestore was created with.
   *
   * @return The firebase::App this Firestore was created with.
   */
  virtual App* app();

  /**
   * @brief Returns a CollectionReference instance that refers to the
   * collection at the specified path within the database.
   *
   * @param[in] collection_path A slash-separated path to a collection.
   *
   * @return The CollectionReference instance.
   */
  virtual CollectionReference Collection(const char* collection_path) const;

  /**
   * @brief Returns a CollectionReference instance that refers to the
   * collection at the specified path within the database.
   *
   * @param[in] collection_path A slash-separated path to a collection.
   *
   * @return The CollectionReference instance.
   */
  virtual CollectionReference Collection(
      const std::string& collection_path) const;

  /**
   * @brief Returns a DocumentReference instance that refers to the document at
   * the specified path within the database.
   *
   * @param[in] document_path A slash-separated path to a document.
   * @return The DocumentReference instance.
   */
  virtual DocumentReference Document(const char* document_path) const;

  /**
   * @brief Returns a DocumentReference instance that refers to the document at
   * the specified path within the database.
   *
   * @param[in] document_path A slash-separated path to a document.
   *
   * @return The DocumentReference instance.
   */
  virtual DocumentReference Document(const std::string& document_path) const;

  /**
   * @brief Returns a Query instance that includes all documents in the
   * database that are contained in a collection or subcollection with the
   * given collection_id.
   *
   * @param[in] collection_id Identifies the collections to query over. Every
   * collection or subcollection with this ID as the last segment of its path
   * will be included. Cannot contain a slash.
   *
   * @return The Query instance.
   */
  virtual Query CollectionGroup(const char* collection_id) const;

  /**
   * @brief Returns a Query instance that includes all documents in the
   * database that are contained in a collection or subcollection with the
   * given collection_id.
   *
   * @param[in] collection_id Identifies the collections to query over. Every
   * collection or subcollection with this ID as the last segment of its path
   * will be included. Cannot contain a slash.
   *
   * @return The Query instance.
   */
  virtual Query CollectionGroup(const std::string& collection_id) const;

  /** Returns the settings used by this Firestore object. */
  virtual Settings settings() const;

  /** Sets any custom settings used to configure this Firestore object. */
  virtual void set_settings(Settings settings);

  /**
   * Creates a write batch, used for performing multiple writes as a single
   * atomic operation.
   *
   * Unlike transactions, write batches are persisted offline and therefore are
   * preferable when you don't need to condition your writes on read data.
   *
   * @return The created WriteBatch object.
   */
  virtual WriteBatch batch() const;

  /**
   * Executes the given update and then attempts to commit the changes applied
   * within the transaction. If any document read within the transaction has
   * changed, the update function will be retried. If it fails to commit after
   * 5 attempts, the transaction will fail.
   *
   * @param update function or lambda to execute within the transaction context.
   * The string reference parameter can be used to set the error message.
   *
   * @return A Future that will be resolved when the transaction finishes.
   */
  virtual Future<void> RunTransaction(
      std::function<Error(Transaction&, std::string&)> update);

  /**
   * Executes the given update and then attempts to commit the changes applied
   * within the transaction. If any document read within the transaction has
   * changed, the update function will be retried. If it fails to commit after
   * the `max_attempts` specified in the given `TransactionOptions`, the
   * transaction will fail.
   *
   * @param options The transaction options for controlling execution.
   * @param update function or lambda to execute within the transaction context.
   * The string reference parameter can be used to set the error message.
   *
   * @return A Future that will be resolved when the transaction finishes.
   */
  virtual Future<void> RunTransaction(
      TransactionOptions options,
      std::function<Error(Transaction&, std::string&)> update);

  /**
   * Sets the log verbosity of all Firestore instances.
   *
   * The default verbosity level is `kLogLevelInfo`.
   *
   * @param[in] log_level The desired verbosity.
   */
  static void set_log_level(LogLevel log_level);

  /**
   * Disables network access for this instance. While the network is disabled,
   * any snapshot listeners or Get() calls will return results from cache, and
   * any write operations will be queued until network usage is re-enabled via a
   * call to EnableNetwork().
   *
   * If the network was already disabled, calling `DisableNetwork()` again is
   * a no-op.
   */
  virtual Future<void> DisableNetwork();

  /**
   * Re-enables network usage for this instance after a prior call to
   * DisableNetwork().
   *
   * If the network is currently enabled, calling `EnableNetwork()` is a no-op.
   */
  virtual Future<void> EnableNetwork();

  /**
   * Terminates this `Firestore` instance.
   *
   * After calling `Terminate()`, only the `ClearPersistence()` method may be
   * used. Calling any other methods will result in an error.
   *
   * To restart after termination, simply create a new instance of `Firestore`
   * with `Firestore::GetInstance()`.
   *
   * `Terminate()` does not cancel any pending writes and any tasks that are
   * awaiting a response from the server will not be resolved. The next time you
   * start this instance, it will resume attempting to send these writes to the
   * server.
   *
   * Note: under normal circumstances, calling `Terminate()` is not required.
   * This method is useful only when you want to force this instance to release
   * all of its resources or in combination with `ClearPersistence()` to ensure
   * that all local state is destroyed between test runs.
   *
   * @return A `Future` that is resolved when the instance has been successfully
   * terminated.
   */
  virtual Future<void> Terminate();

  /**
   * Waits until all currently pending writes for the active user have been
   * acknowledged by the backend.
   *
   * The returned future is resolved immediately without error if there are no
   * outstanding writes. Otherwise, the future is resolved when all previously
   * issued writes (including those written in a previous app session) have been
   * acknowledged by the backend. The future does not wait for writes that were
   * added after the method is called. If you wish to wait for additional
   * writes, you have to call `WaitForPendingWrites` again.
   *
   * Any outstanding `WaitForPendingWrites` futures are resolved with an
   * error during user change.
   */
  virtual Future<void> WaitForPendingWrites();

  /**
   * Clears the persistent storage. This includes pending writes and cached
   * documents.
   *
   * Must be called while the Firestore instance is not started (after the app
   * is shut down or when the app is first initialized). On startup, this method
   * must be called before other methods (other than `settings()` and
   * `set_settings()`). If the Firestore instance is still running, the function
   * will complete with an error code of `FailedPrecondition`.
   *
   * Note: `ClearPersistence()` is primarily intended to help write
   * reliable tests that use Firestore. It uses the most efficient mechanism
   * possible for dropping existing data but does not attempt to securely
   * overwrite or otherwise make cached data unrecoverable. For applications
   * that are sensitive to the disclosure of cache data in between user sessions
   * we strongly recommend not to enable persistence in the first place.
   */
  virtual Future<void> ClearPersistence();

  /**
   * Attaches a listener for a snapshots-in-sync event. Server-generated
   * updates and local changes can affect multiple snapshot listeners.
   * The snapshots-in-sync event indicates that all listeners affected by
   * a given change have fired.
   *
   * NOTE: The snapshots-in-sync event only indicates that listeners are
   * in sync with each other, but does not relate to whether those
   * snapshots are in sync with the server. Use `SnapshotMetadata` in the
   * individual listeners to determine if a snapshot is from the cache or
   * the server.
   *
   * @param callback A callback to be called every time all snapshot
   * listeners are in sync with each other.
   * @return A `ListenerRegistration` object that can be used to remove the
   * listener.
   */
  virtual ListenerRegistration AddSnapshotsInSyncListener(
      std::function<void()> callback);

  /**
   * Loads a Firestore bundle into the local cache.
   *
   * @param bundle A string containing the bundle to be loaded.
   * @return A `Future` that is resolved when the loading is either completed
   * or aborted due to an error.
   */
  virtual Future<LoadBundleTaskProgress> LoadBundle(const std::string& bundle);

  /**
   * Loads a Firestore bundle into the local cache, with the provided callback
   * executed for progress updates.
   *
   * @param bundle A string containing the bundle to be loaded.
   * @param progress_callback A callback that is called with progress
   * updates, and completion or error updates.
   * @return A `Future` that is resolved when the loading is either completed
   * or aborted due to an error.
   */
  virtual Future<LoadBundleTaskProgress> LoadBundle(
      const std::string& bundle,
      std::function<void(const LoadBundleTaskProgress&)> progress_callback);

  /**
   * Reads a Firestore `Query` from the local cache, identified by the given
   * name.
   *
   * Named queries are packaged into bundles on the server side (along with the
   * resulting documents) and loaded into local cache using `LoadBundle`. Once
   * in the local cache, you can use this method to extract a query by name.
   *
   * If a query cannot be found, the returned future will complete with its
   * `error()` set to a non-zero error code.
   *
   * @param query_name The name of the query to read from saved bundles.
   */
  virtual Future<Query> NamedQuery(const std::string& query_name);

 protected:
  /**
   * Default constructor, to be used only for mocking `Firestore`.
   */
  Firestore() = default;

 private:
  friend class FieldValueInternal;
  friend class FirestoreInternal;
  friend class Wrapper;
  friend struct ConverterImpl;
  friend class FirestoreIntegrationTest;
  friend class IncludesTest;
  template <typename T, typename U, typename F>
  friend struct CleanupFn;

  friend class csharp::ApiHeaders;
  friend class csharp::TransactionManager;

  explicit Firestore(::firebase::App* app);
  explicit Firestore(FirestoreInternal* internal);

  static Firestore* CreateFirestore(::firebase::App* app,
                                    FirestoreInternal* internal,
                                    InitResult* init_result_out);
  static Firestore* AddFirestoreToCache(Firestore* firestore,
                                        InitResult* init_result_out);

  static void SetClientLanguage(const std::string& language_token);

  // Delete the internal_ data.
  void DeleteInternal();

  mutable FirestoreInternal* internal_ = nullptr;
};

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_H_
