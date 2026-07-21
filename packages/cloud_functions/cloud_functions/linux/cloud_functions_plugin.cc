// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/cloud_functions/cloud_functions_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <functional>
#include <map>
#include <string>
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

using firebase::App;
using firebase::Future;
using firebase::Variant;
using firebase::functions::Error;
using firebase::functions::Functions;
using firebase::functions::HttpsCallableReference;
using firebase::functions::HttpsCallableResult;

static const char kLibraryName[] = "flutter-fire-fn";

#define CLOUD_FUNCTIONS_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), cloud_functions_plugin_get_type(), \
                              CloudFunctionsPlugin))

struct _CloudFunctionsPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(CloudFunctionsPlugin, cloud_functions_plugin, g_object_get_type())

// Cache of Functions instances keyed by "<appName>|<region>". The C++ SDK
// manages their lifetime via App's CleanupNotifier, so these raw pointers are
// not owned here (mirroring firebase_database / firebase_storage).
static std::map<std::string, Functions*> functions_instances_;

// --- Helper: Run a closure on the GLib main thread ---
// Firebase C++ SDK futures fire on SDK-internal threads, but the GObject
// embedder API (FlBinaryMessenger / pigeon responses) is not thread-safe, so
// every response is marshalled back through the main loop.
static void PostToMainThread(std::function<void()> fn) {
  auto* boxed = new std::function<void()>(std::move(fn));
  g_idle_add(
      [](gpointer data) -> gboolean {
        auto* callback = static_cast<std::function<void()>*>(data);
        (*callback)();
        delete callback;
        return G_SOURCE_REMOVE;
      },
      boxed);
}

// --- Helper: Convert firebase::Variant to FlValue (transfer full) ---
static FlValue* VariantToFlValue(const Variant& variant) {
  switch (variant.type()) {
    case Variant::kTypeNull:
      return fl_value_new_null();
    case Variant::kTypeInt64:
      return fl_value_new_int(variant.int64_value());
    case Variant::kTypeDouble:
      return fl_value_new_float(variant.double_value());
    case Variant::kTypeBool:
      return fl_value_new_bool(variant.bool_value());
    case Variant::kTypeStaticString:
      return fl_value_new_string(variant.string_value());
    case Variant::kTypeMutableString:
      return fl_value_new_string(variant.mutable_string().c_str());
    case Variant::kTypeVector: {
      FlValue* list = fl_value_new_list();
      for (const auto& item : variant.vector()) {
        fl_value_append_take(list, VariantToFlValue(item));
      }
      return list;
    }
    case Variant::kTypeMap: {
      FlValue* map = fl_value_new_map();
      for (const auto& kv : variant.map()) {
        fl_value_set_take(map, VariantToFlValue(kv.first),
                          VariantToFlValue(kv.second));
      }
      return map;
    }
    case Variant::kTypeStaticBlob:
      return fl_value_new_uint8_list(variant.blob_data(), variant.blob_size());
    case Variant::kTypeMutableBlob:
      return fl_value_new_uint8_list(variant.blob_data(), variant.blob_size());
    default:
      return fl_value_new_null();
  }
}

// --- Helper: Convert FlValue to firebase::Variant ---
static Variant FlValueToVariant(FlValue* value) {
  if (value == nullptr) {
    return Variant::Null();
  }
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_NULL:
      return Variant::Null();
    case FL_VALUE_TYPE_BOOL:
      return Variant(static_cast<bool>(fl_value_get_bool(value)));
    case FL_VALUE_TYPE_INT:
      return Variant(static_cast<int64_t>(fl_value_get_int(value)));
    case FL_VALUE_TYPE_FLOAT:
      return Variant(fl_value_get_float(value));
    case FL_VALUE_TYPE_STRING:
      return Variant(std::string(fl_value_get_string(value)));
    case FL_VALUE_TYPE_UINT8_LIST:
      return Variant::FromMutableBlob(fl_value_get_uint8_list(value),
                                      fl_value_get_length(value));
    case FL_VALUE_TYPE_LIST: {
      std::vector<Variant> vec;
      size_t length = fl_value_get_length(value);
      for (size_t i = 0; i < length; i++) {
        vec.push_back(FlValueToVariant(fl_value_get_list_value(value, i)));
      }
      return Variant(vec);
    }
    case FL_VALUE_TYPE_MAP: {
      std::map<Variant, Variant> variant_map;
      size_t length = fl_value_get_length(value);
      for (size_t i = 0; i < length; i++) {
        variant_map[FlValueToVariant(fl_value_get_map_key(value, i))] =
            FlValueToVariant(fl_value_get_map_value(value, i));
      }
      return Variant(variant_map);
    }
    default:
      return Variant::Null();
  }
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

// --- Helper: read a string entry from an FlValue map (or nullptr) ---
static const gchar* GetStringArg(FlValue* map, const char* key) {
  FlValue* value = fl_value_lookup_string(map, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return nullptr;
  }
  return fl_value_get_string(value);
}

// --- Helper: resolve (and cache) a Functions instance for app + region ---
static Functions* GetFunctionsInstance(const gchar* app_name,
                                       const gchar* region) {
  App* app = App::GetInstance(app_name);
  if (app == nullptr) {
    return nullptr;
  }
  std::string region_str = region != nullptr ? region : "";
  std::string cache_key = std::string(app_name) + "|" + region_str;

  auto it = functions_instances_.find(cache_key);
  if (it != functions_instances_.end()) {
    return it->second;
  }

  Functions* functions = region_str.empty()
                             ? Functions::GetInstance(app)
                             : Functions::GetInstance(app, region_str.c_str());
  if (functions == nullptr) {
    return nullptr;
  }
  functions_instances_[cache_key] = functions;
  return functions;
}

// --- CloudFunctionsHostApi.call ---
static void HandleCall(
    FlValue* arguments,
    CloudFunctionsCloudFunctionsHostApiResponseHandle* response_handle,
    gpointer user_data) {
  if (arguments == nullptr ||
      fl_value_get_type(arguments) != FL_VALUE_TYPE_MAP) {
    cloud_functions_cloud_functions_host_api_respond_error_call(
        response_handle, "invalid-argument", "Missing call arguments", nullptr);
    return;
  }

  const gchar* app_name = GetStringArg(arguments, "appName");
  const gchar* region = GetStringArg(arguments, "region");
  const gchar* function_name = GetStringArg(arguments, "functionName");
  const gchar* function_uri = GetStringArg(arguments, "functionUri");
  const gchar* origin = GetStringArg(arguments, "origin");

  if (app_name == nullptr) {
    cloud_functions_cloud_functions_host_api_respond_error_call(
        response_handle, "invalid-argument", "Missing appName", nullptr);
    return;
  }

  Functions* functions = GetFunctionsInstance(app_name, region);
  if (functions == nullptr) {
    cloud_functions_cloud_functions_host_api_respond_error_call(
        response_handle, "internal", "Functions instance not found", nullptr);
    return;
  }

  if (origin != nullptr && origin[0] != '\0') {
    functions->UseFunctionsEmulator(origin);
  }

  // The HttpsCallableReference is heap-allocated and only deleted once the
  // response has been delivered (on the main thread, after completion). The
  // reference's internal owns the curl transport that runs the request on an
  // SDK background thread; if the reference were a local and went out of scope
  // when this handler returns, that transport would be destroyed mid-request
  // and crash (use-after-free in the curl thread). A copy captured by value
  // does not help because the SDK's copies own independent transports.
  auto* ref = new HttpsCallableReference();
  if (function_name != nullptr && function_name[0] != '\0') {
    *ref = functions->GetHttpsCallable(function_name);
  } else if (function_uri != nullptr && function_uri[0] != '\0') {
    *ref = functions->GetHttpsCallableFromURL(function_uri);
  } else {
    delete ref;
    cloud_functions_cloud_functions_host_api_respond_error_call(
        response_handle, "invalid-argument",
        "Either functionName or functionUri must be provided", nullptr);
    return;
  }

  Variant parameters =
      FlValueToVariant(fl_value_lookup_string(arguments, "parameters"));

  // The C++ SDK has no per-call deadline API, so the plugin enforces the
  // Dart-provided timeout itself. Whichever of the deadline timer and the SDK
  // completion runs first delivers the response; the loser only cleans up.
  // Both paths run on the main thread (g_timeout_add / PostToMainThread), so a
  // plain bool guard is sufficient. Cleanup (handle unref, reference delete)
  // always happens in the completion path because deleting the reference
  // while the request is in flight would destroy the transport mid-request.
  struct CallState {
    CloudFunctionsCloudFunctionsHostApiResponseHandle* response_handle;
    HttpsCallableReference* ref;
    bool responded = false;
    guint timeout_source_id = 0;
  };
  auto* state = new CallState{response_handle, ref};

  g_object_ref(response_handle);

  int64_t timeout_ms = 0;
  FlValue* timeout_value = fl_value_lookup_string(arguments, "timeout");
  if (timeout_value != nullptr &&
      fl_value_get_type(timeout_value) == FL_VALUE_TYPE_INT) {
    timeout_ms = fl_value_get_int(timeout_value);
  }
  if (timeout_ms > 0) {
    state->timeout_source_id = g_timeout_add(
        static_cast<guint>(timeout_ms),
        +[](gpointer user_data) -> gboolean {
          auto* timeout_state = static_cast<CallState*>(user_data);
          timeout_state->timeout_source_id = 0;
          if (!timeout_state->responded) {
            timeout_state->responded = true;
            FlValue* details = fl_value_new_map();
            fl_value_set_string_take(details, "code",
                                     fl_value_new_string("deadline-exceeded"));
            fl_value_set_string_take(
                details, "message",
                fl_value_new_string("The operation timed out."));
            cloud_functions_cloud_functions_host_api_respond_error_call(
                timeout_state->response_handle, "deadline-exceeded",
                "The operation timed out.", details);
            fl_value_unref(details);
          }
          return G_SOURCE_REMOVE;
        },
        state);
  }

  ref->Call(parameters)
      .OnCompletion([state](const Future<HttpsCallableResult>& future) {
        if (future.error() == Error::kErrorNone) {
          const HttpsCallableResult* result = future.result();
          FlValue* data = result != nullptr ? VariantToFlValue(result->data())
                                            : fl_value_new_null();
          PostToMainThread([state, data]() {
            if (state->timeout_source_id != 0) {
              g_source_remove(state->timeout_source_id);
              state->timeout_source_id = 0;
            }
            if (!state->responded) {
              state->responded = true;
              cloud_functions_cloud_functions_host_api_respond_call(
                  state->response_handle, data);
            }
            fl_value_unref(data);
            g_object_unref(state->response_handle);
            delete state->ref;
            delete state;
          });
        } else {
          std::string code =
              GetFunctionsErrorCode(static_cast<Error>(future.error()));
          std::string message =
              future.error_message() ? future.error_message() : "Unknown error";
          PostToMainThread([state, code, message]() {
            if (state->timeout_source_id != 0) {
              g_source_remove(state->timeout_source_id);
              state->timeout_source_id = 0;
            }
            if (!state->responded) {
              state->responded = true;
              // Dart's platformExceptionToFirebaseFunctionsException reads the
              // canonical code/message out of the error details map.
              FlValue* details = fl_value_new_map();
              fl_value_set_string_take(details, "code",
                                       fl_value_new_string(code.c_str()));
              fl_value_set_string_take(details, "message",
                                       fl_value_new_string(message.c_str()));
              cloud_functions_cloud_functions_host_api_respond_error_call(
                  state->response_handle, code.c_str(), message.c_str(),
                  details);
              fl_value_unref(details);
            }
            g_object_unref(state->response_handle);
            delete state->ref;
            delete state;
          });
        }
      });
}

// --- CloudFunctionsHostApi.registerEventChannel ---
// Streaming callable functions (httpsCallable().stream()) are not yet
// supported on Linux. Fail explicitly rather than silently hanging.
static void HandleRegisterEventChannel(
    FlValue* arguments,
    CloudFunctionsCloudFunctionsHostApiResponseHandle* response_handle,
    gpointer user_data) {
  cloud_functions_cloud_functions_host_api_respond_error_register_event_channel(
      response_handle, "unimplemented",
      "Streaming callable functions are not supported on Linux.", nullptr);
}

static const CloudFunctionsCloudFunctionsHostApiVTable kHostApiVTable = {
    HandleCall,                  // call
    HandleRegisterEventChannel,  // register_event_channel
};

static void cloud_functions_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(cloud_functions_plugin_parent_class)->dispose(object);
}

static void cloud_functions_plugin_class_init(
    CloudFunctionsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = cloud_functions_plugin_dispose;
}

static void cloud_functions_plugin_init(CloudFunctionsPlugin* self) {}

void cloud_functions_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  CloudFunctionsPlugin* plugin = CLOUD_FUNCTIONS_PLUGIN(
      g_object_new(cloud_functions_plugin_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  cloud_functions_cloud_functions_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kHostApiVTable, g_object_ref(plugin),
      g_object_unref);

  g_object_unref(plugin);

  App::RegisterLibrary(
      kLibraryName, cloud_functions_linux::getPluginVersion().c_str(), nullptr);
}
