// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseDatabase
import FirebaseCore
import Flutter
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

let kFLTFirebaseDatabaseChannelName = "plugins.flutter.io/firebase_database"

@objc(FLTFirebaseDatabasePlugin) public class FLTFirebaseDatabasePlugin: NSObject, FlutterPlugin, FLTFirebasePluginProtocol {
    private var binaryMessenger: FlutterBinaryMessenger
    private var streamHandlers: [String: FLTFirebaseDatabaseObserveStreamHandler] = [:]
    private var channel: FlutterMethodChannel
    private var listenerCount: Int = 0
    
    init(messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        self.binaryMessenger = messenger
        self.channel = channel
        super.init()
    }
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: kFLTFirebaseDatabaseChannelName,
            binaryMessenger: registrar.messenger()
        )
        
        let instance = FLTFirebaseDatabasePlugin(
            messenger: registrar.messenger(),
            channel: channel
        )
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        FLTFirebasePluginRegistry.sharedInstance().register(instance)
        
        #if !targetEnvironment(macCatalyst)
        registrar.publish(instance)
        #endif
    }
    
    func cleanup(completion: (() -> Void)? = nil) {
        for (_, handler) in streamHandlers {
            handler.onCancel(withArguments: nil)
        }
        streamHandlers.removeAll()
        completion?()
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        cleanup()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let errorBlock: FLTFirebaseMethodCallErrorBlock = { [weak self] code, message, details, error in
            var finalCode = code
            var finalMessage = message
            var finalDetails = details
            
            if code == nil {
                let codeAndErrorMessage = FLTFirebaseDatabaseUtils.codeAndMessage(from: error)
                finalCode = codeAndErrorMessage[0]
                finalMessage = codeAndErrorMessage[1]
                finalDetails = [
                    "code": finalCode ?? "",
                    "message": finalMessage ?? ""
                ]
            }
            
            if finalCode == "unknown" {
                print("FLTFirebaseDatabase: An error occurred while calling method \(call.method)")
            }
            
            let flutterError = FlutterError(
                code: finalCode ?? "unknown",
                message: finalMessage ?? "Unknown error",
                details: finalDetails
            )
            result(flutterError)
        }
        
        let methodCallResult = FLTFirebaseMethodCallResult.create(
            success: result,
            andErrorBlock: errorBlock
        )
        
        switch call.method {
        case "FirebaseDatabase#goOnline":
            databaseGoOnline(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "FirebaseDatabase#goOffline":
            databaseGoOffline(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "FirebaseDatabase#purgeOutstandingWrites":
            databasePurgeOutstandingWrites(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "DatabaseReference#set":
            databaseSet(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "DatabaseReference#setWithPriority":
            databaseSetWithPriority(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "DatabaseReference#update":
            databaseUpdate(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "DatabaseReference#setPriority":
            databaseSetPriority(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "DatabaseReference#runTransaction":
            databaseRunTransaction(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "OnDisconnect#set":
            onDisconnectSet(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "OnDisconnect#setWithPriority":
            onDisconnectSetWithPriority(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "OnDisconnect#update":
            onDisconnectUpdate(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "OnDisconnect#cancel":
            onDisconnectCancel(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "Query#get":
            queryGet(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "Query#keepSynced":
            queryKeepSynced(arguments: call.arguments, withMethodCallResult: methodCallResult)
        case "Query#observe":
            queryObserve(arguments: call.arguments, withMethodCallResult: methodCallResult)
        default:
            methodCallResult.success(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - FLTFirebasePlugin
    
    public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
        cleanup()
        completion()
    }
    
    public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
        return [:]
    }
    
    @objc public func firebaseLibraryName() -> String {
        return "flutter-fire-rtdb"
    }
    
    @objc public func firebaseLibraryVersion() -> String {
        return "12.0.1"
    }
    
    @objc public func flutterChannelName() -> String {
        return kFLTFirebaseDatabaseChannelName
    }
    
    // MARK: - Database API
    
    private func databaseGoOnline(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let database = FLTFirebaseDatabaseUtils.database(from: args)
        database.goOnline()
        result.success(nil)
    }
    
    private func databaseGoOffline(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let database = FLTFirebaseDatabaseUtils.database(from: args)
        database.goOffline()
        result.success(nil)
    }
    
    private func databasePurgeOutstandingWrites(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let database = FLTFirebaseDatabaseUtils.database(from: args)
        database.purgeOutstandingWrites()
        result.success(nil)
    }
    
    private func databaseSet(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        let value = args["value"]
        
        reference.setValue(value) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func databaseSetWithPriority(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        let value = args["value"]
        let priority = args["priority"]
        
        reference.setValue(value, andPriority: priority) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func databaseUpdate(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let values = args["value"] as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        
        reference.updateChildValues(values) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func databaseSetPriority(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        let priority = args["priority"]
        
        reference.setPriority(priority) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func databaseRunTransaction(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let transactionKey = args["transactionKey"] as? Int else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        let applyLocally = args["transactionApplyLocally"] as? Bool ?? false
        
        reference.runTransactionBlock { currentData in
            let semaphore = DispatchSemaphore(value: 0)
            var aborted = false
            var exception = false
            
            let methodCallResultHandler: (Any?) -> Void = { transactionResult in
                if let resultDict = transactionResult as? [String: Any] {
                    aborted = resultDict["aborted"] as? Bool ?? false
                    exception = resultDict["exception"] as? Bool ?? false
                    currentData.value = resultDict["value"]
                }
                semaphore.signal()
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.channel.invokeMethod(
                    "FirebaseDatabase#callTransactionHandler",
                    arguments: [
                        "transactionKey": transactionKey,
                        "snapshot": [
                            "key": currentData.key ?? "",
                            "value": currentData.value ?? ""
                        ]
                    ],
                    result: methodCallResultHandler
                )
            }

            semaphore.wait()

            if aborted || exception {
                return TransactionResult.abort()
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else if let snapshot = snapshot {
                let snapshotDict = FLTFirebaseDatabaseUtils.dictionary(from: snapshot)
                result.success([
                    "committed": committed,
                    "snapshot": snapshotDict
                ])
            }
        }
    }

    private func onDisconnectSet(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        let value = args["value"]
        
        reference.onDisconnectSetValue(value) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func onDisconnectSetWithPriority(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        let value = args["value"]
        let priority = args["priority"]
        
        reference.onDisconnectSetValue(value, andPriority: priority) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func onDisconnectUpdate(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let values = args["value"] as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        
        reference.onDisconnectUpdateChildValues(values) { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func onDisconnectCancel(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let reference = FLTFirebaseDatabaseUtils.databaseReference(from: args)
        
        reference.cancelDisconnectOperations { error, _ in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(nil)
            }
        }
    }
    
    private func queryGet(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any] else { return }
        let query = FLTFirebaseDatabaseUtils.databaseQuery(from: args)
        
        query.getData { error, snapshot in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else if let snapshot = snapshot {
                let snapshotDict = FLTFirebaseDatabaseUtils.dictionary(from: snapshot)
                result.success(["snapshot": snapshotDict])
            }
        }
    }
    
    private func queryKeepSynced(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let value = args["value"] as? Bool else { return }
        let query = FLTFirebaseDatabaseUtils.databaseQuery(from: args)
        query.keepSynced(value)
        result.success(nil)
    }
    
    private func queryObserve(arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let eventChannelNamePrefix = args["eventChannelNamePrefix"] as? String else { return }
        
        let databaseQuery = FLTFirebaseDatabaseUtils.databaseQuery(from: args)
        listenerCount += 1
        let eventChannelName = "\(eventChannelNamePrefix)#\(listenerCount)"
        
        let eventChannel = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: binaryMessenger
        )
        
        let streamHandler = FLTFirebaseDatabaseObserveStreamHandler(
            databaseQuery: databaseQuery,
            disposeBlock: { [weak self] in
                eventChannel.setStreamHandler(nil)
            }
        )
        
        eventChannel.setStreamHandler(streamHandler)
        streamHandlers[eventChannelName] = streamHandler
        result.success(eventChannelName)
    }
}
