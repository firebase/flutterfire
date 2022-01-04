// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_performance;

/// Metric used to collect data for network requests/responses.
///
/// It is possible to have more than one [HttpMetric] running at a time.
/// Attributes can also be added to help measure performance related events. A
/// [HttpMetric] also measures the time between calling `start()` and `stop()`.
///
/// Data collected is automatically sent to the associated Firebase console
/// after stop() is called.
///
/// You can confirm that Performance Monitoring results appear in the Firebase
/// console. Results should appear within 12 hours.
///
/// It is highly recommended that one always calls `start()` and `stop()` on
/// each created [HttpMetric] to avoid leaking on the platform side.
class HttpMetric {
  HttpMetric._(this._delegate);

  HttpMetricPlatform _delegate;

  /// HttpResponse code of the request.
  int? get httpResponseCode => _delegate.httpResponseCode;

  /// Size of the request payload.
  int? get requestPayloadSize => _delegate.requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String? get responseContentType => _delegate.responseContentType;

  /// Size of the response payload.
  int? get responsePayloadSize => _delegate.responsePayloadSize;

  /// HttpResponse code of the request.
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set httpResponseCode(int? httpResponseCode) {
    _delegate.httpResponseCode = httpResponseCode;
  }

  /// Size of the request payload.
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set requestPayloadSize(int? requestPayloadSize) {
    _delegate.requestPayloadSize = requestPayloadSize;
  }

  /// Content type of the response such as text/html, application/json, etc...
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set responseContentType(String? responseContentType) {
    _delegate.responseContentType = responseContentType;
  }

  /// Size of the response payload.
  ///
  /// If the [HttpMetric] has already been stopped, returns immediately without
  /// taking action.
  set responsePayloadSize(int? responsePayloadSize) {
    _delegate.responsePayloadSize = responsePayloadSize;
  }

  /// Starts this [HttpMetric].
  ///
  /// Can only be called once.
  ///
  /// Using `await` with this method is only necessary when accurate timing
  /// is relevant.
  Future<void> start() {
    return _delegate.start();
  }

  /// Stops this [HttpMetric].
  ///
  /// Can only be called once and only after start(), Data collected is
  /// automatically sent to the associate Firebase console after stop() is
  /// called. You can confirm that Performance Monitoring results appear in the
  /// Firebase console. Results should appear within 12 hours.
  ///
  /// Not necessary to use `await` with this method.
  Future<void> stop() {
    return _delegate.stop();
  }

  /// Sets a String [value] for the specified attribute with [name].
  ///
  /// Updates the value of the attribute if the attribute already exists.
  /// The maximum number of attributes that can be added are
  /// [maxCustomAttributes]. An attempt to add more than [maxCustomAttributes]
  /// to this object will return without adding the attribute.
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters. If the name has a length greater
  /// than [maxAttributeKeyLength] or the value has a length greater than
  /// [maxAttributeValueLength], this method will return without adding
  /// anything.
  ///
  /// If this object has been stopped, this method returns without adding the
  /// attribute.
  void putAttribute(String name, String value) {
    return _delegate.putAttribute(name, value);
  }

  /// Removes an already added attribute.
  ///
  /// If this object has been stopped, this method returns without removing the
  /// attribute.
  void removeAttribute(String name) {
    return _delegate.removeAttribute(name);
  }

  /// Returns the value of an attribute.
  ///
  /// Returns `null` if an attribute with this [name] has not been added.
  String? getAttribute(String name) => _delegate.getAttribute(name);

  /// All attributes added.
  Map<String, String> getAttributes() {
    return _delegate.getAttributes();
  }
}
