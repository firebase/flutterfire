#include "cloud_firestore_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h";
#include "firebase/log.h";
#include "firebase/firestore.h";
#include "firebase_core/firebase_core_plugin_c_api.h"

#include "messages.g.h"


#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
using namespace firebase::firestore;

using firebase::firestore::Firestore;
using firebase::App;


namespace cloud_firestore_windows {

// static
void CloudFirestorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "cloud_firestore",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<CloudFirestorePlugin>();

  FirebaseFirestoreHostApi::SetUp(registrar->messenger(), plugin.get());


  registrar->AddPlugin(std::move(plugin));
}

CloudFirestorePlugin::CloudFirestorePlugin() {}

CloudFirestorePlugin::~CloudFirestorePlugin() {}

Firestore* GetFirestoreFromPigeon(const PigeonFirebaseApp& pigeonApp) {
  std::vector<std::string> app_vector = GetFirebaseApp(pigeonApp.app_name());
  firebase::AppOptions options;

  options.set_api_key(app_vector[1].c_str());
  options.set_app_id(app_vector[2].c_str());
  options.set_database_url(app_vector[3].c_str());
  options.set_project_id(app_vector[4].c_str());

  App* app = App::Create(options, pigeonApp.app_name().c_str());

  Firestore* firestore = Firestore::GetInstance(app);

  return firestore;
}

firebase::firestore::Source GetSourceFromPigeon(
  const Source& pigeonSource) {
  switch (pigeonSource) {
    case Source::serverAndCache:
      return firebase::firestore::Source::kDefault;
    case Source::server:
      return firebase::firestore::Source::kServer;
    case Source::cache:
      return firebase::firestore::Source::kCache;
  }
}

firebase::firestore::DocumentSnapshot::ServerTimestampBehavior GetServerTimestampBehaviorFromPigeon(
  const ServerTimestampBehavior& pigeonServerTimestampBehavior) {
  switch (pigeonServerTimestampBehavior) {
    case ServerTimestampBehavior::estimate:
      return firebase::firestore::DocumentSnapshot::ServerTimestampBehavior::kEstimate;
    case ServerTimestampBehavior::previous:
      return firebase::firestore::DocumentSnapshot::ServerTimestampBehavior::kPrevious;
    case ServerTimestampBehavior::none:
      return firebase::firestore::DocumentSnapshot::ServerTimestampBehavior::kNone;
  }
}

using firebase::firestore::DocumentSnapshot;
using flutter::EncodableMap;
using flutter::EncodableValue;

flutter::EncodableMap ConvertToEncodableMap(const firebase::firestore::MapFieldValue& originalMap) {
  EncodableMap convertedMap;
  for (const auto& kv : originalMap) {
    EncodableValue key =
        EncodableValue(kv.first);  // convert std::string to EncodableValue
    EncodableValue value =
        EncodableValue(kv.second);  // convert FieldValue to EncodableValue
    convertedMap[key] = value;      // insert into the new map
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
  PigeonDocumentSnapshot pigeonDocumentSnapshot = PigeonDocumentSnapshot(
      document.reference().path(),
      &ConvertToEncodableMap(document.GetData(serverTimestampBehavior)),
      ParseSnapshotMetadata(document.metadata()));
  return pigeonDocumentSnapshot;
}

flutter::EncodableList ParseDocumentSnapshots(
    std::vector<DocumentSnapshot> documents,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  flutter::EncodableList pigeonDocumentSnapshot = flutter::EncodableList();

  for (const auto& document : documents) {
    pigeonDocumentSnapshot.push_back(EncodableValue(
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
}

PigeonDocumentChange ParseDocumentChange(
  const firebase::firestore::DocumentChange& document_change,
  DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  PigeonDocumentChange pigeonDocumentChange =
      PigeonDocumentChange(ParseDocumentChangeType(document_change.type()), ParseDocumentSnapshot(document_change.document(), serverTimestampBehavior), document_change.old_index(), document_change.new_index());
  return pigeonDocumentChange;
}

flutter::EncodableList ParseDocumentChanges(
    std::vector<firebase::firestore::DocumentChange> document_changes,
    DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  flutter::EncodableList pigeonDocumentChanges = flutter::EncodableList();
  for (const auto& document_change : document_changes) {
    pigeonDocumentChanges.push_back(EncodableValue(
        ParseDocumentChange(document_change, serverTimestampBehavior)));
  }
  return pigeonDocumentChanges;
}




PigeonQuerySnapshot ParseQuerySnapshot(
    const firebase::firestore::QuerySnapshot* query_snapshot, DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
  PigeonQuerySnapshot pigeonQuerySnapshot = PigeonQuerySnapshot(ParseDocumentSnapshots(query_snapshot->documents(), serverTimestampBehavior),
      ParseDocumentChanges(query_snapshot->DocumentChanges(), serverTimestampBehavior),
      ParseSnapshotMetadata(query_snapshot->metadata()));

  return pigeonQuerySnapshot;
}

firebase::firestore::FieldValue ConvertToFieldValue(
    const EncodableValue& value) {
  const flutter::internal::EncodableValueVariant& variant =
      value;  // Replace with appropriate way to access the variant from
              // EncodableValue
  if (std::holds_alternative<bool>(variant)) {
    return firebase::firestore::FieldValue::Boolean(std::get<bool>(variant));
  } else if (std::holds_alternative<int64_t>(variant)) {
    return firebase::firestore::FieldValue::Integer(std::get<int64_t>(variant));
  } else if (std::holds_alternative<double>(variant)) {
    return firebase::firestore::FieldValue::Double(std::get<double>(variant));
  } else if (std::holds_alternative<std::string>(variant)) {
    return firebase::firestore::FieldValue::String(
        std::get<std::string>(variant));
    } else if (std::holds_alternative<flutter::EncodableList>(variant)) {
      const flutter::EncodableList& list = std::get<flutter::EncodableList>(variant);
      std::vector<firebase::firestore::FieldValue> convertedList;
      for (const auto& item : list) {
        convertedList.push_back(ConvertToFieldValue(item));
      }
      return firebase::firestore::FieldValue::Array(convertedList);
      } else if (std::holds_alternative<flutter::EncodableMap>(variant)) {
        const flutter::EncodableMap& map = std::get<flutter::EncodableMap>(variant);
        firebase::firestore::MapFieldValue convertedMap = ConvertToMapFieldValue(map);
        return firebase::firestore::FieldValue::Map(convertedMap);
  } else {
    // Add more types as needed
    // You may throw an exception or handle this some other way
    throw std::runtime_error("Unsupported EncodableValue type");
  }
}

firebase::firestore::MapFieldValue ConvertToMapFieldValue(const EncodableMap& originalMap) {
  firebase::firestore::MapFieldValue convertedMap;

  for (const auto& kv : originalMap) {
    if (std::holds_alternative<std::string>(kv.first)) {
      std::string key = std::get<std::string>(kv.first);
      firebase::firestore::FieldValue value = ConvertToFieldValue(kv.second);
      convertedMap[key] = value;
    } else {
      // Handle or skip non-string keys
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported key type");
    }
  }

  return convertedMap;
}

firebase::firestore::MapFieldPathValue ConvertToMapFieldPathValue(
    const EncodableMap& originalMap) {
  firebase::firestore::MapFieldPathValue convertedMap;

  for (const auto& kv : originalMap) {
    if (std::holds_alternative<std::string>(kv.first)) {
      std::string key = std::get<std::string>(kv.first);
      std::vector<std::string> convertedList;
      convertedList.push_back(key);


      firebase::firestore::FieldValue value = ConvertToFieldValue(kv.second);
      convertedMap[FieldPath(convertedList)] = value;
    } else if (std::holds_alternative<FieldPath>(kv.first)) {
      FieldPath key = std::get<FieldPath>(kv.first);
      firebase::firestore::FieldValue value = ConvertToFieldValue(kv.second);
      convertedMap[key] = value;
    } else {
      // Handle or skip non-string keys
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported key type");
    }
  }

  return convertedMap;
}




void CloudFirestorePlugin::LoadBundle(
    const PigeonFirebaseApp& app, const std::vector<uint8_t>& bundle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  // TODO: uses EventChannels
}

using firebase::firestore::Query;
using firebase::firestore::QuerySnapshot;
using firebase::Future;

void CloudFirestorePlugin::NamedQueryGet(
    const PigeonFirebaseApp& app, const std::string& name,
    const PigeonGetOptions& options,
    std::function<void(ErrorOr<PigeonQuerySnapshot> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Future<Query> future = firestore->NamedQuery(name.c_str());

   future.OnCompletion([result, options](const Future<Query>& completed_future) {
         const Query* query = completed_future.result();

         if (query == nullptr) {
            result(FlutterError("Named query has not been found. Please check it has been loaded properly via loadBundle()."));
            return;
          }

         using firebase::firestore::QuerySnapshot;

         query->Get(GetSourceFromPigeon(options.source()))
             .OnCompletion([result, options](
                               const Future<QuerySnapshot>& completed_future) {
           if (completed_future.error() == 0) {
                     const QuerySnapshot* query_snapshot =
                         completed_future.result();
             result(ParseQuerySnapshot(
                         query_snapshot,
                         GetServerTimestampBehaviorFromPigeon(options
                                     .server_timestamp_behavior())));
           } else {
             result(FlutterError(completed_future.error_message()));
             return;
           }
         });
      });
}

void CloudFirestorePlugin::ClearPersistence(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->ClearPersistence().OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::DisableNetwork(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->DisableNetwork().OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::EnableNetwork(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->EnableNetwork().OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::Terminate(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->Terminate().OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::WaitForPendingWrites(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  firestore->WaitForPendingWrites().OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::SetIndexConfiguration(
    const PigeonFirebaseApp& app, const std::string& index_configuration,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  // TODO: not available in C++ SDK
}

void CloudFirestorePlugin::SetLoggingEnabled(
    bool logging_enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {
      firebase::firestore::Firestore::set_log_level(logging_enabled
                                                     ? firebase::LogLevel::kLogLevelDebug
                                                     : firebase::LogLevel::kLogLevelError);
  result(std::nullopt);
}

void CloudFirestorePlugin::SnapshotsInSyncSetup(
    std::function<void(ErrorOr<std::string> reply)> result) {
  // TODO: uses EventChannels
}

void CloudFirestorePlugin::TransactionCreate(
    std::function<void(ErrorOr<std::string> reply)> result) {
  // TODO: uses EventChannels
}

void CloudFirestorePlugin::TransactionStoreResult(
    const std::string& transaction_id,
    const PigeonTransactionResult& result_type,
    const flutter::EncodableList* commands,
    std::function<void(std::optional<FlutterError> reply)> result) {
  // TODO: uses EventChannels
}

void CloudFirestorePlugin::TransactionGet(
    const PigeonFirebaseApp& app, const std::string& transaction_id,
    const std::string& path,
    std::function<void(ErrorOr<PigeonDocumentSnapshot> reply)> result) {
  // TODO: uses EventChannels
}

using firebase::firestore::DocumentReference;
using firebase::firestore::SetOptions;

std::vector<std::string> ConvertToFieldPathVector(
    const flutter::EncodableList& encodableList) {
  std::vector<std::string> fieldVector;

  for (const auto& element : encodableList) {
    std::string fieldPath = std::get<std::string>(element);

    // Was already converted by the Codec
    fieldVector.push_back(fieldPath);
  }

  return fieldVector;
}

void CloudFirestorePlugin::DocumentReferenceSet(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  // Get the data
  Future<void> future;

  if (request.option()->merge() != nullptr && request.option()->merge()) {
    future = document_reference.Set(ConvertToMapFieldValue(*request.data()),
                                    SetOptions::Merge());
  }
  else if (request.option()->merge_fields()) {
    future = document_reference.Set(ConvertToMapFieldValue(*request.data()),
        SetOptions::MergeFields(
            ConvertToFieldPathVector(*request.option()->merge_fields())));
  }
  else {
    future = document_reference.Set(ConvertToMapFieldValue(*request.data()));
  }

  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
 }

void CloudFirestorePlugin::DocumentReferenceUpdate(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  // Get the data
  MapFieldPathValue data = ConvertToMapFieldPathValue(*request.data());
  Future<void> future = document_reference.Update(ConvertToMapFieldValue(*request.data()));

  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::DocumentReferenceGet(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(ErrorOr<PigeonDocumentSnapshot> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  firebase::firestore::Source source = GetSourceFromPigeon(*request.source());

  Future<DocumentSnapshot> future = document_reference.Get(source);

  future.OnCompletion([result, request](
                          const Future<DocumentSnapshot>& completed_future) {
    if (completed_future.error() == 0) {
          const DocumentSnapshot* document_snapshot = completed_future.result();
      result(ParseDocumentSnapshot(* document_snapshot,
                                    GetServerTimestampBehaviorFromPigeon(
                                      *request.server_timestamp_behavior())));
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::DocumentReferenceDelete(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {

  Firestore* firestore = GetFirestoreFromPigeon(app);
  DocumentReference document_reference = firestore->Document(request.path());

  Future<void> future = document_reference.Delete();

  future.OnCompletion([result](const Future<void>& completed_future) {
    if (completed_future.error() == 0) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
      return;
    }
  });
}

void CloudFirestorePlugin::QueryGet(
    const PigeonFirebaseApp& app, const std::string& path,
    bool is_collection_group, const PigeonQueryParameters& parameters,
    const PigeonGetOptions& options,
    std::function<void(ErrorOr<PigeonQuerySnapshot> reply)> result) {}

void CloudFirestorePlugin::AggregateQueryCount(
    const PigeonFirebaseApp& app, const std::string& path,
    const PigeonQueryParameters& parameters, const AggregateSource& source,
    std::function<void(ErrorOr<double> reply)> result) {}

void CloudFirestorePlugin::WriteBatchCommit(
    const PigeonFirebaseApp& app, const flutter::EncodableList& writes,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::QuerySnapshot(
    const PigeonFirebaseApp& app, const std::string& path,
    bool is_collection_group, const PigeonQueryParameters& parameters,
    const PigeonGetOptions& options, bool include_metadata_changes,
    std::function<void(ErrorOr<std::string> reply)> result) {}

void CloudFirestorePlugin::DocumentReferenceSnapshot(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& parameters,
    bool include_metadata_changes,
    std::function<void(ErrorOr<std::string> reply)> result) {}

}  // namespace cloud_firestore
