// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

import FirebaseFunctions

class FunctionsStreamHandler: NSObject, FlutterStreamHandler {
  var functions: Functions
  private var streamTask: Task<Void, Never>?

  init(functions: Functions) {
    self.functions = functions
    super.init()
  }

  func onListen(withArguments arguments: Any?,
                eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    streamTask = Task {
      await httpsStreamCall(arguments: arguments, events: events)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    streamTask?.cancel()
    return nil
  }

  private func httpsStreamCall(arguments: Any?, events: @escaping FlutterEventSink) async {
    guard let arguments = arguments as? [String: Any] else {
      await MainActor.run {
        events(FlutterError(code: "invalid_arguments",
                            message: "Invalid arguments",
                            details: nil))
      }
      return
    }
    let functionName = arguments["functionName"] as? String
    let functionUri = arguments["functionUri"] as? String
    let origin = arguments["origin"] as? String
    let parameters = arguments["arguments"]

    if let origin,
       let url = URL(string: origin),
       let host = url.host,
       let port = url.port {
      functions.useEmulator(withHost: host, port: port)
    }

    // Stream handling for iOS 15+
    if #available(iOS 15.0, *) {
      let function: Callable<AnyEncodable, StreamResponse<AnyDecodable, AnyDecodable>>

      if let functionName {
        function = self.functions.httpsCallable(functionName)
      } else if let functionUri, let url = URL(string: functionUri) {
        function = self.functions.httpsCallable(url)
      } else {
        await MainActor.run {
          events(FlutterError(code: "IllegalArgumentException",
                              message: "Either functionName or functionUri must be set",
                              details: nil))
        }
        return
      }

      do {
        let encodedParameters = AnyEncodable(parameters)

        let stream = try function.stream(encodedParameters)

        for try await response in stream {
          await MainActor.run {
            switch response {
            case let .message(message):
              var wrappedMessage: [String: Any?] = ["message": message.value]
              events(wrappedMessage)
            case let .result(result):
              var wrappedResult: [String: Any?] = ["result": result.value]
              events(wrappedResult)
            }
          }
        }
      } catch {
        await MainActor.run {
          events(FlutterError(code: "unknown",
                              message: error.localizedDescription,
                              details: ["code": "unknown", "message": error.localizedDescription]))
        }
      }
    } else {
      await MainActor.run {
        events(FlutterError(code: "unknown",
                            message: "Streaming requires iOS 15+",
                            details: nil))
      }
    }
  }
}
