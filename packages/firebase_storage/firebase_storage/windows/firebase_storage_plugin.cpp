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
                                 const std::string& path) {
  void* storage_ptr = GetFirebaseStorage(pigeonApp.app_name(), path);
  Storage* cpp_storage = static_cast<Storage*>(storage_ptr);

  return cpp_storage;
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
    std::function<void(std::optional<FlutterError> reply)> result) {}
void FirebaseStoragePlugin::ReferenceDelete(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(std::optional<FlutterError> reply)> result) {}
void FirebaseStoragePlugin::ReferenceGetDownloadURL(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(ErrorOr<std::string> reply)> result) {}
void FirebaseStoragePlugin::ReferenceGetMetaData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) {}
void FirebaseStoragePlugin::ReferenceList(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const PigeonListOptions& options,
    std::function<void(ErrorOr<PigeonListResult> reply)> result) {}
void FirebaseStoragePlugin::ReferenceListAll(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    std::function<void(ErrorOr<PigeonListResult> reply)> result) {}
void FirebaseStoragePlugin::ReferenceGetData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    int64_t max_size,
    std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
        result) {}
void FirebaseStoragePlugin::ReferencePutData(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::vector<uint8_t>& data,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {}
void FirebaseStoragePlugin::RefrencePutString(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::string& data, int64_t format,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {}
void FirebaseStoragePlugin::ReferencePutFile(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::string& file_path,
    const PigeonSettableMetadata& settable_meta_data, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {}
void FirebaseStoragePlugin::ReferenceDownloadFile(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const std::string& file_path, int64_t handle,
    std::function<void(ErrorOr<std::string> reply)> result) {}
void FirebaseStoragePlugin::ReferenceUpdateMetadata(
    const PigeonFirebaseApp& app, const PigeonStorageReference& reference,
    const PigeonSettableMetadata& metadata,
    std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) {}
void FirebaseStoragePlugin::TaskPause(
    const PigeonFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {}
void FirebaseStoragePlugin::TaskResume(
    const PigeonFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {}
void FirebaseStoragePlugin::TaskCancel(
    const PigeonFirebaseApp& app, int64_t handle,
    std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) {}

}  // namespace firebase_storage_windows
