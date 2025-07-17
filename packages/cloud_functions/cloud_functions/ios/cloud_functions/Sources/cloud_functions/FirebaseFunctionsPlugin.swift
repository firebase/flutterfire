// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif
import FirebaseFunctions

extension FlutterError: Error {}

let kFLTFirebaseFunctionsChannelName = "plugins.flutter.io/firebase_functions"

public class FirebaseFunctionsPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  CloudFunctionsHostApi {
  func call(arguments: [String: Any?], completion: @escaping (Result<Any?, any Error>) -> Void) {
    httpsFunctionCall(arguments: arguments) { result, error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(result))
      }
    }
  }

  func registerEventChannel(arguments: [String: Any],
                            completion: @escaping (Result<Void, any Error>) -> Void) {
    let eventChannelId = arguments["eventChannelId"]!
    let eventChannelName = "\(kFLTFirebaseFunctionsChannelName)/\(eventChannelId)"
    let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: binaryMessenger)
    let functions = getFunctions(arguments: arguments)
    let streamHandler = FunctionsStreamHandler(functions: functions)
    eventChannel.setStreamHandler(streamHandler)
    completion(.success(()))
  }

  private let binaryMessenger: FlutterBinaryMessenger

  init(binaryMessenger: FlutterBinaryMessenger) {
    self.binaryMessenger = binaryMessenger
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  @objc public func firebaseLibraryName() -> String {
    "flutter-fire-fn"
  }

  @objc public func flutterChannelName() -> String {
    kFLTFirebaseFunctionsChannelName
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger
    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseFunctionsPlugin(binaryMessenger: binaryMessenger)
    CloudFunctionsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  private func httpsFunctionCall(arguments: [String: Any],
                                 completion: @escaping (Any?, FlutterError?) -> Void) {
    let appName = arguments["appName"] as? String ?? ""
    let functionName = arguments["functionName"] as? String
    let functionUri = arguments["functionUri"] as? String
    let origin = arguments["origin"] as? String
    let region = arguments["region"] as? String
    let timeout = arguments["timeout"] as? Double
    let parameters = arguments["parameters"]
    let limitedUseAppCheckToken = arguments["limitedUseAppCheckToken"] as? Bool ?? false

    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!

    let functions = Functions.functions(app: app, region: region ?? "")

    if let origin, !origin.isEmpty,
       let url = URL(string: origin),
       let host = url.host,
       let port = url.port {
      functions.useEmulator(withHost: host, port: port)
    }

    let options = HTTPSCallableOptions(requireLimitedUseAppCheckTokens: limitedUseAppCheckToken)

    let function: HTTPSCallable

    if let functionName, !functionName.isEmpty {
      function = functions.httpsCallable(functionName, options: options)
    } else if let functionUri, !functionUri.isEmpty,
              let url = URL(string: functionUri) {
      function = functions.httpsCallable(url, options: options)
    } else {
      completion(nil, FlutterError(
        code: "IllegalArgumentException",
        message: "Either functionName or functionUri must be set",
        details: nil
      ))
      return
    }

    // Set timeout if provided
    if let timeout {
      function.timeoutInterval = timeout / 1000
    }

    function.call(parameters) { result, error in
      if let error {
        let flutterError = self.createFlutterError(from: error)
        completion(nil, flutterError)
      } else {
        completion(result?.data, nil)
      }
    }
  }

  private func getFunctions(arguments: [String: Any]) -> Functions {
    let appName = arguments["appName"] as? String ?? ""
    let region = arguments["region"] as? String
    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!
    return Functions.functions(app: app, region: region ?? "")
  }

  private func createFlutterError(from error: Error) -> FlutterError {
    let nsError = error as NSError
    var errorCode = "unknown"
    var additionalDetails: [String: Any] = [:]

    // Map Firebase Functions error codes
    if nsError.domain == "com.firebase.functions" {
      errorCode = mapFunctionsErrorCode(nsError.code)
      if let details = nsError.userInfo["details"] {
        additionalDetails["additionalData"] = details
      }
    }

    additionalDetails["code"] = errorCode
    additionalDetails["message"] = nsError.localizedDescription

    return FlutterError(
      code: errorCode,
      message: nsError.localizedDescription,
      details: additionalDetails
    )
  }

  private func mapFunctionsErrorCode(_ code: Int) -> String {
    switch code {
    case FunctionsErrorCode.aborted.rawValue: return "aborted"
    case FunctionsErrorCode.alreadyExists.rawValue: return "already-exists"
    case FunctionsErrorCode.cancelled.rawValue: return "cancelled"
    case FunctionsErrorCode.dataLoss.rawValue: return "data-loss"
    case FunctionsErrorCode.deadlineExceeded.rawValue: return "deadline-exceeded"
    case FunctionsErrorCode.failedPrecondition.rawValue: return "failed-precondition"
    case FunctionsErrorCode.internal.rawValue: return "internal"
    case FunctionsErrorCode.invalidArgument.rawValue: return "invalid-argument"
    case FunctionsErrorCode.notFound.rawValue: return "not-found"
    case FunctionsErrorCode.OK.rawValue: return "ok"
    case FunctionsErrorCode.outOfRange.rawValue: return "out-of-range"
    case FunctionsErrorCode.permissionDenied.rawValue: return "permission-denied"
    case FunctionsErrorCode.resourceExhausted.rawValue: return "resource-exhausted"
    case FunctionsErrorCode.unauthenticated.rawValue: return "unauthenticated"
    case FunctionsErrorCode.unavailable.rawValue: return "unavailable"
    case FunctionsErrorCode.unimplemented.rawValue: return "unimplemented"
    default: return "unknown"
    }
  }
}
