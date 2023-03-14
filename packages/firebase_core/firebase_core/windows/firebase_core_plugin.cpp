#include "firebase_core_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "firebase/app.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
using ::firebase::App;

namespace firebase_core {

// static
void FirebaseCorePlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "firebase_core",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FirebaseCorePlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FirebaseCorePlugin::FirebaseCorePlugin() {}

FirebaseCorePlugin::~FirebaseCorePlugin() {}

void FirebaseCorePlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    App *app = App::Create();
    std::cout << static_cast<int>(reinterpret_cast<intptr_t>(app));
    std::ostringstream version_stream;
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace firebase_core
