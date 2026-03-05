/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_DATABASE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_DATABASE_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "firebase/database.h"
#include "firebase/database/common.h"
#include "firebase/database/data_snapshot.h"
#include "messages.g.h"

namespace firebase_database_windows {

class FirebaseDatabasePlugin : public flutter::Plugin,
                               public FirebaseDatabaseHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FirebaseDatabasePlugin();

  virtual ~FirebaseDatabasePlugin();

  // Disallow copy and assign.
  FirebaseDatabasePlugin(const FirebaseDatabasePlugin&) = delete;
  FirebaseDatabasePlugin& operator=(const FirebaseDatabasePlugin&) = delete;

  // Helper functions
  static flutter::EncodableValue VariantToEncodableValue(
      const firebase::Variant& variant);
  static firebase::Variant EncodableValueToVariant(
      const flutter::EncodableValue& value);
  static std::string GetDatabaseErrorCode(firebase::database::Error error);
  static std::string GetDatabaseErrorMessage(firebase::database::Error error);
  static FlutterError ParseError(const firebase::FutureBase& future);
  static flutter::EncodableMap DataSnapshotToEncodableMap(
      const firebase::database::DataSnapshot& snapshot);

  // FirebaseDatabaseHostApi methods
  void GoOnline(
      const DatabasePigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void GoOffline(
      const DatabasePigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void SetPersistenceEnabled(
      const DatabasePigeonFirebaseApp& app, bool enabled,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void SetPersistenceCacheSizeBytes(
      const DatabasePigeonFirebaseApp& app, int64_t cache_size,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void SetLoggingEnabled(
      const DatabasePigeonFirebaseApp& app, bool enabled,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void UseDatabaseEmulator(
      const DatabasePigeonFirebaseApp& app, const std::string& host,
      int64_t port,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void Ref(const DatabasePigeonFirebaseApp& app, const std::string* path,
           std::function<void(ErrorOr<DatabaseReferencePlatform> reply)> result)
      override;
  void RefFromURL(const DatabasePigeonFirebaseApp& app, const std::string& url,
                  std::function<void(ErrorOr<DatabaseReferencePlatform> reply)>
                      result) override;
  void PurgeOutstandingWrites(
      const DatabasePigeonFirebaseApp& app,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void DatabaseReferenceSet(
      const DatabasePigeonFirebaseApp& app,
      const DatabaseReferenceRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void DatabaseReferenceSetWithPriority(
      const DatabasePigeonFirebaseApp& app,
      const DatabaseReferenceRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void DatabaseReferenceUpdate(
      const DatabasePigeonFirebaseApp& app, const UpdateRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void DatabaseReferenceSetPriority(
      const DatabasePigeonFirebaseApp& app,
      const DatabaseReferenceRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void DatabaseReferenceRunTransaction(
      const DatabasePigeonFirebaseApp& app, const TransactionRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void DatabaseReferenceGetTransactionResult(
      const DatabasePigeonFirebaseApp& app, int64_t transaction_key,
      std::function<void(ErrorOr<flutter::EncodableMap> reply)> result)
      override;
  void OnDisconnectSet(
      const DatabasePigeonFirebaseApp& app,
      const DatabaseReferenceRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void OnDisconnectSetWithPriority(
      const DatabasePigeonFirebaseApp& app,
      const DatabaseReferenceRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void OnDisconnectUpdate(
      const DatabasePigeonFirebaseApp& app, const UpdateRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void OnDisconnectCancel(
      const DatabasePigeonFirebaseApp& app, const std::string& path,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void QueryObserve(
      const DatabasePigeonFirebaseApp& app, const QueryRequest& request,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  void QueryKeepSynced(
      const DatabasePigeonFirebaseApp& app, const QueryRequest& request,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  void QueryGet(const DatabasePigeonFirebaseApp& app,
                const QueryRequest& request,
                std::function<void(ErrorOr<flutter::EncodableMap> reply)>
                    result) override;

  static flutter::BinaryMessenger* messenger_;
  static std::map<
      std::string,
      std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
      event_channels_;
  static std::map<std::string, std::unique_ptr<flutter::StreamHandler<>>>
      stream_handlers_;
  static std::map<std::string, firebase::database::Database*>
      database_instances_;

 private:
  firebase::database::Database* GetDatabaseFromPigeon(
      const DatabasePigeonFirebaseApp& app);
  firebase::database::Query ApplyQueryModifiers(
      firebase::database::Query query, const flutter::EncodableList& modifiers);

  std::map<int64_t, flutter::EncodableMap> transaction_results_;
};

}  // namespace firebase_database_windows

#endif /* FLUTTER_PLUGIN_FIREBASE_DATABASE_PLUGIN_H_ */
