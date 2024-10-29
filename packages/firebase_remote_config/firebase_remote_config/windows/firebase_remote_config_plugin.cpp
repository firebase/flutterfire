#include "firebase_remote_config_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
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
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>

// #include "messages.g.h"
// #include "remote_config_pigeon_implemetation.h"

using namespace firebase::remote_config;

extern "C" firebase_core_windows::FirebasePluginRegistry *
GetFlutterFirebaseRegistry();

namespace firebase_remote_config_windows {
    const char *kEventChannelName =
            "plugins.flutter.io/firebase_remote_config_updated";
    const char *kMethodChannelName = "plugins.flutter.io/firebase_remote_config";
    const char *kRemoteConfigLibrary = "firebase_remote_config_windows";
    std::unique_ptr <flutter::EventSink<flutter::EncodableValue>> sink_;

    void FirebaseRemoteConfigPlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarWindows *registrar) {
        auto plugin = std::make_unique<FirebaseRemoteConfigPlugin>();

        // const auto firebase_registry =
        // firebase_core_windows::FirebasePluginRegistry::GetInstance(); const auto
        // shared_plugin = std::make_shared<FirebaseRemoteConfigImplementation>();

        // ::firebase::App::RegisterLibrary(kRemoteConfigLibrary,
        // getPluginVersion().c_str(), nullptr);
        // firebase_registry->put_plugin_ref(shared_plugin);

        // const auto impl = new remote_config_pigeon_implemetation();
        // RemoteConfigHostApi::SetUp(registrar->messenger(), impl);

        const auto method_channel =
                std::make_unique < flutter::MethodChannel < flutter::EncodableValue >> (
                        registrar->messenger(), kMethodChannelName,
                                &flutter::StandardMethodCodec::GetInstance());

        method_channel->SetMethodCallHandler(
                [plugin_pointer = plugin.get()](const auto &call, auto result) {
                    plugin_pointer->HandleMethodCall(call, std::move(result));
                });

        const auto firebase_registry = firebase_core_windows::FirebasePluginRegistry::GetInstance();
        const auto shared_plugin = std::make_shared<FlutterFirebaseRemoteConfigPlugin>();
        ::firebase::App::RegisterLibrary(kRemoteConfigLibrary, getPluginVersion().c_str(), nullptr);
        firebase_registry->put_plugin_ref(shared_plugin);

        // const auto event_channel =
        // std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
        //     registrar->messenger(), kEventChannelName,
        //     &flutter::StandardMethodCodec::GetInstance());

        // auto eventChannelHandler =
        // std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>([&](const
        // flutter::EncodableValue* arguments,
        //     std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
        //     sink)->std::unique_ptr < flutter::StreamHandlerError <
        //     flutter::EncodableValue >>
        //     {
        //         //sink_ = std::move(sink);
        //         const auto firebaseApp =
        //         ::firebase::App::GetInstance(firebase_core_windows::FirebasePluginRegistry::GetInstance()->app_name.c_str());
        //         const auto remoteConfig =
        //         ::firebase::remote_config::RemoteConfig::GetInstance(firebaseApp);
        //         auto registration = remoteConfig->AddOnConfigUpdateListener([&sink,
        //         this](ConfigUpdate&& config_update, RemoteConfigError error)
        //             {
        //                 const auto updatedKeys = config_update.updated_keys;
        //                 flutter::EncodableList keys{};

        //                 for (const auto& key : updatedKeys)
        //                 {
        //                     keys.push_back(flutter::EncodableValue(key));
        //                 }
        //                 sink->Success(flutter::EncodableValue(keys));
        //             });

        //         return nullptr;
        //     },
        //     [](const flutter::EncodableValue* arguments) ->std::unique_ptr <
        //     flutter::StreamHandlerError < flutter::EncodableValue >>
        //     {
        //         return nullptr;
        //     });

        // event_channel->SetStreamHandler(std::move(eventChannelHandler));

        // // method_channel->SetMethodCallHandler([plugin_pointer =
        // plugin.get()](const auto& call, auto result)
        // //     {
        // //         plugin_pointer->HandleMethodCall(call, std::move(result));
        // //     });

        registrar->AddPlugin(std::move(plugin));
    }

    FirebaseRemoteConfigPlugin::FirebaseRemoteConfigPlugin() {}

    FirebaseRemoteConfigPlugin::~FirebaseRemoteConfigPlugin() {}

    void FirebaseRemoteConfigPlugin::HandleMethodCall(
            const flutter::MethodCall <flutter::EncodableValue> &method_call,
            std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result) {
        int iii = 0;
        std::cout << iii << std::endl;
        std::cout << "Method call: " << method_call.method_name() << std::endl;

        if (method_call.method_name() == "RemoteConfig#setConfigSettings") {
          try {
            const auto &args =
                std::get<flutter::EncodableList>(*method_call.arguments());
            const auto &encodable_app_name_arg = args.at(0);
            if (encodable_app_name_arg.IsNull()) {
              result->Error("RemoteConfig#setConfigSettings",
                            "Cannot decode app name");
              return;
            }
            const auto &app_name_arg =
                std::get<std::string>(encodable_app_name_arg);
            const auto &encodable_fetch_timeout_arg = args.at(1);
            if (encodable_fetch_timeout_arg.IsNull()) {
              result->Error("RemoteConfig#setConfigSettings", "Cannot decode timeout");
              return;
            }
            const int64_t fetch_timeout_arg =
                encodable_fetch_timeout_arg.LongValue();
            const auto &encodable_minimum_fetch_interval_arg = args.at(2);
            if (encodable_minimum_fetch_interval_arg.IsNull()) {
              result->Error("RemoteConfig#setConfigSettings", "Cannot decode minimum fetch interval");
              return;
            }
            const int64_t minimum_fetch_interval_arg =
                encodable_minimum_fetch_interval_arg.LongValue();

            const auto firebaseApp = ::firebase::App::GetInstance(app_name_arg.c_str());
            const auto remoteConfig = ::firebase::remote_config::RemoteConfig::GetInstance(firebaseApp);

            const ConfigSettings config_setting{
                static_cast<uint64_t>(fetch_timeout_arg),
                static_cast<uint64_t>(minimum_fetch_interval_arg)};

            remoteConfig->SetConfigSettings(config_setting);

            result->Success();

          } catch (const std::exception &e) {
            result->Error("RemoteConfig#setConfigSettings", e.what());
          }
        }

        result->NotImplemented();
        // if (method_call.method_name().compare("getPlatformVersion") == 0)
        // {
        //     std::ostringstream version_stream;
        //     version_stream << "Windows ";
        //     if (IsWindows10OrGreater())
        //     {
        //         version_stream << "10+";
        //     }
        //     else if (IsWindows8OrGreater())
        //     {
        //         version_stream << "8";
        //     }
        //     else if (IsWindows7OrGreater())
        //     {
        //         version_stream << "7";
        //     }
        //     result->Success(flutter::EncodableValue(version_stream.str()));
        // }
        // else if
        // (method_call.method_name().compare("RemoteConfig#ensureInitialized"))
        // {
        //     int ii = 0;
        //     // const auto app_name =
        //     std::get<flutter::EncodableList>(method_call.arguments());
        //     // const auto firebaseApp =
        //     ::firebase::App::GetInstance(app_name.c_str());
        //     // const auto remoteConfig =
        //     ::firebase::remote_config::RemoteConfig::GetInstance(firebaseApp);
        //     // auto registration = remoteConfig->AddOnConfigUpdateListener([&sink_,
        //     this](ConfigUpdate&& config_update, RemoteConfigError error)
        //     // {
        //     //                        const auto updatedKeys =
        //     config_update.updated_keys;
        //     //         flutter::EncodableList keys{};
        //     //
        //     //         for (const auto& key : updatedKeys)
        //     //         {
        //     // keys.push_back(flutter::EncodableValue(key));
        //     //         }
        //     //         sink_->Success(flutter::EncodableValue(keys));
        //     //     });
        // }
        // else
        // {
        //     result->NotImplemented();
        // }
    }
}  // namespace firebase_remote_config_windows
