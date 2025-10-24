// Copyright 2025 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseStorage
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

extension FlutterError: Error {}

public final class FLTFirebaseStoragePlugin: NSObject, FlutterPlugin, FirebaseStorageHostApi {
  private var channel: FlutterMethodChannel?
  private var messenger: FlutterBinaryMessenger?
  private var eventChannels: [String: FlutterEventChannel] = [:]
  private var streamHandlers: [String: FlutterStreamHandler] = [:]
  private var handleToTask: [Int64: AnyObject] = [:]
  private var handleToPath: [Int64: String] = [:]
  private var handleToIdentifier: [Int64: String] = [:]

  // Registry to help stream handler classify failure events as cancellations when initiated from
  // Dart
  static var canceledIdentifiers = Set<String>()

  @objc
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channelName = "plugins.flutter.io/firebase_storage"
    // Resolve platform-specific messenger API differences
    #if os(iOS)
      let resolvedMessenger: FlutterBinaryMessenger = registrar.messenger()
    #else
      let resolvedMessenger: FlutterBinaryMessenger = registrar.messenger
    #endif
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: resolvedMessenger)
    let instance = FLTFirebaseStoragePlugin()
    instance.channel = channel
    instance.messenger = resolvedMessenger
    registrar.addMethodCallDelegate(instance, channel: channel)
    FirebaseStorageHostApiSetup.setUp(binaryMessenger: resolvedMessenger, api: instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }

  private func storage(app: PigeonStorageFirebaseApp) -> Storage {
    let base = "gs://" + app.bucket
    let firApp = FLTFirebasePlugin.firebaseAppNamed(app.appName)!
    return Storage.storage(app: firApp, url: base)
  }

  private func ref(app: PigeonStorageFirebaseApp,
                   reference: PigeonStorageReference) -> StorageReference {
    storage(app: app).reference(withPath: reference.fullPath)
  }

  private func toPigeon(_ ref: StorageReference) -> PigeonStorageReference {
    PigeonStorageReference(bucket: ref.bucket, fullPath: ref.fullPath, name: ref.name)
  }

  func getReferencebyPath(app: PigeonStorageFirebaseApp, path: String, bucket: String?,
                          completion: @escaping (Result<PigeonStorageReference, Error>) -> Void) {
    let r = storage(app: app).reference(withPath: path)
    completion(.success(PigeonStorageReference(
      bucket: r.bucket,
      fullPath: r.fullPath,
      name: r.name
    )))
  }

  func setMaxOperationRetryTime(app: PigeonStorageFirebaseApp, time: Int64,
                                completion: @escaping (Result<Void, Error>) -> Void) {
    storage(app: app).maxOperationRetryTime = TimeInterval(Double(time) / 1000.0)
    completion(.success(()))
  }

  func setMaxUploadRetryTime(app: PigeonStorageFirebaseApp, time: Int64,
                             completion: @escaping (Result<Void, Error>) -> Void) {
    storage(app: app).maxUploadRetryTime = TimeInterval(Double(time) / 1000.0)
    completion(.success(()))
  }

  func setMaxDownloadRetryTime(app: PigeonStorageFirebaseApp, time: Int64,
                               completion: @escaping (Result<Void, Error>) -> Void) {
    storage(app: app).maxDownloadRetryTime = TimeInterval(Double(time) / 1000.0)
    completion(.success(()))
  }

  func useStorageEmulator(app: PigeonStorageFirebaseApp, host: String, port: Int64,
                          completion: @escaping (Result<Void, Error>) -> Void) {
    let s = storage(app: app)
    s.useEmulator(withHost: host, port: Int(port))
    completion(.success(()))
  }

  func referenceDelete(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                       completion: @escaping (Result<Void, Error>) -> Void) {
    ref(app: app, reference: reference).delete { error in
      if let e = error { completion(.failure(self.toFlutterError(e))) }
      else { completion(.success(())) }
    }
  }

  func referenceGetDownloadURL(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                               completion: @escaping (Result<String, Error>) -> Void) {
    ref(app: app, reference: reference).downloadURL { url, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) }
      else { completion(.success(url!.absoluteString.replacingOccurrences(
        of: ":443",
        with: ""
      ))) }
    }
  }

  func referenceGetMetaData(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                            completion: @escaping (Result<PigeonFullMetaData, Error>) -> Void) {
    ref(app: app, reference: reference).getMetadata { md, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else {
        completion(.success(PigeonFullMetaData(metadata: self.metaToDict(md))))
      }
    }
  }

  func referenceList(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                     options: PigeonListOptions,
                     completion: @escaping (Result<PigeonListResult, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let block: (StorageListResult?, Error?) -> Void = { list, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else {
        completion(.success(self.listToPigeon(list!)))
      }
    }
    if let token = options.pageToken {
      r.list(maxResults: options.maxResults, pageToken: token, completion: block)
    } else {
      r.list(maxResults: options.maxResults, completion: block)
    }
  }

  func referenceListAll(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                        completion: @escaping (Result<PigeonListResult, Error>) -> Void) {
    ref(app: app, reference: reference).listAll { list, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) }
      else { completion(.success(self.listToPigeon(list!))) }
    }
  }

  func referenceGetData(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                        maxSize: Int64,
                        completion: @escaping (Result<FlutterStandardTypedData?, Error>) -> Void) {
    ref(app: app, reference: reference).getData(maxSize: maxSize) { data, error in
      if let e = error {
        completion(.failure(self.toFlutterError(e)))
      } else if let data {
        completion(.success(FlutterStandardTypedData(bytes: data)))
      } else {
        completion(.success(nil))
      }
    }
  }

  func referencePutData(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                        data: FlutterStandardTypedData, settableMetaData: PigeonSettableMetadata,
                        handle: Int64, completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let task = r.putData(data.data, metadata: toMeta(settableMetaData))
    completion(.success(registerTask(
      task: task,
      appName: r.storage.app.name,
      handle: handle,
      path: r.fullPath
    )))
  }

  func referencePutString(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                          data: String, format: Int64, settableMetaData: PigeonSettableMetadata,
                          handle: Int64, completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let d: Data
    if format == 1 { d = Data(base64Encoded: data) ?? Data() }
    else if format ==
      2 {
      d = Data(base64Encoded: data.replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
        .padding(toLength: ((data.count + 3) / 4) * 4, withPad: "=", startingAt: 0)) ?? Data()
    } else { d = Data() }
    let task = r.putData(d, metadata: toMeta(settableMetaData))
    completion(.success(registerTask(
      task: task,
      appName: r.storage.app.name,
      handle: handle,
      path: r.fullPath
    )))
  }

  func referencePutFile(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                        filePath: String, settableMetaData: PigeonSettableMetadata?, handle: Int64,
                        completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let url = URL(fileURLWithPath: filePath)
    let task: StorageUploadTask
    if let md = settableMetaData { task = r.putFile(from: url, metadata: toMeta(md)) }
    else { task = r.putFile(from: url) }
    completion(.success(registerTask(
      task: task,
      appName: r.storage.app.name,
      handle: handle,
      path: r.fullPath
    )))
  }

  func referenceDownloadFile(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                             filePath: String, handle: Int64,
                             completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let url = URL(fileURLWithPath: filePath)
    let task = r.write(toFile: url)
    completion(.success(registerTask(
      task: task,
      appName: r.storage.app.name,
      handle: handle,
      path: r.fullPath
    )))
  }

  func referenceUpdateMetadata(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference,
                               metadata: PigeonSettableMetadata,
                               completion: @escaping (Result<PigeonFullMetaData, Error>) -> Void) {
    ref(app: app, reference: reference).updateMetadata(toMeta(metadata)) { md, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) }
      else { completion(.success(PigeonFullMetaData(metadata: self.metaToDict(md)))) }
    }
  }

  func taskPause(app: PigeonStorageFirebaseApp, handle: Int64,
                 completion: @escaping (Result<[String: Any], Error>) -> Void) {
    if let task = handleToTask[handle] as? StorageUploadTask {
      task.pause()
      completion(.success(["status": true, "snapshot": currentSnapshot(handle: handle)]))
    } else if let task = handleToTask[handle] as? StorageDownloadTask {
      task.pause()
      completion(.success(["status": true, "snapshot": currentSnapshot(handle: handle)]))
    } else {
      completion(.success(["status": false]))
    }
  }

  func taskResume(app: PigeonStorageFirebaseApp, handle: Int64,
                  completion: @escaping (Result<[String: Any], Error>) -> Void) {
    if let task = handleToTask[handle] as? StorageUploadTask {
      task.resume()
      completion(.success(["status": true, "snapshot": currentSnapshot(handle: handle)]))
    } else if let task = handleToTask[handle] as? StorageDownloadTask {
      task.resume()
      completion(.success(["status": true, "snapshot": currentSnapshot(handle: handle)]))
    } else {
      completion(.success(["status": false]))
    }
  }

  func taskCancel(app: PigeonStorageFirebaseApp, handle: Int64,
                  completion: @escaping (Result<[String: Any], Error>) -> Void) {
    if let task = handleToTask[handle] as? StorageUploadTask {
      task.cancel()
      if let id = handleToIdentifier[handle] {
        FLTFirebaseStoragePlugin.canceledIdentifiers.insert(id)
      }
      completion(.success(["status": true, "snapshot": currentSnapshot(handle: handle)]))
    } else if let task = handleToTask[handle] as? StorageDownloadTask {
      task.cancel()
      if let id = handleToIdentifier[handle] {
        FLTFirebaseStoragePlugin.canceledIdentifiers.insert(id)
      }
      completion(.success(["status": true, "snapshot": currentSnapshot(handle: handle)]))
    } else {
      completion(.success(["status": false]))
    }
  }

  private func toMeta(_ m: PigeonSettableMetadata) -> StorageMetadata {
    let md = StorageMetadata()
    if let v = m.cacheControl { md.cacheControl = v }
    if let v = m.contentType { md.contentType = v }
    if let v = m.contentDisposition { md.contentDisposition = v }
    if let v = m.contentEncoding { md.contentEncoding = v }
    if let v = m.contentLanguage { md.contentLanguage = v }
    if let v = m.customMetadata { md.customMetadata = v as? [String: String] }
    return md
  }

  private func metaToDict(_ md: StorageMetadata?) -> [String: Any]? {
    guard let md else { return nil }
    var out: [String: Any] = [:]
    out["name"] = md.name
    out["bucket"] = md.bucket
    out["generation"] = String(md.generation)
    out["metadataGeneration"] = String(md.metageneration)
    out["fullPath"] = md.path
    out["size"] = md.size
    out["creationTimeMillis"] = Int((md.timeCreated?.timeIntervalSince1970 ?? 0) * 1000)
    out["updatedTimeMillis"] = Int((md.updated?.timeIntervalSince1970 ?? 0) * 1000)
    if let v = md.md5Hash { out["md5Hash"] = v }
    if let v = md.cacheControl { out["cacheControl"] = v }
    if let v = md.contentDisposition { out["contentDisposition"] = v }
    if let v = md.contentEncoding { out["contentEncoding"] = v }
    if let v = md.contentLanguage { out["contentLanguage"] = v }
    if let v = md.contentType { out["contentType"] = v }
    out["customMetadata"] = md.customMetadata ?? [:]
    return out
  }

  private func listToPigeon(_ list: StorageListResult) -> PigeonListResult {
    let items = list.items.map { toPigeon($0) }
    let prefixes = list.prefixes.map { toPigeon($0) }
    let itemsOpt: [PigeonStorageReference?] = items.map { Optional($0) }
    let prefixesOpt: [PigeonStorageReference?] = prefixes.map { Optional($0) }
    return PigeonListResult(items: itemsOpt, pageToken: list.pageToken, prefixs: prefixesOpt)
  }

  private func registerTask(task: StorageObservableTask, appName: String, handle: Int64,
                            path: String) -> String {
    let uuid = UUID().uuidString
    let channelName = "plugins.flutter.io/firebase_storage/taskEvent/\(uuid)"
    let channel = FlutterEventChannel(name: channelName, binaryMessenger: messenger!)
    let storageInstance = Storage.storage(app: FLTFirebasePlugin.firebaseAppNamed(appName)!)
    channel.setStreamHandler(TaskStateChannelStreamHandler(
      task: task,
      storage: storageInstance,
      identifier: channelName
    ))
    eventChannels[channelName] = channel
    handleToTask[handle] = task as AnyObject
    handleToPath[handle] = path
    handleToIdentifier[handle] = channelName
    return uuid
  }

  private func currentSnapshot(handle: Int64) -> [String: Any] {
    [
      "path": handleToPath[handle] ?? "",
      "bytesTransferred": 0,
      "totalBytes": 0,
    ]
  }

  private func toFlutterError(_ error: Error) -> Error {
    let ns = error as NSError
    let code = mapStorageErrorCode(ns)
    let message = standardMessage(for: code) ?? ns.localizedDescription
    return FlutterError(code: code, message: message, details: [:])
  }

  private func mapStorageErrorCode(_ error: NSError) -> String {
    if error.domain == StorageErrorDomain, let code = StorageErrorCode(rawValue: error.code) {
      switch code {
      case .objectNotFound: return "object-not-found"
      case .bucketNotFound: return "bucket-not-found"
      case .projectNotFound: return "project-not-found"
      case .quotaExceeded: return "quota-exceeded"
      case .unauthenticated: return "unauthenticated"
      case .unauthorized: return "unauthorized"
      case .retryLimitExceeded: return "retry-limit-exceeded"
      case .cancelled: return "canceled"
      case .downloadSizeExceeded: return "download-size-exceeded"
      @unknown default: return "unknown"
      }
    } else if error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
      return "canceled"
    }
    return "unknown"
  }

  private func standardMessage(for code: String) -> String? {
    switch code {
    case "object-not-found": return "No object exists at the desired reference."
    case "unauthorized": return "User is not authorized to perform the desired action."
    default: return nil
    }
  }
}
