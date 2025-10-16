// Copyright 2025 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import FirebaseStorage

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

final class FLTFirebaseStoragePluginSwift: NSObject, FlutterPlugin, FirebaseStorageHostApi {
  private var channel: FlutterMethodChannel?
  private var messenger: FlutterBinaryMessenger?
  private var eventChannels: [String: FlutterEventChannel] = [:]
  private var streamHandlers: [String: FlutterStreamHandler] = [:]

  static func register(with registrar: FlutterPluginRegistrar) {
    let channelName = "plugins.flutter.io/firebase_storage"
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = FLTFirebaseStoragePluginSwift()
    instance.channel = channel
    instance.messenger = registrar.messenger()
    registrar.addMethodCallDelegate(instance, channel: channel)
    FirebaseStorageHostApiSetup(registrar.messenger(), instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }

  private func storage(app: PigeonStorageFirebaseApp) -> Storage {
    let base = "gs://" + app.bucket
    let firApp = FLTFirebasePlugin.firebaseAppNamed(app.appName)
    return Storage.storage(app: firApp, url: base)
  }

  private func ref(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference) -> StorageReference {
    return storage(app: app).reference(withPath: reference.fullPath)
  }

  private func toPigeon(_ ref: StorageReference) -> PigeonStorageReference {
    return PigeonStorageReference.make(withBucket: ref.bucket, fullPath: ref.fullPath, name: ref.name)
  }

  func getReferencebyPath(app: PigeonStorageFirebaseApp, path: String, bucket: String?, completion: @escaping (Result<PigeonStorageReference, Error>) -> Void) {
    let r = storage(app: app).reference(withPath: path)
    completion(.success(PigeonStorageReference.make(withBucket: bucket, fullPath: r.fullPath, name: r.name)))
  }

  func setMaxOperationRetryTime(app: PigeonStorageFirebaseApp, time: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    storage(app: app).maxOperationRetryTime = TimeInterval(Double(time) / 1000.0)
    completion(.success(()))
  }

  func setMaxUploadRetryTime(app: PigeonStorageFirebaseApp, time: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    storage(app: app).maxUploadRetryTime = TimeInterval(Double(time) / 1000.0)
    completion(.success(()))
  }

  func setMaxDownloadRetryTime(app: PigeonStorageFirebaseApp, time: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    storage(app: app).maxDownloadRetryTime = TimeInterval(Double(time) / 1000.0)
    completion(.success(()))
  }

  func useStorageEmulator(app: PigeonStorageFirebaseApp, host: String, port: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    let key = app.bucket
    let s = storage(app: app)
    s.useEmulator(withHost: host, port: Int(port))
    completion(.success(()))
  }

  func referenceDelete(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, completion: @escaping (Result<Void, Error>) -> Void) {
    ref(app: app, reference: reference).delete { error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else { completion(.success(())) }
    }
  }

  func referenceGetDownloadURL(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, completion: @escaping (Result<String, Error>) -> Void) {
    ref(app: app, reference: reference).downloadURL { url, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else { completion(.success(url!.absoluteString.replacingOccurrences(of: ":443", with: ""))) }
    }
  }

  func referenceGetMetaData(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, completion: @escaping (Result<PigeonFullMetaData, Error>) -> Void) {
    ref(app: app, reference: reference).getMetadata { md, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else {
        completion(.success(PigeonFullMetaData.make(withMetadata: self.metaToDict(md))))
      }
    }
  }

  func referenceList(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, options: PigeonListOptions, completion: @escaping (Result<PigeonListResult, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let block: (StorageListResult?, Error?) -> Void = { list, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else {
        completion(.success(self.listToPigeon(list!)))
      }
    }
    if let token = options.pageToken {
      r.list(maxResults: Int(options.maxResults), pageToken: token, completion: block)
    } else {
      r.list(maxResults: Int(options.maxResults), completion: block)
    }
  }

  func referenceListAll(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, completion: @escaping (Result<PigeonListResult, Error>) -> Void) {
    ref(app: app, reference: reference).listAll { list, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else { completion(.success(self.listToPigeon(list!))) }
    }
  }

  func referenceGetData(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, maxSize: Int64, completion: @escaping (Result<Data?, Error>) -> Void) {
    ref(app: app, reference: reference).getData(maxSize: Int(maxSize)) { data, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else { completion(.success(data)) }
    }
  }

  func referencePutData(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, data: Data, settableMetaData: PigeonSettableMetadata, handle: Int64, completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let task = r.putData(data, metadata: toMeta(settableMetaData))
    completion(.success(registerTask(task: task, appName: r.storage.app.name)))
  }

  func referencePutString(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, data: String, format: Int64, settableMetaData: PigeonSettableMetadata, handle: Int64, completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let d: Data
    if format == 1 { d = Data(base64Encoded: data) ?? Data() }
    else if format == 2 { d = Data(base64Encoded: data.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/").padding(toLength: ((data.count+3)/4)*4, withPad: "=", startingAt: 0)) ?? Data() }
    else { d = Data() }
    let task = r.putData(d, metadata: toMeta(settableMetaData))
    completion(.success(registerTask(task: task, appName: r.storage.app.name)))
  }

  func referencePutFile(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, filePath: String, settableMetaData: PigeonSettableMetadata?, handle: Int64, completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let url = URL(fileURLWithPath: filePath)
    let task: StorageUploadTask
    if let md = settableMetaData { task = r.putFile(from: url, metadata: toMeta(md)) } else { task = r.putFile(from: url) }
    completion(.success(registerTask(task: task, appName: r.storage.app.name)))
  }

  func referenceDownloadFile(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, filePath: String, handle: Int64, completion: @escaping (Result<String, Error>) -> Void) {
    let r = ref(app: app, reference: reference)
    let url = URL(fileURLWithPath: filePath)
    let task = r.write(toFile: url)
    completion(.success(registerTask(task: task, appName: r.storage.app.name)))
  }

  func referenceUpdateMetadata(app: PigeonStorageFirebaseApp, reference: PigeonStorageReference, metadata: PigeonSettableMetadata, completion: @escaping (Result<PigeonFullMetaData, Error>) -> Void) {
    ref(app: app, reference: reference).updateMetadata(toMeta(metadata)) { md, error in
      if let e = error { completion(.failure(self.toFlutterError(e))) } else { completion(.success(PigeonFullMetaData.make(withMetadata: self.metaToDict(md)))) }
    }
  }

  func taskPause(app: PigeonStorageFirebaseApp, handle: Int64, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.success(["status": false]))
  }

  func taskResume(app: PigeonStorageFirebaseApp, handle: Int64, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.success(["status": false]))
  }

  func taskCancel(app: PigeonStorageFirebaseApp, handle: Int64, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    completion(.success(["status": false]))
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
    return PigeonListResult.make(withItems: items, pageToken: list.pageToken, prefixs: prefixes)
  }

  private func registerTask(task: StorageObservableTask, appName: String) -> String {
    let uuid = UUID().uuidString
    let channelName = "plugins.flutter.io/firebase_storage/taskEvent/\(uuid)"
    let channel = FlutterEventChannel(name: channelName, binaryMessenger: messenger!)
    channel.setStreamHandler(FLTTaskStateChannelStreamHandler(task: task, storagePlugin: nil, channelName: channelName, handle: 0))
    eventChannels[channelName] = channel
    return uuid
  }

  private func toFlutterError(_ error: Error) -> Error {
    let ns = error as NSError
    return FlutterError(code: "unknown", message: ns.localizedDescription, details: [:])
  }
}


