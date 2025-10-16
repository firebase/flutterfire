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

final class TaskStateChannelStreamHandler: NSObject, FlutterStreamHandler {
  private let task: StorageObservableTask
  private let storage: Storage
  private let identifier: String
  private weak var plugin: FLTFirebaseStoragePluginSwift?

  private var successHandle: Any?
  private var failureHandle: Any?
  private var pausedHandle: Any?
  private var progressHandle: Any?

  init(task: StorageObservableTask, storage: Storage, identifier: String, plugin: FLTFirebaseStoragePluginSwift?) {
    self.task = task
    self.storage = storage
    self.identifier = identifier
    self.plugin = plugin
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    successHandle = task.observe(.success) { snapshot in
      events([
        "taskState": 2, // success
        "appName": self.storage.app.name,
        "snapshot": self.parseTaskSnapshot(snapshot)
      ])
      self.cleanupObservers()
    }
    failureHandle = task.observe(.failure) { snapshot in
      let err = snapshot.error as NSError?
      let errorDict: [String: Any] = [
        "code": "unknown",
        "message": err?.localizedDescription ?? "An unknown error occurred",
      ]
      events([
        "taskState": 4, // error
        "appName": self.storage.app.name,
        "error": errorDict
      ])
      self.cleanupObservers()
    }
    pausedHandle = task.observe(.pause) { snapshot in
      events([
        "taskState": 0, // paused
        "appName": self.storage.app.name,
        "snapshot": self.parseTaskSnapshot(snapshot)
      ])
    }
    progressHandle = task.observe(.progress) { snapshot in
      events([
        "taskState": 1, // running
        "appName": self.storage.app.name,
        "snapshot": self.parseTaskSnapshot(snapshot)
      ])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    cleanupObservers()
    if let messenger = plugin?.messenger, let ch = plugin?.eventChannels[identifier] {
      ch.setStreamHandler(nil)
      plugin?.eventChannels.removeValue(forKey: identifier)
      plugin?.streamHandlers.removeValue(forKey: identifier)
    }
    return nil
  }

  private func cleanupObservers() {
    if let h = successHandle as? String { task.removeObserver(withHandle: h) }
    if let h = failureHandle as? String { task.removeObserver(withHandle: h) }
    if let h = pausedHandle as? String { task.removeObserver(withHandle: h) }
    if let h = progressHandle as? String { task.removeObserver(withHandle: h) }
    successHandle = nil
    failureHandle = nil
    pausedHandle = nil
    progressHandle = nil
  }

  private func parseTaskSnapshot(_ snapshot: StorageTaskSnapshot) -> [String: Any] {
    var out: [String: Any] = [:]
    out["path"] = snapshot.reference.fullPath
    if let md = snapshot.metadata {
      out["metadata"] = metaToDict(md)
    }
    if let progress = snapshot.progress {
      out["bytesTransferred"] = progress.completedUnitCount
      out["totalBytes"] = progress.totalUnitCount
    } else {
      out["bytesTransferred"] = 0
      out["totalBytes"] = 0
    }
    return out
  }

  private func metaToDict(_ md: StorageMetadata) -> [String: Any] {
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
}


