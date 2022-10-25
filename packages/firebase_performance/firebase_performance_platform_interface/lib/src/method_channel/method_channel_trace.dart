// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';
import 'utils/exception.dart';

class MethodChannelTrace extends TracePlatform {
  MethodChannelTrace(this._name) : super();

  int? _traceHandle;
  final String _name;

  bool _hasStopped = false;

  final Map<String, int> _metrics = <String, int>{};
  final Map<String, String> _attributes = <String, String>{};

  static const int maxTraceNameLength = 100;

  @override
  Future<void> start() async {
    if (_traceHandle != null) return;

    try {
      _traceHandle =
          await MethodChannelFirebasePerformance.channel.invokeMethod<int>(
        'FirebasePerformance#traceStart',
        <String, Object?>{'name': _name},
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> stop() async {
    if (_traceHandle == null || _hasStopped) return;

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'FirebasePerformance#traceStop',
        <String, Object?>{
          'handle': _traceHandle,
          'metrics': _metrics,
          'attributes': _attributes,
        },
      );
      _hasStopped = true;
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  void incrementMetric(String name, int value) {
    _metrics[name] = (_metrics[name] ?? 0) + value;
  }

  @override
  void setMetric(String name, int value) {
    _metrics[name] = value;
  }

  @override
  int getMetric(String name) {
    return _metrics[name] ?? 0;
  }

  @override
  void putAttribute(String name, String value) {
    if (name.length > TracePlatform.maxAttributeKeyLength ||
        value.length > TracePlatform.maxAttributeValueLength ||
        _attributes.length == TracePlatform.maxCustomAttributes) {
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
