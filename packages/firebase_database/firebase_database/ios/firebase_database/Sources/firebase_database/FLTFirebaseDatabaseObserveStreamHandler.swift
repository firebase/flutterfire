// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseDatabase

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

@objc class FLTFirebaseDatabaseObserveStreamHandler: NSObject, FlutterStreamHandler {
  private var databaseHandle: DatabaseHandle = 0
  private let databaseQuery: DatabaseQuery
  private let disposeBlock: () -> Void

  init(databaseQuery: DatabaseQuery, disposeBlock: @escaping () -> Void) {
    self.databaseQuery = databaseQuery
    self.disposeBlock = disposeBlock
    super.init()
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    guard let args = arguments as? [String: Any],
          let eventTypeString = args["eventType"] as? String
    else {
      return nil
    }

    let observeBlock: (DataSnapshot, String?) -> Void = { [weak self] snapshot, previousChildKey in
      var eventDictionary: [String: Any] = [
        "eventType": eventTypeString,
      ]

      let snapshotDict = FLTFirebaseDatabaseUtils.dictionary(
        from: snapshot, withPreviousChildKey: previousChildKey
      )
      eventDictionary.merge(snapshotDict) { _, new in new }

      DispatchQueue.main.async {
        events(eventDictionary)
      }
    }

    let cancelBlock: (Error) -> Void = { [weak self] error in
      let codeAndMessage = FLTFirebaseDatabaseUtils.codeAndMessage(from: error)
      let code = codeAndMessage[0]
      let message = codeAndMessage[1]
      let details: [String: Any] = [
        "code": code,
        "message": message,
      ]

      DispatchQueue.main.async {
        let flutterError = FlutterError(
          code: code,
          message: message,
          details: details
        )
        events(flutterError)
      }
    }

    let eventType = FLTFirebaseDatabaseUtils.eventType(from: eventTypeString)
    databaseHandle = databaseQuery.observe(
      eventType, andPreviousSiblingKeyWith: observeBlock, withCancel: cancelBlock
    )

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    disposeBlock()
    databaseQuery.removeObserver(withHandle: databaseHandle)
    return nil
  }
}
