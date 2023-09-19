// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#define _CRT_SECURE_NO_WARNINGS
#include "firebase_storage_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/log.h"
#include "firebase/storage.h"
#include "firebase/storage/controller.h"
#include "firebase/storage/listener.h"
#include "firebase/storage/metadata.h"
#include "firebase/storage/storage_reference.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
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

static std::string kStorageMethodChannelName =
    "plugins.flutter.io/firebase_storage";
static std::string kStorageTaskEventName = "taskEvent";
// static
void FirebaseStoragePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseStoragePlugin>();

  messenger_ = registrar->messenger();

  FirebaseStorageHostApi::SetUp(registrar->messenger(), plugin.get());

  std::cout << "[C++] FirebaseStoragePlugin::RegisterWithRegistrar()"
            << std::endl;

  registrar->AddPlugin(std::move(plugin));
  firebase::SetLogLevel(firebase::kLogLevelVerbose);
}

FirebaseStoragePlugin::FirebaseStoragePlugin() {}

FirebaseStoragePlugin::~FirebaseStoragePlugin() = default;

Storage* GetCPPStorageFromPigeon(const PigeonFirebaseApp& pigeonApp,
                                 const std::string& bucket_path) {
  std::string default_url = std::string("gs://") + bucket_path;
  App* app = App::GetInstance(pigeonApp.app_name().c_str());
  Storage* cpp_storage = Storage::GetInstance(app, default_url.c_str());

  return cpp_storage;
}

StorageReference GetCPPStorageReferenceFromPigeon(
    const PigeonFirebaseApp& pigeonApp, const std::string& bucket,
    const PigeonStorageReference& pigeonReference) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(pigeonApp, bucket);
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

void FirebaseStoragePlugin::GetReferencebyPath(
    const PigeonFirebaseApp& app, const std::string& path,
    const std::string* bucket,
    std::function<void(ErrorOr<PigeonStorageReference> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, *bucket);
  StorageReference cpp_reference = cpp_storage->GetReference(path);
  PigeonStorageReference* value_ptr = new PigeonStorageReference(
      cpp_reference.bucket(), cpp_reference.full_path(), cpp_reference.name());
  result(*value_ptr);
}

void FirebaseStoragePlugin::SetMaxOperationRetryTime(
    const PigeonFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_operation_retry_time((double)time);
}

void FirebaseStoragePlugin::SetMaxUploadRetryTime(
    const PigeonFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_upload_retry_time((double)time);
}

void FirebaseStoragePlugin::SetMaxDownloadRetryTime(
    const PigeonFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, "");
  cpp_storage->set_max_download_retry_time((double)time);
}

void FirebaseStoragePlugin::UseStorageEmulator(
    const PigeonFirebaseApp& app, const std::string& host, int64_t port,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // C++ doesn't support emulator on desktop for now. Do nothing.
}
void FirebaseStoragePlugin::ReferenceDelete(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(std::optional<FlutterError> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Future<void> future_result = cpp_reference.Delete();
  future_result.OnCompletion([result](const Future<void>& void_result) {
    // TODO error handling
    std::cout << "[C++] FirebaseStoragePlugin::ReferenceDelete() COMPLETE"
              << std::endl;
    result(std::nullopt);
  });
}
void FirebaseStoragePlugin::ReferenceGetDownloadURL(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(ErrorOr<std::string> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Future<std::string> future_result = cpp_reference.GetDownloadUrl();
  future_result.OnCompletion(
      [result](const Future<std::string>& string_result) {
        // TODO error handling
        std::cout
            << "[C++] FirebaseStoragePlugin::ReferenceGetDownloadURL() COMPLETE"
            << std::endl;
        result(*string_result.result());
      });
}

flutter::EncodableMap ConvertMedadataToPigeon(const Metadata* meta) {
  flutter::EncodableMap meta_map = flutter::EncodableMap();
  // TODO: parse the meta
  return meta_map;
}

void GetMetadataFromPigeon(PigeonSettableMetadata pigeonMetadata,
                           Metadata* out_metadata) {
  // out_metadata->set_cache_control(pigeonMetadata.cache_control());
}

void FirebaseStoragePlugin::ReferenceGetMetaData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Future<Metadata> future_result = cpp_reference.GetMetadata();
  future_result.OnCompletion([result](const Future<Metadata>& metadata_result) {
    // TODO error handling
    std::cout << "[C++] FirebaseStoragePlugin::ReferenceGetMetaData() COMPLETE"
              << std::endl;
    PigeonFullMetaData pigeon_meta = PigeonFullMetaData();
    pigeon_meta.set_metadata(ConvertMedadataToPigeon(metadata_result.result()));

    result(pigeon_meta);
  });
}

void FirebaseStoragePlugin::ReferenceList(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const PigeonListOptions& options,
    std::function<void(ErrorOr<PigeonListResult> reply)> result) {
  // C++ doesn't support list yet
  flutter::EncodableList items = flutter::EncodableList();
  flutter::EncodableList prefixs = flutter::EncodableList();
  PigeonListResult pigeon_result = PigeonListResult(items, prefixs);
  result(pigeon_result);
}

void FirebaseStoragePlugin::ReferenceListAll(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(ErrorOr<PigeonListResult> reply)> result) {
  // C++ doesn't support listAll yet
  flutter::EncodableList items = flutter::EncodableList();
  flutter::EncodableList prefixs = flutter::EncodableList();
  PigeonListResult pigeon_result = PigeonListResult(items, prefixs);
  result(pigeon_result);
}

void FirebaseStoragePlugin::ReferenceGetData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    int64_t max_size,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
        result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  const size_t kMaxAllowedSize = 1 * 1024 * 1024;
  int8_t byte_buffer[kMaxAllowedSize];

  Future<size_t> future_result = cpp_reference.GetBytes(byte_buffer, max_size);
  future_result.OnCompletion([result,
                              byte_buffer](const Future<size_t>& data_result) {
    // TODO error handling
    std::cout << "[C++] FirebaseStoragePlugin::ReferenceGetData() COMPLETE"
              << std::endl;
    size_t vector_size = *data_result.result();
    std::vector<uint8_t> vector_buffer(byte_buffer, byte_buffer + vector_size);

    // result(vector_buffer);
  });
}

std::string kTaskStateName = "taskState";
std::string kTaskAppName = "appName";
std::string kTaskSnapshotName = "snapshot";
std::string kTaskSnapshotPath = "path";
std::string kTaskSnapshotBytesTransferred = "bytesTransferred";
std::string kTaskSnapshotTotalBytes = "totalBytes";

class TaskStateListener : public Listener {
 public:
  TaskStateListener(flutter::EventSink<flutter::EncodableValue>* events) {
    events_ = events;
  }
  virtual void OnProgress(firebase::storage::Controller* controller) {
    // A progress event occurred
    // TODO error handling
    std::cout << "[C++] TaskStateListener::OnProgress()" << std::endl;
    flutter::EncodableMap event = flutter::EncodableMap();
    event[kTaskStateName] = static_cast<int>(PigeonTaskState::running);
    event[kTaskAppName] = controller->GetReference().storage()->app()->name();
    flutter::EncodableMap snapshot = flutter::EncodableMap();
    snapshot[kTaskSnapshotPath] = controller->GetReference().full_path();
    snapshot[kTaskSnapshotTotalBytes] = controller->total_byte_count();
    snapshot[kTaskSnapshotBytesTransferred] = controller->bytes_transferred();
    event[kTaskSnapshotName] = snapshot;

    events_->Success(event);
  }

  virtual void OnPaused(firebase::storage::Controller* controller) {
    std::cout << "[C++] TaskStateListener::OnPaused()" << std::endl;
    // A progress event occurred
    flutter::EncodableMap event = flutter::EncodableMap();
    event[kTaskStateName] = static_cast<int>(PigeonTaskState::paused);
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
                       Controller* controller) {
    storage_ = storage;
    reference_path_ = reference_path;
    data_ = data;
    buffer_size_ = buffer_size;
    controller_ = controller;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);
    std::cout << "[C++] PutStringStreamHandler::OnListenInternal() START"
              << std::endl;
    TaskStateListener putStringListener = TaskStateListener(events_.get());
    StorageReference reference = storage_->GetReference(reference_path_);
    Future<Metadata> future_result = reference.PutBytes(
        data_, buffer_size_, &putStringListener, controller_);
    std::cout << "[C++] PutDataStreamHandler::OnListenInternal() after "
                 "reference putString"
              << std::endl;
    future_result.OnCompletion([this](const Future<Metadata>& data_result) {
      // TODO error handling
      std::cout << "[C++] PutDataStreamHandler::OnCompletion(), result error:"
                << data_result.error()
                << ", error message: " << data_result.error_message()
                << std::endl;
      flutter::EncodableMap event = flutter::EncodableMap();
      event[kTaskStateName] = static_cast<int>(PigeonTaskState::success);
      event[kTaskAppName] = std::string(storage_->app()->name());
      flutter::EncodableMap snapshot = flutter::EncodableMap();
      snapshot[kTaskSnapshotPath] = data_result.result()->path();
      snapshot[kTaskSnapshotTotalBytes] = data_result.result()->size_bytes();
      snapshot[kTaskSnapshotBytesTransferred] =
          data_result.result()->size_bytes();
      event[kTaskSnapshotName] = snapshot;

      events_->Success(event);
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    std::cout << "[C++] TaskStateStreamHandler::OnCancelInternal() START"
              << std::endl;
    return nullptr;
  }

 public:
  Storage* storage_;
  std::string reference_path_;
  const void* data_;
  size_t buffer_size_;
  Controller* controller_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events_ =
      nullptr;
};

class PutFileStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  PutFileStreamHandler(Storage* storage, std::string reference_path,
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
    std::cout << "[C++] PutFileStreamHandler::OnListenInternal() START"
              << std::endl;
    TaskStateListener putStringListener = TaskStateListener(events_.get());
    StorageReference reference = storage_->GetReference(reference_path_);
    Future<Metadata> future_result =
        reference.PutFile(file_path_.c_str(), &putStringListener, controller_);
    std::cout << "[C++] PutFileStreamHandler::OnListenInternal() after "
                 "reference putFile"
              << std::endl;
    future_result.OnCompletion([this](const Future<Metadata>& data_result) {
      // TODO error handling
      std::cout << "[C++] PutFileStreamHandler::OnCompletion(), result error:"
                << data_result.error()
                << ", error message: " << data_result.error_message()
                << std::endl;
      flutter::EncodableMap event = flutter::EncodableMap();
      event[kTaskStateName] = static_cast<int>(PigeonTaskState::success);
      event[kTaskAppName] = std::string(storage_->app()->name());
      flutter::EncodableMap snapshot = flutter::EncodableMap();
      snapshot[kTaskSnapshotPath] = data_result.result()->path();
      snapshot[kTaskSnapshotTotalBytes] = data_result.result()->size_bytes();
      snapshot[kTaskSnapshotBytesTransferred] =
          data_result.result()->size_bytes();
      event[kTaskSnapshotName] = snapshot;

      events_->Success(event);
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    std::cout << "[C++] TaskStateStreamHandler::OnCancelInternal() START"
              << std::endl;
    return nullptr;
  }

 public:
  Storage* storage_;
  std::string reference_path_;
  std::string file_path_;
  Controller* controller_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events_ =
      nullptr;
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
    std::cout << "[C++] GetFileStreamHandler::OnListenInternal() START"
              << std::endl;
    TaskStateListener putStringListener = TaskStateListener(events_.get());
    StorageReference reference = storage_->GetReference(reference_path_);
    Future<size_t> future_result =
        reference.GetFile(file_path_.c_str(), &putStringListener, controller_);
    std::cout << "[C++] GetFileStreamHandler::OnListenInternal() after "
                 "reference putString"
              << std::endl;
    future_result.OnCompletion([this](const Future<size_t>& data_result) {
      // TODO error handling
      std::cout << "[C++] GetFileStreamHandler::OnCompletion(), result error:"
                << data_result.error()
                << ", error message: " << data_result.error_message()
                << std::endl;
      flutter::EncodableMap event = flutter::EncodableMap();
      event[kTaskStateName] = static_cast<int>(PigeonTaskState::success);
      event[kTaskAppName] = std::string(storage_->app()->name());
      flutter::EncodableMap snapshot = flutter::EncodableMap();
      // snapshot[kTaskSnapshotPath] = data_result.result()->path();
      snapshot[kTaskSnapshotTotalBytes] = data_result.result();
      snapshot[kTaskSnapshotBytesTransferred] = data_result.result();
      event[kTaskSnapshotName] = snapshot;

      events_->Success(event);
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    std::cout << "[C++] GetFileStreamHandler::OnCancelInternal() START"
              << std::endl;
    return nullptr;
  }

 public:
  Storage* storage_;
  std::string reference_path_;
  std::string file_path_;
  Controller* controller_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events_ =
      nullptr;
};

void FirebaseStoragePlugin::ReferencePutData(
    const PigeonFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference,
    const std::vector<uint8_t>& data,
    const PigeonSettableMetadata& pigeon_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  std::cout << "[C++] FirebaseStoragePlugin::ReferencePutData() START"
            << std::endl;
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutDataStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), &data, data.size(),
      controllers_[handle].get());

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));

  result(channelName);
}

void FirebaseStoragePlugin::RefrencePutString(
    const PigeonFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference, const std::string& data,
    int64_t format, const PigeonSettableMetadata& settable_meta_data,
    int64_t handle, std::function<void(ErrorOr<std::string> reply)> result) {
  std::cout << "[C++] FirebaseStoragePlugin::RefrencePutString() START"
            << std::endl;
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutDataStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), &data, data.size(),
      controllers_[handle].get());

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));
  std::cout << "[C++] FirebaseStoragePlugin::RefrencePutString() End with "
               "channel:"
            << channelName << std::endl;
  result(channelName);
}

void FirebaseStoragePlugin::ReferencePutFile(
    const PigeonFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference,
    const std::string& file_path,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  std::cout << "[C++] FirebaseStoragePlugin::ReferencePutFile() START"
            << std::endl;
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<PutFileStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), std::move(file_path),
      controllers_[handle].get());

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));

  result(channelName);
}

void FirebaseStoragePlugin::ReferenceDownloadFile(
    const PigeonFirebaseApp& pigeon_app,
    const PigeonStorageReference& pigeon_reference,
    const std::string& file_path, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  std::cout << "[C++] FirebaseStoragePlugin::ReferenceDownloadFile() START:"
            << file_path << std::endl;
  Storage* cpp_storage =
      GetCPPStorageFromPigeon(pigeon_app, pigeon_reference.bucket());
  controllers_[handle] = std::make_unique<Controller>();

  auto handler = std::make_unique<GetFileStreamHandler>(
      cpp_storage, pigeon_reference.full_path(), std::move(file_path),
      controllers_[handle].get());

  std::string channelName = RegisterEventChannel(
      kStorageMethodChannelName + "/" + kStorageTaskEventName,
      std::move(handler));
  std::cout << "[C++] FirebaseStoragePlugin::ReferenceDownloadFile() End with "
               "channel:"
            << channelName << std::endl;
  result(channelName);
}

void FirebaseStoragePlugin::ReferenceUpdateMetadata(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const PigeonSettableMetadata& metadata,
    std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Metadata cpp_meta;
  GetMetadataFromPigeon(metadata, &cpp_meta);
  Future<Metadata> future_result = cpp_reference.UpdateMetadata(cpp_meta);
  future_result.OnCompletion([result](const Future<Metadata>& data_result) {
    // TODO error handling
    std::cout
        << "[C++] FirebaseStoragePlugin::ReferenceUpdateMetadata() COMPLETE"
        << std::endl;
    PigeonFullMetaData pigeonData;
    pigeonData.set_metadata(ConvertMedadataToPigeon(data_result.result()));
    result(pigeonData);
  });
}

void FirebaseStoragePlugin::TaskPause(
    const PigeonFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  bool status = controllers_[handle]->Pause();
  flutter::EncodableMap task_result = flutter::EncodableMap();
  flutter::EncodableMap task_data = flutter::EncodableMap();
  task_result["status"] = status;
  task_data["bytesTransferred"] = controllers_[handle]->bytes_transferred();
  task_data["totalBytes"] = controllers_[handle]->total_byte_count();
  task_result["snapshot"] = task_data;
  result(task_result);
}

void FirebaseStoragePlugin::TaskResume(
    const PigeonFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  bool status = controllers_[handle]->Resume();
  flutter::EncodableMap task_result = flutter::EncodableMap();
  flutter::EncodableMap task_data = flutter::EncodableMap();
  task_result["status"] = status;
  task_data["bytesTransferred"] = controllers_[handle]->bytes_transferred();
  task_data["totalBytes"] = controllers_[handle]->total_byte_count();
  task_result["snapshot"] = task_data;
  result(task_result);
}

void FirebaseStoragePlugin::TaskCancel(
    const PigeonFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {
  bool status = controllers_[handle]->Cancel();
  flutter::EncodableMap task_result = flutter::EncodableMap();
  flutter::EncodableMap task_data = flutter::EncodableMap();
  task_result["status"] = status;
  task_data["bytesTransferred"] = controllers_[handle]->bytes_transferred();
  task_data["totalBytes"] = controllers_[handle]->total_byte_count();
  task_result["snapshot"] = task_data;
  result(task_result);
}

}  // namespace firebase_storage_windows
