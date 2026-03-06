// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

public class FirebaseAIPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if canImport(FlutterMacOS)
      let messenger = registrar.messenger
    #else
      let messenger = registrar.messenger()
    #endif

    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/firebase_ai",
      binaryMessenger: messenger
    )
    let instance = FirebaseAIPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformHeaders":
      var headers: [String: String] = [:]
      if let bundleId = Bundle.main.bundleIdentifier {
        headers["x-ios-bundle-identifier"] = bundleId
      }
      result(headers)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
