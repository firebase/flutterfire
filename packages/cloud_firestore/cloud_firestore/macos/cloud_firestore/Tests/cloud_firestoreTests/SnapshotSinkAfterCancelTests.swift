// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import FirebaseCore
import FirebaseFirestore
import ObjectiveC
import XCTest

@testable import cloud_firestore

private final class FakeListenerRegistration: NSObject, ListenerRegistration {
  func remove() {}
}

private enum SwizzleBox {
  static var captured: AnyObject?
  static var original: IMP?
  static var methodClass: AnyClass?
  static var selector: Selector?
}

final class SnapshotSinkAfterCancelTests: XCTestCase {
  override func setUp() {
    super.setUp()
    if FirebaseApp.app() == nil {
      let options = FirebaseOptions(
        googleAppID: "1:123456789012:ios:0000000000000000000000",
        gcmSenderID: "123456789012"
      )
      options.apiKey = "AIzaSyDUMMYKEYFORFLUTTERFIRECITESTS0000"
      options.projectID = "flutterfire-e2e-tests"
      FirebaseApp.configure(options: options)
    }
  }

  override func tearDown() {
    restoreSwizzle()
    super.tearDown()
  }

  func testQueryHandlerDropsSinkCallQueuedBeforeCancel() {
    let firestore = Firestore.firestore()
    let query = firestore.collection("items")
    let handler = QuerySnapshotStreamHandler(
      firestore: firestore,
      query: query,
      includeMetadataChanges: false,
      serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior.none,
      source: FirebaseFirestore.ListenSource.default
    )
    let selector = NSSelectorFromString("addSnapshotListenerWithOptions:listener:")
    installSwizzle(on: query, selector: selector, argumentCount: 2)

    var afterCancel = 0
    var cancelled = false
    let listenError = handler.onListen(withArguments: nil) { _ in
      if cancelled {
        afterCancel += 1
      }
    }
    XCTAssertNil(listenError)
    guard let captured = SwizzleBox.captured else {
      XCTFail("Snapshot listener was not captured")
      return
    }
    restoreSwizzle()

    let listener = unsafeBitCast(
      captured, to: (@convention(block) (Any?, Error?) -> Void).self)
    listener(nil, NSError(domain: "SnapshotSinkAfterCancelTests", code: 1))
    cancelled = true
    XCTAssertNil(handler.onCancel(withArguments: nil))
    drainMainQueue()

    XCTAssertEqual(afterCancel, 0)
  }

  func testDocumentHandlerDropsSinkCallQueuedBeforeCancel() {
    let firestore = Firestore.firestore()
    let reference = firestore.collection("items").document("d1")
    let handler = DocumentSnapshotStreamHandler(
      firestore: firestore,
      reference: reference,
      includeMetadataChanges: false,
      serverTimestampBehavior: FirebaseFirestore.ServerTimestampBehavior.none,
      source: FirebaseFirestore.ListenSource.default
    )
    let selector = NSSelectorFromString("addSnapshotListenerWithOptions:listener:")
    installSwizzle(on: reference, selector: selector, argumentCount: 2)

    var afterCancel = 0
    var cancelled = false
    let listenError = handler.onListen(withArguments: nil) { _ in
      if cancelled {
        afterCancel += 1
      }
    }
    XCTAssertNil(listenError)
    guard let captured = SwizzleBox.captured else {
      XCTFail("Snapshot listener was not captured")
      return
    }
    restoreSwizzle()

    let listener = unsafeBitCast(
      captured, to: (@convention(block) (Any?, Error?) -> Void).self)
    listener(nil, NSError(domain: "SnapshotSinkAfterCancelTests", code: 1))
    cancelled = true
    XCTAssertNil(handler.onCancel(withArguments: nil))
    drainMainQueue()

    XCTAssertEqual(afterCancel, 0)
  }

  func testSnapshotsInSyncHandlerDropsSinkCallQueuedBeforeCancel() {
    let firestore = Firestore.firestore()
    let handler = SnapshotsInSyncStreamHandler(firestore: firestore)
    let selector = NSSelectorFromString("addSnapshotsInSyncListener:")
    installSwizzle(on: firestore, selector: selector, argumentCount: 1)

    var afterCancel = 0
    var cancelled = false
    let listenError = handler.onListen(withArguments: nil) { _ in
      if cancelled {
        afterCancel += 1
      }
    }
    XCTAssertNil(listenError)
    guard let captured = SwizzleBox.captured else {
      XCTFail("Snapshots-in-sync listener was not captured")
      return
    }
    restoreSwizzle()

    let listener = unsafeBitCast(captured, to: (@convention(block) () -> Void).self)
    listener()
    cancelled = true
    XCTAssertNil(handler.onCancel(withArguments: nil))
    drainMainQueue()

    XCTAssertEqual(afterCancel, 0)
  }

  private func drainMainQueue() {
    let done = expectation(description: "main queue drained")
    DispatchQueue.main.async {
      done.fulfill()
    }
    wait(for: [done], timeout: 2)
  }

  private func installSwizzle(on target: AnyObject, selector: Selector, argumentCount: Int) {
    let cls: AnyClass = object_getClass(target)!
    guard let method = class_getInstanceMethod(cls, selector) else {
      XCTFail("Missing \(selector) on \(cls)")
      return
    }
    SwizzleBox.methodClass = cls
    SwizzleBox.selector = selector
    SwizzleBox.original = method_getImplementation(method)
    let block: AnyObject
    if argumentCount == 1 {
      let impl: @convention(block) (AnyObject, AnyObject) -> AnyObject = { _, listener in
        SwizzleBox.captured = listener
        return FakeListenerRegistration()
      }
      block = unsafeBitCast(impl, to: AnyObject.self)
    } else {
      let impl: @convention(block) (AnyObject, AnyObject, AnyObject) -> AnyObject = {
        _, _, listener in
        SwizzleBox.captured = listener
        return FakeListenerRegistration()
      }
      block = unsafeBitCast(impl, to: AnyObject.self)
    }
    method_setImplementation(method, imp_implementationWithBlock(block))
  }

  private func restoreSwizzle() {
    if let cls = SwizzleBox.methodClass, let selector = SwizzleBox.selector,
      let original = SwizzleBox.original,
      let method = class_getInstanceMethod(cls, selector)
    {
      method_setImplementation(method, original)
    }
    SwizzleBox.captured = nil
    SwizzleBox.original = nil
    SwizzleBox.methodClass = nil
    SwizzleBox.selector = nil
  }
}
