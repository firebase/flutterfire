// Copyright 2026 The Chromium Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Serializes task events and invalidates deliveries queued by an earlier listener.
final class TaskEventDispatcher<Event> {
  private var sink: ((Event) -> Void)?
  private var generation: UInt64 = 0

  func listen(_ sink: @escaping (Event) -> Void) -> UInt64 {
    invalidate()
    self.sink = sink
    return generation
  }

  func invalidate() {
    dispatchPrecondition(condition: .onQueue(.main))
    generation &+= 1
    sink = nil
  }

  func enqueue(
    generation: UInt64, terminal: Bool,
    makeEvent: @escaping () -> Event?,
    beforeTerminal: @escaping () -> Void
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self, self.generation == generation, let sink = self.sink,
        let event = makeEvent()
      else { return }
      if terminal {
        self.invalidate()
        beforeTerminal()
      }
      sink(event)
    }
  }
}
