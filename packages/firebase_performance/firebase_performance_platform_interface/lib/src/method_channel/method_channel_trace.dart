// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';
import 'utils/exception.dart';

class MethodChannelTrace extends TracePlatform {
  MethodChannelTrace(this._methodChannelHandle, String name)
      : _traceHandle = _methodChannelHandle + 1,
        super(name);

  final int _methodChannelHandle;
  final int _traceHandle;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final Map<String, int> _metrics = <String, int>{};
  final Map<String, String> _attributes = <String, String>{};

  static const int maxTraceNameLength = 100;

  @override
  Future<void> start() async {
    if (_hasStopped) return;

    try {
      //TODO: update so that the method call & handle is passed on one method channel call (start()) instead.
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'FirebasePerformance#newTrace',
        <String, Object?>{
          'handle': _methodChannelHandle,
          'traceHandle': _traceHandle,
          'name': name
        },
      );
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'Trace#start',
        <String, Object?>{'handle': _traceHandle},
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
        'Trace#stop',
        <String, Object?>{'handle': _traceHandle},
      );
      _hasStopped = true;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> incrementMetric(String name, int value) async {
    if (!_hasStarted || _hasStopped) return;

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'Trace#incrementMetric',
        <String, Object?>{'handle': _traceHandle, 'name': name, 'value': value},
      );
      _metrics[name] = (_metrics[name] ?? 0) + value;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setMetric(String name, int value) async {
    if (!_hasStarted || _hasStopped) return;

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'Trace#setMetric',
        <String, Object?>{'handle': _traceHandle, 'name': name, 'value': value},
      );
      _metrics[name] = value;
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  int getMetric(String name) {
    return _metrics[name] ?? 0;
  }

  @override
  Future<void> putAttribute(String name, String value) async {
    if (_hasStopped ||
        name.length > TracePlatform.maxAttributeKeyLength ||
        value.length > TracePlatform.maxAttributeValueLength ||
        _attributes.length == TracePlatform.maxCustomAttributes) {
      return;
    }

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'Trace#putAttribute',
        <String, Object?>{
          'handle': _traceHandle,
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
    if (_hasStopped) return Future<void>.value();

    try {
      await MethodChannelFirebasePerformance.channel.invokeMethod<void>(
        'Trace#removeAttribute',
        <String, Object?>{'handle': _traceHandle, 'name': name},
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
