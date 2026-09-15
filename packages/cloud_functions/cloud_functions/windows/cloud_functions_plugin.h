// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef FLUTTER_PLUGIN_CLOUD_FUNCTIONS_PLUGIN_H_
#define FLUTTER_PLUGIN_CLOUD_FUNCTIONS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "messages.g.h"

namespace cloud_functions_windows {

class CloudFunctionsPlugin : public flutter::Plugin,
                             public CloudFunctionsHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  CloudFunctionsPlugin();

  virtual ~CloudFunctionsPlugin();

  // Disallow copy and assign.
  CloudFunctionsPlugin(const CloudFunctionsPlugin&) = delete;
  CloudFunctionsPlugin& operator=(const CloudFunctionsPlugin&) = delete;

  // CloudFunctionsHostApi
  void Call(
      const flutter::EncodableMap& arguments,
      std::function<void(ErrorOr<std::optional<flutter::EncodableValue>> reply)>
          result) override;
  void RegisterEventChannel(
      const flutter::EncodableMap& arguments,
      std::function<void(std::optional<FlutterError> reply)> result) override;
};

}  // namespace cloud_functions_windows

#endif  // FLUTTER_PLUGIN_CLOUD_FUNCTIONS_PLUGIN_H_
