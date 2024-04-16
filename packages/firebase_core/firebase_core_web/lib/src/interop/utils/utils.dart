// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

// TODO(Lyokone): should be deleted once all plugins are migrated to use js_interop

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'func.dart';

/// Handles the [Future] object with the provided [mapper] function.
JSPromise handleFutureWithMapper<T, S>(
  Future<JSAny?> future,
  Func1<T, S> mapper,
) {
  // Taken from js_interop:286
  return JSPromise((JSFunction resolve, JSFunction reject) {
    future.then((JSAny? value) {
      resolve.callAsFunction(resolve, value);
      return value;
    }, onError: (Object error, StackTrace stackTrace) {
      final errorConstructor =
          globalContext.getProperty('Error'.toJS)! as JSFunction;
      final wrapper = errorConstructor.callAsConstructor<JSObject>(
          'Dart exception thrown from converted Future. Use the properties '
                  "'error' to fetch the boxed error and 'stack' to recover "
                  'the stack trace.'
              .toJS);
      wrapper['error'] = error.toJSBox;
      wrapper['stack'] = stackTrace.toString().toJS;
      reject.callAsFunction(reject, wrapper);
      return wrapper;
    });
  }.toJS);
}
