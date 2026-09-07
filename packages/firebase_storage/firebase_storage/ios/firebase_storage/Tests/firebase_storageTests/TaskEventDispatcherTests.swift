// Copyright 2026 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import XCTest

@testable import firebase_storage

final class TaskEventDispatcherTests: XCTestCase {
  private func onMain(_ body: @escaping () -> Void) {
    if Thread.isMainThread {
      body()
    } else {
      DispatchQueue.main.sync(execute: body)
    }
  }

  private func drainMainQueue() {
    let drained = expectation(description: "Queued deliveries drained")
    DispatchQueue.main.async { drained.fulfill() }
    wait(for: [drained], timeout: 5)
  }

  func testInvalidationDropsAlreadyQueuedEvents() {
    let dispatcher = TaskEventDispatcher<Int>()
    var events = [Int]()
    onMain {
      let generation = dispatcher.listen { events.append($0) }
      dispatcher.enqueue(
        generation: generation,
        terminal: false,
        makeEvent: { 1 },
        beforeTerminal: {}
      )
      dispatcher.invalidate()
    }
    drainMainQueue()
    XCTAssertTrue(events.isEmpty)
  }

  func testRelistenDoesNotReceiveAnEarlierListenersEvents() {
    let dispatcher = TaskEventDispatcher<Int>()
    var oldEvents = [Int]()
    var newEvents = [Int]()
    onMain {
      let oldGeneration = dispatcher.listen { oldEvents.append($0) }
      dispatcher.enqueue(
        generation: oldGeneration,
        terminal: false,
        makeEvent: { 1 },
        beforeTerminal: {}
      )
      let newGeneration = dispatcher.listen { newEvents.append($0) }
      dispatcher.enqueue(
        generation: oldGeneration,
        terminal: false,
        makeEvent: { 2 },
        beforeTerminal: {}
      )
      dispatcher.enqueue(
        generation: newGeneration,
        terminal: false,
        makeEvent: { 3 },
        beforeTerminal: {}
      )
    }
    drainMainQueue()
    XCTAssertTrue(oldEvents.isEmpty)
    XCTAssertEqual(newEvents, [3])
  }

  func testTerminalDeliveryCleansUpFirstAndDropsFollowingEvents() {
    let dispatcher = TaskEventDispatcher<Int>()
    var events = [Int]()
    var cleanedUp = false
    onMain {
      let generation = dispatcher.listen {
        if $0 == 2 {
          XCTAssertTrue(cleanedUp)
        }
        events.append($0)
      }
      dispatcher.enqueue(
        generation: generation,
        terminal: false,
        makeEvent: { 1 },
        beforeTerminal: {}
      )
      dispatcher.enqueue(
        generation: generation, terminal: true, makeEvent: { 2 },
        beforeTerminal: {
          cleanedUp = true
        })
      dispatcher.enqueue(
        generation: generation,
        terminal: false,
        makeEvent: { 3 },
        beforeTerminal: {}
      )
      dispatcher.enqueue(
        generation: generation, terminal: true, makeEvent: { 4 },
        beforeTerminal: {
          XCTFail("Terminal cleanup must run only once")
        })
    }
    drainMainQueue()
    XCTAssertEqual(events, [1, 2])
  }

  func testBackgroundCallbacksAreDeliveredOnMain() {
    let dispatcher = TaskEventDispatcher<Int>()
    let delivered = expectation(description: "Event delivered")
    var generation: UInt64 = 0
    onMain {
      generation = dispatcher.listen { event in
        XCTAssertTrue(Thread.isMainThread)
        XCTAssertEqual(event, 42)
        delivered.fulfill()
      }
    }
    let listenerGeneration = generation
    DispatchQueue.global().async {
      dispatcher.enqueue(
        generation: listenerGeneration,
        terminal: false,
        makeEvent: { 42 },
        beforeTerminal: {}
      )
    }
    wait(for: [delivered], timeout: 5)
  }

  func testInvalidationReleasesSinkAndDoesNotBuildStaleEvents() {
    final class Owner {}
    let dispatcher = TaskEventDispatcher<Int>()
    weak var owner: Owner?
    onMain {
      let capturedOwner = Owner()
      owner = capturedOwner
      let generation = dispatcher.listen { [capturedOwner] _ in _ = capturedOwner }
      dispatcher.enqueue(
        generation: generation, terminal: false,
        makeEvent: {
          XCTFail("Invalidated events should not be constructed")
          return 1
        }, beforeTerminal: {})
      dispatcher.invalidate()
    }
    drainMainQueue()
    XCTAssertNil(owner)
  }
}
