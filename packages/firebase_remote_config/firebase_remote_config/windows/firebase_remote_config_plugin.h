/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
#define FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_

#include <firebase/remote_config.h>
#include <firebase/variant.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "firebase_core/flutter_firebase_plugin.h"
#include "messages.g.h"

namespace firebase {
    namespace remote_config {
        struct ConfigKeyValueVariant;
    }
}

namespace firebase_remote_config_windows {

    class FirebaseRemoteConfigException : public std::exception {
    public:
        explicit FirebaseRemoteConfigException(std::string message)
                : message_(std::move(message)) {}

        const char *what() const

        noexcept override{return message_.c_str();}

    private:
        std::string message_;
    };

    class FirebaseRemoteConfigPlugin : public flutter::Plugin,
                                       public FirebaseRemoteConfigHostApi {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        FirebaseRemoteConfigPlugin();

        virtual ~FirebaseRemoteConfigPlugin();

        // Disallow copy and assign.
        FirebaseRemoteConfigPlugin(const FirebaseRemoteConfigPlugin &) = delete;

        FirebaseRemoteConfigPlugin &operator=(const FirebaseRemoteConfigPlugin &) =
        delete;

        // Called when a method is called on this plugin's channel from Dart.

        virtual void Fetch(
                const std::string &app_name,
                std::function<void(std::optional < FlutterError > reply)> result) override;

        virtual void FetchAndActivate(
                const std::string &app_name,
                std::function<void(ErrorOr<bool> reply)> result) override;

        virtual void Activate(
                const std::string &app_name,
                std::function<void(ErrorOr<bool> reply)> result) override;

        virtual void SetConfigSettings(
                const std::string& app_name,
                const RemoteConfigPigeonSettings& settings,
                std::function<void(std::optional<FlutterError> reply)> result) override;
        virtual void SetDefaults(
                const std::string& app_name,
                const flutter::EncodableMap& default_parameters,
                std::function<void(std::optional<FlutterError> reply)> result) override;
        virtual void EnsureInitialized(
                const std::string& app_name,
                std::function<void(std::optional<FlutterError> reply)> result) override;
        virtual void SetCustomSignals(
                const std::string& app_name,
                const flutter::EncodableMap& custom_signals,
                std::function<void(std::optional<FlutterError> reply)> result) override;
        virtual void GetAll(
                const std::string& app_name,
                std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) override;
        virtual void GetProperties(
                const std::string& app_name,
                std::function<void(ErrorOr<flutter::EncodableMap> reply)> result) override;

    private:
        // bool set_defaults_(const std::string &app_name,
        //                    const flutter::EncodableMap &args) const;
        std::vector <firebase::remote_config::ConfigKeyValueVariant> set_defaults_convert_to_native_(
                const flutter::EncodableMap &default_parameters) const;

        firebase::Variant set_defaults_to_variant_(flutter::EncodableValue encodableValue) const;

        std::string map_last_fetch_status_(firebase::remote_config::LastFetchStatus lastFetchStatus) const;

        flutter::EncodableMap *try_get_arguments_(const flutter::EncodableValue *arguments) const;

        std::string get_app_name_(flutter::EncodableMap *encodable_map) const;

        std::string map_source_(firebase::remote_config::ValueSource source) const;

        flutter::EncodableMap create_remote_config_values_map_(
                std::string key, firebase::remote_config::RemoteConfig *remote_config) const;

        flutter::EncodableMap map_parameters_(
                std::map <std::string, firebase::Variant> parameters,
                firebase::remote_config::RemoteConfig *remote_config) const;
    };

}  // namespace firebase_remote_config_windows

#endif  // FLUTTER_PLUGIN_FIREBASE_REMOTE_CONFIG_PLUGIN_H_
