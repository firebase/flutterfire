// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

final class TransactionStreamHandler: NSObject, FlutterStreamHandler {
  private let transactionId: String
  private let firestore: Firestore
  private let timeout: Int
  private let maxAttempts: Int
  private let started: (Transaction) -> Void
  private let ended: () -> Void
  private let semaphore = DispatchSemaphore(value: 0)
  private var resultType: InternalTransactionResult = .success
  private var commands: [InternalTransactionCommand?] = []

  init(
    id transactionId: String,
    firestore: Firestore,
    timeout: Int,
    maxAttempts: Int,
    started: @escaping (Transaction) -> Void,
    ended: @escaping () -> Void
  ) {
    self.transactionId = transactionId
    self.firestore = firestore
    self.timeout = timeout
    self.maxAttempts = maxAttempts
    self.started = started
    self.ended = ended
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    let options = TransactionOptions()
    options.maxAttempts = maxAttempts

    firestore.runTransaction(
      with: options,
      block: { [weak self] transaction, _ in
        guard let self else { return nil }
        self.started(transaction)

        DispatchQueue.main.async {
          events([
            "appName": FLTFirebasePlugin.firebaseAppName(fromIosName: self.firestore.app.name)
              as Any
          ])
        }

        let timedOut = self.semaphore.wait(
          timeout: .now() + .milliseconds(self.timeout)
        )
        if timedOut == .timedOut {
          let (code, message) = FirebaseFirestoreUtils.errorCodeAndMessage(
            from: NSError(
              domain: FirestoreErrorDomain,
              code: FirestoreErrorCode.deadlineExceeded.rawValue,
              userInfo: [:]
            )
          )
          DispatchQueue.main.async {
            events(["error": ["code": code, "message": message]])
          }
        }

        if self.resultType == .failure {
          return nil
        }

        for command in self.commands {
          guard let command else { continue }
          let reference = self.firestore.document(command.path)
          switch command.type {
          case .deleteType:
            transaction.deleteDocument(reference)
          case .update:
            if let data = command.data as? [AnyHashable: Any] {
              transaction.updateData(data, forDocument: reference)
            }
          case .set:
            let data = command.data as? [String: Any] ?? [:]
            if command.option?.merge == true {
              transaction.setData(data, forDocument: reference, merge: true)
            } else if let mergeFields = command.option?.mergeFields {
              transaction.setData(
                data,
                forDocument: reference,
                mergeFields: PigeonParser.parseFieldPath(mergeFields)
              )
            } else {
              transaction.setData(data, forDocument: reference)
            }
          case .get:
            break
          }
        }
        return nil
      },
      completion: { [weak self] _, error in
        if let error {
          let (code, message) = FirebaseFirestoreUtils.errorCodeAndMessage(from: error)
          DispatchQueue.main.async {
            events(["error": ["code": code, "message": message]])
          }
        } else {
          DispatchQueue.main.async {
            events(["complete": true])
          }
        }
        DispatchQueue.main.async {
          events(FlutterEndOfEventStream)
        }
        self?.ended()
      }
    )

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    semaphore.signal()
    return nil
  }

  func receiveTransactionResponse(
    _ resultType: InternalTransactionResult,
    commands: [InternalTransactionCommand?]?
  ) {
    self.resultType = resultType
    self.commands = commands ?? []
    semaphore.signal()
  }
}
