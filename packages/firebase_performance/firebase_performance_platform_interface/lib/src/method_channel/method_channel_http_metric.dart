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
    this._url,
    this._httpMethod,
  ) : super();

  final int _methodChannelHandle;
  final int _httpMetricHandle;
  final String _url;
  final HttpMethod _httpMethod;
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
          'url': _url,
          'httpMethod': _httpMethod.toString(),
        },
      );
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#start',
        <String, Object?>{'handle': _httpMetricHandle},
      );
      _hasStarted = true;
    } catch (e, s) {
      convertPlatformException(e, s);
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
          if (_httpResponseCode != null) 'httpResponseCode': _httpResponseCode,
          if (_requestPayloadSize != null)
            'requestPayloadSize': _requestPayloadSize,
          if (_responseContentType != null)
            'responseContentType': _responseContentType,
          if (_responsePayloadSize != null)
            'responsePayloadSize': _responsePayloadSize,
        },
      );
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
}
