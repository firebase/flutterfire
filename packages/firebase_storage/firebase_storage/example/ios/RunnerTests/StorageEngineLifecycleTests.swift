// Copyright 2026 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseStorage
import Flutter
import XCTest

@testable import firebase_storage

final class StorageEngineLifecycleTests: XCTestCase {
  func testEngineDisposalInvalidatesQueuedTaskEvents() throws {
    XCTAssertTrue(Thread.isMainThread)
    var plugin: FLTFirebaseStoragePlugin!
    var handler: TaskStateChannelStreamHandler!
    var task: StorageUploadTask!
    weak var releasedEngine: FlutterEngine?
    var events = 0

    try autoreleasepool {
      let engine = FlutterEngine(
        name: "storage-lifecycle", project: nil, allowHeadlessExecution: true)
      releasedEngine = engine
      XCTAssertTrue(engine.run())
      FLTFirebaseStoragePlugin.register(with: engine.registrar(forPlugin: "storage-lifecycle")!)
      plugin = try XCTUnwrap(
        engine.valuePublished(byPlugin: "storage-lifecycle") as? FLTFirebaseStoragePlugin)
      (task, handler) = try pausedTask(plugin: plugin)
      XCTAssertNil(handler.onListen(withArguments: nil) { _ in events += 1 })
      task.snapshot.reference.storage.callbackQueue.sync {}
      XCTAssertEqual(events, 0)
      engine.destroyContext()
    }

    XCTAssertNil(releasedEngine, "The real engine must dispose before queued events drain")
    let handlers: [String: TaskStateChannelStreamHandler] = try field(plugin!, "streamHandlers")
    let channels: [String: FlutterEventChannel] = try field(plugin!, "eventChannels")
    XCTAssertTrue(
      handlers.isEmpty, "Engine disposal must invoke the published plugin's detach callback")
    XCTAssertTrue(channels.isEmpty)
    drainMainQueue()
    XCTAssertEqual(events, 0, "A task callback queued before disposal must not reach its sink")
    task.cancel()
    withExtendedLifetime(handler) {}
    withExtendedLifetime(plugin) {}
  }

  private func pausedTask(plugin: FLTFirebaseStoragePlugin) throws -> (
    StorageUploadTask, TaskStateChannelStreamHandler
  ) {
    let name = "storage-lifecycle-\(UUID().uuidString)"
    let options = FirebaseOptions(
      googleAppID: "1:123456789012:ios:0000000000000000000000", gcmSenderID: "123456789012")
    options.apiKey = "A00000000000000000000000000000000000000"
    options.projectID = "flutterfire-e2e-tests"
    options.storageBucket = "flutterfire-e2e-tests.appspot.com"
    FirebaseApp.configure(name: name, options: options)
    let app = try XCTUnwrap(FirebaseApp.app(name: name))
    let storage = Storage.storage(app: app)
    storage.useEmulator(withHost: "127.0.0.1", port: 9199)
    storage.callbackQueue = DispatchQueue(label: "storage-lifecycle-callbacks")
    let reference = InternalStorageReference(
      bucket: options.storageBucket!, fullPath: "flutter-tests/\(name)", name: name)
    plugin.referencePutData(
      app: InternalStorageFirebaseApp(appName: name, tenantId: nil, bucket: options.storageBucket!),
      reference: reference,
      data: FlutterStandardTypedData(bytes: Data(repeating: 1, count: 16 * 1024 * 1024)),
      settableMetaData: InternalSettableMetadata(), handle: 1
    ) { result in
      if case .failure(let error) = result { XCTFail("Failed to register upload: \(error)") }
    }
    let tasks: [Int64: AnyObject] = try field(plugin, "handleToTask")
    let task = try XCTUnwrap(tasks[1] as? StorageUploadTask)
    let paused = DispatchSemaphore(value: 0)
    let observer = task.observe(.pause) { _ in paused.signal() }
    task.pause()
    XCTAssertEqual(paused.wait(timeout: .now() + 10), .success)
    task.removeObserver(withHandle: observer)
    let handlers: [String: TaskStateChannelStreamHandler] = try field(plugin, "streamHandlers")
    return (task, try XCTUnwrap(handlers.values.first))
  }

  private func field<T>(_ object: Any, _ name: String) throws -> T {
    try XCTUnwrap(Mirror(reflecting: object).children.first { $0.label == name }?.value as? T)
  }

  private func drainMainQueue() {
    let drained = expectation(description: "queued task deliveries drained")
    DispatchQueue.main.async { drained.fulfill() }
    wait(for: [drained], timeout: 10)
  }
}
