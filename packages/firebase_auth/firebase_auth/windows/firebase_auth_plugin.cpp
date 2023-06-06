#include "firebase_auth_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "messages.g.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace firebase_auth {

// static
void FirebaseAuthPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<FirebaseAuthPlugin>();


  registrar->AddPlugin(std::move(plugin));

FirebaseAuthPlugin::FirebaseAuthPlugin() {}

FirebaseAuthPlugin::~FirebaseAuthPlugin() = default;


}  // namespace firebase_auth
