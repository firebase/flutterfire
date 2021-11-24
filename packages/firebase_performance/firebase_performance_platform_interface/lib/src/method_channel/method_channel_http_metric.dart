// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';
import 'utils/exception.dart';

class MethodChannelHttpMetric extends HttpMetricPlatform {
  MethodChannelHttpMetric(
    this._methodChannelHandle,
    this._httpMetricHandle,
    String url,
    HttpMethod httpMethod,
  ) : super(url, httpMethod);

  final int _methodChannelHandle;
  final int _httpMetricHandle;

  int? _httpResponseCode;
  int? _requestPayloadSize;
  String? _responseContentType;
  int? _responsePayloadSize;

  bool _hasStarted = false;
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
    if (_hasStopped) return;
    try {
      //TODO: update so that the method call & handle is passed on one method channel call (start()) instead.
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'FirebasePerformance#newHttpMetric',
        <String, Object?>{
          'handle': _methodChannelHandle,
          'httpMetricHandle': _httpMetricHandle,
          'url': url,
          'httpMethod': httpMethod.toString(),
        },
      );
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#start',
        <String, Object?>{'handle': _httpMetricHandle},
      );
      _hasStarted = true;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> stop() async {
    if (!_hasStarted || _hasStopped) return;
    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#stop',
        <String, Object?>{
          'handle': _httpMetricHandle,
          'attributes': _attributes,
          'httpResponseCode': _httpResponseCode,
          'requestPayloadSize': _requestPayloadSize,
          'responseContentType': _responseContentType,
          'responsePayloadSize': _responsePayloadSize,
        },
      );
      _hasStopped = true;
    } catch (e, s) {
      throw convertPlatformException(e, s);
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
}
