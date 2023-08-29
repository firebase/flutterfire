#include "cloud_firestore_plugin.h"
#pragma comment(lib, \
                "rpcrt4.lib")  // UuidCreate - Minimum supported OS Win 2000

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h";
#include "firebase/log.h";
#include "firebase/firestore.h";
#include "firebase_core/firebase_core_plugin_c_api.h"

#include "messages.g.h"


#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
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

  messenger_ = registrar->messenger();

  FirebaseFirestoreHostApi::SetUp(registrar->messenger(), plugin.get());


  registrar->AddPlugin(std::move(plugin));
}

std::map<std::string,
         std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>>
    event_channels_;
std::map<std::string, std::unique_ptr<flutter::StreamHandler<>>>
    stream_handlers_;


std::string RegisterEventChannel(
    std::string prefix, const flutter::StreamHandler<EncodableValue>& handler) {
  UUID uuid;
  UuidCreate(&uuid);
  char* str;
  UuidToStringA(&uuid, (RPC_CSTR*)&str);
  std::string channelName = prefix + "_" + str;
  flutter::EventChannel<flutter::EncodableValue>* channel =
      new flutter::EventChannel<flutter::EncodableValue>(
          CloudFirestorePlugin::messenger_, channelName,
          &flutter::StandardMethodCodec::GetInstance());

  event_channels_[channelName] =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(channel);
  stream_handlers_[channelName] = std::make_unique<flutter::StreamHandler<>>(handler);

  event_channels_[channelName]->SetStreamHandler(
      std::move(stream_handlers_[channelName]));

  return channelName;
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

std::vector<firebase::firestore::FieldValue>
    ConvertToFieldValueList
    (const flutter::EncodableList& originalList) {
  std::vector<firebase::firestore::FieldValue> convertedList;
  for (const auto& item : originalList) {
    firebase::firestore::FieldValue convertedItem = ConvertToFieldValue(item);
    convertedList.push_back(convertedItem);
  }
  return convertedList;
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
           if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
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
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      result(std::nullopt);
    }
    else {
      result(FlutterError(completed_future.error_message()));
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

    for (const auto& conditionElement : std::get<flutter::EncodableList>(element)) {
      condition.push_back(conditionElement);
    }

    conditions.push_back(condition);
  }

  return conditions;
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

    // Assume filterFromJson function converts filters to appropriate Firestore
    // filter
    // TODO: not available in the SDK
    // auto filter = filterFromJson(*parameters.filters());


    std::vector<std::vector<EncodableValue>> conditions =
        ConvertToConditions(*parameters.where());

    for (const auto& condition : conditions) {
      auto fieldPath = std::get<FieldPath>(condition[0]);
      std::string op = std::get<std::string>(condition[1]);
      auto value = condition[2];

      if (op == "==") {
        query = query.WhereEqualTo(fieldPath, ConvertToFieldValue(value));
      } else if (op == "!=") {
                          query = query.WhereNotEqualTo(fieldPath, ConvertToFieldValue(value));
      } else if (op == "<") {
        query = query.WhereLessThan(fieldPath, ConvertToFieldValue(value));
      } else if (op == "<=") {
        query = query.WhereLessThanOrEqualTo(fieldPath, ConvertToFieldValue(value));
      } else if (op == ">") {
        query = query.WhereGreaterThan(fieldPath, ConvertToFieldValue(value));
      } else if (op == ">=") {
        query = query.WhereGreaterThanOrEqualTo(fieldPath, ConvertToFieldValue(value));
      } else if (op == "array-contains") {
        query = query.WhereArrayContains(fieldPath, ConvertToFieldValue(value));
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
      query = query.Limit(*parameters.limit());
    }

    if (parameters.limit_to_last()) {
      query = query.LimitToLast(*parameters.limit_to_last());
    }

    if (parameters.order_by() == nullptr) {
      return query;
    }

    std::vector<std::vector<EncodableValue>> order_bys =
        ConvertToConditions(*parameters.order_by());

    for (const auto& order_by : order_bys) {
      auto fieldPath = std::get<FieldPath>(order_by[0]);
      std::string direction = std::get<std::string>(order_by[1]);

      if (direction == "desc") {
        query = query.OrderBy(fieldPath, Query::Direction::kDescending);
      }
      else if (direction == "asc") {
        query = query.OrderBy(fieldPath, Query::Direction::kAscending);
      }
      else {
        throw std::runtime_error("Unknown direction");
      }
    }

    if (parameters.start_at()) {
      query = query.StartAt(ConvertToFieldValueList(*parameters.start_at()));
    }
    if (parameters.start_after()) {
      query = query.StartAfter(ConvertToFieldValueList(*parameters.start_after()));
    }
    if (parameters.end_at()) {
      query = query.EndAt(ConvertToFieldValueList(*parameters.end_at()));
    }
    if (parameters.end_before()) {
      query = query.EndBefore(ConvertToFieldValueList(*parameters.end_before()));
    }

    return query;
  } catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    // Return a 'null' or 'empty' query based on your C++ Firestore API
    return firebase::firestore::Query();
  }
}


void CloudFirestorePlugin::QueryGet(
    const PigeonFirebaseApp& app, const std::string& path,
    bool is_collection_group, const PigeonQueryParameters& parameters,
    const PigeonGetOptions& options,
    std::function<void(ErrorOr<PigeonQuerySnapshot> reply)> result) {
   Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, is_collection_group, parameters);

  firebase::firestore::Source source = GetSourceFromPigeon(options.source());

  Future<firebase::firestore::QuerySnapshot> future = query.Get(source);

  future.OnCompletion([result, options](const Future<firebase::firestore::QuerySnapshot>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
          const firebase::firestore::QuerySnapshot* querySnapshot =
              completed_future.result();
      result(ParseQuerySnapshot(querySnapshot, GetServerTimestampBehaviorFromPigeon(options.server_timestamp_behavior())));
    }
    else {
      result(FlutterError(completed_future.error_message()));
    }
  });


}

using firebase::firestore::AggregateQuery;

firebase::firestore::AggregateSource GetAggregateSourceFromPigeon(const AggregateSource& source) {
  switch (source) {
    case AggregateSource::server:
      return firebase::firestore::AggregateSource::kServer;
  }
}

void CloudFirestorePlugin::AggregateQueryCount(
    const PigeonFirebaseApp& app, const std::string& path,
    const PigeonQueryParameters& parameters, const AggregateSource& source,
    std::function<void(ErrorOr<double> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, false, parameters);
  AggregateQuery aggregate_query = query.Count();

  Future<AggregateQuerySnapshot> future =
      aggregate_query.Get(GetAggregateSourceFromPigeon(source));

  future.OnCompletion([result](const Future<AggregateQuerySnapshot>& completed_future) {
    if (completed_future.error() == firebase::firestore::kErrorOk) {
      const AggregateQuerySnapshot* aggregateQuerySnapshot =
          completed_future.result();
      result(aggregateQuerySnapshot->count());
    }
    else {
      result(FlutterError(completed_future.error_message()));
    }
  });
}


void CloudFirestorePlugin::WriteBatchCommit(
    const PigeonFirebaseApp& app, const flutter::EncodableList& writes,
    std::function<void(std::optional<FlutterError> reply)> result) {
  try {
    Firestore* firestore = GetFirestoreFromPigeon(app);
    firebase::firestore::WriteBatch batch = firestore->batch();

    for (const auto& write : writes) {
      PigeonTransactionCommand transaction =
          std::get<PigeonTransactionCommand>(write);

      PigeonTransactionType type = transaction.type();
      std::string path = transaction.path();
      auto data =
          transaction.data();  

      firebase::firestore::DocumentReference documentReference =
          firestore->Document(path);

      switch (type) {
        case PigeonTransactionType::deleteType:
          batch.Delete(documentReference);
          break;
        case PigeonTransactionType::update:
          batch.Update(documentReference,
                       ConvertToMapFieldValue(*data));  
          break;
        case PigeonTransactionType::set:
          const PigeonDocumentOption* options =
              transaction.option();  

          if (options->merge()) {
            batch.Set(documentReference, ConvertToMapFieldValue(*data),
                      firebase::firestore::SetOptions::Merge());
          } else if (options->merge_fields()) {
            batch.Set(documentReference, ConvertToMapFieldValue(*data),
                      SetOptions::MergeFields(ConvertToFieldPathVector(*options->merge_fields())));
          } else {
            batch.Set(documentReference, ConvertToMapFieldValue(*data));
          }
          break;
      }
    }

    batch.Commit().OnCompletion([result](const Future<void>& completed_future) {
      if (completed_future.error() == firebase::firestore::kErrorOk) {
        result(std::nullopt);
      }
      else {
        result(FlutterError(completed_future.error_message()));
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
      Query* query, bool includeMetadataChanges,
      firebase::firestore::DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior) {
    query_ = query;
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

      listener_ = query_->AddSnapshotListener(
        metadataChanges,
        [events = std::move(events),
         serverTimestampBehavior = serverTimestampBehavior_,
                          metadataChanges](
            const firebase::firestore::QuerySnapshot& snapshot,
            firebase::firestore::Error error,
            const std::string& errorMessage) mutable {
          if (error == firebase::firestore::kErrorOk) {
            flutter::EncodableList toListResult(
                3); 
            std::vector<flutter::EncodableValue> documents(
                snapshot.documents().size());
            std::vector<flutter::EncodableValue> documentChanges(
                snapshot.DocumentChanges(metadataChanges)
                    .size());

            for (const auto& documentSnapshot : snapshot.documents()) {
              documents.push_back(ParseDocumentSnapshot(
                                      documentSnapshot, serverTimestampBehavior)
                                      .ToEncodableList());
            }

            // Assuming querySnapshot.getDocumentChanges() returns an iterable
            // collection
            for (const auto& documentChange :
                 snapshot.DocumentChanges(metadataChanges)) {
              documentChanges.push_back(
                  ParseDocumentChange(documentChange,
                                                       serverTimestampBehavior)
                      .ToEncodableList());
            }

            toListResult[0] = documents;
            toListResult[1] = documentChanges;
            toListResult[2] = ParseSnapshotMetadata(
                                  snapshot.metadata())
                                  .ToEncodableList();

            events->Success(toListResult);
          } else {
            events->Error("Error parsing QuerySnapshot");
          } 
      });
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue* arguments) override {
    listener_.Remove();
    return nullptr;
  }

 private:
  ListenerRegistration listener_;
  Query* query_;
  bool includeMetadataChanges_;
  firebase::firestore::DocumentSnapshot::ServerTimestampBehavior serverTimestampBehavior_;
};

void CloudFirestorePlugin::QuerySnapshot(
    const PigeonFirebaseApp& app, const std::string& path,
    bool is_collection_group, const PigeonQueryParameters& parameters,
    const PigeonGetOptions& options, bool include_metadata_changes,
    std::function<void(ErrorOr<std::string> reply)> result) {
  Firestore* firestore = GetFirestoreFromPigeon(app);
  Query query = ParseQuery(firestore, path, is_collection_group, parameters);

    auto query_snapshot_handler =
      std::make_unique<QuerySnapshotStreamHandler>(&query, include_metadata_changes);

  std::string channelName = RegisterEventChannel(METHOD_CHANNEL_NAME, *query_snapshot_handler);

  result(channelName);
}

void CloudFirestorePlugin::DocumentReferenceSnapshot(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& parameters,
    bool include_metadata_changes,
    std::function<void(ErrorOr<std::string> reply)> result) {
  // TODO: event channels
}

}  // namespace cloud_firestore
