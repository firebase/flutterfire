// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:firebase_performance_platform_interface/src/platform_interface/platform_interface_attributes.dart';
import 'package:flutter/services.dart';

import '../../firebase_performance_platform_interface.dart';
import '../platform_interface/platform_interface_firebase_performance.dart';

/// The method channel implementation of [FirebaseAnalyticsPlatform].
class MethodChannelFirebasePerformance extends FirebasePerformancePlatform {
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  MethodChannelFirebasePerformance._()
      : _handle = _nextHandle++,
        super();

  static int _nextHandle = 0;
  final int _handle;

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebasePerformance get instance {
    return MethodChannelFirebasePerformance._();
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    final isPerformanceCollectionEnabled = await channel.invokeMethod<bool>(
      'FirebasePerformance#isPerformanceCollectionEnabled',
      <String, Object?>{'handle': _handle},
    );
    return isPerformanceCollectionEnabled!;
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) {
    return channel.invokeMethod<void>(
      'FirebasePerformance#setPerformanceCollectionEnabled',
      <String, Object?>{'handle': _handle, 'enable': enabled},
    );
  }

  @override
  TracePlatform newTrace(String name) {
    final int handle = _nextHandle++;

    channel.invokeMethod<void>(
      'FirebasePerformance#newTrace',
      <String, Object?>{'handle': _handle, 'traceHandle': handle, 'name': name},
    );

    return MethodChannelTrace._(handle, name);
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    final int handle = _nextHandle++;

    channel.invokeMethod<void>(
      'FirebasePerformance#newHttpMetric',
      <String, Object?>{
        'handle': _handle,
        'httpMetricHandle': handle,
        'url': url,
        'httpMethod': httpMethod.toString(),
      },
    );

    return MethodChannelHttpMetric._(handle, url, httpMethod);
  }
}

class MethodChannelTrace extends TracePlatform {
  MethodChannelTrace._(this._handle, String name) : super(name);

  final int _handle;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final Map<String, int> _metrics = <String, int>{};

  static const int maxTraceNameLength = 100;

  @override
  Future<void> start() {
    if (_hasStopped) return Future<void>.value();

    _hasStarted = true;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#start',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> stop() {
    if (_hasStopped) return Future<void>.value();

    _hasStopped = true;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#stop',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> incrementMetric(String name, int value) {
    if (!_hasStarted || _hasStopped) {
      return Future<void>.value();
    }

    _metrics[name] = (_metrics[name] ?? 0) + value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#incrementMetric',
      <String, Object?>{'handle': _handle, 'name': name, 'value': value},
    );
  }

  @override
  Future<void> setMetric(String name, int value) {
    if (!_hasStarted || _hasStopped) return Future<void>.value();

    _metrics[name] = value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#setMetric',
      <String, Object?>{'handle': _handle, 'name': name, 'value': value},
    );
  }

  @override
  Future<int> getMetric(String name) async {
    if (_hasStopped) return Future<int>.value(_metrics[name] ?? 0);

    final metric =
    await MethodChannelFirebasePerformance.channel.invokeMethod<int>(
      'Trace#getMetric',
      <String, Object?>{'handle': _handle, 'name': name},
    );
    return metric ?? 0;
  }

  // TODO(kroikie): Find a better way to inherit these attribute methods
  @override
  Future<void> putAttribute(String name, String value) {
    return MethodChannelPerformanceAttributes._(_handle).putAttribute(name, value);
  }

  @override
  Future<void> removeAttribute(String name) {
    return MethodChannelPerformanceAttributes._(_handle).removeAttribute(name);
  }

  @override
  String? getAttribute(String name) {
    return MethodChannelPerformanceAttributes._(_handle).getAttribute(name);
  }

  @override
  Future<Map<String, String>> getAttributes() {
    return MethodChannelPerformanceAttributes._(_handle).getAttributes();
  }
}

class MethodChannelHttpMetric extends HttpMetricPlatform {
  MethodChannelHttpMetric._(this._handle, String url, HttpMethod httpMethod)
      : super(url, httpMethod);

  final int _handle;

  int? _httpResponseCode;
  int? _requestPayloadSize;
  String? _responseContentType;
  int? _responsePayloadSize;

  bool _hasStopped = false;

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
    if (_hasStopped) return;

    _httpResponseCode = httpResponseCode;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#httpResponseCode',
      <String, Object?>{
        'handle': _handle,
        'httpResponseCode': httpResponseCode,
      },
    );
  }

  @override
  set requestPayloadSize(int? requestPayloadSize) {
    if (_hasStopped) return;

    _requestPayloadSize = requestPayloadSize;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#requestPayloadSize',
      <String, Object?>{
        'handle': _handle,
        'requestPayloadSize': requestPayloadSize,
      },
    );
  }

  @override
  set responseContentType(String? responseContentType) {
    if (_hasStopped) return;

    _responseContentType = responseContentType;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#responseContentType',
      <String, Object?>{
        'handle': _handle,
        'responseContentType': responseContentType,
      },
    );
  }

  @override
  set responsePayloadSize(int? responsePayloadSize) {
    if (_hasStopped) return;

    _responsePayloadSize = responsePayloadSize;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#responsePayloadSize',
      <String, Object?>{
        'handle': _handle,
        'responsePayloadSize': responsePayloadSize,
      },
    );
  }

  @override
  Future<void> start() {
    if (_hasStopped) return Future<void>.value();

    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#start',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> stop() {
    if (_hasStopped) return Future<void>.value();

    _hasStopped = true;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#stop',
      <String, Object?>{'handle': _handle},
    );
  }

  // TODO(kroikie): Find a better way to inherit these attribute methods
  @override
  Future<void> putAttribute(String name, String value) {
    return MethodChannelPerformanceAttributes._(_handle).putAttribute(name, value);
  }

  @override
  Future<void> removeAttribute(String name) {
    return MethodChannelPerformanceAttributes._(_handle).removeAttribute(name);
  }

  @override
  String? getAttribute(String name) {
    return MethodChannelPerformanceAttributes._(_handle).getAttribute(name);
  }

  @override
  Future<Map<String, String>> getAttributes() {
    return MethodChannelPerformanceAttributes._(_handle).getAttributes();
  }
}

class MethodChannelPerformanceAttributes extends PerformanceAttributesPlatform {
  MethodChannelPerformanceAttributes._(this._handle);

  final Map<String, String> _attributes = <String, String>{};

  bool _hasStopped = false;

  final int _handle;

  @override
  Future<void> putAttribute(String name, String value) {
    if (_hasStopped ||
        name.length > PerformanceAttributesPlatform.maxAttributeKeyLength ||
        value.length > PerformanceAttributesPlatform.maxAttributeValueLength ||
        _attributes.length ==
            PerformanceAttributesPlatform.maxCustomAttributes) {
      return Future<void>.value();
    }

    _attributes[name] = value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'PerformanceAttributes#putAttribute',
      <String, Object?>{
        'handle': _handle,
        'name': name,
        'value': value,
      },
    );
  }

  @override
  Future<void> removeAttribute(String name) {
    if (_hasStopped) return Future<void>.value();

    _attributes.remove(name);
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'PerformanceAttributes#removeAttribute',
      <String, Object?>{'handle': _handle, 'name': name},
    );
  }

  @override
  String? getAttribute(String name) => _attributes[name];

  @override
  Future<Map<String, String>> getAttributes() async {
    if (_hasStopped) {
      return Future<Map<String, String>>.value(
        Map<String, String>.unmodifiable(_attributes),
      );
    }

    final attributes = await MethodChannelFirebasePerformance.channel
        .invokeMapMethod<String, String>(
      'PerformanceAttributes#getAttributes',
      <String, Object?>{'handle': _handle},
    );
    return attributes ?? {};
  }
}
