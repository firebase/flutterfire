// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';
import 'utils/exception.dart';

class MethodChannelHttpMetric extends HttpMetricPlatform {
  MethodChannelHttpMetric(
    this._methodChannelHandle,
    String url,
    HttpMethod httpMethod,
  )   : _httpMetricHandle = _methodChannelHandle + 1,
        super(url, httpMethod);

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
  Future<void> setHttpResponseCode(int? httpResponseCode) async {
    if (_hasStopped) return;

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#httpResponseCode',
        <String, Object?>{
          'handle': _httpMetricHandle,
          'httpResponseCode': httpResponseCode,
        },
      );
      _httpResponseCode = httpResponseCode;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setRequestPayloadSize(int? requestPayloadSize) async {
    if (_hasStopped) return;

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#requestPayloadSize',
        <String, Object?>{
          'handle': _httpMetricHandle,
          'requestPayloadSize': requestPayloadSize,
        },
      );
      _requestPayloadSize = requestPayloadSize;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setResponseContentType(String? responseContentType) async {
    if (_hasStopped) return;
    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#responseContentType',
        <String, Object?>{
          'handle': _httpMetricHandle,
          'responseContentType': responseContentType,
        },
      );
      _responseContentType = responseContentType;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setResponsePayloadSize(int? responsePayloadSize) async {
    if (_hasStopped) return;
    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#responsePayloadSize',
        <String, Object?>{
          'handle': _httpMetricHandle,
          'responsePayloadSize': responsePayloadSize,
        },
      );
      _responsePayloadSize = responsePayloadSize;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
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
        <String, Object?>{'handle': _httpMetricHandle},
      );
      _hasStopped = true;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> putAttribute(String name, String value) async {
    if (_hasStopped ||
        name.length > HttpMetricPlatform.maxAttributeKeyLength ||
        value.length > HttpMetricPlatform.maxAttributeValueLength ||
        _attributes.length == HttpMetricPlatform.maxCustomAttributes) {
      return;
    }
    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#putAttribute',
        <String, Object?>{
          'handle': _httpMetricHandle,
          'name': name,
          'value': value,
        },
      );
      _attributes[name] = value;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> removeAttribute(String name) async {
    if (_hasStopped) return;
    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'HttpMetric#removeAttribute',
        <String, Object?>{'handle': _httpMetricHandle, 'name': name},
      );
      _attributes.remove(name);
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  String? getAttribute(String name) => _attributes[name];

  @override
  Map<String, String> getAttributes() {
    return {..._attributes};
  }
}
