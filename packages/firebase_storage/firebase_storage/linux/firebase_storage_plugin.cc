// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_storage/firebase_storage_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "../src/firebase_storage_utils.h"
#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/storage.h"
#include "firebase/storage/controller.h"
#include "firebase/storage/listener.h"
#include "firebase/storage/metadata.h"
#include "firebase/storage/storage_reference.h"
#include "firebase_storage/plugin_version.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::Future;
using ::firebase::storage::Controller;
using ::firebase::storage::Error;
using ::firebase::storage::Listener;
using ::firebase::storage::Metadata;
using ::firebase::storage::Storage;
using ::firebase::storage::StorageReference;

static const char kLibraryName[] = "flutter-fire-gcs";
static const char kStorageMethodChannelName[] =
    "plugins.flutter.io/firebase_storage";
static const char kStorageTaskEventName[] = "taskEvent";

#define FIREBASE_STORAGE_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), firebase_storage_plugin_get_type(), \
                              FirebaseStoragePlugin))

struct _FirebaseStoragePlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FirebaseStoragePlugin, firebase_storage_plugin,
              g_object_get_type())

// Messenger used to create per-task event channels. Mirrors the static
// messenger_ member of the Windows implementation.
static FlBinaryMessenger* messenger_ = nullptr;

// Task controllers keyed by the Dart-side task handle. Mirrors the
// controllers_ member of the Windows implementation.
static std::map<int64_t, std::unique_ptr<Controller>> controllers_;

// Runs a function on the GLib main thread. The Firebase C++ SDK invokes
// Future completions and task listeners on its own worker threads, but the
// Flutter Linux embedder (FlBinaryMessenger / FlEventChannel) must only be
// used from the main thread.
static gboolean RunOnMainThreadCallback(gpointer user_data) {
  auto* function = static_cast<std::function<void()>*>(user_data);
  (*function)();
  delete function;
  return G_SOURCE_REMOVE;
}

static void RunOnMainThread(std::function<void()> function) {
  g_idle_add(RunOnMainThreadCallback,
             new std::function<void()>(std::move(function)));
}

static Storage* GetCPPStorageFromPigeon(
    FirebaseStorageInternalStorageFirebaseApp* pigeon_app,
    const std::string& bucket_path) {
  std::string default_url = std::string("gs://") + bucket_path;
  App* app = App::GetInstance(
      firebase_storage_internal_storage_firebase_app_get_app_name(pigeon_app));
  Storage* cpp_storage = Storage::GetInstance(app, default_url.c_str());

  return cpp_storage;
}

static StorageReference GetCPPStorageReferenceFromPigeon(
    FirebaseStorageInternalStorageFirebaseApp* pigeon_app,
    FirebaseStorageInternalStorageReference* pigeon_reference) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(
      pigeon_app,
      firebase_storage_internal_storage_reference_get_bucket(pigeon_reference));
  return cpp_storage->GetReference(
      firebase_storage_internal_storage_reference_get_full_path(
          pigeon_reference));
}

static std::string GetStorageErrorCode(Error storage_error) {
  return firebase_storage_desktop::GetStorageErrorCode(storage_error);
}

static std::string GetStorageErrorMessage(Error storage_error) {
  return firebase_storage_desktop::GetStorageErrorMessage(storage_error);
}

static std::string ParseErrorCode(const firebase::FutureBase& future) {
  return GetStorageErrorCode(static_cast<Error>(future.error()));
}

static std::string ParseErrorMessage(const firebase::FutureBase& future) {
  return GetStorageErrorMessage(static_cast<Error>(future.error()));
}

static const char kCacheControlName[] = "cacheControl";
static const char kContentDispositionName[] = "contentDisposition";
static const char kContentEncodingName[] = "contentEncoding";
static const char kContentLanguageName[] = "contentLanguage";
static const char kContentTypeName[] = "contentType";
static const char kCustomMetadataName[] = "customMetadata";
static const char kMetadataName[] = "metadata";
static const char kSizeName[] = "size";
static const char kBucketName[] = "bucket";
static const char kCreationTimeMillisName[] = "creationTimeMillis";
static const char kUpdatedTimeMillisName[] = "updatedTimeMillis";

static const char kTaskStateName[] = "taskState";
static const char kTaskAppName[] = "appName";
static const char kTaskSnapshotName[] = "snapshot";
static const char kTaskSnapshotPath[] = "path";
static const char kTaskSnapshotBytesTransferred[] = "bytesTransferred";
static const char kTaskSnapshotTotalBytes[] = "totalBytes";
static const char kErrorName[] = "error";

// Converts Firebase C++ SDK metadata to the map streamed back to Dart.
// Ownership: returns a new reference (transfer full).
static FlValue* ConvertMedadataToPigeon(const Metadata* meta) {
  FlValue* meta_map = fl_value_new_map();
  if (meta->cache_control() != nullptr) {
    fl_value_set_string_take(meta_map, kCacheControlName,
                             fl_value_new_string(meta->cache_control()));
  }
  if (meta->content_disposition() != nullptr) {
    fl_value_set_string_take(meta_map, kContentDispositionName,
                             fl_value_new_string(meta->content_disposition()));
  }
  if (meta->content_encoding() != nullptr) {
    fl_value_set_string_take(meta_map, kContentEncodingName,
                             fl_value_new_string(meta->content_encoding()));
  }
  if (meta->content_language() != nullptr) {
    fl_value_set_string_take(meta_map, kContentLanguageName,
                             fl_value_new_string(meta->content_language()));
  }
  if (meta->content_type() != nullptr) {
    fl_value_set_string_take(meta_map, kContentTypeName,
                             fl_value_new_string(meta->content_type()));
  }
  if (meta->bucket() != nullptr) {
    fl_value_set_string_take(meta_map, kBucketName,
                             fl_value_new_string(meta->bucket()));
  }
  fl_value_set_string_take(meta_map, kSizeName,
                           fl_value_new_int(meta->size_bytes()));
  if (meta->custom_metadata() != nullptr) {
    g_autoptr(FlValue) custom_meta_map = fl_value_new_map();
    for (const auto& kv : *meta->custom_metadata()) {
      fl_value_set_string_take(custom_meta_map, kv.first.c_str(),
                               fl_value_new_string(kv.second.c_str()));
    }
    fl_value_set_string(meta_map, kCustomMetadataName, custom_meta_map);
  }
  fl_value_set_string_take(meta_map, kCreationTimeMillisName,
                           fl_value_new_int(meta->creation_time()));

  fl_value_set_string_take(meta_map, kUpdatedTimeMillisName,
                           fl_value_new_int(meta->updated_time()));

  return meta_map;
}

static std::map<std::string, std::string> ProcessCustomMetadataMap(
    FlValue* custom_metadata) {
  std::map<std::string, std::string> processed_metadata;

  if (custom_metadata == nullptr ||
      fl_value_get_type(custom_metadata) != FL_VALUE_TYPE_MAP) {
    return processed_metadata;
  }

  size_t length = fl_value_get_length(custom_metadata);
  for (size_t i = 0; i < length; ++i) {
    FlValue* key = fl_value_get_map_key(custom_metadata, i);
    FlValue* value = fl_value_get_map_value(custom_metadata, i);
    if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING &&
        fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
      processed_metadata.emplace(fl_value_get_string(key),
                                 fl_value_get_string(value));
    } else {
      g_warning("Ignoring non-string key or value in metadata map");
    }
  }

  return processed_metadata;
}

// Converts pigeon settable metadata into SDK metadata. Returns nullptr when
// there is no metadata to apply; otherwise the caller owns the returned
// object.
static Metadata* CreateStorageMetadataFromPigeon(
    FirebaseStorageInternalSettableMetadata* pigeon_meta_data) {
  if (pigeon_meta_data == nullptr) {
    return nullptr;  // No metadata to process
  }

  auto meta_data = std::make_unique<Metadata>();

  bool has_valid_data = false;

  // Set Cache Control
  const gchar* cache_control =
      firebase_storage_internal_settable_metadata_get_cache_control(
          pigeon_meta_data);
  if (cache_control != nullptr) {
    meta_data->set_cache_control(cache_control);
    has_valid_data = true;
  }

  // Set Content Disposition
  const gchar* content_disposition =
      firebase_storage_internal_settable_metadata_get_content_disposition(
          pigeon_meta_data);
  if (content_disposition != nullptr) {
    meta_data->set_content_disposition(content_disposition);
    has_valid_data = true;
  }

  // Set Content Encoding
  const gchar* content_encoding =
      firebase_storage_internal_settable_metadata_get_content_encoding(
          pigeon_meta_data);
  if (content_encoding != nullptr) {
    meta_data->set_content_encoding(content_encoding);
    has_valid_data = true;
  }

  // Set Content Language
  const gchar* content_language =
      firebase_storage_internal_settable_metadata_get_content_language(
          pigeon_meta_data);
  if (content_language != nullptr) {
    meta_data->set_content_language(content_language);
    has_valid_data = true;
  }

  // Set Content Type
  const gchar* content_type =
      firebase_storage_internal_settable_metadata_get_content_type(
          pigeon_meta_data);
  if (content_type != nullptr) {
    meta_data->set_content_type(content_type);
    has_valid_data = true;
  }

  // Set Custom Metadata
  FlValue* custom_metadata =
      firebase_storage_internal_settable_metadata_get_custom_metadata(
          pigeon_meta_data);
  if (custom_metadata != nullptr) {
    std::map<std::string, std::string> custom_meta_data_map =
        ProcessCustomMetadataMap(custom_metadata);
    if (!custom_meta_data_map.empty()) {
      std::map<std::string, std::string>* meta_data_map =
          meta_data->custom_metadata();
      meta_data_map->insert(custom_meta_data_map.begin(),
                            custom_meta_data_map.end());
      has_valid_data = true;
    }
  }

  if (!has_valid_data) {
    return nullptr;  // If no valid data was set, return nullptr
  }

  return meta_data.release();  // Successfully created and populated metadata,
                               // release the pointer
}

// For tasks, we stream the exception back as a map to match other platforms.
// Ownership: returns a new reference (transfer full).
static FlValue* ErrorStreamEvent(const firebase::FutureBase& data_result,
                                 const std::string& app_name) {
  const Error error_code = static_cast<Error>(data_result.error());

  g_autoptr(FlValue) error = fl_value_new_map();
  fl_value_set_string_take(
      error, "code",
      fl_value_new_string(GetStorageErrorCode(error_code).c_str()));
  fl_value_set_string_take(
      error, "message",
      fl_value_new_string(GetStorageErrorMessage(error_code).c_str()));

  FlValue* event = fl_value_new_map();
  fl_value_set_string_take(event, kTaskAppName,
                           fl_value_new_string(app_name.c_str()));
  fl_value_set_string_take(
      event, kTaskStateName,
      fl_value_new_int(
          FIREBASE_STORAGE_PLATFORM_INTERFACE_INTERNAL_STORAGE_TASK_STATE_ERROR));
  fl_value_set_string(event, kErrorName, error);

  return event;
}

// Sends an event on a task event channel from the main thread.
// Takes ownership of @event. The channel object is owned by the global
// event channel registry below and stays alive for the process lifetime,
// mirroring the Windows implementation.
static void SendEventOnMainThread(FlEventChannel* channel, FlValue* event) {
  RunOnMainThread([channel, event]() {
    g_autoptr(GError) error = nullptr;
    if (!fl_event_channel_send(channel, event, nullptr, &error)) {
      g_warning("Failed to send storage task event: %s", error->message);
    }
    fl_value_unref(event);
  });
}

// Builds a task event map (running/paused/success states).
// Ownership: returns a new reference (transfer full); takes ownership of
// @metadata when non-null.
static FlValue* CreateTaskEvent(FirebaseStorageInternalStorageTaskState state,
                                const std::string& app_name,
                                const std::string& path,
                                int64_t bytes_transferred, int64_t total_bytes,
                                FlValue* metadata) {
  FlValue* event = fl_value_new_map();
  fl_value_set_string_take(event, kTaskStateName, fl_value_new_int(state));
  fl_value_set_string_take(event, kTaskAppName,
                           fl_value_new_string(app_name.c_str()));
  g_autoptr(FlValue) snapshot = fl_value_new_map();
  fl_value_set_string_take(snapshot, kTaskSnapshotPath,
                           fl_value_new_string(path.c_str()));
  fl_value_set_string_take(snapshot, kTaskSnapshotTotalBytes,
                           fl_value_new_int(total_bytes));
  fl_value_set_string_take(snapshot, kTaskSnapshotBytesTransferred,
                           fl_value_new_int(bytes_transferred));
  if (metadata != nullptr) {
    fl_value_set_string_take(snapshot, kMetadataName, metadata);
  }
  fl_value_set_string(event, kTaskSnapshotName, snapshot);

  return event;
}

// Streams progress/pause events for an in-flight task to Dart.
class TaskStateListener : public Listener {
 public:
  explicit TaskStateListener(FlEventChannel* channel) : channel_(channel) {}

  void OnProgress(Controller* controller) override {
    SendEventOnMainThread(
        channel_,
        CreateTaskEvent(
            FIREBASE_STORAGE_PLATFORM_INTERFACE_INTERNAL_STORAGE_TASK_STATE_RUNNING,
            controller->GetReference().storage()->app()->name(),
            controller->GetReference().full_path(),
            controller->bytes_transferred(), controller->total_byte_count(),
            nullptr));
  }

  void OnPaused(Controller* controller) override {
    SendEventOnMainThread(
        channel_,
        CreateTaskEvent(
            FIREBASE_STORAGE_PLATFORM_INTERFACE_INTERNAL_STORAGE_TASK_STATE_PAUSED,
            controller->GetReference().storage()->app()->name(),
            controller->GetReference().full_path(),
            controller->bytes_transferred(), controller->total_byte_count(),
            nullptr));
  }

 private:
  FlEventChannel* channel_;
};

// C++ analog of the Windows flutter::StreamHandler subclasses, adapted to the
// FlEventChannel C callback API.
class TaskStreamHandler {
 public:
  virtual ~TaskStreamHandler() = default;

  virtual FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                          FlValue* args) = 0;

  virtual FlMethodErrorResponse* OnCancel(FlValue* args) { return nullptr; }
};

static FlMethodErrorResponse* TaskStreamHandlerListenCallback(
    FlEventChannel* channel, FlValue* args, gpointer user_data) {
  return static_cast<TaskStreamHandler*>(user_data)->OnListen(channel, args);
}

static FlMethodErrorResponse* TaskStreamHandlerCancelCallback(
    FlEventChannel* channel, FlValue* args, gpointer user_data) {
  return static_cast<TaskStreamHandler*>(user_data)->OnCancel(args);
}

static void TaskStreamHandlerDestroyNotify(gpointer user_data) {
  delete static_cast<TaskStreamHandler*>(user_data);
}

// Event channels registered for tasks, keyed by channel name. Channels (and
// their stream handlers) are kept alive for the process lifetime, mirroring
// the Windows implementation.
static std::map<std::string, FlEventChannel*> event_channels_;

// Creates a "<prefix>/<uuid>" event channel with the given stream handler and
// returns the uuid, which the Dart side uses to reconstruct the channel name.
static std::string RegisterEventChannel(
    const std::string& prefix, std::unique_ptr<TaskStreamHandler> handler) {
  g_autofree gchar* uuid = g_uuid_string_random();

  std::string channel_name = prefix + "/" + uuid;

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  FlEventChannel* channel = fl_event_channel_new(messenger_,
                                                 channel_name.c_str(),
                                                 FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(
      channel, TaskStreamHandlerListenCallback, TaskStreamHandlerCancelCallback,
      handler.release(), TaskStreamHandlerDestroyNotify);
  event_channels_[channel_name] = channel;

  return uuid;
}

class PutDataStreamHandler : public TaskStreamHandler {
 public:
  PutDataStreamHandler(Storage* storage, std::string reference_path,
                       const void* data, size_t buffer_size,
                       Controller* controller,
                       FirebaseStorageInternalSettableMetadata* pigeon_meta_data)
      : storage_(storage),
        reference_path_(std::move(reference_path)),
        controller_(controller) {
    auto data_bytes_ptr = static_cast<const uint8_t*>(data);
    data_.assign(data_bytes_ptr, data_bytes_ptr + buffer_size);
    if (pigeon_meta_data != nullptr) {
      meta_data_ = FIREBASE_STORAGE_INTERNAL_SETTABLE_METADATA(
          g_object_ref(pigeon_meta_data));
    }
  }

  ~PutDataStreamHandler() override { g_clear_object(&meta_data_); }

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* args) override {
    listener_ = std::make_unique<TaskStateListener>(channel);
    StorageReference reference = storage_->GetReference(reference_path_);

    std::unique_ptr<Metadata> storage_metadata(
        CreateStorageMetadataFromPigeon(meta_data_));
    Future<Metadata> future_result;
    if (storage_metadata) {
      future_result =
          reference.PutBytes(data_.data(), data_.size(), *storage_metadata,
                             listener_.get(), controller_);
    } else {
      future_result = reference.PutBytes(data_.data(), data_.size(),
                                         listener_.get(), controller_);
    }

    g_usleep(1000);  // timing for c++ sdk grabbing a mutex

    future_result.OnCompletion(
        [this, channel](const Future<Metadata>& data_result) {
          if (data_result.error() == firebase::storage::kErrorNone) {
            SendEventOnMainThread(
                channel,
                CreateTaskEvent(
                    FIREBASE_STORAGE_PLATFORM_INTERFACE_INTERNAL_STORAGE_TASK_STATE_SUCCESS,
                    storage_->app()->name(), data_result.result()->path(),
                    data_result.result()->size_bytes(),
                    data_result.result()->size_bytes(),
                    ConvertMedadataToPigeon(data_result.result())));
          } else {
            SendEventOnMainThread(
                channel, ErrorStreamEvent(data_result, storage_->app()->name()));
          }
        });
    return nullptr;
  }

 private:
  Storage* storage_;
  std::string reference_path_;
  std::vector<uint8_t> data_;
  Controller* controller_;
  FirebaseStorageInternalSettableMetadata* meta_data_ = nullptr;
  std::unique_ptr<TaskStateListener> listener_;
};

class PutFileStreamHandler : public TaskStreamHandler {
 public:
  PutFileStreamHandler(Storage* storage, std::string reference_path,
                       std::string file_path, Controller* controller,
                       FirebaseStorageInternalSettableMetadata* pigeon_meta_data)
      : storage_(storage),
        reference_path_(std::move(reference_path)),
        file_path_(std::move(file_path)),
        controller_(controller) {
    if (pigeon_meta_data != nullptr) {
      meta_data_ = FIREBASE_STORAGE_INTERNAL_SETTABLE_METADATA(
          g_object_ref(pigeon_meta_data));
    }
  }

  ~PutFileStreamHandler() override { g_clear_object(&meta_data_); }

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* args) override {
    listener_ = std::make_unique<TaskStateListener>(channel);
    StorageReference reference = storage_->GetReference(reference_path_);

    std::unique_ptr<Metadata> storage_metadata(
        CreateStorageMetadataFromPigeon(meta_data_));
    Future<Metadata> future_result;
    if (storage_metadata) {
      future_result = reference.PutFile(file_path_.c_str(), *storage_metadata,
                                        listener_.get(), controller_);
    } else {
      future_result =
          reference.PutFile(file_path_.c_str(), listener_.get(), controller_);
    }

    g_usleep(1000);  // timing for c++ sdk grabbing a mutex

    future_result.OnCompletion(
        [this, channel](const Future<Metadata>& data_result) {
          if (data_result.error() == firebase::storage::kErrorNone) {
            SendEventOnMainThread(
                channel,
                CreateTaskEvent(
                    FIREBASE_STORAGE_PLATFORM_INTERFACE_INTERNAL_STORAGE_TASK_STATE_SUCCESS,
                    storage_->app()->name(), data_result.result()->path(),
                    data_result.result()->size_bytes(),
                    data_result.result()->size_bytes(),
                    ConvertMedadataToPigeon(data_result.result())));
          } else {
            SendEventOnMainThread(
                channel, ErrorStreamEvent(data_result, storage_->app()->name()));
          }
        });
    return nullptr;
  }

 private:
  Storage* storage_;
  std::string reference_path_;
  std::string file_path_;
  Controller* controller_;
  FirebaseStorageInternalSettableMetadata* meta_data_ = nullptr;
  std::unique_ptr<TaskStateListener> listener_;
};

class GetFileStreamHandler : public TaskStreamHandler {
 public:
  GetFileStreamHandler(Storage* storage, std::string reference_path,
                       std::string file_path, Controller* controller)
      : storage_(storage),
        reference_path_(std::move(reference_path)),
        file_path_(std::move(file_path)),
        controller_(controller) {}

  FlMethodErrorResponse* OnListen(FlEventChannel* channel,
                                  FlValue* args) override {
    listener_ = std::make_unique<TaskStateListener>(channel);
    StorageReference reference = storage_->GetReference(reference_path_);
    Future<size_t> future_result =
        reference.GetFile(file_path_.c_str(), listener_.get(), controller_);

    g_usleep(1000);  // timing for c++ sdk grabbing a mutex

    future_result.OnCompletion(
        [this, channel](const Future<size_t>& data_result) {
          if (data_result.error() == firebase::storage::kErrorNone) {
            int64_t data_size = static_cast<int64_t>(*data_result.result());
            SendEventOnMainThread(
                channel,
                CreateTaskEvent(
                    FIREBASE_STORAGE_PLATFORM_INTERFACE_INTERNAL_STORAGE_TASK_STATE_SUCCESS,
                    storage_->app()->name(), reference_path_, data_size,
                    data_size, nullptr));
          } else {
            SendEventOnMainThread(
                channel, ErrorStreamEvent(data_result, storage_->app()->name()));
          }
        });
    return nullptr;
  }

 private:
  Storage* storage_;
  std::string reference_path_;
  std::string file_path_;
  Controller* controller_;
  std::unique_ptr<TaskStateListener> listener_;
};

// FirebaseStorageHostApi

static void HandleGetReferencebyPath(
    FirebaseStorageInternalStorageFirebaseApp* app, const gchar* path,
    const gchar* bucket,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(app, bucket == nullptr ? "" : bucket);
  StorageReference cpp_reference = cpp_storage->GetReference(path);
  g_autoptr(FirebaseStorageInternalStorageReference) reference =
      firebase_storage_internal_storage_reference_new(
          cpp_reference.bucket().c_str(), cpp_reference.full_path().c_str(),
          cpp_reference.name().c_str());
  firebase_storage_firebase_storage_host_api_respond_get_referenceby_path(
      response_handle, reference);
}

static void HandleSetMaxOperationRetryTime(
    FirebaseStorageInternalStorageFirebaseApp* app, int64_t time,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_operation_retry_time(static_cast<double>(time));
  // Improvement over the Windows implementation, which never replies and
  // leaves the Dart future pending.
  firebase_storage_firebase_storage_host_api_respond_set_max_operation_retry_time(
      response_handle);
}

static void HandleSetMaxUploadRetryTime(
    FirebaseStorageInternalStorageFirebaseApp* app, int64_t time,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_upload_retry_time(static_cast<double>(time));
  // Improvement over the Windows implementation, which never replies and
  // leaves the Dart future pending.
  firebase_storage_firebase_storage_host_api_respond_set_max_upload_retry_time(
      response_handle);
}

static void HandleSetMaxDownloadRetryTime(
    FirebaseStorageInternalStorageFirebaseApp* app, int64_t time,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_download_retry_time(static_cast<double>(time));
  // Improvement over the Windows implementation, which never replies and
  // leaves the Dart future pending.
  firebase_storage_firebase_storage_host_api_respond_set_max_download_retry_time(
      response_handle);
}

static void HandleUseStorageEmulator(
    FirebaseStorageInternalStorageFirebaseApp* app, const gchar* host,
    int64_t port,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->UseEmulator(host, static_cast<int>(port));
  firebase_storage_firebase_storage_host_api_respond_use_storage_emulator(
      response_handle);
}

static void HandleReferenceDelete(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Future<void> future_result = cpp_reference.Delete();
  g_usleep(1000);  // timing for c++ sdk grabbing a mutex
  g_object_ref(response_handle);
  future_result.OnCompletion([response_handle](
                                 const Future<void>& void_result) {
    if (void_result.error() == firebase::storage::kErrorNone) {
      RunOnMainThread([response_handle]() {
        firebase_storage_firebase_storage_host_api_respond_reference_delete(
            response_handle);
        g_object_unref(response_handle);
      });
    } else {
      std::string code = ParseErrorCode(void_result);
      std::string message = ParseErrorMessage(void_result);
      RunOnMainThread([response_handle, code, message]() {
        firebase_storage_firebase_storage_host_api_respond_error_reference_delete(
            response_handle, code.c_str(), message.c_str(), nullptr);
        g_object_unref(response_handle);
      });
    }
  });
}

static void HandleReferenceGetDownloadURL(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Future<std::string> future_result = cpp_reference.GetDownloadUrl();
  g_usleep(1000);  // timing for c++ sdk grabbing a mutex
  g_object_ref(response_handle);
  future_result.OnCompletion(
      [response_handle](const Future<std::string>& string_result) {
        if (string_result.error() == firebase::storage::kErrorNone) {
          std::string url = *string_result.result();
          RunOnMainThread([response_handle, url]() {
            firebase_storage_firebase_storage_host_api_respond_reference_get_download_u_r_l(
                response_handle, url.c_str());
            g_object_unref(response_handle);
          });
        } else {
          std::string code = ParseErrorCode(string_result);
          std::string message = ParseErrorMessage(string_result);
          RunOnMainThread([response_handle, code, message]() {
            firebase_storage_firebase_storage_host_api_respond_error_reference_get_download_u_r_l(
                response_handle, code.c_str(), message.c_str(), nullptr);
            g_object_unref(response_handle);
          });
        }
      });
}

static void HandleReferenceGetMetaData(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Future<Metadata> future_result = cpp_reference.GetMetadata();
  g_usleep(1000);  // timing for c++ sdk grabbing a mutex
  g_object_ref(response_handle);
  future_result.OnCompletion(
      [response_handle](const Future<Metadata>& metadata_result) {
        if (metadata_result.error() == firebase::storage::kErrorNone) {
          Metadata metadata = *metadata_result.result();
          RunOnMainThread([response_handle, metadata]() {
            g_autoptr(FlValue) meta_map = ConvertMedadataToPigeon(&metadata);
            g_autoptr(FirebaseStorageInternalFullMetaData) pigeon_meta =
                firebase_storage_internal_full_meta_data_new(meta_map);
            firebase_storage_firebase_storage_host_api_respond_reference_get_meta_data(
                response_handle, pigeon_meta);
            g_object_unref(response_handle);
          });
        } else {
          std::string code = ParseErrorCode(metadata_result);
          std::string message = ParseErrorMessage(metadata_result);
          RunOnMainThread([response_handle, code, message]() {
            firebase_storage_firebase_storage_host_api_respond_error_reference_get_meta_data(
                response_handle, code.c_str(), message.c_str(), nullptr);
            g_object_unref(response_handle);
          });
        }
      });
}

static void HandleReferenceList(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference,
    FirebaseStorageInternalListOptions* options,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // C++ doesn't support list yet
  g_autoptr(FlValue) items = fl_value_new_list();
  g_autoptr(FlValue) prefixs = fl_value_new_list();
  g_autoptr(FirebaseStorageInternalListResult) pigeon_result =
      firebase_storage_internal_list_result_new(items, nullptr, prefixs);
  firebase_storage_firebase_storage_host_api_respond_reference_list(
      response_handle, pigeon_result);
}

static void HandleReferenceListAll(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // C++ doesn't support listAll yet
  g_autoptr(FlValue) items = fl_value_new_list();
  g_autoptr(FlValue) prefixs = fl_value_new_list();
  g_autoptr(FirebaseStorageInternalListResult) pigeon_result =
      firebase_storage_internal_list_result_new(items, nullptr, prefixs);
  firebase_storage_firebase_storage_host_api_respond_reference_list_all(
      response_handle, pigeon_result);
}

static void HandleReferenceGetData(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference, int64_t max_size,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);

  // Use a shared pointer for automatic memory management and copyability
  auto byte_buffer = std::make_shared<std::vector<uint8_t>>(max_size);

  Future<size_t> future_result =
      cpp_reference.GetBytes(byte_buffer->data(), max_size);
  g_usleep(1000);  // timing for c++ sdk grabbing a mutex
  g_object_ref(response_handle);
  future_result.OnCompletion(
      [response_handle, byte_buffer](const Future<size_t>& data_result) {
        if (data_result.error() == firebase::storage::kErrorNone) {
          size_t vector_size = *data_result.result();
          auto vector_buffer = std::make_shared<std::vector<uint8_t>>(
              byte_buffer->begin(), byte_buffer->begin() + vector_size);
          RunOnMainThread([response_handle, vector_buffer]() {
            firebase_storage_firebase_storage_host_api_respond_reference_get_data(
                response_handle, vector_buffer->data(), vector_buffer->size());
            g_object_unref(response_handle);
          });
        } else {
          std::string code = ParseErrorCode(data_result);
          std::string message = ParseErrorMessage(data_result);
          RunOnMainThread([response_handle, code, message]() {
            firebase_storage_firebase_storage_host_api_respond_error_reference_get_data(
                response_handle, code.c_str(), message.c_str(), nullptr);
            g_object_unref(response_handle);
          });
        }
      });
}

static void HandleReferencePutData(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference, const uint8_t* data,
    size_t data_length,
    FirebaseStorageInternalSettableMetadata* settable_meta_data, int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(
      app, firebase_storage_internal_storage_reference_get_bucket(reference));
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutDataStreamHandler>(
      cpp_storage,
      firebase_storage_internal_storage_reference_get_full_path(reference),
      data, data_length, controllers_[handle].get(), settable_meta_data);

  std::string channel_id = RegisterEventChannel(
      std::string(kStorageMethodChannelName) + "/" + kStorageTaskEventName,
      std::move(handler));

  firebase_storage_firebase_storage_host_api_respond_reference_put_data(
      response_handle, channel_id.c_str());
}

static void HandleReferencePutString(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference, const gchar* data,
    int64_t format, FirebaseStorageInternalSettableMetadata* settable_meta_data,
    int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(
      app, firebase_storage_internal_storage_reference_get_bucket(reference));
  controllers_[handle] = std::make_unique<Controller>();

  std::vector<uint8_t> decoded_data =
      firebase_storage_desktop::StringToByteData(data, format);

  auto handler = std::make_unique<PutDataStreamHandler>(
      cpp_storage,
      firebase_storage_internal_storage_reference_get_full_path(reference),
      decoded_data.data(), decoded_data.size(), controllers_[handle].get(),
      settable_meta_data);

  std::string channel_id = RegisterEventChannel(
      std::string(kStorageMethodChannelName) + "/" + kStorageTaskEventName,
      std::move(handler));

  firebase_storage_firebase_storage_host_api_respond_reference_put_string(
      response_handle, channel_id.c_str());
}

static void HandleReferencePutFile(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference, const gchar* file_path,
    FirebaseStorageInternalSettableMetadata* settable_meta_data, int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(
      app, firebase_storage_internal_storage_reference_get_bucket(reference));
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutFileStreamHandler>(
      cpp_storage,
      firebase_storage_internal_storage_reference_get_full_path(reference),
      file_path, controllers_[handle].get(), settable_meta_data);

  std::string channel_id = RegisterEventChannel(
      std::string(kStorageMethodChannelName) + "/" + kStorageTaskEventName,
      std::move(handler));

  firebase_storage_firebase_storage_host_api_respond_reference_put_file(
      response_handle, channel_id.c_str());
}

static void HandleReferenceDownloadFile(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference, const gchar* file_path,
    int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(
      app, firebase_storage_internal_storage_reference_get_bucket(reference));
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<GetFileStreamHandler>(
      cpp_storage,
      firebase_storage_internal_storage_reference_get_full_path(reference),
      file_path, controllers_[handle].get());

  std::string channel_id = RegisterEventChannel(
      std::string(kStorageMethodChannelName) + "/" + kStorageTaskEventName,
      std::move(handler));

  firebase_storage_firebase_storage_host_api_respond_reference_download_file(
      response_handle, channel_id.c_str());
}

static void HandleReferenceUpdateMetadata(
    FirebaseStorageInternalStorageFirebaseApp* app,
    FirebaseStorageInternalStorageReference* reference,
    FirebaseStorageInternalSettableMetadata* metadata,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  std::unique_ptr<Metadata> cpp_meta(CreateStorageMetadataFromPigeon(metadata));
  if (!cpp_meta) {
    // Improvement over the Windows implementation, which dereferences the
    // null metadata pointer when nothing is set.
    cpp_meta = std::make_unique<Metadata>();
  }

  Future<Metadata> future_result = cpp_reference.UpdateMetadata(*cpp_meta);
  g_usleep(1000);  // timing for c++ sdk grabbing a mutex
  g_object_ref(response_handle);
  future_result.OnCompletion(
      [response_handle](const Future<Metadata>& data_result) {
        if (data_result.error() == firebase::storage::kErrorNone) {
          Metadata result_meta = *data_result.result();
          RunOnMainThread([response_handle, result_meta]() {
            g_autoptr(FlValue) meta_map = ConvertMedadataToPigeon(&result_meta);
            g_autoptr(FirebaseStorageInternalFullMetaData) pigeon_data =
                firebase_storage_internal_full_meta_data_new(meta_map);
            firebase_storage_firebase_storage_host_api_respond_reference_update_metadata(
                response_handle, pigeon_data);
            g_object_unref(response_handle);
          });
        } else {
          std::string code = ParseErrorCode(data_result);
          std::string message = ParseErrorMessage(data_result);
          RunOnMainThread([response_handle, code, message]() {
            firebase_storage_firebase_storage_host_api_respond_error_reference_update_metadata(
                response_handle, code.c_str(), message.c_str(), nullptr);
            g_object_unref(response_handle);
          });
        }
      });
}

// Builds the {status, snapshot: {bytesTransferred, totalBytes}} map returned
// by taskPause/taskResume/taskCancel.
// Ownership: returns a new reference (transfer full).
static FlValue* CreateTaskStatusResult(bool status, Controller* controller) {
  FlValue* task_result = fl_value_new_map();
  g_autoptr(FlValue) task_data = fl_value_new_map();

  fl_value_set_string_take(task_result, "status", fl_value_new_bool(status));
  fl_value_set_string_take(task_data, kTaskSnapshotBytesTransferred,
                           fl_value_new_int(controller->bytes_transferred()));
  fl_value_set_string_take(task_data, kTaskSnapshotTotalBytes,
                           fl_value_new_int(controller->total_byte_count()));
  fl_value_set_string(task_result, kTaskSnapshotName, task_data);
  return task_result;
}

static void HandleTaskPause(
    FirebaseStorageInternalStorageFirebaseApp* app, int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  auto it = controllers_.find(handle);
  if (it == controllers_.end()) {
    firebase_storage_firebase_storage_host_api_respond_error_task_pause(
        response_handle, "unknown", "No task found with the given handle",
        nullptr);
    return;
  }
  bool status = it->second->Pause();
  g_autoptr(FlValue) task_result =
      CreateTaskStatusResult(status, it->second.get());
  firebase_storage_firebase_storage_host_api_respond_task_pause(response_handle,
                                                                task_result);
}

static void HandleTaskResume(
    FirebaseStorageInternalStorageFirebaseApp* app, int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  auto it = controllers_.find(handle);
  if (it == controllers_.end()) {
    firebase_storage_firebase_storage_host_api_respond_error_task_resume(
        response_handle, "unknown", "No task found with the given handle",
        nullptr);
    return;
  }
  bool status = it->second->Resume();
  g_autoptr(FlValue) task_result =
      CreateTaskStatusResult(status, it->second.get());
  firebase_storage_firebase_storage_host_api_respond_task_resume(
      response_handle, task_result);
}

static void HandleTaskCancel(
    FirebaseStorageInternalStorageFirebaseApp* app, int64_t handle,
    FirebaseStorageFirebaseStorageHostApiResponseHandle* response_handle,
    gpointer user_data) {
  auto it = controllers_.find(handle);
  if (it == controllers_.end()) {
    firebase_storage_firebase_storage_host_api_respond_error_task_cancel(
        response_handle, "unknown", "No task found with the given handle",
        nullptr);
    return;
  }
  bool status = it->second->Cancel();
  g_autoptr(FlValue) task_result =
      CreateTaskStatusResult(status, it->second.get());
  firebase_storage_firebase_storage_host_api_respond_task_cancel(
      response_handle, task_result);
}

static const FirebaseStorageFirebaseStorageHostApiVTable
    kFirebaseStorageHostApiVTable = {
        HandleGetReferencebyPath,      // get_referenceby_path
        HandleSetMaxOperationRetryTime,  // set_max_operation_retry_time
        HandleSetMaxUploadRetryTime,     // set_max_upload_retry_time
        HandleSetMaxDownloadRetryTime,   // set_max_download_retry_time
        HandleUseStorageEmulator,        // use_storage_emulator
        HandleReferenceDelete,           // reference_delete
        HandleReferenceGetDownloadURL,   // reference_get_download_u_r_l
        HandleReferenceGetMetaData,      // reference_get_meta_data
        HandleReferenceList,             // reference_list
        HandleReferenceListAll,          // reference_list_all
        HandleReferenceGetData,          // reference_get_data
        HandleReferencePutData,          // reference_put_data
        HandleReferencePutString,        // reference_put_string
        HandleReferencePutFile,          // reference_put_file
        HandleReferenceDownloadFile,     // reference_download_file
        HandleReferenceUpdateMetadata,   // reference_update_metadata
        HandleTaskPause,                 // task_pause
        HandleTaskResume,                // task_resume
        HandleTaskCancel,                // task_cancel
};

static void firebase_storage_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(firebase_storage_plugin_parent_class)->dispose(object);
}

static void firebase_storage_plugin_class_init(
    FirebaseStoragePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = firebase_storage_plugin_dispose;
}

static void firebase_storage_plugin_init(FirebaseStoragePlugin* self) {}

void firebase_storage_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FirebaseStoragePlugin* plugin = FIREBASE_STORAGE_PLUGIN(
      g_object_new(firebase_storage_plugin_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  messenger_ = FL_BINARY_MESSENGER(g_object_ref(messenger));
  firebase_storage_firebase_storage_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseStorageHostApiVTable,
      g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);

  // Register for platform logging
  App::RegisterLibrary(kLibraryName,
                       firebase_storage_linux::getPluginVersion().c_str(),
                       nullptr);
}
