// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class HttpMetricPlatform extends PlatformInterface {
  HttpMetricPlatform() : super(token: _token);

  static final Object _token = Object();

  /// Ensures that any delegate class has extended a [HttpMetricPlatform].
  static void verify(HttpMetricPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

  /// HttpResponse code of the request.
  int? get httpResponseCode {
    throw UnimplementedError('get httpResponseCode is not implemented');
  }

  /// Size of the request payload.
  int? get requestPayloadSize {
    throw UnimplementedError('get requestPayloadSize is not implemented');
  }

  /// Content type of the response such as text/html, application/json, etc...
  String? get responseContentType {
    throw UnimplementedError('get responseContentType is not implemented');
  }

  /// Size of the response payload.
  int? get responsePayloadSize {
    throw UnimplementedError('get responsePayloadSize is not implemented');
  }

  /// Sets the httpResponse code of the request
  set httpResponseCode(int? httpResponseCode) {
    throw UnimplementedError('set httpResponseCode() is not implemented');
  }

  /// Sets the size of the request payload
  set requestPayloadSize(int? requestPayloadSize) {
    throw UnimplementedError('set requestPayloadSize() is not implemented');
  }

  /// Sets the size of the response payload
  set responsePayloadSize(int? responsePayloadSize) {
    throw UnimplementedError('set responsePayload() is not implemented');
  }

  /// Content type of the response such as text/html, application/json, etc..
  set responseContentType(String? responseContentType) {
    throw UnimplementedError('set responseContentType() is not implemented');
  }

  /// Marks the start time of the request
  Future<void> start() {
    throw UnimplementedError('start() is not implemented');
  }

  /// Marks the end time of the response and queues the network request metric on the device for transmission.
  Future<void> stop() {
    throw UnimplementedError('stop() is not implemented');
  }

  /// Sets a value as a string for the specified attribute. Updates the value of the attribute if a value had already existed.
  void putAttribute(String name, String value) {
    throw UnimplementedError('putAttribute() is not implemented');
  }

  /// Removes an attribute from the list. Does nothing if the attribute does not exist.
  void removeAttribute(String name) {
    throw UnimplementedError('removeAttribute() is not implemented');
  }

  /// Returns the value of an attribute.
  String? getAttribute(String name) {
    throw UnimplementedError('getAttribute() is not implemented');
  }

  /// Returns the map of all the attributes added to this HttpMetric.
  Map<String, String> getAttributes() {
    throw UnimplementedError('getAttributes() is not implemented');
  }
}
