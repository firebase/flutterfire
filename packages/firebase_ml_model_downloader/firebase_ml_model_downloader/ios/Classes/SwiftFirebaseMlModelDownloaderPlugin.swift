// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit
import FirebaseMLModelDownloader
import firebase_core
import FirebaseCore

let kFLTFirebaseMlModelDownloaderChannelName = "plugins.flutter.io/firebase_ml_model_downloader";
let kDefaultAppName = "[DEFAULT]"

let kAppNameArg = "appName"
let kModelNameArg = "modelName"
let kDownloadTypeArg = "downloadType"
let kConditionsArg = "conditions"

public class SwiftFirebaseMlModelDownloaderPlugin: FLTFirebasePlugin, FlutterPlugin {
  var result:FLTFirebaseMethodCallResult?;
  // MARK: - FlutterPlugin
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: kFLTFirebaseMlModelDownloaderChannelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFirebaseMlModelDownloaderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  internal func mapErrorCodes(error:Error) -> NSString {
        switch error {
        case DownloadError.notFound:
            return "no-existing-model"
          case DownloadError.permissionDenied:
            return "permission-denied"
          case DownloadError.notFound:
            return "server-unreachable"
          case DownloadError.failedPrecondition:
            return "failed-precondition"
            // TODO - this needs testing
          case DownloadedModelError.fileIOError(description: ""):
            return "file-io-error"
          case DownloadedModelError.internalError(description: ""):
            return "internal-error"
        default:
            return "unknown";
        }
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    let errorBlock:FLTFirebaseMethodCallErrorBlock = { (code, message, details, error:Error?) in
                var errorDetails:Dictionary = Dictionary<String, Any?>();
                
                errorDetails["code"] = code ?? self.mapErrorCodes(error:error! as NSError)
                errorDetails["message"] = message ?? error?.localizedDescription ?? "An unknown error has occurred.";
                errorDetails["additionalData"] = details ?? [AnyHashable : Any]()
                errorDetails["additionalData"] = details ?? ["code": errorDetails["code"], "message": errorDetails["message"]]
                
                if(code == "unknown") {
                    NSLog("FLTFirebaseMlModelDownloader: An error occured while calling method %@", call.method)
                }
                
                result(FLTFirebasePlugin.createFlutterError(fromCode: errorDetails["code"] as! String,
                                                            message: errorDetails["message"] as! String,
                                                            optionalDetails: (errorDetails["additionalData"] as! [AnyHashable:Any]),
                                                            andOptionalNSError: nil))
            };

    self.result = .create(success: result, andErrorBlock: errorBlock)
    
    if ("FirebaseMlModelDownloader#getModel" == call.method) {
      self.getModel(arguments: call.arguments as! Dictionary<String, Any>)
    }
    if("FirebaseMlModelDownloader#listDownloadedModels" == call.method){
      self.listDownloadedModels(arguments: call.arguments as! Dictionary<String, Any>)
    }
    if("FirebaseMlModelDownloader#deleteDownloadedModel" == call.method){
      self.deleteDownloadedModel(arguments: call.arguments as! Dictionary<String, Any>)
    }
  }
  
  
  // MARK: - Firebase Ml Model Downloader API
  
  internal func listDownloadedModels(arguments: Dictionary<String, Any>) -> Void {
    let modelDownloader = getMlModelInstance(arguments: arguments)
    
    modelDownloader?.listDownloadedModels(){ response in
      switch(response){
        case .success(let customModel):
          let responseList: [[String: Any]] = customModel.map {
            return [
              "filePath": $0.path,
              "size": $0.size,
              "hash": $0.hash,
              "name": $0.name
            ]
          }
          self.result!.success(responseList)
          return;
        case  .failure(let error):
          self.result!.error(nil, nil, nil, error)
          return;
      }
      
    }
  }

  internal func getModel(arguments: Dictionary<String, Any>) -> Void {
    let modelDownloader = getMlModelInstance(arguments: arguments)
    let modelName = arguments[kModelNameArg] as! String
    let downloadType = arguments[kDownloadTypeArg] as! String
    let conditions = arguments[kConditionsArg] as! Dictionary<String, Bool>
    
    let cellularAccess = conditions["iOSAllowsCellularAccess"]!
    var downloadTypeEnum: ModelDownloadType = ModelDownloadType.localModel;
    if(downloadType == "local"){
      downloadTypeEnum = ModelDownloadType.localModel
    }
    if(downloadType == "local_background"){
      downloadTypeEnum = ModelDownloadType.localModelUpdateInBackground
    }
    if(downloadType == "latest"){
      downloadTypeEnum = ModelDownloadType.latestModel
    }
    
    let modelDownloadConditions = ModelDownloadConditions.init(allowsCellularAccess: cellularAccess)
    
    modelDownloader?.getModel(name: modelName, downloadType: downloadTypeEnum, conditions: modelDownloadConditions) { response in
      switch (response) {
      case .success(let customModel):
          let responseDict: [String:Any] = [
            "filePath": customModel.path,
            "size": customModel.size,
            "hash": customModel.hash,
            "name": customModel.name
          ]
          
          self.result!.success(responseDict)
          return
      case .failure(let error):
          self.result!.error(nil, nil, nil, error)
          return
      }
}
  }
  
  internal func deleteDownloadedModel(arguments: Dictionary<String, Any>) -> Void {
    let modelDownloader = getMlModelInstance(arguments: arguments)
    let modelName = arguments[kModelNameArg]
    
    modelDownloader?.deleteDownloadedModel(name: modelName as! String) { response in
      switch(response){
        case .success():
          self.result!.success(nil)
          return
        case .failure(let error):
          self.result!.error(nil, nil, nil, error)
          return
      }
    }
  }
  
  // MARK: - Utilities

  internal func getMlModelInstance(arguments: Dictionary<String, Any>) -> ModelDownloader? {
    let appName = arguments[kAppNameArg] as! String
      if appName == kDefaultAppName {
        return ModelDownloader.modelDownloader()
      } else {
        let app = FirebaseApp.app(name: appName)
        return ModelDownloader.modelDownloader(app: app!)
      }
  }
}
