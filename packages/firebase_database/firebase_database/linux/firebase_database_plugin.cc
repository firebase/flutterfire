// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_database/firebase_database_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
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

static const char kLibraryName[] = "flutter-fire-db";

#define FIREBASE_DATABASE_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), firebase_database_plugin_get_type(), \
                              FirebaseDatabasePlugin))

struct _FirebaseDatabasePlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FirebaseDatabasePlugin, firebase_database_plugin,
              g_object_get_type())

class DatabaseGenericStreamHandler;

// Static state, mirroring the static members of the Windows
// FirebaseDatabasePlugin class. All of it is only mutated on the platform
// (main) thread; Firebase SDK callbacks marshal back via PostToMainThread.
static FlBinaryMessenger* messenger_ = nullptr;
static std::map<std::string, FlEventChannel*> event_channels_;
static std::map<std::string, std::unique_ptr<DatabaseGenericStreamHandler>>
    stream_handlers_;
static std::map<std::string, Database*> database_instances_;
static std::map<int64_t, FlValue*> transaction_results_;

// --- Helper: Run a closure on the GLib main thread ---
// Firebase C++ SDK futures and listeners fire on SDK-internal threads, but
// FlBinaryMessenger / FlEventChannel calls must happen on the platform (main)
// thread; unlike the Windows C++ wrapper, the GObject embedder API is not
// thread-safe, so every response/event is marshalled through the main loop.
static void PostToMainThread(std::function<void()> fn) {
  auto* boxed = new std::function<void()>(std::move(fn));
  g_idle_add(
      [](gpointer data) -> gboolean {
        auto* callback = static_cast<std::function<void()>*>(data);
        (*callback)();
        delete callback;
        return G_SOURCE_REMOVE;
      },
      boxed);
}

// --- Helper: Convert firebase::Variant to FlValue ---
// Ownership: returns a new reference (transfer full).
static FlValue* VariantToFlValue(const Variant& variant) {
  switch (variant.type()) {
    case Variant::kTypeNull:
      return fl_value_new_null();
    case Variant::kTypeInt64:
      return fl_value_new_int(variant.int64_value());
    case Variant::kTypeDouble:
      return fl_value_new_float(variant.double_value());
    case Variant::kTypeBool:
      return fl_value_new_bool(variant.bool_value());
    case Variant::kTypeStaticString:
      return fl_value_new_string(variant.string_value());
    case Variant::kTypeMutableString:
      return fl_value_new_string(variant.mutable_string().c_str());
    case Variant::kTypeVector: {
      FlValue* list = fl_value_new_list();
      for (const auto& item : variant.vector()) {
        fl_value_append_take(list, VariantToFlValue(item));
      }
      return list;
    }
    case Variant::kTypeMap: {
      FlValue* map = fl_value_new_map();
      for (const auto& kv : variant.map()) {
        fl_value_set_take(map, VariantToFlValue(kv.first),
                          VariantToFlValue(kv.second));
      }
      return map;
    }
    case Variant::kTypeStaticBlob:
      return fl_value_new_uint8_list(
          static_cast<const uint8_t*>(variant.blob_data()),
          variant.blob_size());
    case Variant::kTypeMutableBlob:
      return fl_value_new_uint8_list(
          static_cast<const uint8_t*>(variant.mutable_blob_data()),
          variant.blob_size());
    default:
      return fl_value_new_null();
  }
}

// --- Helper: Convert FlValue to firebase::Variant ---
static Variant FlValueToVariant(FlValue* value) {
  if (value == nullptr) {
    return Variant::Null();
  }
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_NULL:
      return Variant::Null();
    case FL_VALUE_TYPE_BOOL:
      return Variant(static_cast<bool>(fl_value_get_bool(value)));
    case FL_VALUE_TYPE_INT:
      return Variant(static_cast<int64_t>(fl_value_get_int(value)));
    case FL_VALUE_TYPE_FLOAT:
      return Variant(fl_value_get_float(value));
    case FL_VALUE_TYPE_STRING:
      return Variant(std::string(fl_value_get_string(value)));
    case FL_VALUE_TYPE_UINT8_LIST:
      return Variant::FromMutableBlob(fl_value_get_uint8_list(value),
                                      fl_value_get_length(value));
    case FL_VALUE_TYPE_LIST: {
      std::vector<Variant> vec;
      size_t length = fl_value_get_length(value);
      vec.reserve(length);
      for (size_t i = 0; i < length; ++i) {
        vec.push_back(FlValueToVariant(fl_value_get_list_value(value, i)));
      }
      return Variant(vec);
    }
    case FL_VALUE_TYPE_MAP: {
      std::map<Variant, Variant> variant_map;
      size_t length = fl_value_get_length(value);
      for (size_t i = 0; i < length; ++i) {
        variant_map[FlValueToVariant(fl_value_get_map_key(value, i))] =
            FlValueToVariant(fl_value_get_map_value(value, i));
      }
      return Variant(variant_map);
    }
    default:
      return Variant::Null();
  }
}

// --- Helper: Error code string from C++ SDK Error enum ---
static std::string GetDatabaseErrorCode(Error error) {
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

// --- Helper: Convert DataSnapshot to FlValue map ---
// Ownership: returns a new reference (transfer full).
static FlValue* DataSnapshotToFlValue(const DataSnapshot& snapshot) {
  FlValue* result = fl_value_new_map();
  if (snapshot.key() != nullptr) {
    fl_value_set_string_take(result, "key",
                             fl_value_new_string(snapshot.key()));
  } else {
    fl_value_set_string_take(result, "key", fl_value_new_null());
  }
  fl_value_set_string_take(result, "value", VariantToFlValue(snapshot.value()));
  fl_value_set_string_take(result, "priority",
                           VariantToFlValue(snapshot.priority()));

  FlValue* child_keys = fl_value_new_list();
  std::vector<DataSnapshot> children = snapshot.children();
  for (const auto& child : children) {
    if (child.key() != nullptr) {
      fl_value_append_take(child_keys, fl_value_new_string(child.key()));
    }
  }
  fl_value_set_string_take(result, "childKeys", child_keys);

  return result;
}

// --- Helper: Build the default (empty) snapshot map used for failed or
// missing transaction results ---
// Ownership: returns a new reference (transfer full).
static FlValue* EmptyTransactionResult() {
  FlValue* result = fl_value_new_map();
  fl_value_set_string_take(result, "committed", fl_value_new_bool(FALSE));
  FlValue* snapshot = fl_value_new_map();
  fl_value_set_string_take(snapshot, "key", fl_value_new_null());
  fl_value_set_string_take(snapshot, "value", fl_value_new_null());
  fl_value_set_string_take(snapshot, "priority", fl_value_new_null());
  fl_value_set_string_take(snapshot, "childKeys", fl_value_new_list());
  fl_value_set_string_take(result, "snapshot", snapshot);
  return result;
}

// --- Helper: Lookup helpers for FlValue maps ---
static const gchar* MapLookupString(FlValue* map, const char* key) {
  FlValue* value = fl_value_lookup_string(map, key);
  if (value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
    return fl_value_get_string(value);
  }
  return nullptr;
}

// --- Helper: Apply query modifiers ---
static firebase::database::Query ApplyQueryModifiers(
    firebase::database::Query query, FlValue* modifiers) {
  if (modifiers == nullptr ||
      fl_value_get_type(modifiers) != FL_VALUE_TYPE_LIST) {
    return query;
  }
  size_t length = fl_value_get_length(modifiers);
  for (size_t i = 0; i < length; ++i) {
    FlValue* mod = fl_value_get_list_value(modifiers, i);
    if (fl_value_get_type(mod) != FL_VALUE_TYPE_MAP) continue;

    const gchar* type = MapLookupString(mod, "type");
    if (type == nullptr) continue;

    const gchar* name = MapLookupString(mod, "name");
    if (name == nullptr) continue;

    if (strcmp(type, "orderBy") == 0) {
      if (strcmp(name, "orderByChild") == 0) {
        const gchar* path = MapLookupString(mod, "path");
        if (path != nullptr) {
          query = query.OrderByChild(path);
        }
      } else if (strcmp(name, "orderByKey") == 0) {
        query = query.OrderByKey();
      } else if (strcmp(name, "orderByValue") == 0) {
        query = query.OrderByValue();
      } else if (strcmp(name, "orderByPriority") == 0) {
        query = query.OrderByPriority();
      }
    } else if (strcmp(type, "cursor") == 0) {
      Variant cursor_value =
          FlValueToVariant(fl_value_lookup_string(mod, "value"));

      const gchar* child_key = MapLookupString(mod, "key");

      if (strcmp(name, "startAt") == 0) {
        query = child_key ? query.StartAt(cursor_value, child_key)
                          : query.StartAt(cursor_value);
      } else if (strcmp(name, "startAfter") == 0) {
        // C++ SDK doesn't have StartAfter; use StartAt workaround
        query = child_key ? query.StartAt(cursor_value, child_key)
                          : query.StartAt(cursor_value);
      } else if (strcmp(name, "endAt") == 0) {
        query = child_key ? query.EndAt(cursor_value, child_key)
                          : query.EndAt(cursor_value);
      } else if (strcmp(name, "endBefore") == 0) {
        // C++ SDK doesn't have EndBefore; use EndAt workaround
        query = child_key ? query.EndAt(cursor_value, child_key)
                          : query.EndAt(cursor_value);
      }
    } else if (strcmp(type, "limit") == 0) {
      FlValue* limit_value = fl_value_lookup_string(mod, "limit");
      if (limit_value != nullptr &&
          fl_value_get_type(limit_value) == FL_VALUE_TYPE_INT) {
        int64_t limit = fl_value_get_int(limit_value);
        if (strcmp(name, "limitToFirst") == 0) {
          query = query.LimitToFirst(static_cast<size_t>(limit));
        } else if (strcmp(name, "limitToLast") == 0) {
          query = query.LimitToLast(static_cast<size_t>(limit));
        }
      }
    }
  }
  return query;
}

// --- Helper: Get Database instance from Pigeon app ---
static Database* GetDatabaseFromPigeon(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app) {
  const gchar* app_name =
      firebase_database_database_pigeon_firebase_app_get_app_name(app);
  App* firebase_app = App::GetInstance(app_name);
  if (!firebase_app) {
    return nullptr;
  }

  FirebaseDatabaseDatabasePigeonSettings* settings =
      firebase_database_database_pigeon_firebase_app_get_settings(app);
  const gchar* url =
      firebase_database_database_pigeon_firebase_app_get_database_u_r_l(app);

  // Build a cache key from app name + effective URL (like Firestore does)
  std::string effective_url;
  if (url != nullptr && url[0] != '\0') {
    effective_url = url;
  }

  std::string cache_key = std::string(app_name) + "-" + effective_url;

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

  gboolean* persistence_enabled =
      firebase_database_database_pigeon_settings_get_persistence_enabled(
          settings);
  if (persistence_enabled != nullptr) {
    database->set_persistence_enabled(*persistence_enabled);
  }
  gboolean* logging_enabled =
      firebase_database_database_pigeon_settings_get_logging_enabled(settings);
  if (logging_enabled != nullptr && *logging_enabled) {
    database->set_log_level(firebase::kLogLevelDebug);
  }

  // Cache raw pointer. We do NOT take ownership — the C++ SDK manages
  // the Database lifetime via App's CleanupNotifier. This matches the
  // pattern used by firebase_auth and firebase_storage.
  database_instances_[cache_key] = database;

  return database;
}

// --- Helper: Complete a Future<void> by responding on the main thread ---
typedef void (*VoidRespondFn)(
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle*);
typedef void (*ErrorRespondFn)(
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle*, const gchar*,
    const gchar*, FlValue*);

// The response handle is ref'd for the duration of the async operation and
// unref'd after responding (pigeon drops its own reference when the handler
// callback returns).
static void CompleteVoidFuture(
    const Future<void>& future,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    VoidRespondFn respond, ErrorRespondFn respond_error) {
  g_object_ref(response_handle);
  future.OnCompletion([response_handle, respond,
                       respond_error](const Future<void>& completed) {
    int error = completed.error();
    std::string code = GetDatabaseErrorCode(static_cast<Error>(error));
    std::string message =
        completed.error_message() ? completed.error_message() : "Unknown error";
    PostToMainThread([response_handle, respond, respond_error, error, code,
                      message]() {
      if (error == Error::kErrorNone) {
        respond(response_handle);
      } else {
        respond_error(response_handle, code.c_str(), message.c_str(), nullptr);
      }
      g_object_unref(response_handle);
    });
  });
}

// --- Helper: Send an event/error on an event channel from any thread ---
// Takes ownership of @event; takes its own reference on @channel.
static void SendEventOnMainThread(FlEventChannel* channel, FlValue* event) {
  g_object_ref(channel);
  PostToMainThread([channel, event]() {
    fl_event_channel_send(channel, event, nullptr, nullptr);
    fl_value_unref(event);
    g_object_unref(channel);
  });
}

static void SendErrorOnMainThread(FlEventChannel* channel,
                                  const std::string& code,
                                  const std::string& message) {
  g_object_ref(channel);
  PostToMainThread([channel, code, message]() {
    fl_event_channel_send_error(channel, code.c_str(), message.c_str(), nullptr,
                                nullptr, nullptr);
    g_object_unref(channel);
  });
}

// ===== Event channel stream handler =====

// Linux port of the Windows DatabaseGenericStreamHandler: one handler per
// QueryObserve call; the Dart side passes eventType as an argument to the
// EventChannel's listen call, and the handler installs either a value or a
// child listener accordingly.
class DatabaseGenericStreamHandler {
 public:
  explicit DatabaseGenericStreamHandler(firebase::database::Query query)
      : query_(query) {}

  ~DatabaseGenericStreamHandler() {
    // Remove listeners before deleting to avoid dangling pointers in the
    // Database's internal listener list. Query::RemoveXxxListener() checks
    // if (internal_) first, so this is a safe no-op if the Database was
    // already destroyed (the cleanup mechanism nullifies internal_).
    RemoveListeners();
    if (channel_ != nullptr) {
      g_object_unref(channel_);
      channel_ = nullptr;
    }
  }

  // Takes its own reference on @channel.
  void SetChannel(FlEventChannel* channel) {
    channel_ = FL_EVENT_CHANNEL(g_object_ref(channel));
  }

  FlMethodErrorResponse* OnListen(FlValue* args) {
    // Extract eventType from arguments
    std::string event_type = "value";
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      const gchar* requested = MapLookupString(args, "eventType");
      if (requested != nullptr) {
        event_type = requested;
      }
    }

    if (event_type == "value") {
      value_listener_ = new ValueListenerImpl(channel_);
      query_.AddValueListener(value_listener_);
    } else {
      child_listener_ = new ChildListenerImpl(channel_, event_type);
      query_.AddChildListener(child_listener_);
    }
    return nullptr;
  }

  FlMethodErrorResponse* OnCancel(FlValue* args) {
    // The GObject embedder tears the stream down itself once the cancel
    // handler returns, so unlike Windows there is no explicit EndOfStream
    // call here.
    RemoveListeners();
    return nullptr;
  }

 private:
  // Value listener: fires on an SDK thread; events are marshalled to the
  // main thread before being sent on the channel.
  class ValueListenerImpl : public firebase::database::ValueListener {
   public:
    explicit ValueListenerImpl(FlEventChannel* channel) : channel_(channel) {}
    void OnValueChanged(const DataSnapshot& snapshot) override {
      FlValue* event = fl_value_new_map();
      fl_value_set_string_take(event, "eventType",
                               fl_value_new_string("value"));
      fl_value_set_string_take(event, "previousChildKey", fl_value_new_null());
      fl_value_set_string_take(event, "snapshot",
                               DataSnapshotToFlValue(snapshot));
      SendEventOnMainThread(channel_, event);
    }
    void OnCancelled(const Error& error, const char* error_message) override {
      SendErrorOnMainThread(channel_, GetDatabaseErrorCode(error),
                            error_message ? error_message : "Unknown error");
    }

   private:
    FlEventChannel* channel_;  // unowned; the stream handler holds a ref.
  };

  // Child listener: fires on an SDK thread; events are marshalled to the
  // main thread before being sent on the channel.
  class ChildListenerImpl : public firebase::database::ChildListener {
   public:
    ChildListenerImpl(FlEventChannel* channel, const std::string& event_type)
        : channel_(channel), event_type_(event_type) {}
    void OnChildAdded(const DataSnapshot& snapshot, const char* prev) override {
      if (event_type_ == "childAdded") Send("childAdded", snapshot, prev);
    }
    void OnChildChanged(const DataSnapshot& snapshot,
                        const char* prev) override {
      if (event_type_ == "childChanged") Send("childChanged", snapshot, prev);
    }
    void OnChildMoved(const DataSnapshot& snapshot, const char* prev) override {
      if (event_type_ == "childMoved") Send("childMoved", snapshot, prev);
    }
    void OnChildRemoved(const DataSnapshot& snapshot) override {
      if (event_type_ == "childRemoved")
        Send("childRemoved", snapshot, nullptr);
    }
    void OnCancelled(const Error& error, const char* error_message) override {
      SendErrorOnMainThread(channel_, GetDatabaseErrorCode(error),
                            error_message ? error_message : "Unknown error");
    }

   private:
    void Send(const std::string& type, const DataSnapshot& snapshot,
              const char* prev) {
      FlValue* event = fl_value_new_map();
      fl_value_set_string_take(event, "eventType",
                               fl_value_new_string(type.c_str()));
      fl_value_set_string_take(
          event, "previousChildKey",
          prev ? fl_value_new_string(prev) : fl_value_new_null());
      fl_value_set_string_take(event, "snapshot",
                               DataSnapshotToFlValue(snapshot));
      SendEventOnMainThread(channel_, event);
    }
    FlEventChannel* channel_;  // unowned; the stream handler holds a ref.
    std::string event_type_;
  };

  void RemoveListeners() {
    if (value_listener_ != nullptr) {
      query_.RemoveValueListener(value_listener_);
      delete value_listener_;
      value_listener_ = nullptr;
    }
    if (child_listener_ != nullptr) {
      query_.RemoveChildListener(child_listener_);
      delete child_listener_;
      child_listener_ = nullptr;
    }
  }

  firebase::database::Query query_;
  FlEventChannel* channel_ = nullptr;  // owned reference.
  ValueListenerImpl* value_listener_ = nullptr;
  ChildListenerImpl* child_listener_ = nullptr;
};

static FlMethodErrorResponse* OnListenCb(FlEventChannel* channel, FlValue* args,
                                         gpointer user_data) {
  return static_cast<DatabaseGenericStreamHandler*>(user_data)->OnListen(args);
}

static FlMethodErrorResponse* OnCancelCb(FlEventChannel* channel, FlValue* args,
                                         gpointer user_data) {
  return static_cast<DatabaseGenericStreamHandler*>(user_data)->OnCancel(args);
}

// --- Helper: Register an EventChannel with a generated name ---
static std::string RegisterEventChannel(
    const std::string& prefix,
    std::unique_ptr<DatabaseGenericStreamHandler> handler) {
  static int channel_counter = 0;
  std::string channel_name =
      prefix + std::to_string(channel_counter++) + "_" +
      std::to_string(
          std::chrono::system_clock::now().time_since_epoch().count());

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  FlEventChannel* channel = fl_event_channel_new(
      messenger_, channel_name.c_str(), FL_METHOD_CODEC(codec));
  handler->SetChannel(channel);
  fl_event_channel_set_stream_handlers(channel, OnListenCb, OnCancelCb,
                                       handler.get(), nullptr);
  event_channels_[channel_name] = channel;
  stream_handlers_[channel_name] = std::move(handler);
  return channel_name;
}

// atexit handler: clean up Database resources before static destruction.
// 1. Clear event channels to trigger stream handler destruction, which
//    unregisters listeners from the Database while it's still alive.
// 2. Call GoOffline() to close WebSocket connections so thread joins
//    during App::~App() → Database::DeleteInternal() complete quickly.
static void CleanupBeforeStaticDestruction() {
  // Destroy stream handlers and event channels first. This triggers
  // DatabaseGenericStreamHandler destructors which call RemoveValueListener /
  // RemoveChildListener while the Database is still valid.
  stream_handlers_.clear();
  for (auto& pair : event_channels_) {
    if (pair.second != nullptr) {
      g_object_unref(pair.second);
    }
  }
  event_channels_.clear();

  // Disconnect all Database instances to close WebSocket connections.
  for (auto& pair : database_instances_) {
    if (pair.second) {
      pair.second->GoOffline();
    }
  }
  // Give the scheduler thread time to process GoOffline callbacks.
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
}

// ===== Database methods =====

static void HandleGoOnline(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_go_online(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }
  database->GoOnline();
  firebase_database_firebase_database_host_api_respond_go_online(
      response_handle);
}

static void HandleGoOffline(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_go_offline(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }
  database->GoOffline();
  firebase_database_firebase_database_host_api_respond_go_offline(
      response_handle);
}

static void HandleSetPersistenceEnabled(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, gboolean enabled,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_set_persistence_enabled(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }
  database->set_persistence_enabled(enabled);
  firebase_database_firebase_database_host_api_respond_set_persistence_enabled(
      response_handle);
}

static void HandleSetPersistenceCacheSizeBytes(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, int64_t cache_size,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // C++ SDK doesn't directly support setting cache size
  firebase_database_firebase_database_host_api_respond_set_persistence_cache_size_bytes(
      response_handle);
}

static void HandleSetLoggingEnabled(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, gboolean enabled,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_set_logging_enabled(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }
  database->set_log_level(enabled ? firebase::kLogLevelDebug
                                  : firebase::kLogLevelInfo);
  firebase_database_firebase_database_host_api_respond_set_logging_enabled(
      response_handle);
}

static void HandleUseDatabaseEmulator(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, const gchar* host,
    int64_t port,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // The C++ SDK for Realtime Database does not have a UseEmulator API.
  // On Windows, tests run against the live Firebase instance.
  firebase_database_firebase_database_host_api_respond_use_database_emulator(
      response_handle);
}

static void HandleRef(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, const gchar* path,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_ref(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref;
  if (path != nullptr && path[0] != '\0') {
    ref = database->GetReference(path);
  } else {
    ref = database->GetReference();
  }

  std::string ref_path;
  if (ref.key() != nullptr) {
    // Build path from the URL
    std::string url = ref.url();
    // Extract path from URL (after the host)
    auto pos = url.find(".com/");
    if (pos != std::string::npos) {
      ref_path = url.substr(pos + 4);
    } else {
      ref_path = path ? path : "/";
    }
  } else {
    ref_path = path ? path : "/";
  }

  g_autoptr(FirebaseDatabaseDatabaseReferencePlatform) reference =
      firebase_database_database_reference_platform_new(ref_path.c_str());
  firebase_database_firebase_database_host_api_respond_ref(response_handle,
                                                           reference);
}

static void HandleRefFromURL(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, const gchar* url,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_ref_from_u_r_l(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReferenceFromUrl(url);

  std::string ref_path;
  std::string ref_url = ref.url();
  auto pos = ref_url.find(".com/");
  if (pos != std::string::npos) {
    ref_path = ref_url.substr(pos + 4);
  } else {
    ref_path = "/";
  }

  g_autoptr(FirebaseDatabaseDatabaseReferencePlatform) reference =
      firebase_database_database_reference_platform_new(ref_path.c_str());
  firebase_database_firebase_database_host_api_respond_ref_from_u_r_l(
      response_handle, reference);
}

static void HandlePurgeOutstandingWrites(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_purge_outstanding_writes(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }
  database->PurgeOutstandingWrites();
  firebase_database_firebase_database_host_api_respond_purge_outstanding_writes(
      response_handle);
}

// ===== DatabaseReference methods =====

static void HandleDatabaseReferenceSet(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseDatabaseReferenceRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_database_reference_set(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_database_reference_request_get_path(request));
  Variant value = FlValueToVariant(
      firebase_database_database_reference_request_get_value(request));

  CompleteVoidFuture(
      ref.SetValue(value), response_handle,
      firebase_database_firebase_database_host_api_respond_database_reference_set,
      firebase_database_firebase_database_host_api_respond_error_database_reference_set);
}

static void HandleDatabaseReferenceSetWithPriority(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseDatabaseReferenceRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_database_reference_set_with_priority(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_database_reference_request_get_path(request));
  Variant value = FlValueToVariant(
      firebase_database_database_reference_request_get_value(request));
  Variant priority = FlValueToVariant(
      firebase_database_database_reference_request_get_priority(request));

  CompleteVoidFuture(
      ref.SetValueAndPriority(value, priority), response_handle,
      firebase_database_firebase_database_host_api_respond_database_reference_set_with_priority,
      firebase_database_firebase_database_host_api_respond_error_database_reference_set_with_priority);
}

static void HandleDatabaseReferenceUpdate(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseUpdateRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_database_reference_update(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_update_request_get_path(request));
  Variant values =
      FlValueToVariant(firebase_database_update_request_get_value(request));

  CompleteVoidFuture(
      ref.UpdateChildren(values), response_handle,
      firebase_database_firebase_database_host_api_respond_database_reference_update,
      firebase_database_firebase_database_host_api_respond_error_database_reference_update);
}

static void HandleDatabaseReferenceSetPriority(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseDatabaseReferenceRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_database_reference_set_priority(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_database_reference_request_get_path(request));
  Variant priority = FlValueToVariant(
      firebase_database_database_reference_request_get_priority(request));

  CompleteVoidFuture(
      ref.SetPriority(priority), response_handle,
      firebase_database_firebase_database_host_api_respond_database_reference_set_priority,
      firebase_database_firebase_database_host_api_respond_error_database_reference_set_priority);
}

// State shared between the SDK transaction thread and the main thread while
// a Dart transaction handler runs. Lives on the transaction function's stack;
// the SDK thread blocks on the condition variable until the main thread has
// delivered the Dart handler's result.
struct TransactionHandlerState {
  std::mutex mutex;
  std::condition_variable cv;
  bool done = false;
  bool aborted = false;
  bool exception = false;
  FlValue* value = nullptr;                                   // owned
  FlValue* snapshot_value = nullptr;                          // owned
  FirebaseDatabaseFirebaseDatabaseFlutterApi* api = nullptr;  // owned
  int64_t transaction_key = 0;
};

static void OnTransactionHandlerResponse(GObject* object, GAsyncResult* result,
                                         gpointer user_data) {
  auto* state = static_cast<TransactionHandlerState*>(user_data);
  g_autoptr(GError) error = nullptr;
  g_autoptr(
      FirebaseDatabaseFirebaseDatabaseFlutterApiCallTransactionHandlerResponse)
      response =
          firebase_database_firebase_database_flutter_api_call_transaction_handler_finish(
              state->api, result, &error);
  if (response == nullptr ||
      firebase_database_firebase_database_flutter_api_call_transaction_handler_response_is_error(
          response)) {
    // Mirrors the Windows error path: treat a failed handler call as an
    // aborted transaction with an exception.
    state->aborted = true;
    state->exception = true;
  } else {
    FirebaseDatabaseTransactionHandlerResult* handler_result =
        firebase_database_firebase_database_flutter_api_call_transaction_handler_response_get_return_value(
            response);
    FlValue* value =
        firebase_database_transaction_handler_result_get_value(handler_result);
    if (value != nullptr && fl_value_get_type(value) != FL_VALUE_TYPE_NULL) {
      state->value = fl_value_ref(value);
    }
    state->aborted = firebase_database_transaction_handler_result_get_aborted(
        handler_result);
    state->exception =
        firebase_database_transaction_handler_result_get_exception(
            handler_result);
  }
  {
    // Notify while holding the lock: the SDK thread destroys the
    // stack-allocated state as soon as it observes done == true, so
    // notifying after unlocking could touch a destroyed condition_variable.
    std::lock_guard<std::mutex> lock(state->mutex);
    state->done = true;
    state->cv.notify_one();
  }
}

// Transaction function: runs on an SDK thread. Calls the Dart transaction
// handler on the main thread and blocks until it responds, mirroring the
// semaphore-based Windows implementation.
static firebase::database::TransactionResult DoTransaction(MutableData* data,
                                                           void* context) {
  auto* transaction_key = static_cast<int64_t*>(context);

  TransactionHandlerState state;
  state.transaction_key = *transaction_key;
  state.snapshot_value = VariantToFlValue(data->value());

  TransactionHandlerState* state_ptr = &state;
  PostToMainThread([state_ptr]() {
    state_ptr->api = firebase_database_firebase_database_flutter_api_new(
        messenger_, nullptr);
    FlValue* snapshot_ptr =
        fl_value_get_type(state_ptr->snapshot_value) == FL_VALUE_TYPE_NULL
            ? nullptr
            : state_ptr->snapshot_value;
    firebase_database_firebase_database_flutter_api_call_transaction_handler(
        state_ptr->api, state_ptr->transaction_key, snapshot_ptr, nullptr,
        OnTransactionHandlerResponse, state_ptr);
  });

  // Wait for the Flutter callback to complete
  {
    std::unique_lock<std::mutex> lock(state.mutex);
    state.cv.wait(lock, [&] { return state.done; });
  }

  firebase::database::TransactionResult transaction_result;
  if (state.aborted || state.exception) {
    transaction_result = firebase::database::kTransactionResultAbort;
  } else {
    // Apply the result value
    if (state.value != nullptr) {
      data->set_value(FlValueToVariant(state.value));
    } else {
      data->set_value(Variant::Null());
    }
    transaction_result = firebase::database::kTransactionResultSuccess;
  }

  if (state.value != nullptr) fl_value_unref(state.value);
  fl_value_unref(state.snapshot_value);
  if (state.api != nullptr) g_object_unref(state.api);
  return transaction_result;
}

static void HandleDatabaseReferenceRunTransaction(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseTransactionRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_database_reference_run_transaction(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_transaction_request_get_path(request));
  int64_t transaction_key =
      firebase_database_transaction_request_get_transaction_key(request);
  bool apply_locally =
      firebase_database_transaction_request_get_apply_locally(request);

  auto* key_context = new int64_t(transaction_key);
  ref.RunTransaction(DoTransaction, key_context, apply_locally);

  // Wait for the transaction to complete
  g_object_ref(response_handle);
  ref.RunTransactionLastResult().OnCompletion([response_handle, transaction_key,
                                               key_context](
                                                  const Future<DataSnapshot>&
                                                      future) {
    delete key_context;
    if (future.error() == Error::kErrorNone) {
      const DataSnapshot* snapshot = future.result();
      FlValue* result_map = fl_value_new_map();
      fl_value_set_string_take(result_map, "committed",
                               fl_value_new_bool(TRUE));
      if (snapshot != nullptr) {
        fl_value_set_string_take(result_map, "snapshot",
                                 DataSnapshotToFlValue(*snapshot));
      } else {
        fl_value_set_string_take(result_map, "snapshot", fl_value_new_null());
      }
      PostToMainThread([response_handle, transaction_key, result_map]() {
        transaction_results_[transaction_key] = result_map;
        firebase_database_firebase_database_host_api_respond_database_reference_run_transaction(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      // Transaction failed but may have been aborted
      FlValue* result_map = EmptyTransactionResult();
      int error = future.error();
      std::string code = GetDatabaseErrorCode(static_cast<Error>(error));
      std::string message =
          future.error_message() ? future.error_message() : "Unknown error";
      PostToMainThread([response_handle, transaction_key, result_map, error,
                        code, message]() {
        transaction_results_[transaction_key] = result_map;
        if (static_cast<Error>(error) ==
            Error::kErrorTransactionAbortedByUser) {
          // Aborted by user is not an error condition
          firebase_database_firebase_database_host_api_respond_database_reference_run_transaction(
              response_handle);
        } else {
          firebase_database_firebase_database_host_api_respond_error_database_reference_run_transaction(
              response_handle, code.c_str(), message.c_str(), nullptr);
        }
        g_object_unref(response_handle);
      });
    }
  });
}

static void HandleDatabaseReferenceGetTransactionResult(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, int64_t transaction_key,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  auto it = transaction_results_.find(transaction_key);
  if (it != transaction_results_.end()) {
    FlValue* result = it->second;
    firebase_database_firebase_database_host_api_respond_database_reference_get_transaction_result(
        response_handle, result);
    fl_value_unref(result);
    transaction_results_.erase(it);
  } else {
    // Return default result
    g_autoptr(FlValue) default_result = EmptyTransactionResult();
    firebase_database_firebase_database_host_api_respond_database_reference_get_transaction_result(
        response_handle, default_result);
  }
}

// ===== OnDisconnect methods =====

static void HandleOnDisconnectSet(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseDatabaseReferenceRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_on_disconnect_set(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_database_reference_request_get_path(request));
  Variant value = FlValueToVariant(
      firebase_database_database_reference_request_get_value(request));

  CompleteVoidFuture(
      ref.OnDisconnect()->SetValue(value), response_handle,
      firebase_database_firebase_database_host_api_respond_on_disconnect_set,
      firebase_database_firebase_database_host_api_respond_error_on_disconnect_set);
}

static void HandleOnDisconnectSetWithPriority(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseDatabaseReferenceRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_on_disconnect_set_with_priority(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_database_reference_request_get_path(request));
  Variant value = FlValueToVariant(
      firebase_database_database_reference_request_get_value(request));
  Variant priority = FlValueToVariant(
      firebase_database_database_reference_request_get_priority(request));

  CompleteVoidFuture(
      ref.OnDisconnect()->SetValueAndPriority(value, priority), response_handle,
      firebase_database_firebase_database_host_api_respond_on_disconnect_set_with_priority,
      firebase_database_firebase_database_host_api_respond_error_on_disconnect_set_with_priority);
}

static void HandleOnDisconnectUpdate(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseUpdateRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_on_disconnect_update(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(
      firebase_database_update_request_get_path(request));
  Variant values =
      FlValueToVariant(firebase_database_update_request_get_value(request));

  CompleteVoidFuture(
      ref.OnDisconnect()->UpdateChildren(values), response_handle,
      firebase_database_firebase_database_host_api_respond_on_disconnect_update,
      firebase_database_firebase_database_host_api_respond_error_on_disconnect_update);
}

static void HandleOnDisconnectCancel(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app, const gchar* path,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_on_disconnect_cancel(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref = database->GetReference(path);

  CompleteVoidFuture(
      ref.OnDisconnect()->Cancel(), response_handle,
      firebase_database_firebase_database_host_api_respond_on_disconnect_cancel,
      firebase_database_firebase_database_host_api_respond_error_on_disconnect_cancel);
}

// ===== Query methods =====

static void HandleQueryObserve(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseQueryRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_query_observe(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref =
      database->GetReference(firebase_database_query_request_get_path(request));
  firebase::database::Query query = ApplyQueryModifiers(
      ref, firebase_database_query_request_get_modifiers(request));

  // The event type will be passed as an argument when the Dart side calls
  // listen on the EventChannel; the stream handler reads it from the listen
  // arguments (see DatabaseGenericStreamHandler).
  auto handler = std::make_unique<DatabaseGenericStreamHandler>(query);
  std::string channel_name = RegisterEventChannel(
      "plugins.flutter.io/firebase_database/query/", std::move(handler));

  firebase_database_firebase_database_host_api_respond_query_observe(
      response_handle, channel_name.c_str());
}

static void HandleQueryKeepSynced(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseQueryRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_query_keep_synced(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref =
      database->GetReference(firebase_database_query_request_get_path(request));
  firebase::database::Query query = ApplyQueryModifiers(
      ref, firebase_database_query_request_get_modifiers(request));

  gboolean* value = firebase_database_query_request_get_value(request);
  bool keep_synced = value != nullptr ? *value : false;
  query.SetKeepSynchronized(keep_synced);
  firebase_database_firebase_database_host_api_respond_query_keep_synced(
      response_handle);
}

static void HandleQueryGet(
    FirebaseDatabaseDatabasePigeonFirebaseApp* app,
    FirebaseDatabaseQueryRequest* request,
    FirebaseDatabaseFirebaseDatabaseHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Database* database = GetDatabaseFromPigeon(app);
  if (!database) {
    firebase_database_firebase_database_host_api_respond_error_query_get(
        response_handle, "unknown", "Database instance not found", nullptr);
    return;
  }

  DatabaseReference ref =
      database->GetReference(firebase_database_query_request_get_path(request));
  firebase::database::Query query = ApplyQueryModifiers(
      ref, firebase_database_query_request_get_modifiers(request));

  g_object_ref(response_handle);
  query.GetValue().OnCompletion([response_handle](
                                    const Future<DataSnapshot>& future) {
    if (future.error() == Error::kErrorNone) {
      const DataSnapshot* snapshot = future.result();
      FlValue* result_map = fl_value_new_map();
      if (snapshot != nullptr) {
        fl_value_set_string_take(result_map, "snapshot",
                                 DataSnapshotToFlValue(*snapshot));
      } else {
        fl_value_set_string_take(result_map, "snapshot", fl_value_new_null());
      }
      PostToMainThread([response_handle, result_map]() {
        firebase_database_firebase_database_host_api_respond_query_get(
            response_handle, result_map);
        fl_value_unref(result_map);
        g_object_unref(response_handle);
      });
    } else {
      std::string code =
          GetDatabaseErrorCode(static_cast<Error>(future.error()));
      std::string message =
          future.error_message() ? future.error_message() : "Unknown error";
      PostToMainThread([response_handle, code, message]() {
        firebase_database_firebase_database_host_api_respond_error_query_get(
            response_handle, code.c_str(), message.c_str(), nullptr);
        g_object_unref(response_handle);
      });
    }
  });
}

static const FirebaseDatabaseFirebaseDatabaseHostApiVTable kHostApiVTable = {
    HandleGoOnline,                          // go_online
    HandleGoOffline,                         // go_offline
    HandleSetPersistenceEnabled,             // set_persistence_enabled
    HandleSetPersistenceCacheSizeBytes,      // set_persistence_cache_size_bytes
    HandleSetLoggingEnabled,                 // set_logging_enabled
    HandleUseDatabaseEmulator,               // use_database_emulator
    HandleRef,                               // ref
    HandleRefFromURL,                        // ref_from_u_r_l
    HandlePurgeOutstandingWrites,            // purge_outstanding_writes
    HandleDatabaseReferenceSet,              // database_reference_set
    HandleDatabaseReferenceSetWithPriority,  // database_reference_set_with_priority
    HandleDatabaseReferenceUpdate,           // database_reference_update
    HandleDatabaseReferenceSetPriority,      // database_reference_set_priority
    HandleDatabaseReferenceRunTransaction,  // database_reference_run_transaction
    HandleDatabaseReferenceGetTransactionResult,  // database_reference_get_transaction_result
    HandleOnDisconnectSet,                        // on_disconnect_set
    HandleOnDisconnectSetWithPriority,  // on_disconnect_set_with_priority
    HandleOnDisconnectUpdate,           // on_disconnect_update
    HandleOnDisconnectCancel,           // on_disconnect_cancel
    HandleQueryObserve,                 // query_observe
    HandleQueryKeepSynced,              // query_keep_synced
    HandleQueryGet,                     // query_get
};

static void firebase_database_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(firebase_database_plugin_parent_class)->dispose(object);
}

static void firebase_database_plugin_class_init(
    FirebaseDatabasePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = firebase_database_plugin_dispose;
}

static void firebase_database_plugin_init(FirebaseDatabasePlugin* self) {}

void firebase_database_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FirebaseDatabasePlugin* plugin = FIREBASE_DATABASE_PLUGIN(
      g_object_new(firebase_database_plugin_get_type(), nullptr));

  messenger_ = fl_plugin_registrar_get_messenger(registrar);
  firebase_database_firebase_database_host_api_set_method_handlers(
      messenger_, /* suffix= */ nullptr, &kHostApiVTable, g_object_ref(plugin),
      g_object_unref);

  g_object_unref(plugin);

  App::RegisterLibrary(kLibraryName,
                       firebase_database_linux::getPluginVersion().c_str(),
                       nullptr);

  // Register atexit handler to clean up listeners and disconnect
  // before static destruction triggers thread joins in the C++ SDK.
  std::atexit(CleanupBeforeStaticDestruction);
}
