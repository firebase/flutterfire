// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

// TODO(Lyokone): should be deleted once all plugins are migrated to use js_interop

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

import 'func.dart';

// Hot restart exists only in debug mode. This must match Flutter's
// kDebugMode (`!dart.vm.product && !dart.vm.profile`). Profile builds leave
// dart.vm.product false, so gating on product mode alone still stores JS
// unsubscribe functions on window. Plugins then share the key 'no-op'
// outside debug and cancel the previous listener on the next subscription.
// See https://github.com/firebase/flutterfire/issues/18728.
// ignore: do_not_use_environment
const bool _kReleaseMode = bool.fromEnvironment('dart.vm.product');

// ignore: do_not_use_environment
const bool _kProfileMode = bool.fromEnvironment('dart.vm.profile');

const bool _kDebugMode = !_kReleaseMode && !_kProfileMode;

/// Handles the [Future] object with the provided [mapper] function.
JSPromise handleFutureWithMapper<T, S>(
  Future<T> future,
  Func1<T, S> mapper,
) {
  return JSPromise((JSFunction resolve, JSFunction reject) {
    future.then<void>((T value) {
      final Object? target = mapper(value);
      final JSAny? jsVal = target?.jsify();
      resolve.callAsFunction(resolve, jsVal);
    }, onError: (Object error, StackTrace stackTrace) {
      final errorConstructor =
          globalContext.getProperty('Error'.toJS)! as JSFunction;
      final wrapper = errorConstructor
          .callAsConstructor<JSObject>('Dart exception: $error'.toJS);
      wrapper['error'] = error.toJSBox;
      wrapper['stack'] = stackTrace.toString().toJS;
      reject.callAsFunction(reject, wrapper);
    });
  }.toJS);
}

// No way to unsubscribe from event listeners on hot reload so we set on the windows object
// and clean up on hot restart if it exists.
// See: https://github.com/firebase/flutterfire/issues/7064
void unsubscribeWindowsListener(String key) {
  if (_kDebugMode) {
    final unsubscribe = web.window.getProperty(key.toJS);
    if (unsubscribe != null) {
      (unsubscribe as JSFunction).callAsFunction();
    }
  }
}

void setWindowsListener(String key, JSFunction unsubscribe) {
  if (_kDebugMode) {
    web.window.setProperty(key.toJS, unsubscribe);
  }
}

void removeWindowsListener(String key) {
  if (_kDebugMode) {
    if (web.window.hasProperty(key.toJS) == true.toJS) {
      web.window.delete(key.toJS);
    }
  }
}
