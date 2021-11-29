// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit
import FirebaseMLModelDownloader
import FirebaseCore

let kFLTFirebaseMlModelDownloaderChannelName = "plugins.flutter.io/firebase_ml_model_downloader";
let kDefaultAppName = "[DEFAULT]"

let kAppNameArg = "appName"
let kModelNameArg = "modelName"
let kDownloadTypeArg = "downloadType"
let kConditionsArg = "conditions"

public class SwiftFirebaseMlModelDownloaderPlugin: NSObject, FlutterPlugin {
  
  // MARK: - FlutterPlugin
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: kFLTFirebaseMlModelDownloaderChannelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFirebaseMlModelDownloaderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    if ("FirebaseMlModelDownloader#getModel" == call.method) {
      self.getModel(arguments: call.arguments as! Dictionary<String, Any>, result: result)
    }
    if("FirebaseMlModelDownloader#listDownloadedModels" == call.method){
      self.listDownloadedModels(arguments: call.arguments as! Dictionary<String, Any>, result: result)
    }
    if("FirebaseMlModelDownloader#deleteDownloadedModel" == call.method){
      self.deleteDownloadedModel(arguments: call.arguments as! Dictionary<String, Any>, result: result)
    }
  }
  
  
  // MARK: - Firebase Ml Model Downloader API
  
  public func listDownloadedModels(arguments: Dictionary<String, Any>, result: @escaping FlutterResult) -> Void {
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
          result(responseList)
          return;
        case  .failure(let error):
          //TODO - proper error handling
          result(FlutterError(code: "unsuccessful-list-models", message: error.localizedDescription, details: {}))
          return;
      }
      
    }
  }

  public func getModel(arguments: Dictionary<String, Any>, result: @escaping FlutterResult) -> Void {
    let modelDownloader = getMlModelInstance(arguments: arguments)
    let modelName = arguments[kModelNameArg]
    let downloadType = arguments[kDownloadTypeArg]
    let conditions = arguments[kConditionsArg]
    modelDownloader?.getModel(name: modelName as! String, downloadType: downloadType as! ModelDownloadType, conditions: conditions as! ModelDownloadConditions) { response in
      switch (response) {
      case .success(let customModel):
          let responseDict: [String:Any] = [
            "filePath": customModel.path,
            "size": customModel.size,
            "hash": customModel.hash,
            "name": customModel.name
          ]
          
          result(responseDict)
          return
      case .failure(let error):
          //TODO - proper error handling
          result(FlutterError(code: "unsuccessful-get-model", message: error.localizedDescription, details: {}))
          return
      }
}
  }
  
  public func deleteDownloadedModel(arguments: Dictionary<String, Any>, result: @escaping FlutterResult) -> Void {
    let modelDownloader = getMlModelInstance(arguments: arguments)
    let modelName = arguments[kModelNameArg]
    
    modelDownloader?.deleteDownloadedModel(name: modelName as! String) { response in
      switch(response){
        case .success():
          result(nil)
          return
        case .failure(let error):
          //TODO - proper error handling
          result(FlutterError(code: "unsuccessful-delete-model", message: error.localizedDescription, details: {}))
          return
      }
    }
  }
  
  // MARK: - Utilities

  public func getMlModelInstance(arguments: Dictionary<String, Any>) -> ModelDownloader? {
    let appName = String(describing: arguments[kAppNameArg])
    
      if appName == kDefaultAppName {
        return ModelDownloader.modelDownloader()
      } else {
        let app = FirebaseApp.app(name: appName)
        return ModelDownloader.modelDownloader(app: app!)
      }
  }
}
