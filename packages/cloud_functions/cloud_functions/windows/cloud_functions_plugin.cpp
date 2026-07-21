// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "cloud_functions_plugin.h"

#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <chrono>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "cloud_functions/plugin_version.h"
#include "firebase/app.h"
#include "firebase/functions.h"
#include "firebase/functions/callable_reference.h"
#include "firebase/functions/callable_result.h"
#include "firebase/functions/common.h"
#include "firebase/future.h"
#include "firebase/variant.h"
#include "messages.g.h"

using ::firebase::App;
using ::firebase::Future;
using ::firebase::Variant;
using ::firebase::functions::Error;
using ::firebase::functions::Functions;
using ::firebase::functions::HttpsCallableReference;
using ::firebase::functions::HttpsCallableResult;

namespace cloud_functions_windows {

static std::string kLibraryName = "flutter-fire-fn";

// Cache of Functions instances keyed by "<appName>|<region>". The C++ SDK
// manages their lifetime via App's CleanupNotifier, so these raw pointers are
// not owned here (mirroring the Linux implementation).
static std::map<std::string, Functions*> functions_instances_;

// --- Helper: Convert firebase::Variant to EncodableValue ---
static flutter::EncodableValue VariantToEncodableValue(const Variant& variant) {
  switch (variant.type()) {
    case Variant::kTypeNull:
      return flutter::EncodableValue();
    case Variant::kTypeInt64:
      return flutter::EncodableValue(variant.int64_value());
    case Variant::kTypeDouble:
      return flutter::EncodableValue(variant.double_value());
    case Variant::kTypeBool:
      return flutter::EncodableValue(variant.bool_value());
    case Variant::kTypeStaticString:
      return flutter::EncodableValue(std::string(variant.string_value()));
    case Variant::kTypeMutableString:
      return flutter::EncodableValue(variant.mutable_string());
    case Variant::kTypeVector: {
      flutter::EncodableList list;
      for (const auto& item : variant.vector()) {
        list.push_back(VariantToEncodableValue(item));
      }
      return flutter::EncodableValue(list);
    }
    case Variant::kTypeMap: {
      flutter::EncodableMap map;
      for (const auto& kv : variant.map()) {
        map[VariantToEncodableValue(kv.first)] =
            VariantToEncodableValue(kv.second);
      }
      return flutter::EncodableValue(map);
    }
    case Variant::kTypeStaticBlob:
    case Variant::kTypeMutableBlob: {
      const uint8_t* data = static_cast<const uint8_t*>(variant.blob_data());
      return flutter::EncodableValue(
          std::vector<uint8_t>(data, data + variant.blob_size()));
    }
    default:
      return flutter::EncodableValue();
  }
}

// --- Helper: Convert EncodableValue to firebase::Variant ---
static Variant EncodableValueToVariant(const flutter::EncodableValue& value) {
  if (std::holds_alternative<std::monostate>(value)) {
    return Variant::Null();
  } else if (std::holds_alternative<bool>(value)) {
    return Variant(std::get<bool>(value));
  } else if (std::holds_alternative<int32_t>(value)) {
    return Variant(static_cast<int64_t>(std::get<int32_t>(value)));
  } else if (std::holds_alternative<int64_t>(value)) {
    return Variant(std::get<int64_t>(value));
  } else if (std::holds_alternative<double>(value)) {
    return Variant(std::get<double>(value));
  } else if (std::holds_alternative<std::string>(value)) {
    return Variant(std::get<std::string>(value));
  } else if (std::holds_alternative<std::vector<uint8_t>>(value)) {
    const auto& bytes = std::get<std::vector<uint8_t>>(value);
    return Variant::FromMutableBlob(bytes.data(), bytes.size());
  } else if (std::holds_alternative<std::vector<int32_t>>(value)) {
    std::vector<Variant> vec;
    for (int32_t item : std::get<std::vector<int32_t>>(value)) {
      vec.push_back(Variant(static_cast<int64_t>(item)));
    }
    return Variant(vec);
  } else if (std::holds_alternative<std::vector<int64_t>>(value)) {
    std::vector<Variant> vec;
    for (int64_t item : std::get<std::vector<int64_t>>(value)) {
      vec.push_back(Variant(item));
    }
    return Variant(vec);
  } else if (std::holds_alternative<std::vector<float>>(value)) {
    std::vector<Variant> vec;
    for (float item : std::get<std::vector<float>>(value)) {
      vec.push_back(Variant(static_cast<double>(item)));
    }
    return Variant(vec);
  } else if (std::holds_alternative<std::vector<double>>(value)) {
    std::vector<Variant> vec;
    for (double item : std::get<std::vector<double>>(value)) {
      vec.push_back(Variant(item));
    }
    return Variant(vec);
  } else if (std::holds_alternative<flutter::EncodableList>(value)) {
    std::vector<Variant> vec;
    for (const auto& item : std::get<flutter::EncodableList>(value)) {
      vec.push_back(EncodableValueToVariant(item));
    }
    return Variant(vec);
  } else if (std::holds_alternative<flutter::EncodableMap>(value)) {
    std::map<Variant, Variant> variant_map;
    for (const auto& kv : std::get<flutter::EncodableMap>(value)) {
      variant_map[EncodableValueToVariant(kv.first)] =
          EncodableValueToVariant(kv.second);
    }
    return Variant(variant_map);
  }
  return Variant::Null();
}

// --- Helper: map a Cloud Functions error enum to its canonical string code ---
static std::string GetFunctionsErrorCode(Error error) {
  switch (error) {
    case Error::kErrorNone:
      return "none";
    case Error::kErrorCancelled:
      return "cancelled";
    case Error::kErrorInvalidArgument:
      return "invalid-argument";
    case Error::kErrorDeadlineExceeded:
      return "deadline-exceeded";
    case Error::kErrorNotFound:
      return "not-found";
    case Error::kErrorAlreadyExists:
      return "already-exists";
    case Error::kErrorPermissionDenied:
      return "permission-denied";
    case Error::kErrorResourceExhausted:
      return "resource-exhausted";
    case Error::kErrorFailedPrecondition:
      return "failed-precondition";
    case Error::kErrorAborted:
      return "aborted";
    case Error::kErrorOutOfRange:
      return "out-of-range";
    case Error::kErrorUnimplemented:
      return "unimplemented";
    case Error::kErrorInternal:
      return "internal";
    case Error::kErrorUnavailable:
      return "unavailable";
    case Error::kErrorDataLoss:
      return "data-loss";
    case Error::kErrorUnauthenticated:
      return "unauthenticated";
    case Error::kErrorUnknown:
    default:
      return "unknown";
  }
}

// --- Helper: read a string entry from an EncodableMap (or empty) ---
static std::string GetStringArg(const flutter::EncodableMap& map,
                                const char* key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it == map.end() || !std::holds_alternative<std::string>(it->second)) {
    return std::string();
  }
  return std::get<std::string>(it->second);
}

// --- Helper: resolve (and cache) a Functions instance for app + region ---
static Functions* GetFunctionsInstance(const std::string& app_name,
                                       const std::string& region) {
  App* app = App::GetInstance(app_name.c_str());
  if (app == nullptr) {
    return nullptr;
  }
  std::string cache_key = app_name + "|" + region;

  auto it = functions_instances_.find(cache_key);
  if (it != functions_instances_.end()) {
    return it->second;
  }

  Functions* functions = region.empty()
                             ? Functions::GetInstance(app)
                             : Functions::GetInstance(app, region.c_str());
  if (functions == nullptr) {
    return nullptr;
  }
  functions_instances_[cache_key] = functions;
  return functions;
}

static FlutterError MakeFunctionsError(const std::string& code,
                                       const std::string& message) {
  // Dart's platformExceptionToFirebaseFunctionsException reads the canonical
  // code/message out of the error details map.
  flutter::EncodableMap details;
  details[flutter::EncodableValue("code")] = flutter::EncodableValue(code);
  details[flutter::EncodableValue("message")] =
      flutter::EncodableValue(message);
  return FlutterError(code, message, flutter::EncodableValue(details));
}

// static
void CloudFunctionsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<CloudFunctionsPlugin>();

  CloudFunctionsHostApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));

  App::RegisterLibrary(kLibraryName.c_str(), getPluginVersion().c_str(),
                       nullptr);
}

CloudFunctionsPlugin::CloudFunctionsPlugin() {}

CloudFunctionsPlugin::~CloudFunctionsPlugin() = default;

void CloudFunctionsPlugin::Call(
    const flutter::EncodableMap& arguments,
    std::function<void(ErrorOr<std::optional<flutter::EncodableValue>> reply)>
        result) {
  std::string app_name = GetStringArg(arguments, "appName");
  std::string region = GetStringArg(arguments, "region");
  std::string function_name = GetStringArg(arguments, "functionName");
  std::string function_uri = GetStringArg(arguments, "functionUri");
  std::string origin = GetStringArg(arguments, "origin");

  if (app_name.empty()) {
    result(MakeFunctionsError("invalid-argument", "Missing appName"));
    return;
  }

  Functions* functions = GetFunctionsInstance(app_name, region);
  if (functions == nullptr) {
    result(MakeFunctionsError("internal", "Functions instance not found"));
    return;
  }

  if (!origin.empty()) {
    functions->UseFunctionsEmulator(origin.c_str());
  }

  // The HttpsCallableReference is heap-allocated and only deleted once the
  // SDK completion has fired. The reference's internal owns the transport
  // that runs the request on an SDK background thread; if the reference were
  // a local and went out of scope when this handler returns, that transport
  // would be destroyed mid-request and crash (use-after-free).
  auto* ref = new HttpsCallableReference();
  if (!function_name.empty()) {
    *ref = functions->GetHttpsCallable(function_name.c_str());
  } else if (!function_uri.empty()) {
    *ref = functions->GetHttpsCallableFromURL(function_uri.c_str());
  } else {
    delete ref;
    result(MakeFunctionsError(
        "invalid-argument",
        "Either functionName or functionUri must be provided"));
    return;
  }

  Variant parameters = Variant::Null();
  auto parameters_it = arguments.find(flutter::EncodableValue("parameters"));
  if (parameters_it != arguments.end()) {
    parameters = EncodableValueToVariant(parameters_it->second);
  }

  // The C++ SDK has no per-call deadline API, so the plugin enforces the
  // Dart-provided timeout itself. Whichever of the deadline thread and the
  // SDK completion runs first delivers the response; the loser only cleans
  // up. Cleanup (reference delete) always happens in the completion path
  // because deleting the reference while the request is in flight would
  // destroy the transport mid-request.
  struct CallState {
    std::mutex mutex;
    bool responded = false;
    HttpsCallableReference* ref;
  };
  auto state = std::make_shared<CallState>();
  state->ref = ref;

  int64_t timeout_ms = 0;
  auto timeout_it = arguments.find(flutter::EncodableValue("timeout"));
  if (timeout_it != arguments.end()) {
    if (std::holds_alternative<int64_t>(timeout_it->second)) {
      timeout_ms = std::get<int64_t>(timeout_it->second);
    } else if (std::holds_alternative<int32_t>(timeout_it->second)) {
      timeout_ms = std::get<int32_t>(timeout_it->second);
    }
  }
  if (timeout_ms > 0) {
    std::thread([state, result, timeout_ms]() {
      std::this_thread::sleep_for(std::chrono::milliseconds(timeout_ms));
      std::lock_guard<std::mutex> lock(state->mutex);
      if (!state->responded) {
        state->responded = true;
        result(MakeFunctionsError("deadline-exceeded",
                                  "The operation timed out."));
      }
    }).detach();
  }

  ref->Call(parameters)
      .OnCompletion([state, result](const Future<HttpsCallableResult>& future) {
        if (future.error() == Error::kErrorNone) {
          const HttpsCallableResult* callable_result = future.result();
          flutter::EncodableValue data =
              callable_result != nullptr
                  ? VariantToEncodableValue(callable_result->data())
                  : flutter::EncodableValue();
          {
            std::lock_guard<std::mutex> lock(state->mutex);
            if (!state->responded) {
              state->responded = true;
              result(ErrorOr<std::optional<flutter::EncodableValue>>(
                  std::optional<flutter::EncodableValue>(data)));
            }
          }
        } else {
          std::string code =
              GetFunctionsErrorCode(static_cast<Error>(future.error()));
          std::string message =
              future.error_message() ? future.error_message() : "Unknown error";
          {
            std::lock_guard<std::mutex> lock(state->mutex);
            if (!state->responded) {
              state->responded = true;
              result(MakeFunctionsError(code, message));
            }
          }
        }
        delete state->ref;
        state->ref = nullptr;
      });
}

// Streaming callable functions (httpsCallable().stream()) are not supported
// by the Firebase C++ SDK. Fail explicitly rather than silently hanging.
void CloudFunctionsPlugin::RegisterEventChannel(
    const flutter::EncodableMap& arguments,
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(MakeFunctionsError(
      "unimplemented",
      "Streaming callable functions are not supported on Windows."));
}

}  // namespace cloud_functions_windows
