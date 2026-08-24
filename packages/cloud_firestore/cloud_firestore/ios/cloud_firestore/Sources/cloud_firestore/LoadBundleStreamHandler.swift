// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import FirebaseFirestore
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

final class LoadBundleStreamHandler: NSObject, FlutterStreamHandler {
  private let firestore: Firestore
  private let bundle: FlutterStandardTypedData
  private var task: LoadBundleTask?

  init(firestore: Firestore, bundle: FlutterStandardTypedData) {
    self.firestore = firestore
    self.bundle = bundle
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    task = firestore.loadBundle(bundle.data) { _, error in
      if let error {
        let (code, message) = FirebaseFirestoreUtils.errorCodeAndMessage(from: error)
        DispatchQueue.main.async {
          events(
            FLTFirebasePlugin.createFlutterError(
              fromCode: code,
              message: message,
              optionalDetails: ["code": code, "message": message],
              andOptionalNSError: error as NSError
            )
          )
        }
      }
    }

    task?.addObserver { progress in
      DispatchQueue.main.async {
        if progress.state != .error {
          events(progress)
        }
      }
    }

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    task?.removeAllObservers()
    task = nil
    return nil
  }
}
