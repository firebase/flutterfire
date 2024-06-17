// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#define _CRT_SECURE_NO_WARNINGS
#include "firebase_storage_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/storage.h"
#include "firebase/storage/controller.h"
#include "firebase/storage/listener.h"
#include "firebase/storage/metadata.h"
#include "firebase/storage/storage_reference.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
#include "firebase_storage/plugin_version.h"
#include "messages.g.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <Windows.h>
#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

// #include <chrono>
#include <future>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
// #include <thread>
#include <mutex>
#include <vector>
using ::firebase::App;
using ::firebase::Future;
using ::firebase::storage::Controller;
using ::firebase::storage::Listener;
using ::firebase::storage::Metadata;
using ::firebase::storage::Storage;
using ::firebase::storage::StorageReference;

using flutter::EncodableValue;

namespace firebase_storage_windows {
enum PutStringFormat { Base64 = 1, Base64Url = 2 };

static std::string kLibraryName = "flutter-fire-gcs";
static std::string kStorageMethodChannelName =
    "plugins.flutter.io/firebase_storage";
static std::string kStorageTaskEventName = "taskEvent";
// static
void FirebaseStoragePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseStoragePlugin>();
  messenger_ = registrar->messenger();
  FirebaseStorageHostApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
  // Register for platform logging
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

FirebaseStoragePlugin::FirebaseStoragePlugin() {}

FirebaseStoragePlugin::~FirebaseStoragePlugin() = default;

Storage* GetCPPStorageFromPigeon(const PigeonStorageFirebaseApp& pigeonApp,
                                 const std::string& bucket_path) {
  std::string default_url = std::string("gs://") + bucket_path;
  App* app = App::GetInstance(pigeonApp.app_name().c_str());
  Storage* cpp_storage = Storage::GetInstance(app, default_url.c_str());

  return cpp_storage;
}

StorageReference GetCPPStorageReferenceFromPigeon(
    const PigeonStorageFirebaseApp& pigeonApp,
    const PigeonStorageReference& pigeonReference) {
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeonApp, pigeonReference.bucket());
  return cpp_storage->GetReference(pigeonReference.full_path());
}

flutter::BinaryMessenger*
    firebase_storage_windows::FirebaseStoragePlugin::messenger_ = nullptr;
std::map<std::string,
         std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
    event_channels_;
std::map<std::string, std::unique_ptr<flutter::StreamHandler<>>>
    stream_handlers_;

std::string RegisterEventChannelWithUUID(
    std::string prefix, std::string uuid,
    std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>> handler) {
  std::string channelName = prefix + "/" + uuid;

  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          FirebaseStoragePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance());
  stream_handlers_[channelName] = std::move(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return uuid;
}

std::string RegisterEventChannel(
    std::string prefix,
    std::unique_ptr<flutter::StreamHandler<EncodableValue>> handler) {
  UUID uuid;
  UuidCreate(&uuid);
  char* str;
  UuidToStringA(&uuid, (RPC_CSTR*)&str);

  std::string channelName = prefix + "/" + str;

  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          FirebaseStoragePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance());
  stream_handlers_[channelName] = std::move(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return str;
}

std::string FirebaseStoragePlugin::GetStorageErrorCode(Error storageError) {
  switch (storageError) {
    case firebase::storage::kErrorNone:
      return "unknown";
    case firebase::storage::kErrorUnknown:
      return "unknown";
    case firebase::storage::kErrorObjectNotFound:
      return "object-not-found";
    case firebase::storage::kErrorBucketNotFound:
      return "bucket-not-found";
    case firebase::storage::kErrorProjectNotFound:
      return "project-not-found";
    case firebase::storage::kErrorQuotaExceeded:
      return "quota-exceeded";
    case firebase::storage::kErrorUnauthenticated:
      return "unauthenticated";
    case firebase::storage::kErrorUnauthorized:
      return "unauthorized";
    case firebase::storage::kErrorRetryLimitExceeded:
      return "retry-limit-exceeded";
    case firebase::storage::kErrorNonMatchingChecksum:
      return "invalid-checksum";
    case firebase::storage::kErrorDownloadSizeExceeded:
      return "download-size-exceeded";
    case firebase::storage::kErrorCancelled:
      return "canceled";

    default:
      return "unknown";
  }
}

std::string FirebaseStoragePlugin::GetStorageErrorMessage(Error storageError) {
  switch (storageError) {
    case firebase::storage::kErrorNone:
      return "An unknown error occurred";
    case firebase::storage::kErrorUnknown:
      return "An unknown error occurred";
    case firebase::storage::kErrorObjectNotFound:
      return "No object exists at the desired reference.";
    case firebase::storage::kErrorBucketNotFound:
      return "No bucket is configured for Firebase Storage.";
    case firebase::storage::kErrorProjectNotFound:
      return "No project is configured for Firebase Storage.";
    case firebase::storage::kErrorQuotaExceeded:
      return "Quota on your Firebase Storage bucket has been exceeded.";
    case firebase::storage::kErrorUnauthenticated:
      return "User is unauthenticated. Authenticate and try again.";
    case firebase::storage::kErrorUnauthorized:
      return "User is not authorized to perform the desired action.";
    case firebase::storage::kErrorRetryLimitExceeded:
      return "The maximum time limit on an operation (upload, download, "
             "delete, etc.) has been exceeded.";
    case firebase::storage::kErrorNonMatchingChecksum:
      return "File on the client does not match the checksum of the file "
             "received by the server.";
    case firebase::storage::kErrorDownloadSizeExceeded:
      return "Size of the downloaded file exceeds the amount of memory "
             "allocated for the download.";
    case firebase::storage::kErrorCancelled:
      return "User cancelled the operation.";

    default:
      return "An unknown error occurred";
  }
}

// For Tasks, we stream exception back as a map to match other platforms
flutter::EncodableMap FirebaseStoragePlugin::ErrorStreamEvent(
    const firebase::FutureBase& data_result, const std::string& app_name) {
  flutter::EncodableMap error;
  const Error errorCode = static_cast<const Error>(data_result.error());
  flutter::EncodableValue code(
      FirebaseStoragePlugin::GetStorageErrorCode(errorCode));
  flutter::EncodableValue message(
      FirebaseStoragePlugin::GetStorageErrorMessage(errorCode));

  error[flutter::EncodableValue("code")] = code;
  error[flutter::EncodableValue("message")] = message;

  flutter::EncodableMap event;
  event[flutter::EncodableValue("appName")] = flutter::EncodableValue(app_name);
  event[flutter::EncodableValue("taskState")] =
      flutter::EncodableValue(static_cast<int>(PigeonStorageTaskState::error));
  event[flutter::EncodableValue("error")] = error;

  return event;
}

FlutterError FirebaseStoragePlugin::ParseError(
    const firebase::FutureBase& completed_future) {
  const Error errorCode = static_cast<const Error>(completed_future.error());

  return FlutterError(FirebaseStoragePlugin::GetStorageErrorCode(errorCode),
                      FirebaseStoragePlugin::GetStorageErrorMessage(errorCode));
}

void FirebaseStoragePlugin::GetReferencebyPath(
    const PigeonStorageFirebaseApp& app, const std::string& path,
    const std::string* bucket,
    std::function<void(ErrorOr<PigeonStorageReference> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, *bucket);
  StorageReference cpp_reference = cpp_storage->GetReference(path);
  PigeonStorageReference* value_ptr = new PigeonStorageReference(
      cpp_reference.bucket(), cpp_reference.full_path(), cpp_reference.name());
  result(*value_ptr);
}

void FirebaseStoragePlugin::SetMaxOperationRetryTime(
    const PigeonStorageFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_operation_retry_time((double)time);
}

void FirebaseStoragePlugin::SetMaxUploadRetryTime(
    const PigeonStorageFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_upload_retry_time((double)time);
}

void FirebaseStoragePlugin::SetMaxDownloadRetryTime(
    const PigeonStorageFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_download_retry_time((double)time);
}

void FirebaseStoragePlugin::UseStorageEmulator(
    const PigeonStorageFirebaseApp& app, const std::string& host, int64_t port,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // C++ doesn't support emulator on desktop for now. Do nothing.
}

void FirebaseStoragePlugin::ReferenceDelete(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference,
    std::function<void(std::optional<FlutterError> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Future<void> future_result = cpp_reference.Delete();
  ::Sleep(1);  // timing for c++ sdk grabbing a mutex
  future_result.OnCompletion([result](const Future<void>& void_result) {
    if (void_result.error() == firebase::storage::kErrorNone) {
      result(std::nullopt);
    } else {
      result(FirebaseStoragePlugin::ParseError(void_result));
    }
  });
}
void FirebaseStoragePlugin::ReferenceGetDownloadURL(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference,
    std::function<void(ErrorOr<std::string> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Future<std::string> future_result = cpp_reference.GetDownloadUrl();
  ::Sleep(1);  // timing for c++ sdk grabbing a mutex
  future_result.OnCompletion(
      [result](const Future<std::string>& string_result) {
        if (string_result.error() == firebase::storage::kErrorNone) {
          result(*string_result.result());
        } else {
          result(FirebaseStoragePlugin::ParseError(string_result));
        }
      });
}

firebase::storage::Metadata*
FirebaseStoragePlugin::CreateStorageMetadataFromPigeon(
    const PigeonSettableMetadata* pigeonMetaData) {
  if (pigeonMetaData == nullptr) {
    return nullptr;  // No metadata to process
  }

  auto metaData = std::make_unique<Metadata>();

  bool hasValidData = false;

  // Set Cache Control
  if (pigeonMetaData->cache_control()) {
    metaData->set_cache_control(pigeonMetaData->cache_control()->c_str());
    hasValidData = true;
  }

  // Set Content Disposition
  if (pigeonMetaData->content_disposition()) {
    metaData->set_content_disposition(
        pigeonMetaData->content_disposition()->c_str());
    hasValidData = true;
  }

  // Set Content Encoding
  if (pigeonMetaData->content_encoding()) {
    metaData->set_content_encoding(pigeonMetaData->content_encoding()->c_str());
    hasValidData = true;
  }

  // Set Content Language
  if (pigeonMetaData->content_language()) {
    metaData->set_content_language(pigeonMetaData->content_language()->c_str());
    hasValidData = true;
  }

  // Set Content Type
  if (pigeonMetaData->content_type()) {
    metaData->set_content_type(pigeonMetaData->content_type()->c_str());
    hasValidData = true;
  }

  // Set Custom Metadata
  if (pigeonMetaData->custom_metadata()) {
    std::map<std::string, std::string> customMetaDataMap =
        FirebaseStoragePlugin::ProcessCustomMetadataMap(
            *pigeonMetaData->custom_metadata());
    if (!customMetaDataMap.empty()) {
      std::map<std::string, std::string>* metaDataMap =
          metaData->custom_metadata();
      metaDataMap->insert(customMetaDataMap.begin(), customMetaDataMap.end());
      hasValidData = true;
    }
  }

  if (!hasValidData) {
    return nullptr;  // If no valid data was set, return nullptr
  }

  return metaData.release();  // Successfully created and populated metadata,
                              // release the pointer
}

std::map<std::string, std::string>
FirebaseStoragePlugin::ProcessCustomMetadataMap(
    const flutter::EncodableMap& customMetadata) {
  std::map<std::string, std::string> processedMetadata;

  for (const auto& pair : customMetadata) {
    if (std::holds_alternative<std::string>(pair.first) &&
        std::holds_alternative<std::string>(pair.second)) {
      processedMetadata.emplace(std::get<std::string>(pair.first),
                                std::get<std::string>(pair.second));
    } else {
      std::cerr << "Ignoring non-string key or value in metadata map"
                << std::endl;
    }
  }

  return processedMetadata;
}

std::string kCacheControlName = "cacheControl";
std::string kContentDispositionName = "contentDisposition";
std::string kContentEncodingName = "contentEncoding";
std::string kContentLanguageName = "contentLanguage";
std::string kContentTypeName = "contentType";
std::string kCustomMetadataName = "customMetadata";
std::string kMetadataName = "metadata";
std::string kSizeName = "size";
std::string kBucketName = "bucket";
std::string kCreationTimeMillisName = "creationTimeMillis";
std::string kUpdatedTimeMillisName = "updatedTimeMillis";

flutter::EncodableMap ConvertMedadataToPigeon(const Metadata* meta) {
  flutter::EncodableMap meta_map = flutter::EncodableMap();
  if (meta->cache_control() != nullptr) {
    meta_map[flutter::EncodableValue(kCacheControlName)] =
        flutter::EncodableValue(meta->cache_control());
  }
  if (meta->content_disposition() != nullptr) {
    meta_map[flutter::EncodableValue(kContentDispositionName)] =
        flutter::EncodableValue(meta->content_disposition());
  }
  if (meta->content_encoding() != nullptr) {
    meta_map[flutter::EncodableValue(kContentEncodingName)] =
        flutter::EncodableValue(meta->content_encoding());
  }
  if (meta->content_language() != nullptr) {
    meta_map[flutter::EncodableValue(kContentLanguageName)] =
        flutter::EncodableValue(meta->content_language());
  }
  if (meta->content_type() != nullptr) {
    meta_map[flutter::EncodableValue(kContentTypeName)] =
        flutter::EncodableValue(meta->content_type());
  }
  if (meta->bucket() != nullptr) {
    meta_map[flutter::EncodableValue(kBucketName)] =
        flutter::EncodableValue(meta->bucket());
  }
  meta_map[flutter::EncodableValue(kSizeName)] =
      flutter::EncodableValue(meta->size_bytes());
  if (meta->custom_metadata() != nullptr) {
    flutter::EncodableMap custom_meta_map = flutter::EncodableMap();
    for (const auto& kv : *meta->custom_metadata()) {
      custom_meta_map[flutter::EncodableValue(kv.first)] =
          flutter::EncodableValue(kv.second);
    }
    meta_map[flutter::EncodableValue(kCustomMetadataName)] = custom_meta_map;
  }
  meta_map[flutter::EncodableValue(kCreationTimeMillisName)] =
      flutter::EncodableValue(meta->creation_time());

  meta_map[flutter::EncodableValue(kUpdatedTimeMillisName)] =
      flutter::EncodableValue(meta->updated_time());

  return meta_map;
}

void FirebaseStoragePlugin::ReferenceGetMetaData(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference,
    std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Future<Metadata> future_result = cpp_reference.GetMetadata();
  ::Sleep(1);  // timing for c++ sdk grabbing a mutex
  future_result.OnCompletion([result](const Future<Metadata>& metadata_result) {
    if (metadata_result.error() == firebase::storage::kErrorNone) {
      PigeonFullMetaData pigeon_meta = PigeonFullMetaData();
      pigeon_meta.set_metadata(
          ConvertMedadataToPigeon(metadata_result.result()));

      result(pigeon_meta);
    } else {
      result(FirebaseStoragePlugin::ParseError(metadata_result));
    }
  });
}

void FirebaseStoragePlugin::ReferenceList(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference, const PigeonListOptions& options,
    std::function<void(ErrorOr<PigeonListResult> reply)> result) {
  // C++ doesn't support list yet
  flutter::EncodableList items = flutter::EncodableList();
  flutter::EncodableList prefixs = flutter::EncodableList();
  PigeonListResult pigeon_result = PigeonListResult(items, prefixs);
  result(pigeon_result);
}

void FirebaseStoragePlugin::ReferenceListAll(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference,
    std::function<void(ErrorOr<PigeonListResult> reply)> result) {
  // C++ doesn't support listAll yet
  flutter::EncodableList items = flutter::EncodableList();
  flutter::EncodableList prefixs = flutter::EncodableList();
  PigeonListResult pigeon_result = PigeonListResult(items, prefixs);
  result(pigeon_result);
}

void FirebaseStoragePlugin::ReferenceGetData(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference, int64_t max_size,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
        result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);

  // Use a shared pointer for automatic memory management and copyability
  auto byte_buffer = std::make_shared<std::vector<uint8_t>>(max_size);

  Future<size_t> future_result =
      cpp_reference.GetBytes(byte_buffer->data(), max_size);
  ::Sleep(1);  // timing for c++ sdk grabbing a mutex

  future_result.OnCompletion(
      [result, byte_buffer](const Future<size_t>& data_result) {
        if (data_result.error() != firebase::storage::kErrorNone) {
          result(FirebaseStoragePlugin::ParseError(data_result));
        } else {
          size_t vector_size = *data_result.result();
          std::optional<std::vector<uint8_t>> vector_buffer;
          vector_buffer = std::vector<uint8_t>(
              byte_buffer->begin(), byte_buffer->begin() + vector_size);
          result(vector_buffer);
        }
      });
}

std::string kTaskStateName = "taskState";
std::string kTaskAppName = "appName";
std::string kTaskSnapshotName = "snapshot";
std::string kTaskSnapshotPath = "path";
std::string kTaskSnapshotBytesTransferred = "bytesTransferred";
std::string kTaskSnapshotTotalBytes = "totalBytes";
std::string kErrorName = "error";

class TaskStateListener : public Listener {
 public:
  TaskStateListener(flutter::EventSink<flutter::EncodableValue>* events) {
    events_ = events;
  }
  virtual void OnProgress(firebase::storage::Controller* controller) {
    flutter::EncodableMap event = flutter::EncodableMap();
    event[kTaskStateName] = static_cast<int>(PigeonStorageTaskState::running);
    event[kTaskAppName] = controller->GetReference().storage()->app()->name();
    flutter::EncodableMap snapshot = flutter::EncodableMap();
    snapshot[kTaskSnapshotPath] = controller->GetReference().full_path();
    snapshot[kTaskSnapshotTotalBytes] = controller->total_byte_count();
    snapshot[kTaskSnapshotBytesTransferred] = controller->bytes_transferred();
    event[kTaskSnapshotName] = snapshot;

    events_->Success(event);
  }

  virtual void OnPaused(firebase::storage::Controller* controller) {
    flutter::EncodableMap event = flutter::EncodableMap();
    event[kTaskStateName] = static_cast<int>(PigeonStorageTaskState::paused);
    event[kTaskAppName] = controller->GetReference().storage()->app()->name();
    flutter::EncodableMap snapshot = flutter::EncodableMap();
    snapshot[kTaskSnapshotPath] = controller->GetReference().full_path();
    snapshot[kTaskSnapshotTotalBytes] = controller->total_byte_count();
    snapshot[kTaskSnapshotBytesTransferred] = controller->bytes_transferred();
    event[kTaskSnapshotName] = snapshot;

    events_->Success(event);
  }

  flutter::EventSink<flutter::EncodableValue>* events_;
};

class PutDataStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  PutDataStreamHandler(Storage* storage, std::string reference_path,
                       const void* data, size_t buffer_size,
                       Controller* controller,
                       const PigeonSettableMetadata& pigeon_meta_data)
      : meta_data_(pigeon_meta_data) {
    storage_ = storage;
    reference_path_ = reference_path;
    auto data_bytes_ptr = static_cast<const uint8_t*>(data);
    data_.assign(data_bytes_ptr, data_bytes_ptr + buffer_size);
    controller_ = controller;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);

    TaskStateListener* putStringListener = new TaskStateListener(events_.get());
    StorageReference reference = storage_->GetReference(reference_path_);

    Metadata* storage_metadata =
        FirebaseStoragePlugin::CreateStorageMetadataFromPigeon(&meta_data_);
    Future<Metadata> future_result;
    if (storage_metadata) {
      future_result =
          reference.PutBytes(data_.data(), data_.size(), *storage_metadata,
                             putStringListener, controller_);
    } else {
      future_result = reference.PutBytes(data_.data(), data_.size(),
                                         putStringListener, controller_);
    }

    ::Sleep(1);  // timing for c++ sdk grabbing a mutex

    future_result.OnCompletion([this](const Future<Metadata>& data_result) {
      if (data_result.error() == firebase::storage::kErrorNone) {
        flutter::EncodableMap event = flutter::EncodableMap();
        event[kTaskStateName] =
            static_cast<int>(PigeonStorageTaskState::success);
        event[kTaskAppName] = std::string(storage_->app()->name());
        flutter::EncodableMap snapshot = flutter::EncodableMap();
        snapshot[kTaskSnapshotPath] = data_result.result()->path();
        snapshot[kTaskSnapshotTotalBytes] = data_result.result()->size_bytes();
        snapshot[kTaskSnapshotBytesTransferred] =
            data_result.result()->size_bytes();
        snapshot[kMetadataName] = ConvertMedadataToPigeon(data_result.result());
        event[kTaskSnapshotName] = snapshot;

        events_->Success(event);
      } else {
        flutter::EncodableMap map = FirebaseStoragePlugin::ErrorStreamEvent(
            data_result, storage_->app()->name());

        events_->Success(map);
      }
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    return nullptr;
  }

 public:
  Storage* storage_;
  std::string reference_path_;
  std::vector<uint8_t> data_;
  PigeonSettableMetadata meta_data_;
  Controller* controller_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events_ =
      nullptr;
};

class PutFileStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  PutFileStreamHandler(Storage* storage, std::string reference_path,
                       std::string file_path, Controller* controller,
                       const PigeonSettableMetadata* pigeon_meta_data)
      : meta_data_(
            std::make_unique<PigeonSettableMetadata>(*pigeon_meta_data)) {
    storage_ = storage;
    reference_path_ = reference_path;
    file_path_ = file_path;
    controller_ = controller;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);

    TaskStateListener* putFileListener = new TaskStateListener(events_.get());
    StorageReference reference = storage_->GetReference(reference_path_);

    Metadata* storage_metadata =
        FirebaseStoragePlugin::CreateStorageMetadataFromPigeon(
            meta_data_.get());
    Future<Metadata> future_result;

    if (storage_metadata) {
      future_result = reference.PutFile(file_path_.c_str(), *storage_metadata,
                                        putFileListener, controller_);
    } else {
      future_result =
          reference.PutFile(file_path_.c_str(), putFileListener, controller_);
    }

    ::Sleep(1);  // timing for c++ sdk grabbing a mutex
    future_result.OnCompletion([this](const Future<Metadata>& data_result) {
      if (data_result.error() == firebase::storage::kErrorNone) {
        flutter::EncodableMap event = flutter::EncodableMap();
        event[kTaskStateName] =
            static_cast<int>(PigeonStorageTaskState::success);
        event[kTaskAppName] = std::string(storage_->app()->name());
        flutter::EncodableMap snapshot = flutter::EncodableMap();
        snapshot[kTaskSnapshotPath] = data_result.result()->path();
        snapshot[kTaskSnapshotTotalBytes] = data_result.result()->size_bytes();
        snapshot[kTaskSnapshotBytesTransferred] =
            data_result.result()->size_bytes();
        snapshot[kMetadataName] = ConvertMedadataToPigeon(data_result.result());
        event[kTaskSnapshotName] = snapshot;

        events_->Success(event);
      } else {
        flutter::EncodableMap map = FirebaseStoragePlugin::ErrorStreamEvent(
            data_result, storage_->app()->name());

        events_->Success(map);
      }
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    return nullptr;
  }

 public:
  Storage* storage_;
  std::string reference_path_;
  std::string file_path_;
  Controller* controller_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events_ =
      nullptr;
  std::unique_ptr<PigeonSettableMetadata> meta_data_;
};

class GetFileStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  GetFileStreamHandler(Storage* storage, std::string reference_path,
                       std::string file_path, Controller* controller) {
    storage_ = storage;
    reference_path_ = reference_path;
    file_path_ = file_path;
    controller_ = controller;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);
    std::unique_lock<std::mutex> lock(mtx_);

    TaskStateListener* getFileListener = new TaskStateListener(events_.get());
    StorageReference reference = storage_->GetReference(reference_path_);
    Future<size_t> future_result =
        reference.GetFile(file_path_.c_str(), getFileListener, controller_);

    ::Sleep(1);  // timing for c++ sdk grabbing a mutex
    future_result.OnCompletion([this](const Future<size_t>& data_result) {
      if (data_result.error() == firebase::storage::kErrorNone) {
        flutter::EncodableMap event = flutter::EncodableMap();
        event[kTaskStateName] =
            static_cast<int>(PigeonStorageTaskState::success);
        event[kTaskAppName] = std::string(storage_->app()->name());
        flutter::EncodableMap snapshot = flutter::EncodableMap();
        size_t data_size = *data_result.result();
        snapshot[kTaskSnapshotTotalBytes] =
            flutter::EncodableValue(static_cast<int64_t>(data_size));
        snapshot[kTaskSnapshotBytesTransferred] =
            flutter::EncodableValue(static_cast<int64_t>(data_size));
        snapshot[kTaskSnapshotPath] = EncodableValue(reference_path_);
        event[kTaskSnapshotName] = snapshot;

        events_->Success(event);
      } else {
        flutter::EncodableMap map = FirebaseStoragePlugin::ErrorStreamEvent(
            data_result, storage_->app()->name());

        events_->Success(map);
      }
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    std::unique_lock<std::mutex> lock(mtx_);

    return nullptr;
  }

 public:
  Storage* storage_;
  std::string reference_path_;
  std::string file_path_;
  Controller* controller_;
  std::mutex mtx_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events_ =
      nullptr;
};

void FirebaseStoragePlugin::ReferencePutData(
    const PigeonStorageFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference,
    const std::vector<uint8_t>& data,
    const PigeonSettableMetadata& pigeon_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutDataStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), data.data(), data.size(),
      controllers_[handle].get(), pigeon_meta_data);

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));

  result(channelName);
}

void FirebaseStoragePlugin::ReferencePutString(
    const PigeonStorageFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference, const std::string& data,
    int64_t format, const PigeonSettableMetadata& settable_meta_data,
    int64_t handle, std::function<void(ErrorOr<std::string> reply)> result) {
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  std::vector<uint8_t> decoded_data =
      FirebaseStoragePlugin::StringToByteData(data, format);

  auto handler = std::make_unique<PutDataStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), decoded_data.data(),
      decoded_data.size(), controllers_[handle].get(), settable_meta_data);

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));

  result(channelName);
}

void FirebaseStoragePlugin::ReferencePutFile(
    const PigeonStorageFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference,
    const std::string& file_path,
    const PigeonSettableMetadata* settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutFileStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), std::move(file_path),
      controllers_[handle].get(), settable_meta_data);

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));

  result(channelName);
}

void FirebaseStoragePlugin::ReferenceDownloadFile(
    const PigeonStorageFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference,
    const std::string& file_path, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<GetFileStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), std::move(file_path),
      controllers_[handle].get());

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));

  result(channelName);
}

void FirebaseStoragePlugin::ReferenceUpdateMetadata(
    const PigeonStorageFirebaseApp& app,
    const PigeonStorageReference& reference,
    const PigeonSettableMetadata& metadata,
    std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, reference);
  Metadata* cpp_meta =
      FirebaseStoragePlugin::CreateStorageMetadataFromPigeon(&metadata);

  Future<Metadata> future_result = cpp_reference.UpdateMetadata(*cpp_meta);
  ::Sleep(1);  // timing for c++ sdk grabbing a mutex
  future_result.OnCompletion([result](const Future<Metadata>& data_result) {
    if (data_result.error() == firebase::storage::kErrorNone) {
      const Metadata* result_meta = data_result.result();
      PigeonFullMetaData pigeonData;
      pigeonData.set_metadata(ConvertMedadataToPigeon(result_meta));

      result(pigeonData);
    } else {
      result(FirebaseStoragePlugin::ParseError(data_result));
    }
  });
}

void FirebaseStoragePlugin::TaskPause(
    const PigeonStorageFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  bool status = controllers_[handle]->Pause();
  flutter::EncodableMap task_result = flutter::EncodableMap();
  flutter::EncodableMap task_data = flutter::EncodableMap();

  task_result[flutter::EncodableValue("status")] =
      flutter::EncodableValue(status);
  task_data[flutter::EncodableValue("bytesTransferred")] =
      flutter::EncodableValue(controllers_[handle]->bytes_transferred());
  task_data[flutter::EncodableValue("totalBytes")] =
      flutter::EncodableValue(controllers_[handle]->total_byte_count());
  task_result[flutter::EncodableValue("snapshot")] =
      flutter::EncodableValue(task_data);
  result(task_result);
}

void FirebaseStoragePlugin::TaskResume(
    const PigeonStorageFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  bool status = controllers_[handle]->Resume();
  flutter::EncodableMap task_result = flutter::EncodableMap();
  flutter::EncodableMap task_data = flutter::EncodableMap();
  task_result[flutter::EncodableValue("status")] =
      flutter::EncodableValue(status);
  task_data[flutter::EncodableValue("bytesTransferred")] =
      flutter::EncodableValue(controllers_[handle]->bytes_transferred());
  task_data[flutter::EncodableValue("totalBytes")] =
      flutter::EncodableValue(controllers_[handle]->total_byte_count());
  task_result[flutter::EncodableValue("snapshot")] =
      flutter::EncodableValue(task_data);
  result(task_result);
}

void FirebaseStoragePlugin::TaskCancel(
    const PigeonStorageFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  bool status = controllers_[handle]->Cancel();
  flutter::EncodableMap task_result = flutter::EncodableMap();
  flutter::EncodableMap task_data = flutter::EncodableMap();
  task_result[flutter::EncodableValue("status")] =
      flutter::EncodableValue(status);
  task_data[flutter::EncodableValue("bytesTransferred")] =
      flutter::EncodableValue(controllers_[handle]->bytes_transferred());
  task_data[flutter::EncodableValue("totalBytes")] =
      flutter::EncodableValue(controllers_[handle]->total_byte_count());
  task_result[flutter::EncodableValue("snapshot")] =
      flutter::EncodableValue(task_data);
  result(task_result);
}

std::vector<unsigned char> FirebaseStoragePlugin::StringToByteData(
    const std::string& data, int64_t format) {
  switch (format) {
    case Base64:
      return FirebaseStoragePlugin::Base64Decode(data);
    case Base64Url: {
      std::string url_safe_data = data;
      std::replace(url_safe_data.begin(), url_safe_data.end(), '-', '+');
      std::replace(url_safe_data.begin(), url_safe_data.end(), '_', '/');
      return FirebaseStoragePlugin::Base64Decode(url_safe_data);
    }
    default:
      return {};  // Return empty vector for unsupported formats
  }
}

std::vector<unsigned char> FirebaseStoragePlugin::Base64Decode(
    const std::string& encoded_string) {
  std::string base64_chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      "abcdefghijklmnopqrstuvwxyz"
      "0123456789+/";
  size_t in_len = encoded_string.size();
  size_t i = 0;
  size_t j = 0;
  size_t in_ = 0;
  unsigned char char_array_4[4], char_array_3[3];
  std::vector<unsigned char> ret;

  while (in_len-- && (encoded_string[in_] != '=') &&
         (isalnum(encoded_string[in_]) || encoded_string[in_] == '+' ||
          encoded_string[in_] == '/')) {
    char_array_4[i++] = encoded_string[in_];
    in_++;
    if (i == 4) {
      for (i = 0; i < 4; i++) {
        char_array_4[i] =
            static_cast<unsigned char>(base64_chars.find(char_array_4[i]));
      }

      char_array_3[0] =
          (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
      char_array_3[1] =
          ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
      char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

      for (i = 0; (i < 3); i++) ret.push_back(char_array_3[i]);
      i = 0;
    }
  }

  if (i) {
    for (j = 0; j < 4; j++)
      char_array_4[j] =
          base64_chars.find(char_array_4[j]) != std::string::npos
              ? static_cast<unsigned char>(base64_chars.find(char_array_4[j]))
              : 0;

    char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
    char_array_3[1] =
        ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
    char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

    for (j = 0; (j < i - 1); j++) ret.push_back(char_array_3[j]);
  }

  return ret;
}

}  // namespace firebase_storage_windows
