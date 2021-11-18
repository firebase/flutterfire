// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';

abstract class HttpMetricPlatform extends PlatformInterface {
  HttpMetricPlatform(this.url, this.httpMethod) : super(token: _token);

  static final Object _token = Object();

  /// Ensures that any delegate class has extended a [HttpMetricPlatform].
  static void verifyExtends(HttpMetricPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

  final String url;
  final HttpMethod httpMethod;

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

  Future<void> setHttpResponseCode(int? httpResponseCode) {
    throw UnimplementedError('set httpResponseCode is not implemented');
  }

  Future<void> setRequestPayloadSize(int? requestPayloadSize) {
    throw UnimplementedError('set requestPayloadSize is not implemented');
  }

  Future<void> setResponsePayloadSize(int? responsePayloadSize) {
    throw UnimplementedError('set responsePayload is not implemented');
  }

  Future<void> setResponseContentType(String? responseContentType) {
    throw UnimplementedError('set responseContentType is not implemented');
  }

  Future<void> start() {
    throw UnimplementedError('start() is not implemented');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() is not implemented');
  }

  Future<void> putAttribute(String name, String value) {
    throw UnimplementedError('putAttribute() is not implemented');
  }

  Future<void> removeAttribute(String name) {
    throw UnimplementedError('removeAttribute() is not implemented');
  }

  String? getAttribute(String name) {
    throw UnimplementedError('getAttribute() is not implemented');
  }

  Map<String, String> getAttributes() {
    throw UnimplementedError('getAttributes() is not implemented');
  }
}
