#include "firebase_remote_config_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include "firebase/app.h"
#include "firebase/remote_config.h"
#include "firebase_core/firebase_plugin_registry.h"
#include "firebase_remote_config/plugin_version.h"
#include "firebase_remote_config_plugin_constants.h"

// #include "messages.g.h"
// #include "remote_config_pigeon_implemetation.h"

using namespace firebase::remote_config;
using namespace firebase;

extern "C" firebase_core_windows::FirebasePluginRegistry*
GetFlutterFirebaseRegistry();

namespace firebase_remote_config_windows {
const char* kEventChannelName =
    "plugins.flutter.io/firebase_remote_config_updated";
const char* kMethodChannelName = "plugins.flutter.io/firebase_remote_config";
const char* kRemoteConfigLibrary = "firebase_remote_config_windows";
std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;

const char* kSetConfigSettingsMethodName = "RemoteConfig#setConfigSettings";
const char* kSetDefaultsMethodName = "RemoteConfig#setDefaults";
const char* kEnsureInitializedMethodName = "RemoteConfig#ensureInitialized";
const char* kFetchMethodName = "RemoteConfig#fetch";
const char* kActivateMethodName = "RemoteConfig#activate";
const char* kGetAllMethodName = "RemoteConfig#getAll";
const char* kGetPropertiesMethodName = "RemoteConfig#getProperties";
const char* kFetchAndActivateMethodName = "RemoteConfig#fetchAndActivate";

void FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FirebaseRemoteConfigPlugin>();

  const auto method_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kMethodChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  method_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  const auto firebase_registry =
      firebase_core_windows::FirebasePluginRegistry::GetInstance();
  const auto shared_plugin =
      std::make_shared<FlutterFirebaseRemoteConfigPlugin>();
  ::firebase::App::RegisterLibrary(kRemoteConfigLibrary,
                                   getPluginVersion().c_str(), nullptr);
  firebase_registry->put_plugin_ref(shared_plugin);

  const auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kEventChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto eventChannelHandler = std::make_unique<
      flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
      [&, plugin_pointer = plugin.get()](
          const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink)
          -> std::unique_ptr<
              flutter::StreamHandlerError<flutter::EncodableValue>> {
        // sink_ = std::move(sink);
        const auto args = plugin_pointer->try_get_arguments_(arguments);

        // Getting app name
        const auto app_name = plugin_pointer->get_app_name_(args);

        const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
        const auto remoteConfig =
            ::firebase::remote_config::RemoteConfig::GetInstance(firebaseApp);
        auto registration = remoteConfig->AddOnConfigUpdateListener(
            [&sink, this](ConfigUpdate&& config_update,
                          RemoteConfigError error) {
              const auto updatedKeys = config_update.updated_keys;
              flutter::EncodableList keys{};

              for (const auto& key : updatedKeys) {
                keys.push_back(flutter::EncodableValue(key));
              }
              sink->Success(flutter::EncodableValue(keys));
            });

        return nullptr;
      },
      [](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<
              flutter::StreamHandlerError<flutter::EncodableValue>> {
        return nullptr;
      });

  event_channel->SetStreamHandler(std::move(eventChannelHandler));

  registrar->AddPlugin(std::move(plugin));
}

FirebaseRemoteConfigPlugin::FirebaseRemoteConfigPlugin() {}

FirebaseRemoteConfigPlugin::~FirebaseRemoteConfigPlugin() {}

void FirebaseRemoteConfigPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::cout << "Method call: " << method_call.method_name() << std::endl;

  const auto& method_name = method_call.method_name();
  try {
    auto shared_result =
        std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(
            std::move(result));

    if (method_name == kSetConfigSettingsMethodName) {
      set_config_settings_(
          method_call.arguments(),
          [shared_result](const std::optional<FirebaseRemoteConfigException>&
                              response_result) {
            if (response_result.has_value()) {
              shared_result->Error(kSetConfigSettingsMethodName,
                                   response_result->what());
            } else {
              shared_result->Success();
            }
          });
    } else if (method_name == kSetDefaultsMethodName) {
      set_defaults_(method_call.arguments(), [shared_result](
                                                 const auto& response_result) {
        if (response_result.has_value()) {
          shared_result->Error(kSetDefaultsMethodName, response_result->what());
        } else {
          shared_result->Success();
        }
      });
    } else if (method_name == kGetPropertiesMethodName) {
      auto properties = get_properties_(method_call.arguments());
      shared_result->Success(flutter::EncodableValue(properties));
    } else if (method_name == kGetAllMethodName) {
      // const auto args = try_get_arguments_(method_call.arguments());
      const auto all = get_all_(method_call.arguments());
      shared_result->Success(flutter::EncodableValue(all));
    } else if (method_name == kEnsureInitializedMethodName) {
      ensure_initialized_(method_call.arguments(),
                          [shared_result](const auto& callback_result) {
                            if (callback_result.has_value()) {
                              shared_result->Error(kEnsureInitializedMethodName,
                                                   callback_result->what());
                            } else {
                              shared_result->Success();
                            }
                          });
    } else if (method_name == kActivateMethodName) {
      activate_(method_call.arguments(), [shared_result](
                                             const auto& callback_result) {
        if (std::holds_alternative<FirebaseRemoteConfigException>(
                callback_result)) {
          shared_result->Error(
              kActivateMethodName,
              std::get<FirebaseRemoteConfigException>(callback_result).what());
        } else {
          shared_result->Success(
              flutter::EncodableValue(std::get<bool>(callback_result)));
        }
      });
    } else if (method_name == kFetchMethodName) {
      fetch_(method_call.arguments(), [shared_result](
                                          const auto& callback_result) {
        if (callback_result.has_value()) {
          shared_result->Error(kFetchMethodName, callback_result->what());
        } else {
          shared_result->Success();
        }
      });
    } else if (method_name == kFetchAndActivateMethodName) {
      fetch_and_activate_(
          method_call.arguments(),
          [shared_result](const auto& callback_result) {
            if (std::holds_alternative<FirebaseRemoteConfigException>(
                    callback_result)) {
              shared_result->Error(
                  kFetchAndActivateMethodName,
                  std::get<FirebaseRemoteConfigException>(callback_result)
                      .what());
            } else {
              shared_result->Success(
                  flutter::EncodableValue(std::get<bool>(callback_result)));
            }
          });
    } else {
      result->NotImplemented();
    }
  } catch (const FirebaseRemoteConfigException& e) {
    result->Error(kSetConfigSettingsMethodName, e.what());
  } catch (const std::exception& e) {
    result->Error(kSetConfigSettingsMethodName, e.what());
  }
}

void FirebaseRemoteConfigPlugin::get_method_channel_arguments_(
    flutter::EncodableMap* args) const {
  for (const auto& [key, value] : *args) {
    std::cout << "Key: " << std::get<std::string>(key) << std::endl;
  }
}

std::vector<firebase::remote_config::ConfigKeyValueVariant>
FirebaseRemoteConfigPlugin::set_defaults_convert_to_native_(
    const flutter::EncodableMap& default_parameters) const {
  std::vector<ConfigKeyValueVariant> parameters;
  std::vector<std::pair<std::string, std::string>> storage;

  for (const auto& items : default_parameters) {
    if (std::holds_alternative<std::string>(items.first)) {
      std::string key_str = std::get<std::string>(items.first);

      ConfigKeyValueVariant kv;
      char* key = new char[key_str.size() + 1];
      // strcpy(key, key_str.c_str());
      strcpy_s(key, sizeof(char) * key_str.size() + 1, key_str.c_str());
      kv.key = key;
      kv.value = set_defaults_to_variant_(items.second);
      parameters.push_back(kv);
    }
  }

  return parameters;
}
firebase::Variant FirebaseRemoteConfigPlugin::set_defaults_to_variant_(
    flutter::EncodableValue encodableValue) const {
  if (std::holds_alternative<bool>(encodableValue)) {
    auto value = std::get<bool>(encodableValue);
    return {value};
  }

  if (std::holds_alternative<int64_t>(encodableValue)) {
    auto value = std::get<int64_t>(encodableValue);
    return {value};
  }

  if (std::holds_alternative<std::string>(encodableValue)) {
    auto value = std::get<std::string>(encodableValue);
    return {value};
  }

  if (std::holds_alternative<double>(encodableValue)) {
    auto value = std::get<double>(encodableValue);
    return {value};
  }

  return {};
}
std::string FirebaseRemoteConfigPlugin::map_last_fetch_status_(
    firebase::remote_config::LastFetchStatus lastFetchStatus) const {
  if (lastFetchStatus == kLastFetchStatusSuccess) {
    return "success";
  } else if (lastFetchStatus == kLastFetchStatusFailure) {
    return "failure";
  } else if (lastFetchStatus == kLastFetchStatusPending) {
    return "noFetchYet";
  } else {
    return "failure";
  }
}
flutter::EncodableMap* FirebaseRemoteConfigPlugin::try_get_arguments_(
    const flutter::EncodableValue* arguments) const {
  const auto args = std::get_if<flutter::EncodableMap>(arguments);
  return args ? const_cast<flutter::EncodableMap*>(args) : nullptr;
}

std::string FirebaseRemoteConfigPlugin::get_app_name_(
    flutter::EncodableMap* args) const {
  const auto& encodable_app_name_arg =
      args->find(flutter::EncodableValue("appName"));
  if (encodable_app_name_arg == args->end()) {
    throw std::exception("Arguments does not contains appName");
  }
  const auto& app_name_arg =
      std::get<std::string>(encodable_app_name_arg->second);

  return app_name_arg;
}

std::string FirebaseRemoteConfigPlugin::map_source_(ValueSource source) const {
  if (source == kValueSourceStaticValue) {
    return "static";
  } else if (source == kValueSourceDefaultValue) {
    return "default";
  } else if (source == kValueSourceRemoteValue) {
    return "remote";
  } else {
    return "static";
  }
}

flutter::EncodableMap
FirebaseRemoteConfigPlugin::create_remote_config_values_map_(
    std::string key, RemoteConfig* remote_config) const {
  flutter::EncodableMap parsed_parameters;

  ValueInfo value_info{};
  auto data = remote_config->GetData(key.c_str(), &value_info);

  parsed_parameters.insert(
      {flutter::EncodableValue("value"), flutter::EncodableValue(data)});
  const auto source_mapped = map_source_(value_info.source);
  parsed_parameters.insert({flutter::EncodableValue("source"),
                            flutter::EncodableValue(source_mapped.c_str())});
  return parsed_parameters;
}

flutter::EncodableMap FirebaseRemoteConfigPlugin::map_parameters_(
    std::map<std::string, firebase::Variant> parameters,
    RemoteConfig* remote_config) const {
  flutter::EncodableMap map_;

  for (const auto& val : parameters) {
    auto param = val.second;
    auto name = val.first;

    map_.insert({name, create_remote_config_values_map_(name, remote_config)});
  }

  return map_;
}

void FirebaseRemoteConfigPlugin::set_config_settings_(
    const flutter::EncodableValue* arguments,
    std::function<void(std::optional<FirebaseRemoteConfigException>)>
        completion) {
  const auto& args = try_get_arguments_(arguments);

  if (!args) {
    completion(FirebaseRemoteConfigException("Cannot decode arguments"));
    return;
  }

  const auto app_name = get_app_name_(args);

  const auto& encodable_fetch_timeout_arg =
      args->find(flutter::EncodableValue("fetchTimeout"));
  if (encodable_fetch_timeout_arg == args->end()) {
    completion(FirebaseRemoteConfigException("Cannot decode fetch timeout"));
    return;
  }
  const int64_t fetch_timeout_arg =
      encodable_fetch_timeout_arg->second.LongValue();

  const auto& encodable_minimum_fetch_interval_arg =
      args->find(flutter::EncodableValue("minimumFetchInterval"));
  if (encodable_minimum_fetch_interval_arg == args->end()) {
    completion(
        FirebaseRemoteConfigException("Cannot decode minimum fetch interval"));
    return;
  }
  const int64_t minimum_fetch_interval_arg =
      encodable_minimum_fetch_interval_arg->second.LongValue();

  const auto firebaseApp = App::GetInstance(app_name.c_str());
  const auto remoteConfig = RemoteConfig::GetInstance(firebaseApp);

  const ConfigSettings config_setting{
      static_cast<uint64_t>(fetch_timeout_arg),
      static_cast<uint64_t>(minimum_fetch_interval_arg)};

  auto future = remoteConfig->SetConfigSettings(config_setting);

  future.OnCompletion([completion](const Future<void>& futureResult) {
    if (futureResult.error() == kFutureStatusComplete) {
      completion({});
    } else {
      completion(FirebaseRemoteConfigException("Cannot set config settings"));
    }
  });
}

void FirebaseRemoteConfigPlugin::set_defaults_(
    const flutter::EncodableValue* arguments,
    std::function<void(std::optional<FirebaseRemoteConfigException>)>
        completion) {
  const auto& args = try_get_arguments_(arguments);

  if (!args) {
    completion(FirebaseRemoteConfigException("Cannot decode arguments"));
    return;
  }

  const auto app_name = get_app_name_(args);

  const auto& encodable_defaults_arg =
      args->find(flutter::EncodableValue("defaults"));
  if (encodable_defaults_arg == args->end()) {
    completion(FirebaseRemoteConfigException("Cannot decode defaults"));
    return;
  }
  const auto& defaults_arg =
      std::get<flutter::EncodableMap>(encodable_defaults_arg->second);

  App* firebaseApp = App::GetInstance(app_name.c_str());
  RemoteConfig* remoteConfig = RemoteConfig::GetInstance(firebaseApp);

  const auto& default_args_native =
      set_defaults_convert_to_native_(defaults_arg);

  auto future = remoteConfig->SetDefaults(default_args_native.data(),
                                          default_args_native.size());

  future.OnCompletion([completion](const Future<void>& futureResult) {
    if (futureResult.error() == kFutureStatusComplete) {
      completion({});
    } else {
      completion(FirebaseRemoteConfigException("Cannot set defaults"));
    }
  });
}
flutter::EncodableMap FirebaseRemoteConfigPlugin::get_properties_(
    const flutter::EncodableValue* arguments) {
  const auto& args = try_get_arguments_(arguments);

  if (!args) {
    throw FirebaseRemoteConfigException("Cannot decode arguments");
  }

  const auto app_name = get_app_name_(args);

  App* firebaseApp = App::GetInstance(app_name.c_str());
  RemoteConfig* remote_config = RemoteConfig::GetInstance(firebaseApp);

  const auto configSettings = remote_config->GetConfigSettings();
  auto fetchTimeout =
      static_cast<int64_t>(configSettings.fetch_timeout_in_milliseconds);
  auto minFetchTimeout = static_cast<int64_t>(
      configSettings.minimum_fetch_interval_in_milliseconds);

  const auto configInfo = remote_config->GetInfo();
  const auto lastFetch = static_cast<int64_t>(configInfo.fetch_time);
  const auto lastFetchStatus = configInfo.last_fetch_status;
  const auto lastFetchStatusMapped = map_last_fetch_status_(lastFetchStatus);
  //
  flutter::EncodableMap values;

  values.insert({flutter::EncodableValue("fetchTimeout"),
                 flutter::EncodableValue(fetchTimeout)});
  values.insert({flutter::EncodableValue("minimumFetchInterval"),
                 flutter::EncodableValue(minFetchTimeout)});
  values.insert({flutter::EncodableValue("lastFetchTime"),
                 flutter::EncodableValue(lastFetch)});
  values.insert({flutter::EncodableValue("lastFetchStatus"),
                 flutter::EncodableValue(lastFetchStatusMapped.c_str())});

  return values;
}

void FirebaseRemoteConfigPlugin::ensure_initialized_(
    const flutter::EncodableValue* arguments,
    std::function<void(std::optional<FirebaseRemoteConfigException>)>
        completion) {
  const auto& args = try_get_arguments_(arguments);

  auto app_name = get_app_name_(args);

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  const auto future = remote_config->EnsureInitialized();

  future.OnCompletion([completion](const Future<ConfigInfo>& futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      completion({});
    } else {
      completion(
          FirebaseRemoteConfigException("Cannot initialize remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::activate_(
    const flutter::EncodableValue* arguments,
    std::function<void(std::variant<bool, FirebaseRemoteConfigException>)>
        completion) {
  const auto& args = try_get_arguments_(arguments);
  if (!args) {
    throw FirebaseRemoteConfigException("Cannot decode arguments");
  }

  const auto app_name = get_app_name_(args);

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  auto future = remote_config->Activate();

  future.OnCompletion([completion](const Future<bool>& futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      auto result = *futureResult.result();
      completion(std::variant<bool, FirebaseRemoteConfigException>(result));
    } else {
      completion(
          FirebaseRemoteConfigException("Cannot activate remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::fetch_(
    const flutter::EncodableValue* arguments,
    std::function<void(std::optional<FirebaseRemoteConfigException>)>
        completion) {
  const auto& args = try_get_arguments_(arguments);

  if (!args) {
    throw FirebaseRemoteConfigException("Cannot decode arguments");
  }

  const auto app_name = get_app_name_(args);

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  auto future = remote_config->Fetch();

  future.OnCompletion([completion](const Future<void>& futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      completion({});
    } else {
      completion(FirebaseRemoteConfigException("Cannot fetch remote config"));
    }
  });
}

void FirebaseRemoteConfigPlugin::fetch_and_activate_(
    const flutter::EncodableValue* arguments,
    std::function<void(std::variant<bool, FirebaseRemoteConfigException>)>
        completion) {
  const auto& args = try_get_arguments_(arguments);
  if (!args) {
    throw FirebaseRemoteConfigException("Cannot decode arguments");
  }

  const auto app_name = get_app_name_(args);

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  auto future = remote_config->FetchAndActivate();

  future.OnCompletion([completion](const Future<bool>& futureResult) {
    if (futureResult.status() == kFutureStatusComplete) {
      auto result = *futureResult.result();
      completion(std::variant<bool, FirebaseRemoteConfigException>(result));
    } else {
      completion(
          FirebaseRemoteConfigException("Cannot activate remote config"));
    }
  });
}

flutter::EncodableMap FirebaseRemoteConfigPlugin::get_all_(
    const flutter::EncodableValue* arguments) const {
  const auto& args = try_get_arguments_(arguments);

  if (!args) {
    throw FirebaseRemoteConfigException("Cannot decode arguments");
  }

  const auto app_name = get_app_name_(args);

  const auto firebaseApp = ::firebase::App::GetInstance(app_name.c_str());
  const auto remote_config = RemoteConfig::GetInstance(firebaseApp);

  const auto get_all = remote_config->GetAll();
  //
  auto all_mapped = map_parameters_(get_all, remote_config);

  return all_mapped;
}
}  // namespace firebase_remote_config_windows
