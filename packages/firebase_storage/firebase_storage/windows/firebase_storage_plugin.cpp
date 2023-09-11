// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#define _CRT_SECURE_NO_WARNINGS
#include "firebase_storage_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/"
#include "firebase/app.h"
#include "firebase/future.h"
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

namespace firebase_storage_windows {

// static
void FirebaseStoragePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseStoragePlugin>();

  FirebaseStorageHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

FirebaseStoragePlugin::FirebaseStoragePlugin() {}

FirebaseStoragePlugin::~FirebaseStoragePlugin() = default;

Storage* GetCPPStorageFromPigeon(const PigeonFirebaseApp& pigeonApp,
                                 const std::string& pathconst
                                     std::string& path) {
  void* storage_ptr = GetFirebaseStorage(pigeonApp.app_name(), path);
  Storage* cpp_storage = static_cast<Storage*>(storage_ptr);

  return cpp_storage;
}

StorageReference GetCPPStorageReferenceFromPigeon(
    const PigeonFirebaseApp& pigeonApp, const std::string& bucket,
    const PigeonStorageReference& pigeonReference) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, *bucket);
  return cpp_storage->GetReference(pigeonReference.full_path());
}

std::string RegisterEventChannelWithUUID(
    std::string prefix, std::string uuid,
    const flutter::StreamHandler<flutter::EncodableValue>& handler) {
  std::string channelName = prefix + uuid;
  flutter::EventChannel<flutter::EncodableValue>* channel =
      new flutter::EventChannel<flutter::EncodableValue>(
          FirebaseStoragePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance());

  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(channel);
  stream_handlers_[channelName] =
      std::make_unique<flutter::StreamHandler<>>(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return channelName;
}

std::string RegisterEventChannel(
    std::string prefix, const flutter::StreamHandler<EncodableValue>& handler) {
  UUID uuid;
  UuidCreate(&uuid);
  char* str;
  UuidToStringA(&uuid, (RPC_CSTR*)&str);

  std::string channelName = prefix + "_" + str;
  flutter::EventChannel<flutter::EncodableValue>* channel =
      new flutter::EventChannel<flutter::EncodableValue>(
          FirebaseStoragePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance());

  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(channel);
  stream_handlers_[channelName] =
      std::make_unique<flutter::StreamHandler<>>(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return channelName;
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

std::optional<FlutterError> FirebaseStoragePlugin::SetMaxOperationRetryTime(
    const PigeonFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, *bucket);
  cpp_storage->set_max_operation_retry_time((double)time);
}

std::optional<FlutterError> FirebaseStoragePlugin::SetMaxUploadRetryTime(
    const PigeonFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, *bucket);
  cpp_storage->set_max_upload_retry_time((double)time);
}

std::optional<FlutterError> FirebaseStoragePlugin::SetMaxDownloadRetryTime(
    const PigeonFirebaseApp& app, int64_t time,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Storage* cpp_storage = GetCPPStorageFromPigeon(app, *bucket);
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
        result(string_result.result());
      });
}

flutter::EncodableMap ConvertMedadataToPigeon(Metadata* meta) {
  flutter::EncodableMap meta_map = flutter::EncodableMap();
  // TODO: parse the meta
  return meta_map;
}

void GetMetadataFromPigeon(PigeonSettableMetadata pigeonMetadata,
                           Metadata* out_metadata) {
  out_metadata->set_cache_control(pigeonMetadata.cache_control());
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

    PigeonFullMetaData pigeon_meta =
        PigeonFullMetaData(ConvertMedadataToPigeon(metadata_result.result()));

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

class TaskStateStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  TaskStateStreamHandler(Storage* storage, Listener* listener) {
    storage_ = storage;
    listener_ = listener;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {}

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    return nullptr;
  }

 private:
  Storage* storage_;
  Listener* listener_;
};

void FirebaseStoragePlugin::ReferenceGetData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    int64_t max_size,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
        result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  int8_t byte_buffer[max_size];

  Future<size_t> future_result = cpp_reference.GetBytes(byte_buffer, max_size);
  future_result.OnCompletion([result](const Future<size_t>& data_result) {
    // TODO error handling
    std::cout << "[C++] FirebaseStoragePlugin::ReferenceGetData() COMPLETE"
              << std::endl;

    result(byte_buffer);
  });
}

void FirebaseStoragePlugin::ReferencePutData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::vector<uint8_t>& data,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Controller controller;
  Listener listener;
  auto handler =
      std::make_unique<TaskStateStreamHandler>(&cpp_reference, &listener);

  std::string channelName = RegisterEventChannel("putData", *handler);

  Future<Metadata> future_result =
      cpp_reference.PutBytes(data, data.size(), &listener, &controller);
  controllers_[handle] = controller;

  result(channelName);
}

void FirebaseStoragePlugin::RefrencePutString(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::string& data, int64_t format,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Controller controller;
  Listener listener;
  auto handler =
      std::make_unique<TaskStateStreamHandler>(&cpp_reference, &listener);

  std::string channelName = RegisterEventChannel("putString", *handler);

  Future<Metadata> future_result =
      cpp_reference.PutBytes(data, data.size(), &listener, &controller);
  controllers_[handle] = controller;

  result(channelName);
}

void FirebaseStoragePlugin::ReferencePutFile(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::string& file_path,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Controller controller;
  Listener listener;
  auto handler =
      std::make_unique<TaskStateStreamHandler>(&cpp_reference, &listener);

  std::string channelName = RegisterEventChannel("putFile", *handler);

  Future<Metadata> future_result =
      cpp_reference.PutFile(file_path.c_str(), &listener, &controller);
  controllers_[handle] = controller;

  result(channelName);
}

void FirebaseStoragePlugin::ReferenceDownloadFile(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::string& file_path, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  StorageReference cpp_reference =
      GetCPPStorageReferenceFromPigeon(app, "", reference);
  Controller controller;
  Listener listener;
  auto handler =
      std::make_unique<TaskStateStreamHandler>(&cpp_reference, &listener);

  std::string channelName = RegisterEventChannel("putFile", *handler);

  Future<Metadata> future_result =
      cpp_reference.GetFile(file_path.c_str(), &listener, &controller);
  controllers_[handle] = controller;

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
  Future<MetaData> future_result = cpp_reference.UpdateMetadata(cpp_meta);
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
