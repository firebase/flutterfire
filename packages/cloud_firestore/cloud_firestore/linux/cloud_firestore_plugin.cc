// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/cloud_firestore/cloud_firestore_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <chrono>
#include <condition_variable>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "cloud_firestore/plugin_version.h"
#include "firebase/app.h"
#include "firebase/firestore.h"
#include "firebase/firestore/filter.h"
#include "firebase/log.h"
#include "firebase_core/firebase_core_plugin.h"
#include "firebase_core/flutter_firebase_plugin.h"
#include "firestore_codec.h"
#include "messages.g.h"

using firebase::App;
using firebase::Future;
using firebase::firestore::AggregateQuerySnapshot;
using firebase::firestore::DocumentReference;
using firebase::firestore::DocumentSnapshot;
using firebase::firestore::Error;
using firebase::firestore::FieldPath;
using firebase::firestore::FieldValue;
using firebase::firestore::Filter;
using firebase::firestore::Firestore;
using firebase::firestore::ListenerRegistration;
using firebase::firestore::LoadBundleTaskProgress;
using firebase::firestore::MapFieldPathValue;
using firebase::firestore::MapFieldValue;
using firebase::firestore::MetadataChanges;
using firebase::firestore::Query;
using firebase::firestore::QuerySnapshot;
using firebase::firestore::SetOptions;
using firebase::firestore::Transaction;
using firebase::firestore::TransactionOptions;

using cloud_firestore_linux::ConvertFieldValueToFlValue;
using cloud_firestore_linux::ConvertToFieldPathVector;
using cloud_firestore_linux::ConvertToFieldValue;
using cloud_firestore_linux::ConvertToFieldValueList;
using cloud_firestore_linux::ConvertToMapFieldPathValue;
using cloud_firestore_linux::ConvertToMapFieldValue;
using cloud_firestore_linux::FirestoreInstanceCache;
using cloud_firestore_linux::GetCustomFieldPath;

static const char kLibraryName[] = "flutter-fire-fst";

#define CLOUD_FIRESTORE_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), cloud_firestore_plugin_get_type(), \
                              CloudFirestorePlugin))

struct _CloudFirestorePlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(CloudFirestorePlugin, cloud_firestore_plugin, g_object_get_type())

namespace {

FlBinaryMessenger* messenger_ = nullptr;

// -----------------------------------------------------------------------------
// Platform-thread dispatch.
//
// Firebase future/listener callbacks run on SDK worker threads, but all
// Flutter messaging (Pigeon responses and event-channel sends) must happen on
// the platform thread. On Linux the platform thread runs the GLib main loop,
// so g_idle_add is the equivalent of the Windows message-window dispatcher.
// -----------------------------------------------------------------------------

void PostToMainThread(std::function<void()> task) {
  auto* heap_task = new std::function<void()>(std::move(task));
  g_idle_add_full(
      G_PRIORITY_DEFAULT,
      [](gpointer data) -> gboolean {
        (*static_cast<std::function<void()>*>(data))();
        return G_SOURCE_REMOVE;
      },
      heap_task,
      [](gpointer data) { delete static_cast<std::function<void()>*>(data); });
}

// -----------------------------------------------------------------------------
// Event channels.
// -----------------------------------------------------------------------------

struct EventChannelState {
  std::mutex mutex;
  FlEventChannel* channel = nullptr;  // Owned reference while active.
  bool active = false;
};

void SendSuccessOnPlatformThread(std::shared_ptr<EventChannelState> state,
                                 FlValue* value /* transfer full */) {
  if (!state) {
    if (value != nullptr) fl_value_unref(value);
    return;
  }

  PostToMainThread([state, value]() {
    std::lock_guard<std::mutex> lock(state->mutex);
    if (state->active && state->channel != nullptr) {
      fl_event_channel_send(state->channel, value, nullptr, nullptr);
    }
    if (value != nullptr) fl_value_unref(value);
  });
}

void SendErrorOnPlatformThread(std::shared_ptr<EventChannelState> state,
                               const std::string& code,
                               const std::string& message,
                               FlValue* details /* transfer full, nullable */,
                               bool end_stream = false) {
  if (!state) {
    if (details != nullptr) fl_value_unref(details);
    return;
  }

  PostToMainThread([state, code, message, details, end_stream]() {
    std::lock_guard<std::mutex> lock(state->mutex);
    if (state->active && state->channel != nullptr) {
      fl_event_channel_send_error(state->channel, code.c_str(), message.c_str(),
                                  details, nullptr, nullptr);
      if (end_stream) {
        fl_event_channel_send_end_of_stream(state->channel, nullptr, nullptr);
        g_clear_object(&state->channel);
        state->active = false;
      }
    }
    if (details != nullptr) fl_value_unref(details);
  });
}

void EndStreamOnPlatformThread(std::shared_ptr<EventChannelState> state) {
  if (!state) {
    return;
  }

  PostToMainThread([state]() {
    std::lock_guard<std::mutex> lock(state->mutex);
    if (state->active && state->channel != nullptr) {
      fl_event_channel_send_end_of_stream(state->channel, nullptr, nullptr);
      g_clear_object(&state->channel);
      state->active = false;
    }
  });
}

// Base class mirroring flutter::StreamHandler on Windows.
class EventStreamHandler {
 public:
  virtual ~EventStreamHandler() = default;
  virtual FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                          FlValue* arguments) = 0;
  virtual FlMethodErrorResponse* OnCancel(FlValue* arguments) = 0;
};

std::map<std::string, FlEventChannel*> event_channels_;
std::map<std::string, std::unique_ptr<EventStreamHandler>> stream_handlers_;

FlMethodErrorResponse* EventChannelListenCb(FlEventChannel* channel,
                                            FlValue* args, gpointer user_data) {
  return static_cast<EventStreamHandler*>(user_data)->OnListen(channel, args);
}

FlMethodErrorResponse* EventChannelCancelCb(FlEventChannel* channel,
                                            FlValue* args, gpointer user_data) {
  return static_cast<EventStreamHandler*>(user_data)->OnCancel(args);
}

std::string RegisterEventChannelWithUUID(
    std::string prefix, std::string uuid,
    std::unique_ptr<EventStreamHandler> handler) {
  std::string channel_name = prefix + uuid;

  g_autoptr(FlStandardMessageCodec) message_codec =
      FL_STANDARD_MESSAGE_CODEC(cloud_firestore_message_codec_new());
  g_autoptr(FlStandardMethodCodec) codec =
      fl_standard_method_codec_new_with_message_codec(message_codec);

  FlEventChannel* channel = fl_event_channel_new(
      messenger_, channel_name.c_str(), FL_METHOD_CODEC(codec));

  EventStreamHandler* raw_handler = handler.get();
  stream_handlers_[channel_name] = std::move(handler);
  event_channels_[channel_name] = channel;

  fl_event_channel_set_stream_handlers(channel, EventChannelListenCb,
                                       EventChannelCancelCb, raw_handler,
                                       nullptr);

  return uuid;
}

std::string RegisterEventChannel(std::string prefix,
                                 std::unique_ptr<EventStreamHandler> handler) {
  g_autofree gchar* uuid = g_uuid_string_random();
  return RegisterEventChannelWithUUID(prefix, uuid, std::move(handler));
}

// -----------------------------------------------------------------------------
// Firestore helpers.
// -----------------------------------------------------------------------------

bool HasValue(FlValue* value) {
  return value != nullptr && fl_value_get_type(value) != FL_VALUE_TYPE_NULL;
}

Firestore* GetFirestoreFromPigeon(
    CloudFirestoreFirestorePigeonFirebaseApp* pigeon_app) {
  const gchar* app_name =
      cloud_firestore_firestore_pigeon_firebase_app_get_app_name(pigeon_app);
  const gchar* database_url =
      cloud_firestore_firestore_pigeon_firebase_app_get_database_u_r_l(
          pigeon_app);
  std::string cache_key = std::string(app_name) + "-" + database_url;

  auto& instances = FirestoreInstanceCache();
  if (instances.find(cache_key) != instances.end()) {
    return instances[cache_key].get();
  }

  App* app = App::GetInstance(app_name);

  Firestore* firestore = Firestore::GetInstance(app, database_url);

  CloudFirestoreInternalFirebaseSettings* pigeon_settings =
      cloud_firestore_firestore_pigeon_firebase_app_get_settings(pigeon_app);

  firebase::firestore::Settings settings;

  gboolean* persistence_enabled =
      cloud_firestore_internal_firebase_settings_get_persistence_enabled(
          pigeon_settings);
  if (persistence_enabled != nullptr && *persistence_enabled) {
    // This is the maximum amount of cache allowed. We use the same number on
    // android.
    int64_t size = 104857600;

    int64_t* cache_size_bytes =
        cloud_firestore_internal_firebase_settings_get_cache_size_bytes(
            pigeon_settings);
    if (cache_size_bytes != nullptr && *cache_size_bytes != -1) {
      size = *cache_size_bytes;
    }

    settings.set_cache_size_bytes(size);
  }

  const gchar* host =
      cloud_firestore_internal_firebase_settings_get_host(pigeon_settings);
  if (host != nullptr) {
    settings.set_host(host);

    // Only allow changing ssl if host is also specified.
    settings.set_ssl_enabled(false);
  }

  firestore->set_settings(settings);

  instances[cache_key] = std::unique_ptr<Firestore>(firestore);

  return firestore;
}

std::string GetErrorCode(Error error) {
  switch (error) {
    case firebase::firestore::kErrorOk:
      return "ok";
    case firebase::firestore::kErrorCancelled:
      return "cancelled";
    case firebase::firestore::kErrorUnknown:
      return "unknown";
    case firebase::firestore::kErrorInvalidArgument:
      return "invalid-argument";
    case firebase::firestore::kErrorDeadlineExceeded:
      return "deadline-exceeded";
    case firebase::firestore::kErrorNotFound:
      return "not-found";
    case firebase::firestore::kErrorAlreadyExists:
      return "already-exists";
    case firebase::firestore::kErrorPermissionDenied:
      return "permission-denied";
    case firebase::firestore::kErrorResourceExhausted:
      return "resource-exhausted";
    case firebase::firestore::kErrorFailedPrecondition:
      return "failed-precondition";
    case firebase::firestore::kErrorAborted:
      return "aborted";
    case firebase::firestore::kErrorOutOfRange:
      return "out-of-range";
    case firebase::firestore::kErrorUnimplemented:
      return "unimplemented";
    case firebase::firestore::kErrorInternal:
      return "internal";
    case firebase::firestore::kErrorUnavailable:
      return "unavailable";
    case firebase::firestore::kErrorDataLoss:
      return "data-loss";
    case firebase::firestore::kErrorUnauthenticated:
      return "unauthenticated";
    default:
      return "unknown-error";
  }
}

// Builds the FlutterError details map used on Windows
// (FlutterError("firebase_firestore", message, {code, message})).
// Ownership: returns a new reference (transfer full).
FlValue* ParseErrorDetails(const std::string& error_code,
                           const std::string& message) {
  FlValue* details = fl_value_new_map();
  fl_value_set_take(details, fl_value_new_string("code"),
                    fl_value_new_string(error_code.c_str()));
  fl_value_set_take(details, fl_value_new_string("message"),
                    fl_value_new_string(message.c_str()));
  return details;
}

typedef void (*RespondErrorFn)(
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    const gchar* code, const gchar* message, FlValue* details);

// Responds with the Firestore error of a completed future on the platform
// thread and releases the (owned) response handle reference.
void RespondFutureErrorOnMainThread(
    RespondErrorFn respond_error,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    const firebase::FutureBase& completed_future) {
  const Error error_code = static_cast<const Error>(completed_future.error());
  std::string error_code_string = GetErrorCode(error_code);
  std::string message = completed_future.error_message();

  PostToMainThread([respond_error, response_handle, error_code_string,
                    message]() {
    g_autoptr(FlValue) details = ParseErrorDetails(error_code_string, message);
    respond_error(response_handle, "firebase_firestore", message.c_str(),
                  details);
    g_object_unref(response_handle);
  });
}

firebase::firestore::Source GetSourceFromPigeon(
    CloudFirestoreSource pigeon_source) {
  switch (pigeon_source) {
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_SOURCE_SERVER:
      return firebase::firestore::Source::kServer;
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_SOURCE_CACHE:
      return firebase::firestore::Source::kCache;
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_SOURCE_SERVER_AND_CACHE:
    default:
      return firebase::firestore::Source::kDefault;
  }
}

DocumentSnapshot::ServerTimestampBehavior GetServerTimestampBehaviorFromPigeon(
    CloudFirestoreServerTimestampBehavior pigeon_server_timestamp_behavior) {
  switch (pigeon_server_timestamp_behavior) {
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_SERVER_TIMESTAMP_BEHAVIOR_ESTIMATE:
      return DocumentSnapshot::ServerTimestampBehavior::kEstimate;
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_SERVER_TIMESTAMP_BEHAVIOR_PREVIOUS:
      return DocumentSnapshot::ServerTimestampBehavior::kPrevious;
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_SERVER_TIMESTAMP_BEHAVIOR_NONE:
    default:
      return DocumentSnapshot::ServerTimestampBehavior::kNone;
  }
}

// Ownership: returns a new reference (transfer full).
CloudFirestoreInternalSnapshotMetadata* ParseSnapshotMetadata(
    const firebase::firestore::SnapshotMetadata& metadata) {
  return cloud_firestore_internal_snapshot_metadata_new(
      metadata.has_pending_writes(), metadata.is_from_cache());
}

// Ownership: returns a new reference (transfer full).
CloudFirestoreInternalDocumentSnapshot* ParseDocumentSnapshot(
    const DocumentSnapshot& document,
    DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior) {
  g_autoptr(FlValue) data =
      cloud_firestore_linux::ConvertMapFieldValueToFlValue(
          document.GetData(server_timestamp_behavior));
  g_autoptr(CloudFirestoreInternalSnapshotMetadata) metadata =
      ParseSnapshotMetadata(document.metadata());

  if (fl_value_get_length(data) == 0) {
    return cloud_firestore_internal_document_snapshot_new(
        document.reference().path().c_str(), nullptr, metadata);
  }

  return cloud_firestore_internal_document_snapshot_new(
      document.reference().path().c_str(), data, metadata);
}

// Ownership: returns a new reference (transfer full).
FlValue* ParseDocumentSnapshots(
    const std::vector<DocumentSnapshot>& documents,
    DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior) {
  FlValue* snapshots = fl_value_new_list();

  for (const auto& document : documents) {
    g_autoptr(CloudFirestoreInternalDocumentSnapshot) snapshot =
        ParseDocumentSnapshot(document, server_timestamp_behavior);
    fl_value_append_take(snapshots,
                         fl_value_new_custom_object(
                             cloud_firestore_internal_document_snapshot_type_id,
                             G_OBJECT(snapshot)));
  }
  return snapshots;
}

CloudFirestoreDocumentChangeType ParseDocumentChangeType(
    const firebase::firestore::DocumentChange::Type& type) {
  switch (type) {
    case firebase::firestore::DocumentChange::Type::kAdded:
      return CLOUD_FIRESTORE_PLATFORM_INTERFACE_DOCUMENT_CHANGE_TYPE_ADDED;
    case firebase::firestore::DocumentChange::Type::kRemoved:
      return CLOUD_FIRESTORE_PLATFORM_INTERFACE_DOCUMENT_CHANGE_TYPE_REMOVED;
    case firebase::firestore::DocumentChange::Type::kModified:
      return CLOUD_FIRESTORE_PLATFORM_INTERFACE_DOCUMENT_CHANGE_TYPE_MODIFIED;
  }

  return CLOUD_FIRESTORE_PLATFORM_INTERFACE_DOCUMENT_CHANGE_TYPE_ADDED;
}

// Ownership: returns a new reference (transfer full).
CloudFirestoreInternalDocumentChange* ParseDocumentChange(
    const firebase::firestore::DocumentChange& document_change,
    DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior) {
  g_autoptr(CloudFirestoreInternalDocumentSnapshot) document =
      ParseDocumentSnapshot(document_change.document(),
                            server_timestamp_behavior);
  return cloud_firestore_internal_document_change_new(
      ParseDocumentChangeType(document_change.type()), document,
      document_change.old_index(), document_change.new_index());
}

// Ownership: returns a new reference (transfer full).
FlValue* ParseDocumentChanges(
    const std::vector<firebase::firestore::DocumentChange>& document_changes,
    DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior) {
  FlValue* changes = fl_value_new_list();
  for (const auto& document_change : document_changes) {
    g_autoptr(CloudFirestoreInternalDocumentChange) change =
        ParseDocumentChange(document_change, server_timestamp_behavior);
    fl_value_append_take(changes,
                         fl_value_new_custom_object(
                             cloud_firestore_internal_document_change_type_id,
                             G_OBJECT(change)));
  }
  return changes;
}

// Ownership: returns a new reference (transfer full).
CloudFirestoreInternalQuerySnapshot* ParseQuerySnapshot(
    const QuerySnapshot* query_snapshot,
    DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior) {
  g_autoptr(FlValue) documents = ParseDocumentSnapshots(
      query_snapshot->documents(), server_timestamp_behavior);
  g_autoptr(FlValue) document_changes = ParseDocumentChanges(
      query_snapshot->DocumentChanges(), server_timestamp_behavior);
  g_autoptr(CloudFirestoreInternalSnapshotMetadata) metadata =
      ParseSnapshotMetadata(query_snapshot->metadata());

  return cloud_firestore_internal_query_snapshot_new(
      documents, document_changes, metadata);
}

Filter FilterFromJson(FlValue* map) {
  FlValue* field_path_value = fl_value_lookup_string(map, "fieldPath");
  if (HasValue(field_path_value)) {
    // Deserialize a FilterQuery
    std::string op = fl_value_get_string(fl_value_lookup_string(map, "op"));
    const FieldPath& field_path = GetCustomFieldPath(field_path_value);

    FlValue* value = fl_value_lookup_string(map, "value");

    // All the operators from Firebase
    if (op == "==") {
      return Filter::EqualTo(field_path, ConvertToFieldValue(value));
    } else if (op == "!=") {
      return Filter::NotEqualTo(field_path, ConvertToFieldValue(value));
    } else if (op == "<") {
      return Filter::LessThan(field_path, ConvertToFieldValue(value));
    } else if (op == "<=") {
      return Filter::LessThanOrEqualTo(field_path, ConvertToFieldValue(value));
    } else if (op == ">") {
      return Filter::GreaterThan(field_path, ConvertToFieldValue(value));
    } else if (op == ">=") {
      return Filter::GreaterThanOrEqualTo(field_path,
                                          ConvertToFieldValue(value));
    } else if (op == "array-contains") {
      return Filter::ArrayContains(field_path, ConvertToFieldValue(value));
    } else if (op == "array-contains-any") {
      return Filter::ArrayContainsAny(field_path,
                                      ConvertToFieldValueList(value));
    } else if (op == "in") {
      return Filter::In(field_path, ConvertToFieldValueList(value));
    } else if (op == "not-in") {
      return Filter::NotIn(field_path, ConvertToFieldValueList(value));
    } else {
      throw std::runtime_error("Invalid operator");
    }
  }

  // Deserialize a FilterOperator
  std::string op = fl_value_get_string(fl_value_lookup_string(map, "op"));

  FlValue* queries = fl_value_lookup_string(map, "queries");
  std::vector<Filter> parsed_filters;
  size_t length = fl_value_get_length(queries);
  for (size_t i = 0; i < length; ++i) {
    parsed_filters.push_back(
        FilterFromJson(fl_value_get_list_value(queries, i)));
  }

  if (op == "OR") {
    return Filter::Or(parsed_filters);
  } else if (op == "AND") {
    return Filter::And(parsed_filters);
  }

  throw std::runtime_error("Invalid operator");
}

Query ParseQuery(Firestore* firestore, const std::string& path,
                 bool is_collection_group,
                 CloudFirestoreInternalQueryParameters* parameters) {
  try {
    Query query;

    if (is_collection_group) {
      query = firestore->CollectionGroup(path);
    } else {
      query = firestore->Collection(path);
    }

    FlValue* filters =
        cloud_firestore_internal_query_parameters_get_filters(parameters);
    if (HasValue(filters)) {
      query = query.Where(FilterFromJson(filters));
    }

    FlValue* where =
        cloud_firestore_internal_query_parameters_get_where(parameters);
    size_t where_length = HasValue(where) ? fl_value_get_length(where) : 0;
    for (size_t i = 0; i < where_length; ++i) {
      FlValue* condition = fl_value_get_list_value(where, i);
      const FieldPath& field_path =
          GetCustomFieldPath(fl_value_get_list_value(condition, 0));
      std::string op =
          fl_value_get_string(fl_value_get_list_value(condition, 1));
      FlValue* value = fl_value_get_list_value(condition, 2);

      if (op == "==") {
        query = query.WhereEqualTo(field_path, ConvertToFieldValue(value));
      } else if (op == "!=") {
        query = query.WhereNotEqualTo(field_path, ConvertToFieldValue(value));
      } else if (op == "<") {
        query = query.WhereLessThan(field_path, ConvertToFieldValue(value));
      } else if (op == "<=") {
        query = query.WhereLessThanOrEqualTo(field_path,
                                             ConvertToFieldValue(value));
      } else if (op == ">") {
        query = query.WhereGreaterThan(field_path, ConvertToFieldValue(value));
      } else if (op == ">=") {
        query = query.WhereGreaterThanOrEqualTo(field_path,
                                                ConvertToFieldValue(value));
      } else if (op == "array-contains") {
        query =
            query.WhereArrayContains(field_path, ConvertToFieldValue(value));
      } else if (op == "array-contains-any") {
        query = query.WhereArrayContainsAny(field_path,
                                            ConvertToFieldValueList(value));
      } else if (op == "in") {
        query = query.WhereIn(field_path, ConvertToFieldValueList(value));
      } else if (op == "not-in") {
        query = query.WhereNotIn(field_path, ConvertToFieldValueList(value));
      } else {
        throw std::runtime_error("Unknown operator");
      }
    }

    int64_t* limit =
        cloud_firestore_internal_query_parameters_get_limit(parameters);
    if (limit != nullptr) {
      query = query.Limit(static_cast<int32_t>(*limit));
    }

    int64_t* limit_to_last =
        cloud_firestore_internal_query_parameters_get_limit_to_last(parameters);
    if (limit_to_last != nullptr) {
      query = query.LimitToLast(static_cast<int32_t>(*limit_to_last));
    }

    FlValue* order_by =
        cloud_firestore_internal_query_parameters_get_order_by(parameters);
    if (!HasValue(order_by)) {
      return query;
    }

    size_t order_by_length = fl_value_get_length(order_by);
    for (size_t i = 0; i < order_by_length; ++i) {
      FlValue* order = fl_value_get_list_value(order_by, i);
      const FieldPath& field_path =
          GetCustomFieldPath(fl_value_get_list_value(order, 0));
      bool direction = fl_value_get_bool(fl_value_get_list_value(order, 1));

      if (direction) {
        query = query.OrderBy(field_path, Query::Direction::kDescending);
      } else {
        query = query.OrderBy(field_path, Query::Direction::kAscending);
      }
    }

    FlValue* start_at =
        cloud_firestore_internal_query_parameters_get_start_at(parameters);
    if (HasValue(start_at)) {
      query = query.StartAt(ConvertToFieldValueList(start_at));
    }
    FlValue* start_after =
        cloud_firestore_internal_query_parameters_get_start_after(parameters);
    if (HasValue(start_after)) {
      query = query.StartAfter(ConvertToFieldValueList(start_after));
    }
    FlValue* end_at =
        cloud_firestore_internal_query_parameters_get_end_at(parameters);
    if (HasValue(end_at)) {
      query = query.EndAt(ConvertToFieldValueList(end_at));
    }
    FlValue* end_before =
        cloud_firestore_internal_query_parameters_get_end_before(parameters);
    if (HasValue(end_before)) {
      query = query.EndBefore(ConvertToFieldValueList(end_before));
    }

    return query;
  } catch (const std::exception& e) {
    g_warning("Error: %s", e.what());
    // Return a 'null' or 'empty' query based on your C++ Firestore API
    return Query();
  }
}

// -----------------------------------------------------------------------------
// Write commands (transactions and write batches).
// -----------------------------------------------------------------------------

// A fully converted write command. The conversion from the Pigeon
// InternalTransactionCommand happens on the platform thread so that no
// GObject/FlValue is touched from the Firestore transaction worker thread
// (an improvement over Windows, which converted on the worker thread).
struct ConvertedTransactionCommand {
  CloudFirestoreInternalTransactionType type;
  std::string path;
  enum class SetMode { kOverwrite, kMerge, kMergeFields } set_mode;
  MapFieldValue set_data;
  std::vector<FieldPath> merge_fields;
  MapFieldPathValue update_data;
};

ConvertedTransactionCommand ConvertTransactionCommand(
    CloudFirestoreInternalTransactionCommand* command) {
  ConvertedTransactionCommand converted;
  converted.type =
      cloud_firestore_internal_transaction_command_get_type_(command);
  converted.path =
      cloud_firestore_internal_transaction_command_get_path(command);
  converted.set_mode = ConvertedTransactionCommand::SetMode::kOverwrite;

  FlValue* data =
      cloud_firestore_internal_transaction_command_get_data(command);
  CloudFirestoreInternalDocumentOption* option =
      cloud_firestore_internal_transaction_command_get_option(command);

  switch (converted.type) {
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_SET: {
      converted.set_data = ConvertToMapFieldValue(data);
      if (option != nullptr) {
        gboolean* merge =
            cloud_firestore_internal_document_option_get_merge(option);
        FlValue* merge_fields =
            cloud_firestore_internal_document_option_get_merge_fields(option);
        if (merge != nullptr && *merge) {
          converted.set_mode = ConvertedTransactionCommand::SetMode::kMerge;
        } else if (HasValue(merge_fields)) {
          converted.set_mode =
              ConvertedTransactionCommand::SetMode::kMergeFields;
          converted.merge_fields = ConvertToFieldPathVector(merge_fields);
        }
      }
      break;
    }
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_UPDATE:
      converted.update_data = ConvertToMapFieldPathValue(data);
      break;
    default:
      break;
  }
  return converted;
}

std::map<std::string, std::shared_ptr<Transaction>> transactions_;

// -----------------------------------------------------------------------------
// Stream handlers.
// -----------------------------------------------------------------------------

class LoadBundleStreamHandler : public EventStreamHandler {
 public:
  LoadBundleStreamHandler(Firestore* firestore, std::string bundle)
      : firestore_(firestore), bundle_(std::move(bundle)) {}

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* arguments) override {
    events_state_ = std::make_shared<EventChannelState>();
    events_state_->channel = FL_EVENT_CHANNEL(g_object_ref(channel));
    events_state_->active = true;
    firestore_->LoadBundle(
        bundle_,
        [events_state = events_state_](const LoadBundleTaskProgress& progress) {
          FlValue* map = fl_value_new_map();
          fl_value_set_take(map, fl_value_new_string("bytesLoaded"),
                            fl_value_new_int(progress.bytes_loaded()));
          fl_value_set_take(map, fl_value_new_string("documentsLoaded"),
                            fl_value_new_int(progress.documents_loaded()));
          fl_value_set_take(map, fl_value_new_string("totalBytes"),
                            fl_value_new_int(progress.total_bytes()));
          fl_value_set_take(map, fl_value_new_string("totalDocuments"),
                            fl_value_new_int(progress.total_documents()));
          switch (progress.state()) {
            case LoadBundleTaskProgress::State::kError: {
              fl_value_unref(map);
              SendErrorOnPlatformThread(
                  events_state, "firebase_firestore",
                  "Error loading the bundle",
                  ParseErrorDetails("load-bundle-error",
                                    "Error loading the bundle"),
                  true);
              return;
            }
            case LoadBundleTaskProgress::State::kInProgress: {
              fl_value_set_take(map, fl_value_new_string("taskState"),
                                fl_value_new_string("running"));
              SendSuccessOnPlatformThread(events_state, map);
              break;
            }
            case LoadBundleTaskProgress::State::kSuccess: {
              fl_value_set_take(map, fl_value_new_string("taskState"),
                                fl_value_new_string("success"));
              SendSuccessOnPlatformThread(events_state, map);
              EndStreamOnPlatformThread(events_state);
              break;
            }
          }
        });
    return nullptr;
  }

  FlMethodErrorResponse* OnCancel(FlValue* arguments) override {
    EndStreamOnPlatformThread(events_state_);
    return nullptr;
  }

 private:
  Firestore* firestore_;
  std::string bundle_;
  std::shared_ptr<EventChannelState> events_state_;
};

class SnapshotInSyncStreamHandler : public EventStreamHandler {
 public:
  explicit SnapshotInSyncStreamHandler(Firestore* firestore)
      : firestore_(firestore) {}

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* arguments) override {
    events_state_ = std::make_shared<EventChannelState>();
    events_state_->channel = FL_EVENT_CHANNEL(g_object_ref(channel));
    events_state_->active = true;

    listener_ = firestore_->AddSnapshotsInSyncListener(
        [events_state = events_state_]() {
          SendSuccessOnPlatformThread(events_state, fl_value_new_null());
        });
    return nullptr;
  }

  FlMethodErrorResponse* OnCancel(FlValue* arguments) override {
    listener_.Remove();
    EndStreamOnPlatformThread(events_state_);
    return nullptr;
  }

 private:
  Firestore* firestore_;
  ListenerRegistration listener_;
  std::shared_ptr<EventChannelState> events_state_;
};

class TransactionStreamHandler : public EventStreamHandler {
 public:
  TransactionStreamHandler(Firestore* firestore, long timeout, int max_attempts,
                           std::string transaction_id)
      : firestore_(firestore),
        timeout_(timeout),
        max_attempts_(max_attempts),
        transaction_id_(std::move(transaction_id)) {}

  void ReceiveTransactionResponse(
      CloudFirestoreInternalTransactionResult result_type,
      std::vector<ConvertedTransactionCommand> commands) {
    {
      std::lock_guard<std::mutex> command_lock(commands_mutex_);
      result_type_ = result_type;
      commands_ = std::move(commands);
    }
    // Signal under mtx_ with a predicate flag so the transaction worker can
    // neither miss the notification (if it arrives before the worker starts
    // waiting) nor wake spuriously and commit an empty transaction. The
    // Windows implementation notifies without a predicate and is exposed to
    // both races.
    {
      std::lock_guard<std::mutex> lock(mtx_);
      signaled_ = true;
    }
    cv_.notify_one();
  }

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* arguments) override {
    events_state_ = std::make_shared<EventChannelState>();
    events_state_->channel = FL_EVENT_CHANNEL(g_object_ref(channel));
    events_state_->active = true;

    TransactionOptions options;
    options.set_max_attempts(max_attempts_);

    firestore_
        ->RunTransaction(
            options,
            [this](Transaction& transaction, std::string& str) -> Error {
              auto noop_deleter = [](Transaction*) {};
              std::shared_ptr<Transaction> ptr(&transaction, noop_deleter);
              transactions_[transaction_id_] = std::move(ptr);

              FlValue* map = fl_value_new_map();
              fl_value_set_take(map, fl_value_new_string("appName"),
                                fl_value_new_string(firestore_->app()->name()));
              SendSuccessOnPlatformThread(events_state_, map);

              std::unique_lock<std::mutex> lock(mtx_);
              bool signaled =
                  cv_.wait_for(lock, std::chrono::milliseconds(timeout_),
                               [this] { return signaled_; });
              // Reset for the next attempt: RunTransaction may re-invoke this
              // callback on conflict (up to max_attempts_ times).
              signaled_ = false;
              if (!signaled) {
                SendErrorOnPlatformThread(events_state_, "Timeout",
                                          "Transaction timed out.", nullptr,
                                          true);
                return firebase::firestore::kErrorDeadlineExceeded;
              }

              std::lock_guard<std::mutex> command_lock(commands_mutex_);
              if (result_type_ ==
                  CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_RESULT_FAILURE) {
                return firebase::firestore::kErrorAborted;
              }
              if (commands_.empty()) return firebase::firestore::kErrorOk;

              for (const ConvertedTransactionCommand& command : commands_) {
                if (command.path.empty()) {
                  g_warning("Path is invalid: %s", command.path.c_str());
                  continue;  // Skip this iteration.
                }

                DocumentReference reference =
                    firestore_->Document(command.path);

                switch (command.type) {
                  case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_SET:
                    switch (command.set_mode) {
                      case ConvertedTransactionCommand::SetMode::kMerge:
                        transaction.Set(reference, command.set_data,
                                        SetOptions::Merge());
                        break;
                      case ConvertedTransactionCommand::SetMode::kMergeFields:
                        transaction.Set(
                            reference, command.set_data,
                            SetOptions::MergeFieldPaths(command.merge_fields));
                        break;
                      case ConvertedTransactionCommand::SetMode::kOverwrite:
                        transaction.Set(reference, command.set_data);
                        break;
                    }
                    break;
                  case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_UPDATE:
                    transaction.Update(reference, command.update_data);
                    break;
                  case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_DELETE_TYPE:
                    transaction.Delete(reference);
                    break;
                  default:
                    break;
                }
              }
              return firebase::firestore::kErrorOk;
            })
        .OnCompletion([this](const Future<void>& completed_future) {
          if (completed_future.error() == firebase::firestore::kErrorOk) {
            FlValue* result = fl_value_new_map();
            fl_value_set_take(result, fl_value_new_string("complete"),
                              fl_value_new_bool(TRUE));
            SendSuccessOnPlatformThread(events_state_, result);
          } else {
            SendErrorOnPlatformThread(events_state_, "transaction_error",
                                      completed_future.error_message(),
                                      nullptr);
          }
          EndStreamOnPlatformThread(events_state_);
        });

    return nullptr;
  }

  FlMethodErrorResponse* OnCancel(FlValue* arguments) override {
    {
      std::unique_lock<std::mutex> lock(mtx_);
      signaled_ = true;
    }
    cv_.notify_one();
    EndStreamOnPlatformThread(events_state_);
    return nullptr;
  }

 private:
  Firestore* firestore_;
  long timeout_;
  int max_attempts_;
  std::string transaction_id_;
  std::vector<ConvertedTransactionCommand> commands_;
  CloudFirestoreInternalTransactionResult result_type_ =
      CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_RESULT_SUCCESS;
  // Guarded by mtx_. True once the Dart side stored its result (or the stream
  // was cancelled); consumed by the transaction worker per attempt.
  bool signaled_ = false;
  std::mutex mtx_;
  std::mutex commands_mutex_;
  std::condition_variable cv_;
  std::shared_ptr<EventChannelState> events_state_;
};

std::map<std::string, TransactionStreamHandler*> transaction_handlers_;

class QuerySnapshotStreamHandler : public EventStreamHandler {
 public:
  QuerySnapshotStreamHandler(
      std::unique_ptr<Query> query, bool include_metadata_changes,
      DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior)
      : query_(std::move(query)),
        include_metadata_changes_(include_metadata_changes),
        server_timestamp_behavior_(server_timestamp_behavior) {}

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* arguments) override {
    MetadataChanges metadata_changes = include_metadata_changes_
                                           ? MetadataChanges::kInclude
                                           : MetadataChanges::kExclude;

    events_state_ = std::make_shared<EventChannelState>();
    events_state_->channel = FL_EVENT_CHANNEL(g_object_ref(channel));
    events_state_->active = true;

    listener_ = query_->AddSnapshotListener(
        metadata_changes,
        [events_state = events_state_,
         server_timestamp_behavior = server_timestamp_behavior_,
         metadata_changes](const QuerySnapshot& snapshot, Error error,
                           const std::string& error_message) mutable {
          if (error == firebase::firestore::kErrorOk) {
            // Emit the Pigeon object directly so the Pigeon-aware codec on
            // the EventChannel serializes it end-to-end. Pigeon 26 no longer
            // flattens nested types, so sending a raw list here would cause
            // the Dart side to receive a List<Object?> it can no longer
            // decode into InternalQuerySnapshot.
            g_autoptr(FlValue) documents = ParseDocumentSnapshots(
                snapshot.documents(), server_timestamp_behavior);
            g_autoptr(FlValue) document_changes =
                ParseDocumentChanges(snapshot.DocumentChanges(metadata_changes),
                                     server_timestamp_behavior);
            g_autoptr(CloudFirestoreInternalSnapshotMetadata) metadata =
                ParseSnapshotMetadata(snapshot.metadata());
            g_autoptr(CloudFirestoreInternalQuerySnapshot) query_snapshot =
                cloud_firestore_internal_query_snapshot_new(
                    documents, document_changes, metadata);
            SendSuccessOnPlatformThread(
                events_state,
                fl_value_new_custom_object(
                    cloud_firestore_internal_query_snapshot_type_id,
                    G_OBJECT(query_snapshot)));
          } else {
            SendErrorOnPlatformThread(
                events_state, "firebase_firestore", error_message,
                ParseErrorDetails(GetErrorCode(error), error_message), true);
          }
        });
    return nullptr;
  }

  FlMethodErrorResponse* OnCancel(FlValue* arguments) override {
    listener_.Remove();
    EndStreamOnPlatformThread(events_state_);
    return nullptr;
  }

 private:
  ListenerRegistration listener_;
  std::unique_ptr<Query> query_;
  std::shared_ptr<EventChannelState> events_state_;
  bool include_metadata_changes_;
  DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior_;
};

class DocumentSnapshotStreamHandler : public EventStreamHandler {
 public:
  DocumentSnapshotStreamHandler(
      std::unique_ptr<DocumentReference> reference,
      bool include_metadata_changes,
      DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior)
      : reference_(std::move(reference)),
        include_metadata_changes_(include_metadata_changes),
        server_timestamp_behavior_(server_timestamp_behavior) {}

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* arguments) override {
    MetadataChanges metadata_changes = include_metadata_changes_
                                           ? MetadataChanges::kInclude
                                           : MetadataChanges::kExclude;

    events_state_ = std::make_shared<EventChannelState>();
    events_state_->channel = FL_EVENT_CHANNEL(g_object_ref(channel));
    events_state_->active = true;

    listener_ = reference_->AddSnapshotListener(
        metadata_changes,
        [events_state = events_state_,
         server_timestamp_behavior = server_timestamp_behavior_](
            const DocumentSnapshot& snapshot, Error error,
            const std::string& error_message) mutable {
          if (error == firebase::firestore::kErrorOk) {
            // Emit the Pigeon object directly so the Pigeon-aware codec on
            // the EventChannel serializes it end-to-end. Pigeon 26 no longer
            // flattens nested types, so sending a raw list here would cause
            // the Dart side to receive a List<Object?> it can no longer
            // decode into InternalDocumentSnapshot.
            g_autoptr(CloudFirestoreInternalDocumentSnapshot)
                document_snapshot =
                    ParseDocumentSnapshot(snapshot, server_timestamp_behavior);
            SendSuccessOnPlatformThread(
                events_state,
                fl_value_new_custom_object(
                    cloud_firestore_internal_document_snapshot_type_id,
                    G_OBJECT(document_snapshot)));
          } else {
            SendErrorOnPlatformThread(
                events_state, "firebase_firestore", error_message,
                ParseErrorDetails(GetErrorCode(error), error_message), true);
          }
        });
    return nullptr;
  }

  FlMethodErrorResponse* OnCancel(FlValue* arguments) override {
    listener_.Remove();
    EndStreamOnPlatformThread(events_state_);
    return nullptr;
  }

 private:
  ListenerRegistration listener_;
  std::unique_ptr<DocumentReference> reference_;
  std::shared_ptr<EventChannelState> events_state_;
  bool include_metadata_changes_;
  DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior_;
};

// -----------------------------------------------------------------------------
// FirebaseFirestoreHostApi handlers.
// -----------------------------------------------------------------------------

void HandleLoadBundle(
    CloudFirestoreFirestorePigeonFirebaseApp* app, const uint8_t* bundle,
    size_t bundle_length,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  std::string bundle_converted(reinterpret_cast<const char*>(bundle),
                               bundle_length);

  auto handler =
      std::make_unique<LoadBundleStreamHandler>(firestore, bundle_converted);

  std::string channel_name = RegisterEventChannel(
      "plugins.flutter.io/firebase_firestore/loadBundle/", std::move(handler));

  cloud_firestore_firebase_firestore_host_api_respond_load_bundle(
      response_handle, channel_name.c_str());
}

void HandleNamedQueryGet(
    CloudFirestoreFirestorePigeonFirebaseApp* app, const gchar* name,
    CloudFirestoreInternalGetOptions* options,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  firebase::firestore::Source source = GetSourceFromPigeon(
      cloud_firestore_internal_get_options_get_source(options));
  DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior =
      GetServerTimestampBehaviorFromPigeon(
          cloud_firestore_internal_get_options_get_server_timestamp_behavior(
              options));

  g_object_ref(response_handle);
  firestore->NamedQuery(name).OnCompletion([response_handle, source,
                                            server_timestamp_behavior](
                                               const Future<Query>&
                                                   completed_future) {
    const Query* query = completed_future.result();

    if (query == nullptr) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_error_named_query_get(
            response_handle,
            "Named query has not been found. Please check it has "
            "been loaded properly via loadBundle().",
            "Named query has not been found. Please check it has "
            "been loaded properly via loadBundle().",
            nullptr);
        g_object_unref(response_handle);
      });
      return;
    }

    query->Get(source).OnCompletion([response_handle,
                                     server_timestamp_behavior](
                                        const Future<QuerySnapshot>&
                                            completed_future) {
      if (completed_future.error() == firebase::firestore::kErrorOk) {
        const QuerySnapshot* query_snapshot = completed_future.result();
        CloudFirestoreInternalQuerySnapshot* snapshot =
            ParseQuerySnapshot(query_snapshot, server_timestamp_behavior);
        PostToMainThread([response_handle, snapshot]() {
          cloud_firestore_firebase_firestore_host_api_respond_named_query_get(
              response_handle, snapshot);
          g_object_unref(snapshot);
          g_object_unref(response_handle);
        });
      } else {
        RespondFutureErrorOnMainThread(
            cloud_firestore_firebase_firestore_host_api_respond_error_named_query_get,
            response_handle, completed_future);
      }
    });
  });
}

void HandleClearPersistence(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  g_object_ref(response_handle);
  firestore->ClearPersistence().OnCompletion([response_handle](
                                                 const Future<void>&
                                                     completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_clear_persistence(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_clear_persistence,
          response_handle, completed_future);
    }
  });
}

void HandleDisableNetwork(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  g_object_ref(response_handle);
  firestore->DisableNetwork().OnCompletion([response_handle](
                                               const Future<void>&
                                                   completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_disable_network(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_disable_network,
          response_handle, completed_future);
    }
  });
}

void HandleEnableNetwork(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  g_object_ref(response_handle);
  firestore->EnableNetwork().OnCompletion([response_handle](
                                              const Future<void>&
                                                  completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_enable_network(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_enable_network,
          response_handle, completed_future);
    }
  });
}

void HandleTerminate(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  std::string cache_key =
      std::string(
          cloud_firestore_firestore_pigeon_firebase_app_get_app_name(app)) +
      "-" +
      cloud_firestore_firestore_pigeon_firebase_app_get_database_u_r_l(app);
  Firestore* firestore = GetFirestoreFromPigeon(app);
  g_object_ref(response_handle);
  firestore->Terminate().OnCompletion([response_handle,
                                       cache_key](const Future<void>&
                                                      completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle, cache_key]() {
        FirestoreInstanceCache().erase(cache_key);
        cloud_firestore_firebase_firestore_host_api_respond_terminate(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_terminate,
          response_handle, completed_future);
    }
  });
}

void HandleWaitForPendingWrites(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  g_object_ref(response_handle);
  firestore->WaitForPendingWrites().OnCompletion([response_handle](
                                                     const Future<void>&
                                                         completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_wait_for_pending_writes(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_wait_for_pending_writes,
          response_handle, completed_future);
    }
  });
}

void HandleSetIndexConfiguration(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    const gchar* index_configuration,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // TODO: not available in C++ SDK
  cloud_firestore_firebase_firestore_host_api_respond_error_set_index_configuration(
      response_handle, "Not available in C++ SDK", "Not available in C++ SDK",
      nullptr);
}

void HandleSetLoggingEnabled(
    gboolean logging_enabled,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore::set_log_level(logging_enabled
                               ? firebase::LogLevel::kLogLevelDebug
                               : firebase::LogLevel::kLogLevelError);
  cloud_firestore_firebase_firestore_host_api_respond_set_logging_enabled(
      response_handle);
}

void HandleSnapshotsInSyncSetup(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  auto handler = std::make_unique<SnapshotInSyncStreamHandler>(firestore);

  g_autofree gchar* uuid = g_uuid_string_random();
  std::string snapshot_in_sync_id(uuid);

  RegisterEventChannelWithUUID(
      "plugins.flutter.io/firebase_firestore/snapshotsInSync/",
      snapshot_in_sync_id, std::move(handler));
  cloud_firestore_firebase_firestore_host_api_respond_snapshots_in_sync_setup(
      response_handle, snapshot_in_sync_id.c_str());
}

void HandleTransactionCreate(
    CloudFirestoreFirestorePigeonFirebaseApp* app, int64_t timeout,
    int64_t max_attempts,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  g_autofree gchar* uuid = g_uuid_string_random();
  std::string transaction_id(uuid);

  auto handler = std::make_unique<TransactionStreamHandler>(
      firestore, static_cast<long>(timeout), static_cast<int>(max_attempts),
      transaction_id);
  TransactionStreamHandler* raw_handler = handler.get();
  transaction_handlers_[transaction_id] = raw_handler;

  // Register the event channel.
  RegisterEventChannelWithUUID(
      "plugins.flutter.io/firebase_firestore/transaction/", transaction_id,
      std::move(handler));

  cloud_firestore_firebase_firestore_host_api_respond_transaction_create(
      response_handle, transaction_id.c_str());
}

void HandleTransactionStoreResult(
    const gchar* transaction_id,
    CloudFirestoreInternalTransactionResult result_type, FlValue* commands,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  auto handler_it = transaction_handlers_.find(transaction_id);
  if (handler_it != transaction_handlers_.end() && handler_it->second) {
    TransactionStreamHandler& handler = *handler_it->second;
    std::vector<ConvertedTransactionCommand> command_vector;
    if (HasValue(commands)) {
      size_t length = fl_value_get_length(commands);
      for (size_t i = 0; i < length; ++i) {
        FlValue* element = fl_value_get_list_value(commands, i);
        CloudFirestoreInternalTransactionCommand* command =
            CLOUD_FIRESTORE_INTERNAL_TRANSACTION_COMMAND(
                fl_value_get_custom_value_object(element));
        command_vector.push_back(ConvertTransactionCommand(command));
      }
    }
    handler.ReceiveTransactionResponse(result_type, std::move(command_vector));
    cloud_firestore_firebase_firestore_host_api_respond_transaction_store_result(
        response_handle);
  } else {
    g_autoptr(FlValue) details = fl_value_new_string(transaction_id);
    cloud_firestore_firebase_firestore_host_api_respond_error_transaction_store_result(
        response_handle, "transaction_not_found", "Transaction not found",
        details);
  }
}

void HandleTransactionGet(
    CloudFirestoreFirestorePigeonFirebaseApp* app, const gchar* transaction_id,
    const gchar* path,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference reference = firestore->Document(path);

  auto transaction_it = transactions_.find(transaction_id);
  if (transaction_it == transactions_.end() || !transaction_it->second) {
    // Improvement over Windows, which would dereference a null transaction.
    cloud_firestore_firebase_firestore_host_api_respond_error_transaction_get(
        response_handle, "transaction_not_found", "Transaction not found",
        nullptr);
    return;
  }
  std::shared_ptr<Transaction> transaction = transaction_it->second;

  Error error_code;
  std::string error_message;

  // Call the Get function
  DocumentSnapshot snapshot =
      transaction->Get(reference, &error_code, &error_message);

  if (error_code != firebase::firestore::kErrorOk) {
    cloud_firestore_firebase_firestore_host_api_respond_error_transaction_get(
        response_handle, error_message.c_str(), error_message.c_str(), nullptr);
  } else {
    g_autoptr(CloudFirestoreInternalDocumentSnapshot) document_snapshot =
        ParseDocumentSnapshot(
            snapshot, DocumentSnapshot::ServerTimestampBehavior::kDefault);
    cloud_firestore_firebase_firestore_host_api_respond_transaction_get(
        response_handle, document_snapshot);
  }
}

void HandleDocumentReferenceSet(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreDocumentReferenceRequest* request,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(
      cloud_firestore_document_reference_request_get_path(request));

  FlValue* data = cloud_firestore_document_reference_request_get_data(request);
  CloudFirestoreInternalDocumentOption* option =
      cloud_firestore_document_reference_request_get_option(request);

  // Get the data
  Future<void> future;

  gboolean* merge =
      option != nullptr
          ? cloud_firestore_internal_document_option_get_merge(option)
          : nullptr;
  FlValue* merge_fields =
      option != nullptr
          ? cloud_firestore_internal_document_option_get_merge_fields(option)
          : nullptr;

  if (merge != nullptr && *merge) {
    future = document_reference.Set(ConvertToMapFieldValue(data),
                                    SetOptions::Merge());
  } else if (HasValue(merge_fields)) {
    future = document_reference.Set(
        ConvertToMapFieldValue(data),
        SetOptions::MergeFieldPaths(ConvertToFieldPathVector(merge_fields)));
  } else {
    future = document_reference.Set(ConvertToMapFieldValue(data));
  }

  g_object_ref(response_handle);
  future.OnCompletion([response_handle](const Future<void>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_document_reference_set(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_document_reference_set,
          response_handle, completed_future);
    }
  });
}

void HandleDocumentReferenceUpdate(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreDocumentReferenceRequest* request,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(
      cloud_firestore_document_reference_request_get_path(request));

  // Get the data
  MapFieldPathValue data = ConvertToMapFieldPathValue(
      cloud_firestore_document_reference_request_get_data(request));
  Future<void> future = document_reference.Update(data);

  g_object_ref(response_handle);
  future.OnCompletion([response_handle](const Future<void>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_document_reference_update(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_document_reference_update,
          response_handle, completed_future);
    }
  });
}

void HandleDocumentReferenceGet(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreDocumentReferenceRequest* request,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(
      cloud_firestore_document_reference_request_get_path(request));

  CloudFirestoreSource* pigeon_source =
      cloud_firestore_document_reference_request_get_source(request);
  firebase::firestore::Source source =
      pigeon_source != nullptr ? GetSourceFromPigeon(*pigeon_source)
                               : firebase::firestore::Source::kDefault;

  CloudFirestoreServerTimestampBehavior* pigeon_behavior =
      cloud_firestore_document_reference_request_get_server_timestamp_behavior(
          request);
  DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior =
      pigeon_behavior != nullptr
          ? GetServerTimestampBehaviorFromPigeon(*pigeon_behavior)
          : DocumentSnapshot::ServerTimestampBehavior::kNone;

  Future<DocumentSnapshot> future = document_reference.Get(source);

  g_object_ref(response_handle);
  future.OnCompletion([response_handle, server_timestamp_behavior](
                          const Future<DocumentSnapshot>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      const DocumentSnapshot* document_snapshot = completed_future.result();
      CloudFirestoreInternalDocumentSnapshot* snapshot =
          ParseDocumentSnapshot(*document_snapshot, server_timestamp_behavior);
      PostToMainThread([response_handle, snapshot]() {
        cloud_firestore_firebase_firestore_host_api_respond_document_reference_get(
            response_handle, snapshot);
        g_object_unref(snapshot);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_document_reference_get,
          response_handle, completed_future);
    }
  });
}

void HandleDocumentReferenceDelete(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreDocumentReferenceRequest* request,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(
      cloud_firestore_document_reference_request_get_path(request));

  Future<void> future = document_reference.Delete();

  g_object_ref(response_handle);
  future.OnCompletion([response_handle](const Future<void>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      PostToMainThread([response_handle]() {
        cloud_firestore_firebase_firestore_host_api_respond_document_reference_delete(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_document_reference_delete,
          response_handle, completed_future);
    }
  });
}

void HandleQueryGet(
    CloudFirestoreFirestorePigeonFirebaseApp* app, const gchar* path,
    gboolean is_collection_group,
    CloudFirestoreInternalQueryParameters* parameters,
    CloudFirestoreInternalGetOptions* options,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, is_collection_group, parameters);

  firebase::firestore::Source source = GetSourceFromPigeon(
      cloud_firestore_internal_get_options_get_source(options));
  DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior =
      GetServerTimestampBehaviorFromPigeon(
          cloud_firestore_internal_get_options_get_server_timestamp_behavior(
              options));

  Future<QuerySnapshot> future = query.Get(source);

  g_object_ref(response_handle);
  future.OnCompletion([response_handle, server_timestamp_behavior](
                          const Future<QuerySnapshot>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      const QuerySnapshot* query_snapshot = completed_future.result();
      CloudFirestoreInternalQuerySnapshot* snapshot =
          ParseQuerySnapshot(query_snapshot, server_timestamp_behavior);
      PostToMainThread([response_handle, snapshot]() {
        cloud_firestore_firebase_firestore_host_api_respond_query_get(
            response_handle, snapshot);
        g_object_unref(snapshot);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_query_get,
          response_handle, completed_future);
    }
  });
}

firebase::firestore::AggregateSource GetAggregateSourceFromPigeon(
    CloudFirestoreAggregateSource source) {
  switch (source) {
    case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_SOURCE_SERVER:
    default:
      return firebase::firestore::AggregateSource::kServer;
  }
}

void HandleAggregateQuery(
    CloudFirestoreFirestorePigeonFirebaseApp* app, const gchar* path,
    CloudFirestoreInternalQueryParameters* parameters,
    CloudFirestoreAggregateSource source, FlValue* queries,
    gboolean is_collection_group,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, is_collection_group, parameters);

  // C++ SDK does not support average and sum
  firebase::firestore::AggregateQuery aggregate_query;

  std::vector<CloudFirestoreAggregateType> query_types;
  size_t queries_length = fl_value_get_length(queries);
  for (size_t i = 0; i < queries_length; ++i) {
    CloudFirestoreAggregateQuery* query_request =
        CLOUD_FIRESTORE_AGGREGATE_QUERY(fl_value_get_custom_value_object(
            fl_value_get_list_value(queries, i)));
    CloudFirestoreAggregateType type =
        cloud_firestore_aggregate_query_get_type_(query_request);
    query_types.push_back(type);

    switch (type) {
      case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_COUNT:
        aggregate_query = query.Count();
        break;
      case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_SUM:
        g_warning("Sum aggregation is not supported by the C++ SDK.");
        break;
      case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_AVERAGE:
        g_warning("Average aggregation is not supported by the C++ SDK.");
        break;
    }
  }

  Future<AggregateQuerySnapshot> future =
      aggregate_query.Get(GetAggregateSourceFromPigeon(source));

  g_object_ref(response_handle);
  future.OnCompletion([response_handle,
                       query_types](const Future<AggregateQuerySnapshot>&
                                        completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      const AggregateQuerySnapshot* aggregate_query_snapshot =
          completed_future.result();
      FlValue* aggregate_responses = fl_value_new_list();

      for (CloudFirestoreAggregateType type : query_types) {
        switch (type) {
          case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_COUNT: {
            double double_value =
                static_cast<double>(aggregate_query_snapshot->count());
            g_autoptr(CloudFirestoreAggregateQueryResponse) aggregate_response =
                cloud_firestore_aggregate_query_response_new(
                    CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_COUNT,
                    nullptr, &double_value);
            fl_value_append_take(
                aggregate_responses,
                fl_value_new_custom_object(
                    cloud_firestore_aggregate_query_response_type_id,
                    G_OBJECT(aggregate_response)));
            break;
          }
          case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_SUM:
            g_warning("Sum aggregation is not supported by the C++ SDK.");
            break;
          case CLOUD_FIRESTORE_PLATFORM_INTERFACE_AGGREGATE_TYPE_AVERAGE:
            g_warning("Average aggregation is not supported by the C++ SDK.");
            break;
        }
      }

      PostToMainThread([response_handle, aggregate_responses]() {
        cloud_firestore_firebase_firestore_host_api_respond_aggregate_query(
            response_handle, aggregate_responses);
        fl_value_unref(aggregate_responses);
        g_object_unref(response_handle);
      });
    } else {
      RespondFutureErrorOnMainThread(
          cloud_firestore_firebase_firestore_host_api_respond_error_aggregate_query,
          response_handle, completed_future);
    }
  });
}

void HandleWriteBatchCommit(
    CloudFirestoreFirestorePigeonFirebaseApp* app, FlValue* writes,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  try {
    Firestore* firestore = GetFirestoreFromPigeon(app);
    firebase::firestore::WriteBatch batch = firestore->batch();

    size_t length = fl_value_get_length(writes);
    for (size_t i = 0; i < length; ++i) {
      CloudFirestoreInternalTransactionCommand* command =
          CLOUD_FIRESTORE_INTERNAL_TRANSACTION_COMMAND(
              fl_value_get_custom_value_object(
                  fl_value_get_list_value(writes, i)));
      ConvertedTransactionCommand converted =
          ConvertTransactionCommand(command);

      DocumentReference document_reference =
          firestore->Document(converted.path);

      switch (converted.type) {
        case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_DELETE_TYPE:
          batch.Delete(document_reference);
          break;
        case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_UPDATE:
          batch.Update(document_reference, converted.update_data);
          break;
        case CLOUD_FIRESTORE_PLATFORM_INTERFACE_INTERNAL_TRANSACTION_TYPE_SET:
          switch (converted.set_mode) {
            case ConvertedTransactionCommand::SetMode::kMerge:
              batch.Set(document_reference, converted.set_data,
                        SetOptions::Merge());
              break;
            case ConvertedTransactionCommand::SetMode::kMergeFields:
              batch.Set(document_reference, converted.set_data,
                        SetOptions::MergeFieldPaths(converted.merge_fields));
              break;
            case ConvertedTransactionCommand::SetMode::kOverwrite:
              batch.Set(document_reference, converted.set_data);
              break;
          }
          break;
        default:
          break;
      }
    }

    g_object_ref(response_handle);
    batch.Commit().OnCompletion([response_handle](
                                    const Future<void>& completed_future) {
      if (completed_future.error() == firebase::firestore::kErrorOk) {
        PostToMainThread([response_handle]() {
          cloud_firestore_firebase_firestore_host_api_respond_write_batch_commit(
              response_handle);
          g_object_unref(response_handle);
        });
      } else {
        RespondFutureErrorOnMainThread(
            cloud_firestore_firebase_firestore_host_api_respond_error_write_batch_commit,
            response_handle, completed_future);
      }
    });

  } catch (const std::exception& e) {
    g_warning("Error: %s", e.what());
    cloud_firestore_firebase_firestore_host_api_respond_error_write_batch_commit(
        response_handle, e.what(), e.what(), nullptr);
  }
}

void HandleQuerySnapshot(
    CloudFirestoreFirestorePigeonFirebaseApp* app, const gchar* path,
    gboolean is_collection_group,
    CloudFirestoreInternalQueryParameters* parameters,
    CloudFirestoreInternalGetOptions* options,
    gboolean include_metadata_changes, CloudFirestoreListenSource source,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  if (source == CLOUD_FIRESTORE_PLATFORM_INTERFACE_LISTEN_SOURCE_CACHE) {
    cloud_firestore_firebase_firestore_host_api_respond_error_query_snapshot(
        response_handle, "Listening from cache isn't supported on Linux",
        "Listening from cache isn't supported on Linux", nullptr);
    return;
  }

  Firestore* firestore = GetFirestoreFromPigeon(app);
  std::unique_ptr<Query> query_ptr = std::make_unique<Query>(
      ParseQuery(firestore, path, is_collection_group, parameters));

  auto query_snapshot_handler = std::make_unique<QuerySnapshotStreamHandler>(
      std::move(query_ptr), include_metadata_changes,
      GetServerTimestampBehaviorFromPigeon(
          cloud_firestore_internal_get_options_get_server_timestamp_behavior(
              options)));

  std::string channel_name =
      RegisterEventChannel("plugins.flutter.io/firebase_firestore/query/",
                           std::move(query_snapshot_handler));

  cloud_firestore_firebase_firestore_host_api_respond_query_snapshot(
      response_handle, channel_name.c_str());
}

void HandleDocumentReferenceSnapshot(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestoreDocumentReferenceRequest* parameters,
    gboolean include_metadata_changes, CloudFirestoreListenSource source,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  if (source == CLOUD_FIRESTORE_PLATFORM_INTERFACE_LISTEN_SOURCE_CACHE) {
    cloud_firestore_firebase_firestore_host_api_respond_error_document_reference_snapshot(
        response_handle, "Listening from cache isn't supported on Linux",
        "Listening from cache isn't supported on Linux", nullptr);
    return;
  }
  Firestore* firestore = GetFirestoreFromPigeon(app);
  std::unique_ptr<DocumentReference> document_reference =
      std::make_unique<DocumentReference>(firestore->Document(
          cloud_firestore_document_reference_request_get_path(parameters)));

  CloudFirestoreServerTimestampBehavior* pigeon_behavior =
      cloud_firestore_document_reference_request_get_server_timestamp_behavior(
          parameters);
  DocumentSnapshot::ServerTimestampBehavior server_timestamp_behavior =
      pigeon_behavior != nullptr
          ? GetServerTimestampBehaviorFromPigeon(*pigeon_behavior)
          : DocumentSnapshot::ServerTimestampBehavior::kNone;

  auto document_snapshot_handler =
      std::make_unique<DocumentSnapshotStreamHandler>(
          std::move(document_reference), include_metadata_changes,
          server_timestamp_behavior);

  std::string channel_name =
      RegisterEventChannel("plugins.flutter.io/firebase_firestore/document/",
                           std::move(document_snapshot_handler));
  cloud_firestore_firebase_firestore_host_api_respond_document_reference_snapshot(
      response_handle, channel_name.c_str());
}

void HandlePersistenceCacheIndexManagerRequest(
    CloudFirestoreFirestorePigeonFirebaseApp* app,
    CloudFirestorePersistenceCacheIndexManagerRequest request,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // Not available in the C++ SDK; mirrors the Windows stub.
  cloud_firestore_firebase_firestore_host_api_respond_error_persistence_cache_index_manager_request(
      response_handle, "Not implemented on Linux", "Not implemented on Linux",
      nullptr);
}

void HandleExecutePipeline(
    CloudFirestoreFirestorePigeonFirebaseApp* app, FlValue* stages,
    FlValue* options,
    CloudFirestoreFirebaseFirestoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // Not available in the C++ SDK; mirrors the Windows stub.
  cloud_firestore_firebase_firestore_host_api_respond_error_execute_pipeline(
      response_handle, "Not implemented on Linux", "Not implemented on Linux",
      nullptr);
}

const CloudFirestoreFirebaseFirestoreHostApiVTable kHostApiVTable = {
    HandleLoadBundle,                           // load_bundle
    HandleNamedQueryGet,                        // named_query_get
    HandleClearPersistence,                     // clear_persistence
    HandleDisableNetwork,                       // disable_network
    HandleEnableNetwork,                        // enable_network
    HandleTerminate,                            // terminate
    HandleWaitForPendingWrites,                 // wait_for_pending_writes
    HandleSetIndexConfiguration,                // set_index_configuration
    HandleSetLoggingEnabled,                    // set_logging_enabled
    HandleSnapshotsInSyncSetup,                 // snapshots_in_sync_setup
    HandleTransactionCreate,                    // transaction_create
    HandleTransactionStoreResult,               // transaction_store_result
    HandleTransactionGet,                       // transaction_get
    HandleDocumentReferenceSet,                 // document_reference_set
    HandleDocumentReferenceUpdate,              // document_reference_update
    HandleDocumentReferenceGet,                 // document_reference_get
    HandleDocumentReferenceDelete,              // document_reference_delete
    HandleQueryGet,                             // query_get
    HandleAggregateQuery,                       // aggregate_query
    HandleWriteBatchCommit,                     // write_batch_commit
    HandleQuerySnapshot,                        // query_snapshot
    HandleDocumentReferenceSnapshot,            // document_reference_snapshot
    HandlePersistenceCacheIndexManagerRequest,  // persistence_cache_index_manager_request
    HandleExecutePipeline,                      // execute_pipeline
};

// Implements the firebase_core plugin registry contract. Windows does not
// register Firestore with its registry; on Linux we register with an empty
// constants map, matching the Android/iOS implementations.
class CloudFirestoreFlutterFirebasePlugin : public FlutterFirebasePlugin {
 public:
  FlValue* GetPluginConstantsForFirebaseApp(const App& app) override {
    return fl_value_new_map();
  }

  void DidReinitializeFirebaseCore() override {
    // Release all cached Firestore instances on hot restart, mirroring the
    // Android implementation (the Windows one keeps stale instances).
    transaction_handlers_.clear();
    transactions_.clear();
    FirestoreInstanceCache().clear();
  }
};

CloudFirestoreFlutterFirebasePlugin* GetFlutterFirebasePlugin() {
  static CloudFirestoreFlutterFirebasePlugin plugin;
  return &plugin;
}

}  // namespace

static void cloud_firestore_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(cloud_firestore_plugin_parent_class)->dispose(object);
}

static void cloud_firestore_plugin_class_init(
    CloudFirestorePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = cloud_firestore_plugin_dispose;
}

static void cloud_firestore_plugin_init(CloudFirestorePlugin* self) {}

void cloud_firestore_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  CloudFirestorePlugin* plugin = CLOUD_FIRESTORE_PLUGIN(
      g_object_new(cloud_firestore_plugin_get_type(), nullptr));

  messenger_ = fl_plugin_registrar_get_messenger(registrar);

  cloud_firestore_firebase_firestore_host_api_set_method_handlers(
      messenger_, /* suffix= */ nullptr, &kHostApiVTable, g_object_ref(plugin),
      g_object_unref);

  g_object_unref(plugin);

  RegisterFlutterFirebasePlugin("plugins.flutter.io/firebase_firestore",
                                GetFlutterFirebasePlugin());

  // Register for platform logging
  App::RegisterLibrary(
      kLibraryName, cloud_firestore_linux::getPluginVersion().c_str(), nullptr);
}
