/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_STORAGE_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_STORAGE_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "firebase/storage/common.h"
#include "firebase/storage/controller.h"
#include "firebase/storage/metadata.h"
#include "messages.g.h"

using firebase::storage::Error;

namespace firebase_storage_windows {

class FirebaseStoragePlugin : public flutter::Plugin,
                              public FirebaseStorageHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FirebaseStoragePlugin();

  virtual ~FirebaseStoragePlugin();

  // Disallow copy and assign.
  FirebaseStoragePlugin(const FirebaseStoragePlugin&) = delete;
  FirebaseStoragePlugin& operator=(const FirebaseStoragePlugin&) = delete;
  // Static function declarations
  // Helper functions
  static firebase::storage::Metadata* CreateStorageMetadataFromPigeon(
      const PigeonSettableMetadata* pigeonMetaData);
  static std::map<std::string, std::string> ProcessCustomMetadataMap(
      const flutter::EncodableMap& customMetadata);
  static std::vector<unsigned char> StringToByteData(const std::string& data,
                                                     int64_t format);
  static std::vector<unsigned char> Base64Decode(
      const std::string& encoded_string);
  // Parser functions
  static std::string GetStorageErrorCode(Error cppError);
  static std::string GetStorageErrorMessage(Error cppError);
  static FlutterError ParseError(const firebase::FutureBase& future);
  static flutter::EncodableMap ErrorStreamEvent(
      const firebase::FutureBase& data_result, const std::string& app_name);

  // FirebaseStorageHostApi
  virtual void GetReferencebyPath(
      const PigeonStorageFirebaseApp& app, const std::string& path,
      const std::string* bucket,
      std::function<void(ErrorOr<PigeonStorageReference> reply)> result)
      override;
  virtual void SetMaxOperationRetryTime(
      const PigeonStorageFirebaseApp& app, int64_t time,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SetMaxUploadRetryTime(
      const PigeonStorageFirebaseApp& app, int64_t time,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void SetMaxDownloadRetryTime(
      const PigeonStorageFirebaseApp& app, int64_t time,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void UseStorageEmulator(
      const PigeonStorageFirebaseApp& app, const std::string& host,
      int64_t port,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void ReferenceDelete(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference,
      std::function<void(std::optional<FlutterError> reply)> result) override;
  virtual void ReferenceGetDownloadURL(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void ReferenceGetMetaData(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference,
      std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) override;
  virtual void ReferenceList(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference, const PigeonListOptions& options,
      std::function<void(ErrorOr<PigeonListResult> reply)> result) override;
  virtual void ReferenceListAll(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference,
      std::function<void(ErrorOr<PigeonListResult> reply)> result) override;
  virtual void ReferenceGetData(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference, int64_t max_size,
      std::function<void(ErrorOr<std::optional<std::vector<uint8_t>>> reply)>
          result) override;
  virtual void ReferencePutData(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference, const std::vector<uint8_t>& data,
      const PigeonSettableMetadata& settable_meta_data, int64_t handle,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void ReferencePutString(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference, const std::string& data,
      int64_t format, const PigeonSettableMetadata& settable_meta_data,
      int64_t handle,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void ReferencePutFile(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference, const std::string& file_path,
      const PigeonSettableMetadata* settable_meta_data, int64_t handle,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void ReferenceDownloadFile(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference, const std::string& file_path,
      int64_t handle,
      std::function<void(ErrorOr<std::string> reply)> result) override;
  virtual void ReferenceUpdateMetadata(
      const PigeonStorageFirebaseApp& app,
      const PigeonStorageReference& reference,
      const PigeonSettableMetadata& metadata,
      std::function<void(ErrorOr<PigeonFullMetaData> reply)> result) override;
  virtual void TaskPause(
      const PigeonStorageFirebaseApp& app, int64_t handle,
      std::function<void(ErrorOr<flutter::EncodableMap> reply)> result)
      override;
  virtual void TaskResume(
      const PigeonStorageFirebaseApp& app, int64_t handle,
      std::function<void(ErrorOr<flutter::EncodableMap> reply)> result)
      override;
  virtual void TaskCancel(
      const PigeonStorageFirebaseApp& app, int64_t handle,
      std::function<void(ErrorOr<flutter::EncodableMap> reply)> result)
      override;

  static flutter::BinaryMessenger* messenger_;
  static std::map<
      std::string,
      std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
      event_channels_;
  static std::map<std::string, std::unique_ptr<flutter::StreamHandler<>>>
      stream_handlers_;

 private:
  bool storageInitialized = false;
  std::map<uint64_t, std::unique_ptr<::firebase::storage::Controller>>
      controllers_;
};

}  // namespace firebase_storage_windows

#endif /* FLUTTER_PLUGIN_FIREBASE_STORAGE_PLUGIN_H_ */
