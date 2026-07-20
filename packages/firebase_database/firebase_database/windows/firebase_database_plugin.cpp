// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_database_plugin.h"

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>

#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <mutex>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#include "firebase/app.h"
#include "firebase/database.h"
#include "firebase/database/common.h"
#include "firebase/database/data_snapshot.h"
#include "firebase/database/database_reference.h"
#include "firebase/database/disconnection.h"
#include "firebase/database/listener.h"
#include "firebase/database/mutable_data.h"
#include "firebase/database/query.h"
#include "firebase/future.h"
#include "firebase/log.h"
#include "firebase/variant.h"
#include "firebase_database/plugin_version.h"
#include "messages.g.h"

using firebase::App;
using firebase::Future;
using firebase::Variant;
using firebase::database::Database;
using firebase::database::DatabaseReference;
using firebase::database::DataSnapshot;
using firebase::database::Error;
using firebase::database::MutableData;
using firebase::database::TransactionResult;
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace firebase_database_windows {

static const std::string kLibraryName = "flutter-fire-db";

// Static member initialization
flutter::BinaryMessenger* FirebaseDatabasePlugin::messenger_ = nullptr;
std::map<std::string,
         std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
    FirebaseDatabasePlugin::event_channels_;
std::map<std::string, std::unique_ptr<flutter::StreamHandler<>>>
    FirebaseDatabasePlugin::stream_handlers_;
std::map<std::string, firebase::database::Database*>
    FirebaseDatabasePlugin::database_instances_;

// atexit handler: clean up Database resources before static destruction.
// 1. Clear event channels to trigger StreamHandler destruction, which
//    unregisters listeners from the Database while it's still alive.
// 2. Call GoOffline() to close WebSocket connections so thread joins
//    during App::~App() → Database::DeleteInternal() complete quickly.
static void CleanupBeforeStaticDestruction() {
  // Destroy event channels and stream handlers first. This triggers
  // StreamHandler destructors which call RemoveValueListener /
  // RemoveChildListener while the Database is still valid.
  FirebaseDatabasePlugin::event_channels_.clear();
  FirebaseDatabasePlugin::stream_handlers_.clear();

  // Disconnect all Database instances to close WebSocket connections.
  for (auto& pair : FirebaseDatabasePlugin::database_instances_) {
    if (pair.second) {
      pair.second->GoOffline();
    }
  }
  // Give the scheduler thread time to process GoOffline callbacks.
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
}

// --- Helper: Register an EventChannel with a generated name ---
static std::string RegisterEventChannel(
    const std::string& prefix,
    std::unique_ptr<flutter::StreamHandler<EncodableValue>> handler) {
  static int channel_counter = 0;
  std::string channelName =
      prefix + std::to_string(channel_counter++) + "_" +
      std::to_string(
          std::chrono::system_clock::now().time_since_epoch().count());

  FirebaseDatabasePlugin::event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          FirebaseDatabasePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance());
  FirebaseDatabasePlugin::stream_handlers_[channelName] = std::move(handler);
  FirebaseDatabasePlugin::event_channels_[channelName]->SetStreamHandler(
      std::move(FirebaseDatabasePlugin::stream_handlers_[channelName]));
  return channelName;
}

// --- Helper: Convert firebase::Variant to flutter::EncodableValue ---
EncodableValue FirebaseDatabasePlugin::VariantToEncodableValue(
    const Variant& variant) {
  switch (variant.type()) {
    case Variant::kTypeNull:
      return EncodableValue();
    case Variant::kTypeInt64:
      return EncodableValue(variant.int64_value());
    case Variant::kTypeDouble:
      return EncodableValue(variant.double_value());
    case Variant::kTypeBool:
      return EncodableValue(variant.bool_value());
    case Variant::kTypeStaticString:
      return EncodableValue(std::string(variant.string_value()));
    case Variant::kTypeMutableString:
      return EncodableValue(variant.mutable_string());
    case Variant::kTypeVector: {
      EncodableList list;
      for (const auto& item : variant.vector()) {
        list.push_back(VariantToEncodableValue(item));
      }
      return EncodableValue(list);
    }
    case Variant::kTypeMap: {
      EncodableMap map;
      for (const auto& kv : variant.map()) {
        EncodableValue key = VariantToEncodableValue(kv.first);
        EncodableValue value = VariantToEncodableValue(kv.second);
        map[key] = value;
      }
      return EncodableValue(map);
    }
    case Variant::kTypeStaticBlob: {
      std::vector<uint8_t> blob(variant.blob_data(),
                                variant.blob_data() + variant.blob_size());
      return EncodableValue(blob);
    }
    case Variant::kTypeMutableBlob: {
      std::vector<uint8_t> blob(
          variant.mutable_blob_data(),
          variant.mutable_blob_data() + variant.blob_size());
      return EncodableValue(blob);
    }
    default:
      return EncodableValue();
  }
}

// --- Helper: Convert flutter::EncodableValue to firebase::Variant ---
Variant FirebaseDatabasePlugin::EncodableValueToVariant(
    const EncodableValue& value) {
  if (std::holds_alternative<std::monostate>(value)) {
    return Variant::Null();
  } else if (std::holds_alternative<bool>(value)) {
    return Variant(std::get<bool>(value));
  } else if (std::holds_alternative<int32_t>(value)) {
    return Variant(static_cast<int64_t>(std::get<int32_t>(value)));
  } else if (std::holds_alternative<int64_t>(value)) {
    return Variant(std::get<int64_t>(value));
  } else if (std::holds_alternative<double>(value)) {
    return Variant(std::get<double>(value));
  } else if (std::holds_alternative<std::string>(value)) {
    return Variant(std::get<std::string>(value));
  } else if (std::holds_alternative<std::vector<uint8_t>>(value)) {
    const auto& blob = std::get<std::vector<uint8_t>>(value);
    return Variant::FromMutableBlob(blob.data(), blob.size());
  } else if (std::holds_alternative<EncodableList>(value)) {
    const auto& list = std::get<EncodableList>(value);
    std::vector<Variant> vec;
    vec.reserve(list.size());
    for (const auto& item : list) {
      vec.push_back(EncodableValueToVariant(item));
    }
    return Variant(vec);
  } else if (std::holds_alternative<EncodableMap>(value)) {
    const auto& map = std::get<EncodableMap>(value);
    std::map<Variant, Variant> variant_map;
    for (const auto& kv : map) {
      variant_map[EncodableValueToVariant(kv.first)] =
          EncodableValueToVariant(kv.second);
    }
    return Variant(variant_map);
  }
  return Variant::Null();
}

// --- Helper: Error code string from C++ SDK Error enum ---
std::string FirebaseDatabasePlugin::GetDatabaseErrorCode(Error error) {
  switch (error) {
    case Error::kErrorNone:
      return "none";
    case Error::kErrorDisconnected:
      return "disconnected";
    case Error::kErrorExpiredToken:
      return "expired-token";
    case Error::kErrorInvalidToken:
      return "invalid-token";
    case Error::kErrorMaxRetries:
      return "max-retries";
    case Error::kErrorNetworkError:
      return "network-error";
    case Error::kErrorOperationFailed:
      return "operation-failed";
    case Error::kErrorOverriddenBySet:
      return "overridden-by-set";
    case Error::kErrorPermissionDenied:
      return "permission-denied";
    case Error::kErrorUnavailable:
      return "unavailable";
    case Error::kErrorWriteCanceled:
      return "write-canceled";
    case Error::kErrorInvalidVariantType:
      return "invalid-variant-type";
    case Error::kErrorConflictingOperationInProgress:
      return "conflicting-operation-in-progress";
    case Error::kErrorTransactionAbortedByUser:
      return "transaction-aborted-by-user";
    default:
      return "unknown";
  }
}

std::string FirebaseDatabasePlugin::GetDatabaseErrorMessage(Error error) {
  const char* msg = firebase::database::GetErrorMessage(error);
  return msg ? std::string(msg) : "Unknown error";
}

FlutterError FirebaseDatabasePlugin::ParseError(
    const firebase::FutureBase& future) {
  Error error = static_cast<Error>(future.error());
  std::string code = GetDatabaseErrorCode(error);
  std::string message =
      future.error_message() ? future.error_message() : "Unknown error";
  return FlutterError(code, message);
}

// --- Helper: Convert DataSnapshot to EncodableMap ---
EncodableMap FirebaseDatabasePlugin::DataSnapshotToEncodableMap(
    const DataSnapshot& snapshot) {
  EncodableMap result;
  result[EncodableValue("key")] =
      snapshot.key() ? EncodableValue(std::string(snapshot.key()))
                     : EncodableValue();
  result[EncodableValue("value")] = VariantToEncodableValue(snapshot.value());
  result[EncodableValue("priority")] =
      VariantToEncodableValue(snapshot.priority());

  EncodableList childKeys;
  std::vector<DataSnapshot> children = snapshot.children();
  for (const auto& child : children) {
    if (child.key()) {
      childKeys.push_back(EncodableValue(std::string(child.key())));
    }
  }
  result[EncodableValue("childKeys")] = EncodableValue(childKeys);

  return result;
}

// --- Helper: Apply query modifiers ---
firebase::database::Query FirebaseDatabasePlugin::ApplyQueryModifiers(
    firebase::database::Query query, const EncodableList& modifiers) {
  for (const auto& mod_value : modifiers) {
    const auto& mod = std::get<EncodableMap>(mod_value);

    auto type_it = mod.find(EncodableValue("type"));
    if (type_it == mod.end()) continue;
    std::string type = std::get<std::string>(type_it->second);

    auto name_it = mod.find(EncodableValue("name"));
    if (name_it == mod.end()) continue;
    std::string name = std::get<std::string>(name_it->second);

    if (type == "orderBy") {
      if (name == "orderByChild") {
        auto path_it = mod.find(EncodableValue("path"));
        if (path_it != mod.end()) {
          query = query.OrderByChild(
              std::get<std::string>(path_it->second).c_str());
        }
      } else if (name == "orderByKey") {
        query = query.OrderByKey();
      } else if (name == "orderByValue") {
        query = query.OrderByValue();
      } else if (name == "orderByPriority") {
        query = query.OrderByPriority();
      }
    } else if (type == "cursor") {
      auto value_it = mod.find(EncodableValue("value"));
      Variant cursor_value = Variant::Null();
      if (value_it != mod.end()) {
        cursor_value = EncodableValueToVariant(value_it->second);
      }

      auto key_it = mod.find(EncodableValue("key"));
      const char* child_key = nullptr;
      std::string key_str;
      if (key_it != mod.end() &&
          std::holds_alternative<std::string>(key_it->second)) {
        key_str = std::get<std::string>(key_it->second);
        child_key = key_str.c_str();
      }

      if (name == "startAt") {
        query = child_key ? query.StartAt(cursor_value, child_key)
                          : query.StartAt(cursor_value);
      } else if (name == "startAfter") {
        // C++ SDK doesn't have StartAfter; use StartAt workaround
        query = child_key ? query.StartAt(cursor_value, child_key)
                          : query.StartAt(cursor_value);
      } else if (name == "endAt") {
        query = child_key ? query.EndAt(cursor_value, child_key)
                          : query.EndAt(cursor_value);
      } else if (name == "endBefore") {
        // C++ SDK doesn't have EndBefore; use EndAt workaround
        query = child_key ? query.EndAt(cursor_value, child_key)
                          : query.EndAt(cursor_value);
      }
    } else if (type == "limit") {
      auto limit_it = mod.find(EncodableValue("limit"));
      if (limit_it != mod.end()) {
        int limit = 0;
        if (std::holds_alternative<int32_t>(limit_it->second)) {
          limit = std::get<int32_t>(limit_it->second);
        } else if (std::holds_alternative<int64_t>(limit_it->second)) {
          limit = static_cast<int>(std::get<int64_t>(limit_it->second));
        }
        if (name == "limitToFirst") {
          query = query.LimitToFirst(static_cast<size_t>(limit));
        } else if (name == "limitToLast") {
          query = query.LimitToLast(static_cast<size_t>(limit));
        }
      }
    }
  }
  return query;
}

// ===== Plugin Implementation =====

FirebaseDatabasePlugin::FirebaseDatabasePlugin() {}

FirebaseDatabasePlugin::~FirebaseDatabasePlugin() {}

void FirebaseDatabasePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseDatabasePlugin>();
  messenger_ = registrar->messenger();
  FirebaseDatabaseHostApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);

  // Register atexit handler to clean up listeners and disconnect
  // before static destruction triggers thread joins in the C++ SDK.
  std::atexit(CleanupBeforeStaticDestruction);
}

// --- Helper: Get Database instance from Pigeon app ---
Database* FirebaseDatabasePlugin::GetDatabaseFromPigeon(
    const DatabasePigeonFirebaseApp& app) {
  App* firebase_app = App::GetInstance(app.app_name().c_str());
  if (!firebase_app) {
    return nullptr;
  }

  const auto& settings = app.settings();
  const std::string* url = app.database_u_r_l();

  // Build a cache key from app name + effective URL (like Firestore does)
  std::string effective_url;
  if (url && !url->empty()) {
    effective_url = *url;
  }

  std::string cache_key = app.app_name() + "-" + effective_url;

  // Return cached instance if available (raw pointer, not owned).
  // The C++ SDK manages Database instance lifetime internally.
  // App::~App() triggers Database::DeleteInternal() during static destruction.
  auto it = database_instances_.find(cache_key);
  if (it != database_instances_.end()) {
    return it->second;
  }

  // Create new instance
  // Always pass the URL explicitly - the C++ SDK on desktop may not
  // properly read database_url from app options without it.
  const char* app_db_url = firebase_app->options().database_url();
  if (effective_url.empty() && app_db_url && strlen(app_db_url) > 0) {
    effective_url = app_db_url;
  }
  Database* database = nullptr;
  if (!effective_url.empty()) {
    database = Database::GetInstance(firebase_app, effective_url.c_str());
  } else {
    database = Database::GetInstance(firebase_app);
  }

  if (!database) return nullptr;

  if (settings.persistence_enabled()) {
    database->set_persistence_enabled(*settings.persistence_enabled());
  }
  if (settings.logging_enabled() && *settings.logging_enabled()) {
    database->set_log_level(firebase::kLogLevelDebug);
  }

  // Cache raw pointer. We do NOT take ownership — the C++ SDK manages
  // the Database lifetime via App's CleanupNotifier. This matches the
  // pattern used by firebase_auth and firebase_storage.
  database_instances_[cache_key] = database;

  return database;
}

// ===== Database methods =====

void FirebaseDatabasePlugin::GoOnline(
    const DatabasePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }
  database->GoOnline();
  result(std::nullopt);
}

void FirebaseDatabasePlugin::GoOffline(
    const DatabasePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }
  database->GoOffline();
  result(std::nullopt);
}

void FirebaseDatabasePlugin::SetPersistenceEnabled(
    const DatabasePigeonFirebaseApp& app, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }
  database->set_persistence_enabled(enabled);
  result(std::nullopt);
}

void FirebaseDatabasePlugin::SetPersistenceCacheSizeBytes(
    const DatabasePigeonFirebaseApp& app, int64_t cache_size,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // C++ SDK doesn't directly support setting cache size
  result(std::nullopt);
}

void FirebaseDatabasePlugin::SetLoggingEnabled(
    const DatabasePigeonFirebaseApp& app, bool enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }
  database->set_log_level(enabled ? firebase::kLogLevelDebug
                                  : firebase::kLogLevelInfo);
  result(std::nullopt);
}

void FirebaseDatabasePlugin::UseDatabaseEmulator(
    const DatabasePigeonFirebaseApp& app, const std::string& host, int64_t port,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // The C++ SDK for Realtime Database does not have a UseEmulator API.
  // On Windows, tests run against the live Firebase instance.
  result(std::nullopt);
}

void FirebaseDatabasePlugin::Ref(
    const DatabasePigeonFirebaseApp& app, const std::string* path,
    std::function<void(ErrorOr<DatabaseReferencePlatform> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref;
  if (path && !path->empty()) {
    ref = database->GetReference(path->c_str());
  } else {
    ref = database->GetReference();
  }

  std::string ref_path;
  if (ref.key()) {
    // Build path from the URL
    std::string url = ref.url();
    // Extract path from URL (after the host)
    auto pos = url.find(".com/");
    if (pos != std::string::npos) {
      ref_path = url.substr(pos + 4);
    } else {
      ref_path = path ? *path : "/";
    }
  } else {
    ref_path = path ? *path : "/";
  }

  result(DatabaseReferencePlatform(ref_path));
}

void FirebaseDatabasePlugin::RefFromURL(
    const DatabasePigeonFirebaseApp& app, const std::string& url,
    std::function<void(ErrorOr<DatabaseReferencePlatform> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReferenceFromUrl(url.c_str());

  std::string ref_path;
  std::string ref_url = ref.url();
  auto pos = ref_url.find(".com/");
  if (pos != std::string::npos) {
    ref_path = ref_url.substr(pos + 4);
  } else {
    ref_path = "/";
  }

  result(DatabaseReferencePlatform(ref_path));
}

void FirebaseDatabasePlugin::PurgeOutstandingWrites(
    const DatabasePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }
  database->PurgeOutstandingWrites();
  result(std::nullopt);
}

// ===== DatabaseReference methods =====

void FirebaseDatabasePlugin::DatabaseReferenceSet(
    const DatabasePigeonFirebaseApp& app,
    const DatabaseReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant value = request.value() ? EncodableValueToVariant(*request.value())
                                  : Variant::Null();

  ref.SetValue(value).OnCompletion([result](const Future<void>& future) {
    if (future.error() == Error::kErrorNone) {
      result(std::nullopt);
    } else {
      result(FirebaseDatabasePlugin::ParseError(future));
    }
  });
}

void FirebaseDatabasePlugin::DatabaseReferenceSetWithPriority(
    const DatabasePigeonFirebaseApp& app,
    const DatabaseReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant value = request.value() ? EncodableValueToVariant(*request.value())
                                  : Variant::Null();
  Variant priority = request.priority()
                         ? EncodableValueToVariant(*request.priority())
                         : Variant::Null();

  ref.SetValueAndPriority(value, priority)
      .OnCompletion([result](const Future<void>& future) {
        if (future.error() == Error::kErrorNone) {
          result(std::nullopt);
        } else {
          result(FirebaseDatabasePlugin::ParseError(future));
        }
      });
}

void FirebaseDatabasePlugin::DatabaseReferenceUpdate(
    const DatabasePigeonFirebaseApp& app, const UpdateRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant values = EncodableValueToVariant(EncodableValue(request.value()));

  ref.UpdateChildren(values).OnCompletion([result](const Future<void>& future) {
    if (future.error() == Error::kErrorNone) {
      result(std::nullopt);
    } else {
      result(FirebaseDatabasePlugin::ParseError(future));
    }
  });
}

void FirebaseDatabasePlugin::DatabaseReferenceSetPriority(
    const DatabasePigeonFirebaseApp& app,
    const DatabaseReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant priority = request.priority()
                         ? EncodableValueToVariant(*request.priority())
                         : Variant::Null();

  ref.SetPriority(priority).OnCompletion([result](const Future<void>& future) {
    if (future.error() == Error::kErrorNone) {
      result(std::nullopt);
    } else {
      result(FirebaseDatabasePlugin::ParseError(future));
    }
  });
}

void FirebaseDatabasePlugin::DatabaseReferenceRunTransaction(
    const DatabasePigeonFirebaseApp& app, const TransactionRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  int64_t transaction_key = request.transaction_key();
  bool apply_locally = request.apply_locally();

  struct TransactionContext {
    flutter::BinaryMessenger* messenger;
    int64_t transaction_key;
    std::map<int64_t, EncodableMap>* transaction_results;
    std::function<void(std::optional<FlutterError> reply)> result;
  };

  auto* ctx = new TransactionContext{messenger_, transaction_key,
                                     &transaction_results_, result};

  ref.RunTransaction(
      [](MutableData* data,
         void* context) -> firebase::database::TransactionResult {
        auto* ctx = static_cast<TransactionContext*>(context);

        // Convert current data to EncodableValue
        Variant current_value = data->value();
        EncodableValue snapshot_value =
            FirebaseDatabasePlugin::VariantToEncodableValue(current_value);

        // Call the Flutter transaction handler synchronously using a semaphore
        std::mutex mtx;
        std::condition_variable cv;
        bool handler_complete = false;
        TransactionHandlerResult* handler_result = nullptr;

        auto flutter_api =
            std::make_unique<FirebaseDatabaseFlutterApi>(ctx->messenger);

        const EncodableValue* snapshot_ptr =
            std::holds_alternative<std::monostate>(snapshot_value)
                ? nullptr
                : &snapshot_value;

        flutter_api->CallTransactionHandler(
            ctx->transaction_key, snapshot_ptr,
            [&](const TransactionHandlerResult& result) {
              handler_result = new TransactionHandlerResult(
                  result.value(), result.aborted(), result.exception());
              std::lock_guard<std::mutex> lock(mtx);
              handler_complete = true;
              cv.notify_one();
            },
            [&](const FlutterError& error) {
              handler_result = new TransactionHandlerResult(true, true);
              std::lock_guard<std::mutex> lock(mtx);
              handler_complete = true;
              cv.notify_one();
            });

        // Wait for the Flutter callback to complete
        {
          std::unique_lock<std::mutex> lock(mtx);
          cv.wait(lock, [&] { return handler_complete; });
        }

        if (!handler_result || handler_result->aborted() ||
            handler_result->exception()) {
          delete handler_result;
          return firebase::database::kTransactionResultAbort;
        }

        // Apply the result value
        if (handler_result->value()) {
          Variant new_value = FirebaseDatabasePlugin::EncodableValueToVariant(
              *handler_result->value());
          data->set_value(new_value);
        } else {
          data->set_value(Variant::Null());
        }

        delete handler_result;
        return firebase::database::kTransactionResultSuccess;
      },
      ctx, apply_locally);

  // Wait for the transaction to complete
  ref.RunTransactionLastResult().OnCompletion(
      [ctx](const Future<DataSnapshot>& future) {
        if (future.error() == Error::kErrorNone) {
          const DataSnapshot* snapshot = future.result();
          EncodableMap result_map;
          result_map[EncodableValue("committed")] = EncodableValue(true);
          if (snapshot) {
            result_map[EncodableValue("snapshot")] = EncodableValue(
                FirebaseDatabasePlugin::DataSnapshotToEncodableMap(*snapshot));
          } else {
            result_map[EncodableValue("snapshot")] = EncodableValue();
          }
          (*ctx->transaction_results)[ctx->transaction_key] = result_map;
          ctx->result(std::nullopt);
        } else {
          // Transaction failed but may have been aborted
          EncodableMap result_map;
          result_map[EncodableValue("committed")] = EncodableValue(false);
          result_map[EncodableValue("snapshot")] = EncodableValue(EncodableMap{
              {EncodableValue("key"), EncodableValue()},
              {EncodableValue("value"), EncodableValue()},
              {EncodableValue("priority"), EncodableValue()},
              {EncodableValue("childKeys"), EncodableValue(EncodableList{})},
          });
          (*ctx->transaction_results)[ctx->transaction_key] = result_map;

          if (static_cast<Error>(future.error()) ==
              Error::kErrorTransactionAbortedByUser) {
            // Aborted by user is not an error condition
            ctx->result(std::nullopt);
          } else {
            ctx->result(FirebaseDatabasePlugin::ParseError(future));
          }
        }
        delete ctx;
      });
}

void FirebaseDatabasePlugin::DatabaseReferenceGetTransactionResult(
    const DatabasePigeonFirebaseApp& app, int64_t transaction_key,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  auto it = transaction_results_.find(transaction_key);
  if (it != transaction_results_.end()) {
    result(it->second);
    transaction_results_.erase(it);
  } else {
    // Return default result
    EncodableMap default_result;
    default_result[EncodableValue("committed")] = EncodableValue(false);
    default_result[EncodableValue("snapshot")] = EncodableValue(EncodableMap{
        {EncodableValue("key"), EncodableValue()},
        {EncodableValue("value"), EncodableValue()},
        {EncodableValue("priority"), EncodableValue()},
        {EncodableValue("childKeys"), EncodableValue(EncodableList{})},
    });
    result(default_result);
  }
}

// ===== OnDisconnect methods =====

void FirebaseDatabasePlugin::OnDisconnectSet(
    const DatabasePigeonFirebaseApp& app,
    const DatabaseReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant value = request.value() ? EncodableValueToVariant(*request.value())
                                  : Variant::Null();

  ref.OnDisconnect()->SetValue(value).OnCompletion(
      [result](const Future<void>& future) {
        if (future.error() == Error::kErrorNone) {
          result(std::nullopt);
        } else {
          result(FirebaseDatabasePlugin::ParseError(future));
        }
      });
}

void FirebaseDatabasePlugin::OnDisconnectSetWithPriority(
    const DatabasePigeonFirebaseApp& app,
    const DatabaseReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant value = request.value() ? EncodableValueToVariant(*request.value())
                                  : Variant::Null();
  Variant priority = request.priority()
                         ? EncodableValueToVariant(*request.priority())
                         : Variant::Null();

  ref.OnDisconnect()
      ->SetValueAndPriority(value, priority)
      .OnCompletion([result](const Future<void>& future) {
        if (future.error() == Error::kErrorNone) {
          result(std::nullopt);
        } else {
          result(FirebaseDatabasePlugin::ParseError(future));
        }
      });
}

void FirebaseDatabasePlugin::OnDisconnectUpdate(
    const DatabasePigeonFirebaseApp& app, const UpdateRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  Variant values = EncodableValueToVariant(EncodableValue(request.value()));

  ref.OnDisconnect()->UpdateChildren(values).OnCompletion(
      [result](const Future<void>& future) {
        if (future.error() == Error::kErrorNone) {
          result(std::nullopt);
        } else {
          result(FirebaseDatabasePlugin::ParseError(future));
        }
      });
}

void FirebaseDatabasePlugin::OnDisconnectCancel(
    const DatabasePigeonFirebaseApp& app, const std::string& path,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(path.c_str());

  ref.OnDisconnect()->Cancel().OnCompletion(
      [result](const Future<void>& future) {
        if (future.error() == Error::kErrorNone) {
          result(std::nullopt);
        } else {
          result(FirebaseDatabasePlugin::ParseError(future));
        }
      });
}

// ===== Query methods =====

void FirebaseDatabasePlugin::QueryObserve(
    const DatabasePigeonFirebaseApp& app, const QueryRequest& request,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  firebase::database::Query query =
      ApplyQueryModifiers(ref, request.modifiers());

  // The event type will be passed as an argument when the Dart side calls
  // listen on the EventChannel. We need to create the appropriate handler.
  // Since we don't know the event type here, we create both a value and child
  // handler based on a shared approach: the Dart side passes eventType as an
  // argument to the EventChannel's listen call.

  // We use a generic approach: create one handler that reads the eventType
  // from the listen arguments.
  class DatabaseGenericStreamHandler
      : public flutter::StreamHandler<flutter::EncodableValue> {
   public:
    DatabaseGenericStreamHandler(firebase::database::Query query)
        : query_(query), value_listener_(nullptr), child_listener_(nullptr) {}

    ~DatabaseGenericStreamHandler() override {
      // Remove listeners before deleting to avoid dangling pointers in the
      // Database's internal listener list. Query::RemoveXxxListener() checks
      // if (internal_) first, so this is a safe no-op if the Database was
      // already destroyed (the cleanup mechanism nullifies internal_).
      if (value_listener_) {
        query_.RemoveValueListener(value_listener_);
        delete value_listener_;
        value_listener_ = nullptr;
      }
      if (child_listener_) {
        query_.RemoveChildListener(child_listener_);
        delete child_listener_;
        child_listener_ = nullptr;
      }
    }

   protected:
    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
    OnListenInternal(
        const flutter::EncodableValue* arguments,
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
        override {
      events_ = std::move(events);

      // Extract eventType from arguments
      std::string event_type = "value";
      if (arguments && std::holds_alternative<EncodableMap>(*arguments)) {
        const auto& args_map = std::get<EncodableMap>(*arguments);
        auto it = args_map.find(EncodableValue("eventType"));
        if (it != args_map.end() &&
            std::holds_alternative<std::string>(it->second)) {
          event_type = std::get<std::string>(it->second);
        }
      }

      if (event_type == "value") {
        // Value listener
        class VL : public firebase::database::ValueListener {
         public:
          VL(flutter::EventSink<flutter::EncodableValue>* events)
              : events_(events) {}
          void OnValueChanged(const DataSnapshot& snapshot) override {
            EncodableMap event;
            event[EncodableValue("eventType")] = EncodableValue("value");
            event[EncodableValue("previousChildKey")] = EncodableValue();
            event[EncodableValue("snapshot")] = EncodableValue(
                FirebaseDatabasePlugin::DataSnapshotToEncodableMap(snapshot));
            events_->Success(EncodableValue(event));
          }
          void OnCancelled(const Error& error,
                           const char* error_message) override {
            events_->Error(FirebaseDatabasePlugin::GetDatabaseErrorCode(error),
                           error_message ? error_message : "Unknown error");
          }

         private:
          flutter::EventSink<flutter::EncodableValue>* events_;
        };
        value_listener_ = new VL(events_.get());
        query_.AddValueListener(value_listener_);
      } else {
        // Child listener
        class CL : public firebase::database::ChildListener {
         public:
          CL(flutter::EventSink<flutter::EncodableValue>* events,
             const std::string& event_type)
              : events_(events), event_type_(event_type) {}
          void OnChildAdded(const DataSnapshot& snapshot,
                            const char* prev) override {
            if (event_type_ == "childAdded") Send("childAdded", snapshot, prev);
          }
          void OnChildChanged(const DataSnapshot& snapshot,
                              const char* prev) override {
            if (event_type_ == "childChanged")
              Send("childChanged", snapshot, prev);
          }
          void OnChildMoved(const DataSnapshot& snapshot,
                            const char* prev) override {
            if (event_type_ == "childMoved") Send("childMoved", snapshot, prev);
          }
          void OnChildRemoved(const DataSnapshot& snapshot) override {
            if (event_type_ == "childRemoved")
              Send("childRemoved", snapshot, nullptr);
          }
          void OnCancelled(const Error& error,
                           const char* error_message) override {
            events_->Error(FirebaseDatabasePlugin::GetDatabaseErrorCode(error),
                           error_message ? error_message : "Unknown error");
          }

         private:
          void Send(const std::string& type, const DataSnapshot& snapshot,
                    const char* prev) {
            EncodableMap event;
            event[EncodableValue("eventType")] = EncodableValue(type);
            event[EncodableValue("previousChildKey")] =
                prev ? EncodableValue(std::string(prev)) : EncodableValue();
            event[EncodableValue("snapshot")] = EncodableValue(
                FirebaseDatabasePlugin::DataSnapshotToEncodableMap(snapshot));
            events_->Success(EncodableValue(event));
          }
          flutter::EventSink<flutter::EncodableValue>* events_;
          std::string event_type_;
        };
        child_listener_ = new CL(events_.get(), event_type);
        query_.AddChildListener(child_listener_);
      }

      return nullptr;
    }

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
    OnCancelInternal(const flutter::EncodableValue* arguments) override {
      if (value_listener_) {
        query_.RemoveValueListener(value_listener_);
        delete value_listener_;
        value_listener_ = nullptr;
      }
      if (child_listener_) {
        query_.RemoveChildListener(child_listener_);
        delete child_listener_;
        child_listener_ = nullptr;
      }
      if (events_) {
        events_->EndOfStream();
      }
      return nullptr;
    }

   private:
    firebase::database::Query query_;
    firebase::database::ValueListener* value_listener_;
    firebase::database::ChildListener* child_listener_;
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  };

  auto handler = std::make_unique<DatabaseGenericStreamHandler>(query);
  std::string channelName = RegisterEventChannel(
      "plugins.flutter.io/firebase_database/query/", std::move(handler));

  result(channelName);
}

void FirebaseDatabasePlugin::QueryKeepSynced(
    const DatabasePigeonFirebaseApp& app, const QueryRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  firebase::database::Query query =
      ApplyQueryModifiers(ref, request.modifiers());

  bool keep_synced = request.value() ? *request.value() : false;
  query.SetKeepSynchronized(keep_synced);
  result(std::nullopt);
}

void FirebaseDatabasePlugin::QueryGet(
    const DatabasePigeonFirebaseApp& app, const QueryRequest& request,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    result(FlutterError("unknown", "Database instance not found"));
    return;
  }

  DatabaseReference ref = database->GetReference(request.path().c_str());
  firebase::database::Query query =
      ApplyQueryModifiers(ref, request.modifiers());

  query.GetValue().OnCompletion([result](const Future<DataSnapshot>& future) {
    if (future.error() == Error::kErrorNone) {
      const DataSnapshot* snapshot = future.result();
      EncodableMap result_map;
      if (snapshot) {
        result_map[EncodableValue("snapshot")] = EncodableValue(
            FirebaseDatabasePlugin::DataSnapshotToEncodableMap(*snapshot));
      } else {
        result_map[EncodableValue("snapshot")] = EncodableValue();
      }
      result(result_map);
    } else {
      result(FirebaseDatabasePlugin::ParseError(future));
    }
  });
}

}  // namespace firebase_database_windows
