// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_performance_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';
import 'utils/exception.dart';

class MethodChannelHttpMetric extends HttpMetricPlatform {
  MethodChannelHttpMetric(
    this._url,
    this._httpMethod,
  ) : super();

  int? _httpMetricHandle;
  final String _url;
  final HttpMethod _httpMethod;
  int? _httpResponseCode;
  int? _requestPayloadSize;
  String? _responseContentType;
  int? _responsePayloadSize;

  bool _hasStopped = false;

  final Map<String, String> _attributes = <String, String>{};

  @override
  int? get httpResponseCode => _httpResponseCode;

  @override
  int? get requestPayloadSize => _requestPayloadSize;

  @override
  String? get responseContentType => _responseContentType;

  @override
  int? get responsePayloadSize => _responsePayloadSize;

  @override
  set httpResponseCode(int? httpResponseCode) {
    _httpResponseCode = httpResponseCode;
  }

  @override
  set requestPayloadSize(int? requestPayloadSize) {
    _requestPayloadSize = requestPayloadSize;
  }

  @override
  set responseContentType(String? responseContentType) {
    _responseContentType = responseContentType;
  }

  @override
  set responsePayloadSize(int? responsePayloadSize) {
    _responsePayloadSize = responsePayloadSize;
  }

  @override
  Future<void> start() async {
    if (_httpMetricHandle != null) return;
    try {
      final options = pigeon.HttpMetricOptions(
        url: _url,
        httpMethod: _convertHttpMethod(_httpMethod),
      );
      _httpMetricHandle = await MethodChannelFirebasePerformance.pigeonChannel
          .startHttpMetric(options);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> stop() async {
    if (_httpMetricHandle == null || _hasStopped) return;
    try {
      final attributes = pigeon.HttpMetricAttributes(
        httpResponseCode: _httpResponseCode,
        requestPayloadSize: _requestPayloadSize,
        responsePayloadSize: _responsePayloadSize,
        responseContentType: _responseContentType,
        attributes: _attributes,
      );
      await MethodChannelFirebasePerformance.pigeonChannel
          .stopHttpMetric(_httpMetricHandle!, attributes);
      _hasStopped = true;
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  void putAttribute(String name, String value) {
    if (name.length > HttpMetricPlatform.maxAttributeKeyLength ||
        value.length > HttpMetricPlatform.maxAttributeValueLength ||
        _attributes.length == HttpMetricPlatform.maxCustomAttributes) {
      return;
    }
    _attributes[name] = value;
  }

  @override
  void removeAttribute(String name) {
    _attributes.remove(name);
  }

  @override
  String? getAttribute(String name) => _attributes[name];

  @override
  Map<String, String> getAttributes() {
    return {..._attributes};
  }

  pigeon.HttpMethod _convertHttpMethod(HttpMethod method) {
    switch (method) {
      case HttpMethod.Connect:
        return pigeon.HttpMethod.connect;
      case HttpMethod.Delete:
        return pigeon.HttpMethod.delete;
      case HttpMethod.Get:
        return pigeon.HttpMethod.get;
      case HttpMethod.Head:
        return pigeon.HttpMethod.head;
      case HttpMethod.Options:
        return pigeon.HttpMethod.options;
      case HttpMethod.Patch:
        return pigeon.HttpMethod.patch;
      case HttpMethod.Post:
        return pigeon.HttpMethod.post;
      case HttpMethod.Put:
        return pigeon.HttpMethod.put;
      case HttpMethod.Trace:
        return pigeon.HttpMethod.trace;
    }
  }
}
