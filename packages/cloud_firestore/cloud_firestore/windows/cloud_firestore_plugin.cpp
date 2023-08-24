#include "cloud_firestore_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h";

#include "messages.g.h"


#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

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


void CloudFirestorePlugin::LoadBundle(
    const PigeonFirebaseApp& app, const std::vector<uint8_t>& bundle,
    std::function<void(ErrorOr<std::string> reply)> result) {
  // TODO: uses EventChannels
}

void CloudFirestorePlugin::NamedQueryGet(
    const PigeonFirebaseApp& app, const std::string& name,
    const PigeonGetOptions& options,
    std::function<void(ErrorOr<PigeonQuerySnapshot> reply)> result) {}

void CloudFirestorePlugin::ClearPersistence(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::DisableNetwork(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::EnableNetwork(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::Terminate(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::WaitForPendingWrites(
    const PigeonFirebaseApp& app,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::SetIndexConfiguration(
    const PigeonFirebaseApp& app, const std::string& index_configuration,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::SetLoggingEnabled(
    bool logging_enabled,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::SnapshotsInSyncSetup(
    std::function<void(ErrorOr<std::string> reply)> result) {}

void CloudFirestorePlugin::TransactionCreate(
    std::function<void(ErrorOr<std::string> reply)> result) {}

void CloudFirestorePlugin::TransactionStoreResult(
    const std::string& transaction_id,
    const PigeonTransactionResult& result_type,
    const flutter::EncodableList* commands,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::TransactionGet(
    const PigeonFirebaseApp& app, const std::string& transaction_id,
    const std::string& path,
    std::function<void(ErrorOr<PigeonDocumentSnapshot> reply)> result) {}

void CloudFirestorePlugin::DocumentReferenceSet(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::DocumentReferenceUpdate(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {}

void CloudFirestorePlugin::DocumentReferenceGet(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(ErrorOr<PigeonDocumentSnapshot> reply)> result) {}

void CloudFirestorePlugin::DocumentReferenceDelete(
    const PigeonFirebaseApp& app, const DocumentReferenceRequest& request,
    std::function<void(std::optional<FlutterError> reply)> result) {}

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
