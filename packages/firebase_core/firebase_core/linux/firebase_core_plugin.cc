// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/firebase_core/firebase_core_plugin.h"

#include <flutter_linux/flutter_linux.h>

#include <string>
#include <vector>

#include "firebase/app.h"
#include "firebase_core/plugin_version.h"
#include "flutter_firebase_plugin_registry.h"
#include "messages.g.h"

using ::firebase::App;

static const char kLibraryName[] = "flutter-fire-core";

#define FIREBASE_CORE_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), firebase_core_plugin_get_type(), \
                              FirebaseCorePlugin))

struct _FirebaseCorePlugin {
  GObject parent_instance;

  // Whether initializeCore has already been called once for this Dart
  // isolate; a second call means a hot restart occurred.
  bool core_initialized;
};

G_DEFINE_TYPE(FirebaseCorePlugin, firebase_core_plugin, g_object_get_type())

// Convert a FirebaseCoreCoreFirebaseOptions to a firebase::AppOptions.
static firebase::AppOptions CoreFirebaseOptionsToAppOptions(
    FirebaseCoreCoreFirebaseOptions* pigeon_options) {
  firebase::AppOptions options;
  options.set_api_key(
      firebase_core_core_firebase_options_get_api_key(pigeon_options));
  options.set_app_id(
      firebase_core_core_firebase_options_get_app_id(pigeon_options));
  const gchar* database_url =
      firebase_core_core_firebase_options_get_database_u_r_l(pigeon_options);
  if (database_url != nullptr) {
    options.set_database_url(database_url);
  }
  const gchar* tracking_id =
      firebase_core_core_firebase_options_get_tracking_id(pigeon_options);
  if (tracking_id != nullptr) {
    options.set_ga_tracking_id(tracking_id);
  }
  options.set_messaging_sender_id(
      firebase_core_core_firebase_options_get_messaging_sender_id(
          pigeon_options));

  options.set_project_id(
      firebase_core_core_firebase_options_get_project_id(pigeon_options));

  const gchar* storage_bucket =
      firebase_core_core_firebase_options_get_storage_bucket(pigeon_options);
  if (storage_bucket != nullptr) {
    options.set_storage_bucket(storage_bucket);
  }
  return options;
}

// Convert a firebase::AppOptions to FirebaseCoreCoreFirebaseOptions.
// Ownership: returns a new reference (transfer full).
static FirebaseCoreCoreFirebaseOptions* OptionsFromFIROptions(
    const firebase::AppOptions& options) {
  // AppOptions initialises as empty char so we check to stop empty string to
  // Flutter. Same for storage bucket below.
  const char* database_url = options.database_url();
  if (database_url != nullptr && database_url[0] == '\0') {
    database_url = nullptr;
  }
  const char* storage_bucket = options.storage_bucket();
  if (storage_bucket != nullptr && storage_bucket[0] == '\0') {
    storage_bucket = nullptr;
  }
  return firebase_core_core_firebase_options_new(
      options.api_key(), options.app_id(), options.messaging_sender_id(),
      options.project_id(),
      /* auth_domain= */ nullptr, database_url, storage_bucket,
      /* measurement_id= */ nullptr, /* tracking_id= */ nullptr,
      /* deep_link_u_r_l_scheme= */ nullptr,
      /* android_client_id= */ nullptr, /* ios_client_id= */ nullptr,
      /* ios_bundle_id= */ nullptr, /* app_group_id= */ nullptr,
      /* recaptcha_site_key= */ nullptr);
}

// Convert a firebase::App to FirebaseCoreCoreInitializeResponse.
// Ownership: returns a new reference (transfer full).
static FirebaseCoreCoreInitializeResponse* AppToCoreInitializeResponse(
    const App& app) {
  g_autoptr(FlValue) plugin_constants = firebase_core_linux::
      FlutterFirebasePluginRegistry::GetPluginConstantsForFirebaseApp(app);
  g_autoptr(FirebaseCoreCoreFirebaseOptions) options =
      OptionsFromFIROptions(app.options());
  return firebase_core_core_initialize_response_new(
      app.name(), options,
      /* is_automatic_data_collection_enabled= */ nullptr, plugin_constants);
}

// FirebaseCoreHostApi

static void HandleInitializeApp(
    const gchar* app_name,
    FirebaseCoreCoreFirebaseOptions* initialize_app_request,
    FirebaseCoreFirebaseCoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // Create an app
  App* app = App::Create(
      CoreFirebaseOptionsToAppOptions(initialize_app_request), app_name);

  // Send back the result to Flutter
  g_autoptr(FirebaseCoreCoreInitializeResponse) response =
      AppToCoreInitializeResponse(*app);
  firebase_core_firebase_core_host_api_respond_initialize_app(response_handle,
                                                              response);
}

static void HandleInitializeCore(
    FirebaseCoreFirebaseCoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  FirebaseCorePlugin* self = FIREBASE_CORE_PLUGIN(user_data);
  if (self->core_initialized) {
    firebase_core_linux::FlutterFirebasePluginRegistry::
        DidReinitializeFirebaseCore();
  }
  self->core_initialized = true;

  g_autoptr(FlValue) initialized_apps = fl_value_new_list();
  std::vector<App*> all_apps = App::GetApps();
  for (const App* app : all_apps) {
    g_autoptr(FirebaseCoreCoreInitializeResponse) response =
        AppToCoreInitializeResponse(*app);
    fl_value_append_take(initialized_apps,
                         fl_value_new_custom_object(
                             firebase_core_core_initialize_response_type_id,
                             G_OBJECT(response)));
  }
  firebase_core_firebase_core_host_api_respond_initialize_core(
      response_handle, initialized_apps);
}

static void HandleOptionsFromResource(
    FirebaseCoreFirebaseCoreHostApiResponseHandle* response_handle,
    gpointer user_data) {
  // optionsFromResource reads platform resource files (e.g.
  // google-services.json on Android) and has no equivalent on Linux desktop.
  // Windows leaves the reply pending forever; responding with an error is a
  // deliberate improvement so callers do not hang.
  firebase_core_firebase_core_host_api_respond_error_options_from_resource(
      response_handle, "unimplemented",
      "optionsFromResource is not supported on Linux", nullptr);
}

// FirebaseAppHostApi

static void HandleSetAutomaticDataCollectionEnabled(
    const gchar* app_name, gboolean enabled,
    FirebaseCoreFirebaseAppHostApiResponseHandle* response_handle,
    gpointer user_data) {
  App* firebase_app = App::GetInstance(app_name);
  if (firebase_app != nullptr) {
    // TODO: Missing method
  }
  firebase_core_firebase_app_host_api_respond_set_automatic_data_collection_enabled(
      response_handle);
}

static void HandleSetAutomaticResourceManagementEnabled(
    const gchar* app_name, gboolean enabled,
    FirebaseCoreFirebaseAppHostApiResponseHandle* response_handle,
    gpointer user_data) {
  App* firebase_app = App::GetInstance(app_name);
  if (firebase_app != nullptr) {
    // TODO: Missing method
  }
  firebase_core_firebase_app_host_api_respond_set_automatic_resource_management_enabled(
      response_handle);
}

static void HandleDelete(
    const gchar* app_name,
    FirebaseCoreFirebaseAppHostApiResponseHandle* response_handle,
    gpointer user_data) {
  App* firebase_app = App::GetInstance(app_name);
  if (firebase_app != nullptr) {
    // Improvement over the Windows implementation (which is a TODO no-op):
    // the C++ SDK supports destroying an app on desktop; deleting the
    // firebase::App instance unregisters it from the app registry.
    delete firebase_app;
  }
  firebase_core_firebase_app_host_api_respond_delete(response_handle);
}

static const FirebaseCoreFirebaseCoreHostApiVTable kFirebaseCoreHostApiVTable =
    {
        HandleInitializeApp,        // initialize_app
        HandleInitializeCore,       // initialize_core
        HandleOptionsFromResource,  // options_from_resource
};

static const FirebaseCoreFirebaseAppHostApiVTable kFirebaseAppHostApiVTable = {
    HandleSetAutomaticDataCollectionEnabled,  // set_automatic_data_collection_enabled
    HandleSetAutomaticResourceManagementEnabled,  // set_automatic_resource_management_enabled
    HandleDelete,                                 // delete_
};

static void firebase_core_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(firebase_core_plugin_parent_class)->dispose(object);
}

static void firebase_core_plugin_class_init(FirebaseCorePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = firebase_core_plugin_dispose;
}

static void firebase_core_plugin_init(FirebaseCorePlugin* self) {
  self->core_initialized = false;
}

void firebase_core_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FirebaseCorePlugin* plugin = FIREBASE_CORE_PLUGIN(
      g_object_new(firebase_core_plugin_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  firebase_core_firebase_core_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseCoreHostApiVTable,
      g_object_ref(plugin), g_object_unref);
  firebase_core_firebase_app_host_api_set_method_handlers(
      messenger, /* suffix= */ nullptr, &kFirebaseAppHostApiVTable,
      g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);

  // Register for platform logging
  App::RegisterLibrary(
      kLibraryName, firebase_core_linux::getPluginVersion().c_str(), nullptr);
}

void RegisterFlutterFirebasePlugin(const std::string& channel_name,
                                   FlutterFirebasePlugin* plugin) {
  firebase_core_linux::FlutterFirebasePluginRegistry::RegisterPlugin(
      channel_name, plugin);
}
