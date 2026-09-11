// Copyright 2026 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseStorage
import Flutter
import XCTest

@testable import firebase_core
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

  func testQueuedCallbackAfterCancelOnLiveEngine() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      defer { task.cancel() }
      task.snapshot.reference.storage.callbackQueue = .main
      var events = 0
      _ = handler.onListen(withArguments: nil) { _ in events += 1 }
      XCTAssertEqual(events, 0)
      _ = handler.onCancel(withArguments: nil)
      drainMainQueue()
      XCTAssertEqual(events, 0)
      XCTAssertEqual(task.snapshot.status, .pause)
    }
  }

  func testOldCallbackCannotReachEitherListenerAfterRelisten() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      defer { task.cancel() }
      task.snapshot.reference.storage.callbackQueue = .main
      var oldEvents = 0
      var newEvents = 0
      _ = handler.onListen(withArguments: nil) { _ in oldEvents += 1 }
      _ = handler.onCancel(withArguments: nil)
      _ = handler.onListen(withArguments: nil) { _ in newEvents += 1 }
      drainMainQueue()
      XCTAssertEqual(oldEvents, 0)
      XCTAssertEqual(newEvents, 1)
      _ = handler.onCancel(withArguments: nil)
    }
  }

  func testBackgroundCallbackQueuedForMainIsInvalidated() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      defer { task.cancel() }
      var events = 0
      _ = handler.onListen(withArguments: nil) { _ in events += 1 }
      task.snapshot.reference.storage.callbackQueue.sync {}
      XCTAssertEqual(events, 0)
      _ = handler.onCancel(withArguments: nil)
      drainMainQueue()
      XCTAssertEqual(events, 0)
    }
  }

  func testBackgroundCallbacksAreDeliveredOnMain() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      defer { task.cancel() }
      let delivered = expectation(description: "pause delivered on main")
      _ = handler.onListen(withArguments: nil) { _ in
        XCTAssertTrue(Thread.isMainThread)
        delivered.fulfill()
      }
      wait(for: [delivered], timeout: 10)
      _ = handler.onCancel(withArguments: nil)
    }
  }

  func testCancellationReleasesSinkBeforeQueuedCallbackDrains() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      defer { task.cancel() }
      task.snapshot.reference.storage.callbackQueue = .main
      var retainedBySink: NSObject? = NSObject()
      weak var released = retainedBySink
      _ = handler.onListen(withArguments: nil) { [object = retainedBySink!] _ in
        withExtendedLifetime(object) {}
      }
      retainedBySink = nil
      XCTAssertNotNil(released)
      _ = handler.onCancel(withArguments: nil)
      XCTAssertNil(released)
      drainMainQueue()
    }
  }

  func testSuccessDeliversOnceAndRemovesObservers() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      defer { task.cancel() }
      task.snapshot.reference.storage.callbackQueue = .main
      let completed = expectation(description: "upload succeeds")
      var successes = 0
      _ = handler.onListen(withArguments: nil) { event in
        guard let event = event as? [String: Any], event["taskState"] as? Int == 2 else { return }
        successes += 1
        self.assertObserversRemoved(handler)
        completed.fulfill()
      }
      task.resume()
      wait(for: [completed], timeout: 30)
      drainMainQueue()
      XCTAssertEqual(successes, 1)
    }
  }

  func testTransferCancellationDeliversFailureOnceAndRemovesObservers() throws {
    try withPlugin { _, plugin in
      let (task, handler) = try pausedTask(plugin: plugin)
      task.snapshot.reference.storage.callbackQueue = .main
      let failed = expectation(description: "cancelled transfer reports failure")
      var failures = 0
      _ = handler.onListen(withArguments: nil) { event in
        guard let event = event as? [String: Any], event["taskState"] as? Int == 4 else { return }
        failures += 1
        XCTAssertEqual((event["error"] as? [String: Any])?["code"] as? String, "canceled")
        self.assertObserversRemoved(handler)
        failed.fulfill()
      }
      task.cancel()
      wait(for: [failed], timeout: 10)
      drainMainQueue()
      XCTAssertEqual(failures, 1)
    }
  }

  func testCoreReinitializationInvalidatesOldCallbacksAndAllowsFreshTask() throws {
    try withPlugin { engine, plugin in
      FLTFirebaseCorePlugin.register(with: engine.registrar(forPlugin: "storage-test-core")!)
      let core = try XCTUnwrap(
        engine.valuePublished(byPlugin: "storage-test-core") as? FLTFirebaseCorePlugin)
      initializeCore(core)
      let (oldTask, oldHandler) = try pausedTask(plugin: plugin)
      defer { oldTask.cancel() }
      oldTask.snapshot.reference.storage.callbackQueue = .main
      var oldEvents = 0
      _ = oldHandler.onListen(withArguments: nil) { _ in oldEvents += 1 }
      initializeCore(core)
      drainMainQueue()
      XCTAssertEqual(oldEvents, 0)
      assertPluginMapsEmpty(plugin)
      XCTAssertEqual(oldTask.snapshot.status, .pause)

      let (newTask, newHandler) = try pausedTask(plugin: plugin)
      defer { newTask.cancel() }
      newTask.snapshot.reference.storage.callbackQueue = .main
      let completed = expectation(description: "fresh upload after reinitialization succeeds")
      _ = newHandler.onListen(withArguments: nil) { event in
        if let event = event as? [String: Any], event["taskState"] as? Int == 2 {
          completed.fulfill()
        }
      }
      newTask.resume()
      wait(for: [completed], timeout: 30)
    }
  }

  private func initializeCore(_ core: FLTFirebaseCorePlugin) {
    let initialized = expectation(description: "Firebase Core initialization completes")
    core.initializeCore { result in
      if case .failure(let error) = result { XCTFail("Core initialization failed: \(error)") }
      initialized.fulfill()
    }
    wait(for: [initialized], timeout: 10)
  }

  private func withPlugin(_ body: (FlutterEngine, FLTFirebaseStoragePlugin) throws -> Void) throws {
    let engine = FlutterEngine(
      name: "storage-listener-test", project: nil, allowHeadlessExecution: true)
    XCTAssertTrue(engine.run())
    defer { engine.destroyContext() }
    FLTFirebaseStoragePlugin.register(with: engine.registrar(forPlugin: "storage-listener-test")!)
    let plugin = try XCTUnwrap(
      engine.valuePublished(byPlugin: "storage-listener-test") as? FLTFirebaseStoragePlugin)
    try body(engine, plugin)
    withExtendedLifetime(engine) {}
  }

  private func assertObserversRemoved(
    _ handler: TaskStateChannelStreamHandler, file: StaticString = #filePath, line: UInt = #line
  ) {
    for name in ["successHandle", "failureHandle", "pausedHandle", "progressHandle"] {
      let handle = Mirror(reflecting: handler).children.first { $0.label == name }?.value as? String
      XCTAssertNil(handle, file: file, line: line)
    }
  }

  private func assertPluginMapsEmpty(
    _ plugin: FLTFirebaseStoragePlugin, file: StaticString = #filePath, line: UInt = #line
  ) {
    for name in [
      "streamHandlers", "eventChannels", "handleToTask", "handleToPath", "handleToIdentifier",
    ] {
      guard let map = Mirror(reflecting: plugin).children.first(where: { $0.label == name }) else {
        XCTFail("Missing plugin map \(name)", file: file, line: line)
        continue
      }
      XCTAssertEqual(Mirror(reflecting: map.value).children.count, 0, file: file, line: line)
    }
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
