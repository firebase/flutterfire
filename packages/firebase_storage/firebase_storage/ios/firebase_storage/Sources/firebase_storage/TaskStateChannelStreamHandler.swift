// Copyright 2025 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseStorage
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

final class TaskStateChannelStreamHandler: NSObject, FlutterStreamHandler {
  private let task: StorageObservableTask
  private let storage: Storage
  private let identifier: String

  private var successHandle: String?
  private var failureHandle: String?
  private var pausedHandle: String?
  private var progressHandle: String?

  init(task: StorageObservableTask, storage: Storage, identifier: String) {
    self.task = task
    self.storage = storage
    self.identifier = identifier
  }

  func onListen(withArguments arguments: Any?,
                eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    successHandle = task.observe(.success) { snapshot in
      events([
        "taskState": 2, // success
        "appName": self.storage.app.name,
        "snapshot": self.parseTaskSnapshot(snapshot),
      ])
      self.cleanupObservers()
    }
    failureHandle = task.observe(.failure) { snapshot in
      let err = snapshot.error as NSError?
      let errorDict: [String: Any] = self.errorDict(err)
      events([
        "taskState": 4, // error (including cancellations as errors per platform contract)
        "appName": self.storage.app.name,
        "error": errorDict,
      ])
      self.cleanupObservers()
    }
    pausedHandle = task.observe(.pause) { snapshot in
      events([
        "taskState": 0, // paused
        "appName": self.storage.app.name,
        "snapshot": self.parseTaskSnapshot(snapshot),
      ])
    }
    progressHandle = task.observe(.progress) { snapshot in
      events([
        "taskState": 1, // running
        "appName": self.storage.app.name,
        "snapshot": self.parseTaskSnapshot(snapshot),
      ])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    cleanupObservers()
    return nil
  }

  private func cleanupObservers() {
    if let h = successHandle { task.removeObserver(withHandle: h) }
    if let h = failureHandle { task.removeObserver(withHandle: h) }
    if let h = pausedHandle { task.removeObserver(withHandle: h) }
    if let h = progressHandle { task.removeObserver(withHandle: h) }
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

  private func errorDict(_ error: NSError?) -> [String: Any] {
    guard let error else {
      return [
        "code": "unknown",
        "message": "An unknown error occurred",
      ]
    }
    let code: String
    if error.domain == StorageErrorDomain,
       let storageCode = StorageErrorCode(rawValue: error.code) {
      switch storageCode {
      case .objectNotFound: code = "object-not-found"
      case .bucketNotFound: code = "bucket-not-found"
      case .projectNotFound: code = "project-not-found"
      case .quotaExceeded: code = "quota-exceeded"
      case .unauthenticated: code = "unauthenticated"
      case .unauthorized: code = "unauthorized"
      case .retryLimitExceeded: code = "retry-limit-exceeded"
      case .cancelled: code = "canceled"
      case .downloadSizeExceeded: code = "download-size-exceeded"
      @unknown default: code = "unknown"
      }
    } else if error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
      code = "canceled"
    } else {
      code = "unknown"
    }
    return [
      "code": code,
      "message": standardMessage(for: code) ?? error.localizedDescription,
    ]
  }

  private func standardMessage(for code: String) -> String? {
    switch code {
    case "object-not-found": return "No object exists at the desired reference."
    case "unauthorized": return "User is not authorized to perform the desired action."
    case "canceled": return "The operation was canceled."
    default: return nil
    }
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
