// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif
import FirebasePerformance

let FirebasePerformanceChannelName = "plugins.flutter.io/firebase_performance"

extension FlutterError: Error {}

public class FirebasePerformancePlugin: NSObject, FlutterPlugin, FLTFirebasePluginProtocol,
  FirebasePerformanceHostApi {
  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  public func firebaseLibraryName() -> String {
    "flutter-fire-perf"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func flutterChannelName() -> String {
    FirebasePerformanceChannelName
  }

  private var httpMetrics: [Int: HTTPMetric] = [:]
  private var traces: [Int: Trace] = [:]
  private var traceHandle: Int = 0
  private var httpMetricHandle: Int = 0

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif
    let instance = FirebasePerformancePlugin()
    FirebasePerformanceHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  public func setPerformanceCollectionEnabled(enabled: Bool,
                                              completion: @escaping (Result<Void, Error>) -> Void) {
    Performance.sharedInstance().isDataCollectionEnabled = enabled
    completion(.success(()))
  }

  public func isPerformanceCollectionEnabled(completion: @escaping (Result<Bool, Error>) -> Void) {
    let result = Performance.sharedInstance().isDataCollectionEnabled
    completion(.success(result))
  }

  public func startTrace(name: String, completion: @escaping (Result<Int64, Error>) -> Void) {
    let trace = Performance.sharedInstance().trace(name: name)
    trace?.start()
    traceHandle += 1
    traces[traceHandle] = trace
    completion(.success(Int64(traceHandle)))
  }

  func stopTrace(handle: Int64, attributes: TraceAttributes,
                 completion: @escaping (Result<Void, Error>) -> Void) {
    guard let trace = traces[Int(handle)] else {
      completion(.success(()))
      return
    }

    if let metrics = attributes.metrics {
      for (key, value) in metrics {
        trace.setValue(value, forMetric: key)
      }
    }

    if let attributes = attributes.attributes {
      for (key, value) in attributes {
        trace.setValue(value, forAttribute: key)
      }
    }

    trace.stop()
    traces.removeValue(forKey: Int(handle))
    completion(.success(()))
  }

  func startHttpMetric(options: HttpMetricOptions,
                       completion: @escaping (Result<Int64, Error>) -> Void) {
    guard let url = URL(string: options.url) else {
      completion(.failure(FlutterError(code: "invalid-url", message: "Invalid url", details: nil)))
      return
    }

    guard let httpMethod = parseHttpMethod(options.httpMethod) else {
      completion(.failure(FlutterError(
        code: "invalid-argument",
        message: "Invalid httpMethod",
        details: nil
      )))
      return
    }

    let httpMetric = HTTPMetric(url: url, httpMethod: httpMethod)
    httpMetric?.start()
    httpMetricHandle += 1
    httpMetrics[httpMetricHandle] = httpMetric
    completion(.success(Int64(httpMetricHandle)))
  }

  func stopHttpMetric(handle: Int64, attributes: HttpMetricAttributes,
                      completion: @escaping (Result<Void, Error>) -> Void) {
    guard let httpMetric = httpMetrics[Int(handle)] else {
      completion(.success(()))
      return
    }

    if let httpResponseCode = attributes.httpResponseCode {
      httpMetric.responseCode = Int(httpResponseCode)
    }
    if let responseContentType = attributes.responseContentType {
      httpMetric.responseContentType = responseContentType
    }
    if let requestPayloadSize = attributes.requestPayloadSize {
      httpMetric.requestPayloadSize = Int(requestPayloadSize)
    }
    if let responsePayloadSize = attributes.responsePayloadSize {
      httpMetric.responsePayloadSize = Int(responsePayloadSize)
    }

    if let attributes = attributes.attributes {
      for (key, value) in attributes {
        httpMetric.setValue(value, forAttribute: key)
      }
    }

    httpMetric.stop()
    httpMetrics.removeValue(forKey: Int(handle))
    completion(.success(()))
  }

  private func parseHttpMethod(_ method: HttpMethod) -> HTTPMethod? {
    switch method {
    case HttpMethod.connect: return .connect
    case HttpMethod.delete: return .delete
    case HttpMethod.get: return .get
    case HttpMethod.head: return .head
    case HttpMethod.options: return .options
    case HttpMethod.patch: return .patch
    case HttpMethod.post: return .post
    case HttpMethod.put: return .put
    case HttpMethod.trace: return .trace
    }
  }
}
