// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#pragma comment(lib, \
                "rpcrt4.lib")  // UuidCreate - Minimum supported OS Win 2000

#include "cloud_firestore_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <condition_variable>
#include <future>
#include <memory>
#include <mutex>
#include <sstream>

#include "cloud_firestore/plugin_version.h"
#include "firebase/app.h"
#include "firebase/firestore.h"
#include "firebase/firestore/filter.h"
#include "firebase/log.h"
#include "firebase_core/firebase_core_plugin_c_api.h"
#include "messages.g.h"

using namespace firebase::firestore;
using firebase::App;
using firebase::firestore::DocumentSnapshot;
using firebase::firestore::Firestore;
using flutter::CustomEncodableValue;
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace cloud_firestore_windows {

static std::string kLibraryName = "flutter-fire-fst";
// static
void CloudFirestorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "cloud_firestore",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<CloudFirestorePlugin>();

  messenger_ = registrar->messenger();

  FirebaseFirestoreHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  // Register for platform logging
  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

firebase::firestore::FieldValue CloudFirestorePlugin::ConvertToFieldValue(
    const flutter::EncodableValue& variant) {
  if (std::holds_alternative<std::monostate>(variant)) {
    return firebase::firestore::FieldValue::Null();
  } else if (std::holds_alternative<bool>(variant)) {
    return firebase::firestore::FieldValue::Boolean(std::get<bool>(variant));
  } else if (std::holds_alternative<int32_t>(variant)) {
    return firebase::firestore::FieldValue::Integer(std::get<int32_t>(variant));
  } else if (std::holds_alternative<int64_t>(variant)) {
    return firebase::firestore::FieldValue::Integer(std::get<int64_t>(variant));
  } else if (std::holds_alternative<double>(variant)) {
    return firebase::firestore::FieldValue::Double(std::get<double>(variant));
  } else if (std::holds_alternative<std::string>(variant)) {
    return firebase::firestore::FieldValue::String(
        std::get<std::string>(variant));
  } else if (std::holds_alternative<flutter::EncodableList>(variant)) {
    const flutter::EncodableList& list =
        std::get<flutter::EncodableList>(variant);
    std::vector<firebase::firestore::FieldValue> convertedList;
    for (const auto& item : list) {
      convertedList.push_back(ConvertToFieldValue(item));
    }
    return firebase::firestore::FieldValue::Array(convertedList);
  } else if (std::holds_alternative<flutter::EncodableMap>(variant)) {
    const flutter::EncodableMap& map = std::get<flutter::EncodableMap>(variant);
    firebase::firestore::MapFieldValue convertedMap =
        ConvertToMapFieldValue(map);
    return firebase::firestore::FieldValue::Map(convertedMap);
  } else if (std::holds_alternative<flutter::CustomEncodableValue>(variant)) {
    const CustomEncodableValue& custom_value =
        std::get<CustomEncodableValue>(variant);

    using firebase::Timestamp;

    if (custom_value.type() ==
        typeid(firebase::firestore::FieldValue::Timestamp)) {
      const firebase::firestore::FieldValue& timestamp =
          std::any_cast<firebase::firestore::FieldValue>(custom_value);
      return timestamp;
    } else if (custom_value.type() ==
               typeid(firebase::firestore::DocumentReference)) {
      const firebase::firestore::DocumentReference& documentReference =
          std::any_cast<firebase::firestore::DocumentReference>(custom_value);
      return firebase::firestore::FieldValue::Reference(documentReference);
    }
    // check if nan and store it in number
    else if (custom_value.type() == typeid(double)) {
      const double& number = std::any_cast<double>(custom_value);
      return firebase::firestore::FieldValue::Double(number);
    }

    const firebase::firestore::FieldValue& anyField =
        std::any_cast<firebase::firestore::FieldValue>(custom_value);
    return anyField;
  } else {
    // Add more types as needed
    // You may throw an exception or handle this some other way
    throw std::runtime_error("Unsupported EncodableValue type");
  }
}

flutter::BinaryMessenger*
    cloud_firestore_windows::CloudFirestorePlugin::messenger_ = nullptr;

std::map<std::string,
         std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
    event_channels_;
std::map<std::string, std::unique_ptr<flutter::StreamHandler<>>>
    stream_handlers_;
std::map<std::string,
         std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>>>
    cloud_firestore_windows::CloudFirestorePlugin::transaction_handlers_;
std::map<std::string, std::shared_ptr<firebase::firestore::Transaction>>
    cloud_firestore_windows::CloudFirestorePlugin::transactions_;
std::map<std::string, std::unique_ptr<firebase::firestore::Firestore>>
    cloud_firestore_windows::CloudFirestorePlugin::firestoreInstances_;

std::string RegisterEventChannelWithUUID(
    std::string prefix, std::string uuid,
    std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>> handler) {
  std::string channelName = prefix + uuid;
  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          CloudFirestorePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance(
              &FirebaseFirestoreHostApiCodecSerializer::GetInstance()));

  stream_handlers_[channelName] = std::move(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return channelName;
}

std::string RegisterEventChannel(
    std::string prefix,
    std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>> handler) {
  UUID uuid;
  UuidCreate(&uuid);
  char* str;
  UuidToStringA(&uuid, (RPC_CSTR*)&str);

  std::string channelName = prefix + str;
  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          CloudFirestorePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance(
              &FirebaseFirestoreHostApiCodecSerializer::GetInstance()));
  stream_handlers_[channelName] = std::move(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return str;
}

CloudFirestorePlugin::CloudFirestorePlugin() {}

CloudFirestorePlugin::~CloudFirestorePlugin() {}

Firestore* GetFirestoreFromPigeon(const FirestorePigeonFirebaseApp& pigeonApp) {
  std::string cacheKey =
      pigeonApp.app_name() + "-" + pigeonApp.database_u_r_l();

  if (CloudFirestorePlugin::firestoreInstances_.find(cacheKey) !=
      CloudFirestorePlugin::firestoreInstances_.end()) {
    return CloudFirestorePlugin::firestoreInstances_[cacheKey].get();
  }

  App* app = App::GetInstance(pigeonApp.app_name().c_str());

  Firestore* firestore =
      Firestore::GetInstance(app, pigeonApp.database_u_r_l().c_str());

  firebase::firestore::Settings settings;

  if (pigeonApp.settings().persistence_enabled()) {
    bool persistEnabled = pigeonApp.settings().persistence_enabled();

    // This is the maximum amount of cache allowed. We use the same number on
    // android.
    int64_t size = 104857600;

    if (pigeonApp.settings().cache_size_bytes()) {
      const int64_t* cacheSizeBytes = pigeonApp.settings().cache_size_bytes();
      if (*cacheSizeBytes != -1) {
        size = *cacheSizeBytes;
      }
    }

    if (persistEnabled) {
      settings.set_cache_size_bytes(size);
    }
  }

  if (pigeonApp.settings().host()) {
    settings.set_host(*pigeonApp.settings().host());

    // Only allow changing ssl if host is also specified.
    settings.set_ssl_enabled(false);
  }

  firestore->set_settings(settings);

  CloudFirestorePlugin::firestoreInstances_[cacheKey] =
      std::unique_ptr<firebase::firestore::Firestore>(firestore);

  return firestore;
}

std::string CloudFirestorePlugin::GetErrorCode(
    firebase::firestore::Error error) {
  switch (error) {
    case kErrorOk:
      return "ok";
    case kErrorCancelled:
      return "cancelled";
    case kErrorUnknown:
      return "unknown";
    case kErrorInvalidArgument:
      return "invalid-argument";
    case kErrorDeadlineExceeded:
      return "deadline-exceeded";
    case kErrorNotFound:
      return "not-found";
    case kErrorAlreadyExists:
      return "already-exists";
    case kErrorPermissionDenied:
      return "permission-denied";
    case kErrorResourceExhausted:
      return "resource-exhausted";
    case kErrorFailedPrecondition:
      return "failed-precondition";
    case kErrorAborted:
      return "aborted";
    case kErrorOutOfRange:
      return "out-of-range";
    case kErrorUnimplemented:
      return "unimplemented";
    case kErrorInternal:
      return "internal";
    case kErrorUnavailable:
      return "unavailable";
    case kErrorDataLoss:
      return "data-loss";
    case kErrorUnauthenticated:
      return "unauthenticated";
    default:
      return "unknown-error";
  }
}

FlutterError CloudFirestorePlugin::ParseError(
    const firebase::FutureBase& completed_future) {
  const firebase::firestore::Error errorCode =
      static_cast<const firebase::firestore::Error>(completed_future.error());

  EncodableMap details;
  details[EncodableValue("code")] =
      EncodableValue(CloudFirestorePlugin::GetErrorCode(errorCode));
  details[EncodableValue("message")] =
      EncodableValue(completed_future.error_message());

  return FlutterError("firebase_firestore", completed_future.error_message(),
                      details);
}

firebase::firestore::Source GetSourceFromPigeon(const Source& pigeonSource) {
  switch (pigeonSource) {
    case Source::serverAndCache:
    default:
      return firebase::firestore::Source::kDefault;
    case Source::server:
      return firebase::firestore::Source::kServer;
    case Source::cache:
      return firebase::firestore::Source::kCache;
  }
}

firebase::firestore::DocumentSnapshot::ServerTimestampBehavior
GetServerTimestampBehaviorFromPigeon(
    const ServerTimestampBehavior& pigeonServerTimestampBehavior) {
  switch (pigeonServerTimestampBehavior) {
    case ServerTimestampBehavior::estimate:
      return firebase::firestore::DocumentSnapshot::ServerTimestampBehavior::
          kEstimate;
    case ServerTimestampBehavior::previous:
      return firebase::firestore::DocumentSnapshot::ServerTimestampBehavior::
          kPrevious;
    case ServerTimestampBehavior::none:
    default:
      return firebase::firestore::DocumentSnapshot::ServerTimestampBehavior::
          kNone;
  }
}

EncodableValue ConvertFieldValueToEncodableValue(const FieldValue& fieldValue) {
  switch (fieldValue.type()) {
    case FieldValue::Type::kNull:
      return EncodableValue();

    case FieldValue::Type::kBoolean:
      return EncodableValue(fieldValue.boolean_value());

    case FieldValue::Type::kInteger:
      return EncodableValue(static_cast<int64_t>(fieldValue.integer_value()));

    case FieldValue::Type::kDouble:
      return EncodableValue(fieldValue.double_value());

    case FieldValue::Type::kTimestamp:
      // Assuming timestamp can be converted to int64_t or some other type that
      // EncodableValue accepts
      return CustomEncodableValue(fieldValue.timestamp_value());

    case FieldValue::Type::kString:
      return EncodableValue(fieldValue.string_value());

    case FieldValue::Type::kMap: {
      EncodableMap encodableMap;
      for (const auto& [key, val] : fieldValue.map_value()) {
        encodableMap[EncodableValue(key)] =
            ConvertFieldValueToEncodableValue(val);
      }
      return EncodableValue(encodableMap);
    }

    case FieldValue::Type::kArray: {
      flutter::EncodableList encodableList;
      for (const auto& val : fieldValue.array_value()) {
        encodableList.push_back(ConvertFieldValueToEncodableValue(val));
      }
      return encodableList;
    }

    case FieldValue::Type::kGeoPoint: {
      return CustomEncodableValue(fieldValue.geo_point_value());
    }

    case FieldValue::Type::kReference: {
      return CustomEncodableValue(fieldValue.reference_value());
    }

    default:
      return EncodableValue(nullptr);
  }
}

flutter::EncodableMap ConvertToEncodableMap(
    const firebase::firestore::MapFieldValue& originalMap) {
  EncodableMap convertedMap;
  for (const auto& kv : originalMap) {
    EncodableValue key = EncodableValue(kv.first);
    EncodableValue value = ConvertFieldValueToEncodableValue(
        kv.second);             // convert FieldValue to EncodableValue
    convertedMap[key] = value;  // insert into the new map
  }
  return convertedMap;
}

PigeonSnapshotMetadata ParseSnapshotMetadata(
    const firebase::firestore::SnapshotMetadata& metadata) {
  PigeonSnapshotMetadata pigeonSnapshotMetadata = PigeonSnapshotMetadata(
      metadata.has_pending_writes(), metadata.is_from_cache());
  return pigeonSnapshotMetadata;
}

PigeonDocumentSnapshot ParseDocumentSnapshot(
    DocumentSnapshot document,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  flutter::EncodableMap tempMap =
      ConvertToEncodableMap(document.GetData(serverTimestampBehavior));

  if (tempMap.empty()) {
    return PigeonDocumentSnapshot(document.reference().path(), nullptr,
                                  ParseSnapshotMetadata(document.metadata()));
  }

  PigeonDocumentSnapshot pigeonDocumentSnapshot =
      PigeonDocumentSnapshot(document.reference().path(), &tempMap,
                             ParseSnapshotMetadata(document.metadata()));
  return pigeonDocumentSnapshot;
}

flutter::EncodableList ParseDocumentSnapshots(
    std::vector<DocumentSnapshot> documents,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  flutter::EncodableList pigeonDocumentSnapshot = flutter::EncodableList();

  for (const auto& document : documents) {
    pigeonDocumentSnapshot.push_back(CustomEncodableValue(
        ParseDocumentSnapshot(document, serverTimestampBehavior)));
  }
  return pigeonDocumentSnapshot;
}

DocumentChangeType ParseDocumentChangeType(
    const firebase::firestore::DocumentChange::Type& type) {
  switch (type) {
    case firebase::firestore::DocumentChange::Type::kAdded:
      return DocumentChangeType::added;
    case firebase::firestore::DocumentChange::Type::kRemoved:
      return DocumentChangeType::removed;
    case firebase::firestore::DocumentChange::Type::kModified:
      return DocumentChangeType::modified;
  }

  throw std::invalid_argument("Invalid DocumentChangeType");
}

PigeonDocumentChange ParseDocumentChange(
    const firebase::firestore::DocumentChange& document_change,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  PigeonDocumentChange pigeonDocumentChange = PigeonDocumentChange(
      ParseDocumentChangeType(document_change.type()),
      ParseDocumentSnapshot(document_change.document(),
                            serverTimestampBehavior),
      document_change.old_index(), document_change.new_index());
  return pigeonDocumentChange;
}

flutter::EncodableList ParseDocumentChanges(
    std::vector<firebase::firestore::DocumentChange> document_changes,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  flutter::EncodableList pigeonDocumentChanges = flutter::EncodableList();
  for (const auto& document_change : document_changes) {
    pigeonDocumentChanges.push_back(CustomEncodableValue(
        ParseDocumentChange(document_change, serverTimestampBehavior)));
  }
  return pigeonDocumentChanges;
}

PigeonQuerySnapshot ParseQuerySnapshot(
    const firebase::firestore::QuerySnapshot* query_snapshot,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  PigeonQuerySnapshot pigeonQuerySnapshot = PigeonQuerySnapshot(
      ParseDocumentSnapshots(query_snapshot->documents(),
                             serverTimestampBehavior),
      ParseDocumentChanges(query_snapshot->DocumentChanges(),
                           serverTimestampBehavior),
      ParseSnapshotMetadata(query_snapshot->metadata()));

  return pigeonQuerySnapshot;
}

std::vector<firebase::firestore::FieldValue> ConvertToFieldValueList(
    const flutter::EncodableList& originalList) {
  std::vector<firebase::firestore::FieldValue> convertedList;
  for (const auto& item : originalList) {
    firebase::firestore::FieldValue convertedItem =
        CloudFirestorePlugin::ConvertToFieldValue(item);
    convertedList.push_back(convertedItem);
  }
  return convertedList;
}

firebase::firestore::MapFieldValue ConvertToMapFieldValue(
    const EncodableMap& originalMap) {
  firebase::firestore::MapFieldValue convertedMap;

  for (const auto& kv : originalMap) {
    if (std::holds_alternative<std::string>(kv.first)) {
      std::string key = std::get<std::string>(kv.first);
      firebase::firestore::FieldValue value =
          CloudFirestorePlugin::ConvertToFieldValue(kv.second);
      convertedMap[key] = value;
    } else {
      // Handle or skip non-string keys
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported key type");
    }
  }

  return convertedMap;
}

using flutter::CustomEncodableValue;

firebase::firestore::MapFieldPathValue ConvertToMapFieldPathValue(
    const EncodableMap& originalMap) {
  firebase::firestore::MapFieldPathValue convertedMap;

  for (const auto& kv : originalMap) {
    if (std::holds_alternative<std::string>(kv.first)) {
      std::string key = std::get<std::string>(kv.first);
      std::vector<std::string> convertedList;
      convertedList.push_back(key);

      firebase::firestore::FieldValue value =
          CloudFirestorePlugin::ConvertToFieldValue(kv.second);
      convertedMap[FieldPath(convertedList)] = value;
    } else if (std::holds_alternative<CustomEncodableValue>(kv.first)) {
      const FieldPath& fieldPath =
          std::any_cast<FieldPath>(std::get<CustomEncodableValue>(kv.first));
      firebase::firestore::FieldValue value =
          CloudFirestorePlugin::ConvertToFieldValue(kv.second);
      convertedMap[fieldPath] = value;
    } else {
      // Handle or skip non-string keys
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported key type");
    }
  }

  return convertedMap;
}

class LoadBundleStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  LoadBundleStreamHandler(Firestore* firestore, std::string bundle) {
    firestore_ = firestore;
    bundle_ = bundle;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);
    events.reset();
    firestore_->LoadBundle(
        bundle_, [this](const LoadBundleTaskProgress& progress) {
          flutter::EncodableMap map;
          map[flutter::EncodableValue("bytesLoaded")] =
              flutter::EncodableValue(progress.bytes_loaded());
          map[flutter::EncodableValue("documentsLoaded")] =
              flutter::EncodableValue(progress.documents_loaded());
          map[flutter::EncodableValue("totalBytes")] =
              flutter::EncodableValue(progress.total_bytes());
          map[flutter::EncodableValue("totalDocuments")] =
              flutter::EncodableValue(progress.total_documents());
          switch (progress.state()) {
            case LoadBundleTaskProgress::State::kError: {
              EncodableMap details;
              details[EncodableValue("code")] =
                  EncodableValue("load-bundle-error");
              details[EncodableValue("message")] =
                  EncodableValue("Error loading the bundle");

              events_->Error("firebase_firestore", "Error loading the bundle",
                             details);
              events_->EndOfStream();
              return;
            }
            case LoadBundleTaskProgress::State::kInProgress: {
              std::cout << "Bytes loaded from bundle: "
                        << progress.bytes_loaded() << std::endl;
              map[flutter::EncodableValue("taskState")] =
                  flutter::EncodableValue("running");

              events_->Success(map);
              break;
            }
            case LoadBundleTaskProgress::State::kSuccess: {
              std::cout << "Bundle load succeeded" << std::endl;
              map[flutter::EncodableValue("taskState")] =
                  flutter::EncodableValue("success");

              events_->Success(map);
              events_->EndOfStream();
              break;
            }
          }
        });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    events_->EndOfStream();
    return nullptr;
  }

 private:
  Firestore* firestore_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  std::string bundle_;
};

void CloudFirestorePlugin::LoadBundle(
    const FirestorePigeonFirebaseApp& app, const std::vector<uint8_t>& bundle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  std::string bundleConverted(bundle.begin(), bundle.end());

  auto handler =
      std::make_unique<LoadBundleStreamHandler>(firestore, bundleConverted);

  std::string channelName = RegisterEventChannel(
      "plugins.flutter.io/firebase_firestore/loadBundle/", std::move(handler));

  result(channelName);
}

using firebase::Future;
using firebase::firestore::Query;
using firebase::firestore::QuerySnapshot;

void CloudFirestorePlugin::NamedQueryGet(
    const FirestorePigeonFirebaseApp& app, const std::string& name,
    const PigeonGetOptions& options,
    std::function<void(ErrorOr<PigeonQuerySnapshot> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Future<Query> future = firestore->NamedQuery(name.c_str());

  future.OnCompletion([result, options](const Future<Query>& completed_future) {
    const Query* query = completed_future.result();

    if (query == nullptr) {
      result(
          FlutterError("Named query has not been found. Please check it has "
                       "been loaded properly via loadBundle()."));
      return;
    }

    using firebase::firestore::QuerySnapshot;

    query->Get(GetSourceFromPigeon(options.source()))
        .OnCompletion(
            [result, options](const Future<QuerySnapshot>& completed_future) {
              if (completed_future.error() == firebase::firestore::kErrorOk) {
                const QuerySnapshot* query_snapshot = completed_future.result();
                result(ParseQuerySnapshot(
                    query_snapshot, GetServerTimestampBehaviorFromPigeon(
                                        options.server_timestamp_behavior())));
              } else {
                result(CloudFirestorePlugin::ParseError(completed_future));
                return;
              }
            });
  });
}

void CloudFirestorePlugin::ClearPersistence(
    const FirestorePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->ClearPersistence().OnCompletion(
      [result](const Future<void>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          result(std::nullopt);
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
          return;
        }
      });
}

void CloudFirestorePlugin::DisableNetwork(
    const FirestorePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->DisableNetwork().OnCompletion(
      [result](const Future<void>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          result(std::nullopt);
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
          return;
        }
      });
}

void CloudFirestorePlugin::EnableNetwork(
    const FirestorePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->EnableNetwork().OnCompletion(
      [result](const Future<void>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          result(std::nullopt);
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
          return;
        }
      });
}

void CloudFirestorePlugin::Terminate(
    const FirestorePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->Terminate().OnCompletion(
      [result](const Future<void>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          result(std::nullopt);
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
          return;
        }
      });
}

void CloudFirestorePlugin::WaitForPendingWrites(
    const FirestorePigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->WaitForPendingWrites().OnCompletion(
      [result](const Future<void>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          result(std::nullopt);
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
          return;
        }
      });
}

void CloudFirestorePlugin::SetIndexConfiguration(
    const FirestorePigeonFirebaseApp& app,
    const std::string& index_configuration,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: not available in C++ SDK
  result(FlutterError("Not available in C++ SDK"));
}

void CloudFirestorePlugin::SetLoggingEnabled(
    bool logging_enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
  firebase::firestore::Firestore::set_log_level(
      logging_enabled ? firebase::LogLevel::kLogLevelDebug
                      : firebase::LogLevel::kLogLevelError);
  result(std::nullopt);
}

class SnapshotInSyncStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  SnapshotInSyncStreamHandler(Firestore* firestore) { firestore_ = firestore; }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);
    events.reset();
    // We do this to bind the event to the main channel
    auto boundSendEvent =
        std::bind(&SnapshotInSyncStreamHandler::SendEvent, this);
    this->SetSendEventFunction(boundSendEvent);

    listener_ = firestore_->AddSnapshotsInSyncListener([this]() {
      if (sendEventFunc_) sendEventFunc_();
    });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    listener_.Remove();
    events_->EndOfStream();
    return nullptr;
  }

  void SetSendEventFunction(std::function<void()> func) {
    sendEventFunc_ = func;
  }

  void SendEvent() { events_->Success(flutter::EncodableValue()); }

 private:
  Firestore* firestore_;
  ListenerRegistration listener_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  std::function<void()> sendEventFunc_;
};

void CloudFirestorePlugin::SnapshotsInSyncSetup(
    const FirestorePigeonFirebaseApp& app,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  auto handler = std::make_unique<SnapshotInSyncStreamHandler>(firestore);

  UUID uuid;
  UuidCreate(&uuid);
  char* str;
  UuidToStringA(&uuid, (RPC_CSTR*)&str);
  std::string snapshotInSyncId(str);

  std::string channelName = RegisterEventChannelWithUUID(
      "plugins.flutter.io/firebase_firestore/snapshotsInSync/",
      snapshotInSyncId, std::move(handler));
  result(snapshotInSyncId);
}

class TransactionStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  TransactionStreamHandler(Firestore* firestore, long timeout, int maxAttempts,
                           std::string transactionId)
      : firestore_(firestore),
        timeout_(timeout),
        maxAttempts_(maxAttempts),
        transactionId_(transactionId) {}

  void ReceiveTransactionResponse(
      PigeonTransactionResult resultType,
      std::vector<PigeonTransactionCommand> commands) {
    std::lock_guard<std::mutex> lock(commands_mutex_);
    resultType_ = resultType;
    commands_ = commands;
    cv_.notify_one();
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    events_ = std::move(events);
    events.reset();
    TransactionOptions options;
    options.set_max_attempts(maxAttempts_);

    firestore_
        ->RunTransaction(
            options,
            [this](Transaction& transaction, std::string& str) -> Error {
              auto noopDeleter = [](Transaction*) {};
              std::shared_ptr<Transaction> ptr(&transaction, noopDeleter);
              CloudFirestorePlugin::transactions_[transactionId_] =
                  std::move(ptr);

              flutter::EncodableMap map;
              map.emplace("appName", firestore_->app()->name());
              events_->Success(flutter::EncodableValue(map));

              std::unique_lock<std::mutex> lock(mtx_);
              if (cv_.wait_for(lock, std::chrono::milliseconds(timeout_)) ==
                  std::cv_status::timeout) {
                events_->Error("Timeout", "Transaction timed out.");
                events_->EndOfStream();
                return Error::kErrorDeadlineExceeded;
              }

              std::lock_guard<std::mutex> command_lock(commands_mutex_);
              if (commands_.empty()) return Error::kErrorOk;

              for (PigeonTransactionCommand& command : commands_) {
                std::string path = command.path();
                PigeonTransactionType type = command.type();
                if (path.empty() /* or some other invalid condition */) {
                  std::cerr << "Path is invalid: " << path << std::endl;
                  continue;  // Skip this iteration.
                }

                std::cout << "Before: " << path << std::endl;  // Debug print.

                DocumentReference reference = firestore_->Document(path);
                std::cout << "After: " << command.path()
                          << std::endl;  // debug print

                switch (type) {
                  case PigeonTransactionType::set:
                    std::cout << "Transaction set" << path
                              << std::endl;  // Debug print.

                    if (command.option()->merge() != nullptr &&
                        command.option()->merge()) {
                      transaction.Set(reference,
                                      ConvertToMapFieldValue(*command.data()),
                                      SetOptions::Merge());
                    } else if (command.option()->merge_fields()) {
                      transaction.Set(
                          reference, ConvertToMapFieldValue(*command.data()),
                          SetOptions::MergeFieldPaths(ConvertToFieldPathVector(
                              *command.option()->merge_fields())));
                    } else {
                      transaction.Set(reference,
                                      ConvertToMapFieldValue(*command.data()));
                    }

                    break;
                  case PigeonTransactionType::update:
                    std::cout << "Transaction update" << path
                              << std::endl;  // Debug print.

                    transaction.Update(reference,
                                       ConvertToMapFieldValue(*command.data()));
                    break;
                  case PigeonTransactionType::deleteType:
                    std::cout << "Transaction delete" << path
                              << std::endl;  // Debug print.

                    transaction.Delete(reference);
                    break;
                }
              }
              return Error::kErrorOk;
            })
        .OnCompletion([this](const Future<void>& completed_future) {
          flutter::EncodableMap result;
          if (completed_future.error() == firebase::firestore::kErrorOk) {
            result.insert(std::make_pair(flutter::EncodableValue("complete"),
                                         flutter::EncodableValue(true)));
            events_->Success(result);
          } else {
            events_->Error("transaction_error",
                           completed_future.error_message());
          }
          events_->EndOfStream();
        });

    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    std::unique_lock<std::mutex> lock(mtx_);
    cv_.notify_one();
    events_->EndOfStream();
    return nullptr;
  }

 private:
  Firestore* firestore_;
  long timeout_;
  int maxAttempts_;
  std::string transactionId_;
  std::vector<PigeonTransactionCommand> commands_;
  PigeonTransactionResult resultType_;
  std::mutex mtx_;
  std::mutex commands_mutex_;
  std::condition_variable cv_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
};

void CloudFirestorePlugin::TransactionCreate(
    const FirestorePigeonFirebaseApp& app, int64_t timeout,
    int64_t max_attempts,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);

  UUID uuid;
  UuidCreate(&uuid);
  char* str;
  UuidToStringA(&uuid, (RPC_CSTR*)&str);
  std::string transactionId(str);

  auto handler = std::make_unique<TransactionStreamHandler>(
      firestore, static_cast<long>(timeout), static_cast<int>(max_attempts),
      transactionId);

  // Temporarily release the ownership.
  TransactionStreamHandler* raw_handler = handler.release();
  CloudFirestorePlugin::transaction_handlers_[transactionId] =
      std::unique_ptr<TransactionStreamHandler>(raw_handler);

  // Register the event channel.
  std::string channelName = RegisterEventChannelWithUUID(
      "plugins.flutter.io/firebase_firestore/transaction/", transactionId,
      std::unique_ptr<TransactionStreamHandler>(raw_handler));

  // Return the result (assumed to be transaction ID in this example).
  result(transactionId);
}

using flutter::CustomEncodableValue;

void CloudFirestorePlugin::TransactionStoreResult(
    const std::string& transaction_id,
    const PigeonTransactionResult& result_type,
    const flutter::EncodableList* commands,
    std::function<void(std::optional<FlutterError> reply)> result) {
  if (CloudFirestorePlugin::transaction_handlers_[transaction_id]) {
    TransactionStreamHandler& handler = *static_cast<TransactionStreamHandler*>(
        CloudFirestorePlugin::transaction_handlers_[transaction_id].get());
    std::vector<PigeonTransactionCommand> commandVector;
    for (const auto& element : *commands) {
      const PigeonTransactionCommand& command =
          std::any_cast<PigeonTransactionCommand>(
              std::get<CustomEncodableValue>(element));
      commandVector.push_back(command);
    }
    handler.ReceiveTransactionResponse(result_type, commandVector);
    result(std::nullopt);

  } else {
    result(std::make_optional(FlutterError(
        "transaction_not_found", "Transaction not found", transaction_id)));
  }
}

void CloudFirestorePlugin::TransactionGet(
    const FirestorePigeonFirebaseApp& app, const std::string& transaction_id,
    const std::string& path,
    std::function<void(ErrorOr<PigeonDocumentSnapshot> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference reference = firestore->Document(path);

  std::shared_ptr<Transaction> transaction = transactions_[transaction_id];
  Error error_code;
  std::string error_message;

  // Call the Get function
  DocumentSnapshot snapshot =
      transaction->Get(reference, &error_code, &error_message);

  if (error_code != Error::kErrorOk) {
    result(FlutterError(error_message));
  } else {
    result(ParseDocumentSnapshot(
        snapshot, DocumentSnapshot::ServerTimestampBehavior::kDefault));
  }
}

using firebase::firestore::DocumentReference;
using firebase::firestore::SetOptions;

std::vector<firebase::firestore::FieldPath> ConvertToFieldPathVector(
    const flutter::EncodableList& encodableList) {
  std::vector<firebase::firestore::FieldPath> fieldVector;

  for (const auto& element : encodableList) {
    flutter::EncodableList fieldPath =
        std::get<flutter::EncodableList>(element);

    std::vector<std::string> convertedList;
    for (const auto& field : fieldPath) {
      convertedList.push_back(std::get<std::string>(field));
    }

    // Was already converted by the Codec
    fieldVector.push_back(firebase::firestore::FieldPath(convertedList));
  }

  return fieldVector;
}

void CloudFirestorePlugin::DocumentReferenceSet(
    const FirestorePigeonFirebaseApp& app,
    const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  // Get the data
  Future<void> future;

  if (request.option()->merge() != nullptr && request.option()->merge()) {
    future = document_reference.Set(ConvertToMapFieldValue(*request.data()),
                                    SetOptions::Merge());
  } else if (request.option()->merge_fields()) {
    future = document_reference.Set(
        ConvertToMapFieldValue(*request.data()),
        SetOptions::MergeFieldPaths(
            ConvertToFieldPathVector(*request.option()->merge_fields())));
  } else {
    future = document_reference.Set(ConvertToMapFieldValue(*request.data()));
  }

  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      result(std::nullopt);
    } else {
      result(CloudFirestorePlugin::ParseError(completed_future));
      return;
    }
  });
}

void CloudFirestorePlugin::DocumentReferenceUpdate(
    const FirestorePigeonFirebaseApp& app,
    const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  // Get the data
  MapFieldPathValue data = ConvertToMapFieldPathValue(*request.data());
  Future<void> future = document_reference.Update(data);

  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      result(std::nullopt);
    } else {
      result(CloudFirestorePlugin::ParseError(completed_future));
      return;
    }
  });
}

void CloudFirestorePlugin::DocumentReferenceGet(
    const FirestorePigeonFirebaseApp& app,
    const DocumentReferenceRequest& request,
    std::function<void(ErrorOr<PigeonDocumentSnapshot> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  firebase::firestore::Source source = GetSourceFromPigeon(*request.source());

  Future<DocumentSnapshot> future = document_reference.Get(source);

  future.OnCompletion(
      [result, request](const Future<DocumentSnapshot>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          const DocumentSnapshot* document_snapshot = completed_future.result();
          result(ParseDocumentSnapshot(
              *document_snapshot, GetServerTimestampBehaviorFromPigeon(
                                      *request.server_timestamp_behavior())));
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
          return;
        }
      });
}

void CloudFirestorePlugin::DocumentReferenceDelete(
    const FirestorePigeonFirebaseApp& app,
    const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  Future<void> future = document_reference.Delete();

  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      result(std::nullopt);
    } else {
      result(CloudFirestorePlugin::ParseError(completed_future));
      return;
    }
  });
}

// Convert EncodableList to std::vector<std::vector<EncodableValue>>
std::vector<std::vector<EncodableValue>> ConvertToConditions(
    const flutter::EncodableList& encodableList) {
  std::vector<std::vector<EncodableValue>> conditions;

  for (const auto& element : encodableList) {
    std::vector<EncodableValue> condition;

    for (const auto& conditionElement :
         std::get<flutter::EncodableList>(element)) {
      condition.push_back(conditionElement);
    }

    conditions.push_back(condition);
  }

  return conditions;
}

using firebase::firestore::Filter;

firebase::firestore::Filter filterFromJson(const EncodableMap& map) {
  if (map.find(EncodableValue("fieldPath")) != map.end()) {
    // Deserialize a FilterQuery
    std::string op = std::get<std::string>(map.at(EncodableValue("op")));
    const FieldPath& fieldPath = std::any_cast<FieldPath>(
        std::get<CustomEncodableValue>(map.at(EncodableValue("fieldPath"))));

    auto value = map.at(EncodableValue("value"));

    // All the operators from Firebase
    if (op == "==") {
      return Filter::EqualTo(fieldPath,
                             CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == "!=") {
      return Filter::NotEqualTo(
          fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == "<") {
      return Filter::LessThan(fieldPath,
                              CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == "<=") {
      return Filter::LessThanOrEqualTo(
          fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == ">") {
      return Filter::GreaterThan(
          fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == ">=") {
      return Filter::GreaterThanOrEqualTo(
          fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == "array-contains") {
      return Filter::ArrayContains(
          fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
    } else if (op == "array-contains-any") {
      // Here you should make sure 'value' is the correct type, e.g., a vector
      return Filter::ArrayContainsAny(
          fieldPath,
          ConvertToFieldValueList(std::get<flutter::EncodableList>(value)));
    } else if (op == "in") {
      return Filter::In(
          fieldPath,
          ConvertToFieldValueList(std::get<flutter::EncodableList>(value)));
    } else if (op == "not-in") {
      return Filter::NotIn(
          fieldPath,
          ConvertToFieldValueList(std::get<flutter::EncodableList>(value)));
    } else {
      throw std::runtime_error("Invalid operator");
    }
  }

  // Deserialize a FilterOperator
  std::string op = std::get<std::string>(map.at(EncodableValue("op")));
  // Assuming the queries are a list of maps

  std::vector<EncodableMap> queries;
  for (const auto& query :
       std::get<flutter::EncodableList>(map.at(EncodableValue("queries")))) {
    queries.push_back(std::get<EncodableMap>(query));
  }

  std::vector<Filter> parsedFilters;
  for (const auto& query : queries) {
    parsedFilters.push_back(filterFromJson(query));
  }

  if (op == "OR") {
    return Filter::Or(parsedFilters);
  } else if (op == "AND") {
    return Filter::And(parsedFilters);
  }

  throw std::runtime_error("Invalid operator");
}

firebase::firestore::Query ParseQuery(firebase::firestore::Firestore* firestore,
                                      const std::string& path,
                                      bool isCollectionGroup,
                                      const PigeonQueryParameters& parameters) {
  try {
    firebase::firestore::Query query;

    if (isCollectionGroup) {
      query = firestore->CollectionGroup(path);
    } else {
      query = firestore->Collection(path);
    }

    if (parameters.filters()) {
      Filter filter = filterFromJson(*parameters.filters());
      query = query.Where(filter);
    }

    std::vector<std::vector<EncodableValue>> conditions =
        ConvertToConditions(*parameters.where());

    for (const auto& condition : conditions) {
      const FieldPath& fieldPath = std::any_cast<FieldPath>(
          std::get<CustomEncodableValue>(condition[0]));
      const std::string& op = std::get<std::string>(condition[1]);

      auto value = condition[2];
      if (op == "==") {
        query = query.WhereEqualTo(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == "!=") {
        query = query.WhereNotEqualTo(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == "<") {
        query = query.WhereLessThan(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == "<=") {
        query = query.WhereLessThanOrEqualTo(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == ">") {
        query = query.WhereGreaterThan(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == ">=") {
        query = query.WhereGreaterThanOrEqualTo(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == "array-contains") {
        query = query.WhereArrayContains(
            fieldPath, CloudFirestorePlugin::ConvertToFieldValue(value));
      } else if (op == "array-contains-any") {
        query = query.WhereArrayContainsAny(
            fieldPath,
            ConvertToFieldValueList(std::get<flutter::EncodableList>(value)));
      } else if (op == "in") {
        query = query.WhereIn(
            fieldPath,
            ConvertToFieldValueList(std::get<flutter::EncodableList>(value)));
      } else if (op == "not-in") {
        query = query.WhereNotIn(
            fieldPath,
            ConvertToFieldValueList(std::get<flutter::EncodableList>(value)));
      } else {
        throw std::runtime_error("Unknown operator");
      }
    }

    if (parameters.limit()) {
      query = query.Limit(static_cast<int32_t>(*parameters.limit()));
    }

    if (parameters.limit_to_last()) {
      query =
          query.LimitToLast(static_cast<int32_t>(*parameters.limit_to_last()));
    }

    if (parameters.order_by() == nullptr) {
      return query;
    }

    std::vector<std::vector<EncodableValue>> order_bys =
        ConvertToConditions(*parameters.order_by());

    for (const auto& order_by : order_bys) {
      const FieldPath& fieldPath =
          std::any_cast<FieldPath>(std::get<CustomEncodableValue>(order_by[0]));
      const bool& direction = std::get<bool>(order_by[1]);

      if (direction) {
        query = query.OrderBy(fieldPath, Query::Direction::kDescending);
      } else if (!direction) {
        query = query.OrderBy(fieldPath, Query::Direction::kAscending);
      } else {
        throw std::runtime_error("Unknown direction");
      }
    }

    if (parameters.start_at()) {
      query = query.StartAt(ConvertToFieldValueList(*parameters.start_at()));
    }
    if (parameters.start_after()) {
      query =
          query.StartAfter(ConvertToFieldValueList(*parameters.start_after()));
    }
    if (parameters.end_at()) {
      query = query.EndAt(ConvertToFieldValueList(*parameters.end_at()));
    }
    if (parameters.end_before()) {
      query =
          query.EndBefore(ConvertToFieldValueList(*parameters.end_before()));
    }

    return query;
  } catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    // Return a 'null' or 'empty' query based on your C++ Firestore API
    return firebase::firestore::Query();
  }
}

void CloudFirestorePlugin::QueryGet(
    const FirestorePigeonFirebaseApp& app, const std::string& path,
    bool is_collection_group, const PigeonQueryParameters& parameters,
    const PigeonGetOptions& options,
    std::function<void(ErrorOr<PigeonQuerySnapshot> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, is_collection_group, parameters);

  firebase::firestore::Source source = GetSourceFromPigeon(options.source());

  Future<firebase::firestore::QuerySnapshot> future = query.Get(source);

  future.OnCompletion(
      [result, options](
          const Future<firebase::firestore::QuerySnapshot>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          const firebase::firestore::QuerySnapshot* querySnapshot =
              completed_future.result();
          result(ParseQuerySnapshot(querySnapshot,
                                    GetServerTimestampBehaviorFromPigeon(
                                        options.server_timestamp_behavior())));
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
        }
      });
}

firebase::firestore::AggregateSource GetAggregateSourceFromPigeon(
    const AggregateSource& source) {
  switch (source) {
    case AggregateSource::server:
    default:
      return firebase::firestore::AggregateSource::kServer;
  }
}

void CloudFirestorePlugin::AggregateQuery(
    const FirestorePigeonFirebaseApp& app, const std::string& path,
    const PigeonQueryParameters& parameters, const AggregateSource& source,
    const flutter::EncodableList& queries, bool is_collection_group,
    std::function<void(ErrorOr<flutter::EncodableList> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, is_collection_group, parameters);

  // C++ SDK does not support average and sum
  firebase::firestore::AggregateQuery aggregate_query;

  for (auto& queryRequest : queries) {
    const cloud_firestore_windows::AggregateQuery& queryRequestTyped =
        std::any_cast<cloud_firestore_windows::AggregateQuery>(
            std::get<CustomEncodableValue>(queryRequest));

    switch (queryRequestTyped.type()) {
      case AggregateType::count:
        aggregate_query = query.Count();
        break;
      case AggregateType::sum:
        std::cout << "Sum is not supported on C++" << std::endl;
        break;
      case AggregateType::average:
        std::cout << "Average is not supported on C++" << std::endl;
        break;
    }
  }

  Future<AggregateQuerySnapshot> future =
      aggregate_query.Get(GetAggregateSourceFromPigeon(source));

  future.OnCompletion(
      [result,
       queries](const Future<AggregateQuerySnapshot>& completed_future) {
        if (completed_future.error() == firebase::firestore::kErrorOk) {
          const AggregateQuerySnapshot* aggregateQuerySnapshot =
              completed_future.result();
          EncodableList aggregateResponses;

          for (auto& queryRequest : queries) {
            const cloud_firestore_windows::AggregateQuery& queryRequestTyped =
                std::any_cast<cloud_firestore_windows::AggregateQuery>(
                    std::get<CustomEncodableValue>(queryRequest));

            switch (queryRequestTyped.type()) {
              case AggregateType::count: {
                double doubleValue =
                    static_cast<double>(aggregateQuerySnapshot->count());
                AggregateQueryResponse aggregateResponse(AggregateType::count,
                                                         nullptr, &doubleValue);
                aggregateResponses.push_back(
                    CustomEncodableValue(aggregateResponse));
                break;
              }
              case AggregateType::sum: {
                std::cout << "Sum is not supported on C++" << std::endl;
                break;
              }
              case AggregateType::average: {
                std::cout << "Average is not supported on C++" << std::endl;
                break;
              }
            }
          }

          result(aggregateResponses);
        } else {
          result(CloudFirestorePlugin::ParseError(completed_future));
        }
      });
}

void CloudFirestorePlugin::WriteBatchCommit(
    const FirestorePigeonFirebaseApp& app, const flutter::EncodableList& writes,
    std::function<void(std::optional<FlutterError> reply)> result) {
  try {
    Firestore* firestore = GetFirestoreFromPigeon(app);
    firebase::firestore::WriteBatch batch = firestore->batch();

    for (const auto& write : writes) {
      const PigeonTransactionCommand& transaction =
          std::any_cast<PigeonTransactionCommand>(
              std::get<CustomEncodableValue>(write));

      PigeonTransactionType type = transaction.type();
      std::string path = transaction.path();
      auto data = transaction.data();

      firebase::firestore::DocumentReference documentReference =
          firestore->Document(path);

      switch (type) {
        case PigeonTransactionType::deleteType:
          batch.Delete(documentReference);
          break;
        case PigeonTransactionType::update:
          batch.Update(documentReference, ConvertToMapFieldValue(*data));
          break;
        case PigeonTransactionType::set:
          const PigeonDocumentOption* options = transaction.option();

          if (options->merge()) {
            batch.Set(documentReference, ConvertToMapFieldValue(*data),
                      firebase::firestore::SetOptions::Merge());
          } else if (options->merge_fields()) {
            batch.Set(documentReference, ConvertToMapFieldValue(*data),
                      SetOptions::MergeFieldPaths(
                          ConvertToFieldPathVector(*options->merge_fields())));
          } else {
            batch.Set(documentReference, ConvertToMapFieldValue(*data));
          }
          break;
      }
    }

    batch.Commit().OnCompletion([result](const Future<void>& completed_future) {
      if (completed_future.error() == firebase::firestore::kErrorOk) {
        result(std::nullopt);
      } else {
        result(CloudFirestorePlugin::ParseError(completed_future));
      }
    });

  } catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    result(FlutterError(e.what()));
  }
}

std::string METHOD_CHANNEL_NAME = "cloud_firestore";

using firebase::firestore::ListenerRegistration;

class QuerySnapshotStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  QuerySnapshotStreamHandler(
      std::unique_ptr<Query> query, bool includeMetadataChanges,
      firebase::firestore::DocumentSnapshot::ServerTimestampBehavior
          serverTimestampBehavior) {
    query_ = std::move(query);
    includeMetadataChanges_ = includeMetadataChanges;
    serverTimestampBehavior_ = serverTimestampBehavior;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    MetadataChanges metadataChanges = includeMetadataChanges_
                                          ? MetadataChanges::kInclude
                                          : MetadataChanges::kExclude;

    events_ = std::move(events);
    events.reset();

    listener_ = query_->AddSnapshotListener(
        metadataChanges,
        [this, serverTimestampBehavior = serverTimestampBehavior_,
         metadataChanges](const firebase::firestore::QuerySnapshot& snapshot,
                          firebase::firestore::Error error,
                          const std::string& errorMessage) mutable {
          if (error == firebase::firestore::kErrorOk) {
            flutter::EncodableList toListResult(3);
            std::vector<flutter::EncodableValue> documents;
            std::vector<flutter::EncodableValue> documentChanges;

            for (const auto& documentSnapshot : snapshot.documents()) {
              documents.push_back(ParseDocumentSnapshot(documentSnapshot,
                                                        serverTimestampBehavior)
                                      .ToEncodableList());
            }

            // Assuming querySnapshot.getDocumentChanges() returns an iterable
            // collection
            for (const auto& documentChange :
                 snapshot.DocumentChanges(metadataChanges)) {
              documentChanges.push_back(
                  ParseDocumentChange(documentChange, serverTimestampBehavior)
                      .ToEncodableList());
            }

            toListResult[0] = documents;
            toListResult[1] = documentChanges;
            toListResult[2] =
                ParseSnapshotMetadata(snapshot.metadata()).ToEncodableList();

            events_->Success(toListResult);
          } else {
            EncodableMap details;
            details[EncodableValue("code")] =
                EncodableValue(CloudFirestorePlugin::GetErrorCode(error));
            details[EncodableValue("message")] = EncodableValue(errorMessage);

            events_->Error("firebase_firestore", errorMessage, details);
            events_->EndOfStream();
          }
        });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    listener_.Remove();
    events_->EndOfStream();
    return nullptr;
  }

 private:
  ListenerRegistration listener_;
  std::unique_ptr<Query> query_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  bool includeMetadataChanges_;
  firebase::firestore::DocumentSnapshot::ServerTimestampBehavior
      serverTimestampBehavior_;
};

void CloudFirestorePlugin::QuerySnapshot(
    const FirestorePigeonFirebaseApp& app, const std::string& path,
    bool is_collection_group, const PigeonQueryParameters& parameters,
    const PigeonGetOptions& options, bool include_metadata_changes,
    const ListenSource& source,
    std::function<void(ErrorOr<std::string> reply)> result) {
  if (source == ListenSource::cache) {
    result(FlutterError("Listening from cache isn't supported on Windows"));
    return;
  }

  Firestore* firestore = GetFirestoreFromPigeon(app);
  std::unique_ptr<Query> query_ptr = std::make_unique<Query>(
      ParseQuery(firestore, path, is_collection_group, parameters));

  auto query_snapshot_handler = std::make_unique<QuerySnapshotStreamHandler>(
      std::move(query_ptr), include_metadata_changes,
      GetServerTimestampBehaviorFromPigeon(
          options.server_timestamp_behavior()));

  std::string channelName =
      RegisterEventChannel("plugins.flutter.io/firebase_firestore/query/",
                           std::move(query_snapshot_handler));

  result(channelName);
}

class DocumentSnapshotStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  DocumentSnapshotStreamHandler(
      std::unique_ptr<DocumentReference> reference, bool includeMetadataChanges,
      firebase::firestore::DocumentSnapshot::ServerTimestampBehavior
          serverTimestampBehavior) {
    reference_ = std::move(reference);
    includeMetadataChanges_ = includeMetadataChanges;
    serverTimestampBehavior_ = serverTimestampBehavior;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    MetadataChanges metadataChanges = includeMetadataChanges_
                                          ? MetadataChanges::kInclude
                                          : MetadataChanges::kExclude;

    events_ = std::move(events);
    events.reset();

    listener_ = reference_->AddSnapshotListener(
        metadataChanges,
        [this, serverTimestampBehavior = serverTimestampBehavior_,
         metadataChanges](const firebase::firestore::DocumentSnapshot& snapshot,
                          firebase::firestore::Error error,
                          const std::string& errorMessage) mutable {
          if (error == firebase::firestore::kErrorOk) {
            events_->Success(
                ParseDocumentSnapshot(snapshot, serverTimestampBehavior)
                    .ToEncodableList());
          } else {
            EncodableMap details;
            details[EncodableValue("code")] =
                EncodableValue(CloudFirestorePlugin::GetErrorCode(error));
            details[EncodableValue("message")] = EncodableValue(errorMessage);

            events_->Error("firebase_firestore", errorMessage, details);
            events_->EndOfStream();
          }
        });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    listener_.Remove();
    events_->EndOfStream();
    return nullptr;
  }

 private:
  firebase::firestore::ListenerRegistration listener_;
  std::unique_ptr<DocumentReference> reference_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  bool includeMetadataChanges_;
  firebase::firestore::DocumentSnapshot::ServerTimestampBehavior
      serverTimestampBehavior_;
};

void CloudFirestorePlugin::DocumentReferenceSnapshot(
    const FirestorePigeonFirebaseApp& app,
    const DocumentReferenceRequest& parameters, bool include_metadata_changes,
    const ListenSource& source,
    std::function<void(ErrorOr<std::string> reply)> result) {
  if (source == ListenSource::cache) {
    result(FlutterError("Listening from cache isn't supported on Windows"));
    return;
  }
  Firestore* firestore = GetFirestoreFromPigeon(app);
  std::unique_ptr<DocumentReference> documentReference =
      std::make_unique<DocumentReference>(
          firestore->Document(parameters.path()));

  auto document_snapshot_handler =
      std::make_unique<DocumentSnapshotStreamHandler>(
          std::move(documentReference), include_metadata_changes,
          GetServerTimestampBehaviorFromPigeon(
              *parameters.server_timestamp_behavior()));

  std::string channelName =
      RegisterEventChannel("plugins.flutter.io/firebase_firestore/document/",
                           std::move(document_snapshot_handler));
  result(channelName);
}

void CloudFirestorePlugin::PersistenceCacheIndexManagerRequest(
    const FirestorePigeonFirebaseApp& app,
    const PersistenceCacheIndexManagerRequestEnum& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(FlutterError("Not implemented on Windows"));
}

}  // namespace cloud_firestore_windows
