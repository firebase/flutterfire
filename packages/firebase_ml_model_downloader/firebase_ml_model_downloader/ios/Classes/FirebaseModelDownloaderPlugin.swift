// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

import FirebaseCore
import FirebaseMLModelDownloader

import firebase_core

let kFLTFirebaseModelDownloaderChannelName = "plugins.flutter.io/firebase_ml_model_downloader"

public class FirebaseModelDownloaderPluginSwift: FLTFirebasePlugin, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let channel = FlutterMethodChannel(
      name: kFLTFirebaseModelDownloaderChannelName,
      binaryMessenger: binaryMessenger
    )
    let instance = FirebaseModelDownloaderPluginSwift()
    registrar.addMethodCallDelegate(instance, channel: channel)
    #if os(iOS)
      registrar.publish(instance)
    #endif
  }

  internal func mapErrorCodes(error: Error) -> NSString {
    switch error {
    case DownloadError.notFound:
      return "no-existing-model"
    case DownloadError.permissionDenied:
      return "permission-denied"
    case DownloadError.notFound:
      return "server-unreachable"
    case DownloadError.failedPrecondition:
      return "failed-precondition"
    case DownloadedModelError.fileIOError:
      return "file-io-error"
    case DownloadedModelError.internalError:
      return "internal-error"
    default:
      return "unknown"
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let errorBlock: FLTFirebaseMethodCallErrorBlock = { (code, message, details, error: Error?) in
      var errorDetails = [String: Any?]()

      errorDetails["code"] = code ?? self.mapErrorCodes(error: error! as NSError)
      errorDetails["message"] = message ?? error?
        .localizedDescription ?? "An unknown error has occurred."
      errorDetails["additionalData"] = details ??
        ["code": errorDetails["code"], "message": errorDetails["message"]]

      if code == "unknown" {
        NSLog("FLTFirebaseModelDownloader: An error occurred while calling method %@", call.method)
      }

      result(FLTFirebasePlugin.createFlutterError(fromCode: errorDetails["code"] as! String,
                                                  message: errorDetails["message"] as! String,
                                                  optionalDetails: errorDetails[
                                                    "additionalData"
                                                  ] as? [AnyHashable: Any],
                                                  andOptionalNSError: nil))
    }

    let result = FLTFirebaseMethodCallResult.create(success: result, andErrorBlock: errorBlock)
    if call.method == "FirebaseModelDownloader#getModel" {
      getModel(arguments: call.arguments as! [String: Any], result: result)
    }
    if call.method == "FirebaseModelDownloader#listDownloadedModels" {
      listDownloadedModels(arguments: call.arguments as! [String: Any], result: result)
    }
    if call.method == "FirebaseModelDownloader#deleteDownloadedModel" {
      deleteDownloadedModel(arguments: call.arguments as! [String: Any], result: result)
    }
  }

  internal func listDownloadedModels(arguments: [String: Any],
                                     result: FLTFirebaseMethodCallResult) {
    let modelDownloader = modelDownloaderFromArguments(arguments: arguments)

    modelDownloader?.listDownloadedModels { response in
      switch response {
      case let .success(customModel):
        let responseList: [[String: Any]] = customModel.map {
          [
            "filePath": $0.path,
            "size": $0.size,
            "hash": $0.hash,
            "name": $0.name,
          ]
        }
        result.success(responseList)
      case let .failure(error):
        result.error(nil, nil, nil, error)
      }
    }
  }

  internal func getModel(arguments: [String: Any], result: FLTFirebaseMethodCallResult) {
    let modelDownloader = modelDownloaderFromArguments(arguments: arguments)
    let modelName = arguments["modelName"] as! String
    let downloadType = arguments["downloadType"] as! String
    let conditions = arguments["conditions"] as! [String: Bool]

    let cellularAccess = conditions["iosAllowsCellularAccess"]!
    var downloadTypeEnum = ModelDownloadType.localModel
    if downloadType == "local" {
      downloadTypeEnum = ModelDownloadType.localModel
    } else if downloadType == "local_background" {
      downloadTypeEnum = ModelDownloadType.localModelUpdateInBackground
    } else if downloadType == "latest" {
      downloadTypeEnum = ModelDownloadType.latestModel
    }

    let modelDownloadConditions = ModelDownloadConditions(allowsCellularAccess: cellularAccess)

    modelDownloader?.getModel(
      name: modelName,
      downloadType: downloadTypeEnum,
      conditions: modelDownloadConditions
    ) { response in
      switch response {
      case let .success(customModel):
        result.success([
          "filePath": customModel.path,
          "size": customModel.size,
          "hash": customModel.hash,
          "name": customModel.name,
        ])
      case let .failure(error):
        result.error(nil, nil, nil, error)
      }
    }
  }

  internal func deleteDownloadedModel(arguments: [String: Any],
                                      result: FLTFirebaseMethodCallResult) {
    let modelDownloader = modelDownloaderFromArguments(arguments: arguments)
    let modelName = arguments["modelName"]

    modelDownloader?.deleteDownloadedModel(name: modelName as! String) { response in
      switch response {
      case .success():
        result.success(nil)
      case let .failure(error):
        result.error(nil, nil, nil, error)
      }
    }
  }

  internal func modelDownloaderFromArguments(arguments: [String: Any]) -> ModelDownloader? {
    let app: FirebaseApp = FLTFirebasePlugin.firebaseAppNamed(arguments["appName"] as! String)!
    return ModelDownloader.modelDownloader(app: app)
  }
}
