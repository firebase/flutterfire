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
  private var eventSink: FlutterEventSink?
  private var generation: UInt64 = 0
  private var isListening = false

  init(task: StorageObservableTask, storage: Storage, identifier: String) {
    self.task = task
    self.storage = storage
    self.identifier = identifier
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    if Thread.isMainThread {
      return startListening(events)
    }

    var error: FlutterError?
    DispatchQueue.main.sync {
      error = startListening(events)
    }
    return error
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if Thread.isMainThread {
      invalidateOnMain()
    } else {
      DispatchQueue.main.sync {
        self.invalidateOnMain()
      }
    }
    return nil
  }

  /// Invalidates queued deliveries before removing Firebase observers. This is
  /// also called by the plugin when Flutter detaches, since Flutter does not
  /// necessarily invoke onCancel for every active event channel.
  func invalidate() {
    if Thread.isMainThread {
      invalidateOnMain()
    } else {
      DispatchQueue.main.sync {
        self.invalidateOnMain()
      }
    }
  }

  private func startListening(_ events: @escaping FlutterEventSink) -> FlutterError? {
    invalidateOnMain()
    eventSink = events
    isListening = true
    let listenGeneration = generation

    successHandle = task.observe(.success) { [weak self] snapshot in
      self?.enqueue(generation: listenGeneration, terminal: true) { handler in
        [
          "taskState": 2,  // success
          "appName": handler.storage.app.name,
          "snapshot": handler.parseTaskSnapshot(snapshot),
        ]
      }
    }
    failureHandle = task.observe(.failure) { [weak self] snapshot in
      self?.enqueue(generation: listenGeneration, terminal: true) { handler in
        let err = snapshot.error as NSError?
        return [
          "taskState": 4,  // error (including cancellations as errors per platform contract)
          "appName": handler.storage.app.name,
          "error": handler.errorDict(err),
        ]
      }
    }
    pausedHandle = task.observe(.pause) { [weak self] snapshot in
      self?.enqueue(generation: listenGeneration, terminal: false) { handler in
        [
          "taskState": 0,  // paused
          "appName": handler.storage.app.name,
          "snapshot": handler.parseTaskSnapshot(snapshot),
        ]
      }
    }
    progressHandle = task.observe(.progress) { [weak self] snapshot in
      self?.enqueue(generation: listenGeneration, terminal: false) { handler in
        [
          "taskState": 1,  // running
          "appName": handler.storage.app.name,
          "snapshot": handler.parseTaskSnapshot(snapshot),
        ]
      }
    }
    return nil
  }

  private func enqueue(
    generation: UInt64,
    terminal: Bool,
    makeEvent: @escaping (TaskStateChannelStreamHandler) -> [String: Any]
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self,
        self.isListening,
        self.generation == generation,
        let events = self.eventSink
      else { return }

      let event = makeEvent(self)
      if terminal {
        // Invalidate and remove observers before sending the terminal event so
        // callbacks queued by observer removal cannot send another event.
        self.invalidateOnMain()
      }
      events(event)
    }
  }

  private func invalidateOnMain() {
    dispatchPrecondition(condition: .onQueue(.main))
    generation &+= 1
    isListening = false
    eventSink = nil

    let handles = [successHandle, failureHandle, pausedHandle, progressHandle]
    successHandle = nil
    failureHandle = nil
    pausedHandle = nil
    progressHandle = nil
    for handle in handles {
      if let handle {
        task.removeObserver(withHandle: handle)
      }
    }
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
      let storageCode = StorageErrorCode(rawValue: error.code)
    {
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
