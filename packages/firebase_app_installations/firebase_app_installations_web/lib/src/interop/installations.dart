// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

import 'firebase_interop.dart' as firebase_interop;
import 'installations_interop.dart' as installations_interop;

export 'installations_interop.dart';

Installations getInstallationsInstance([App? app]) {
  return Installations.getInstance(app != null
      ? firebase_interop.installations(app.jsObject)
      : firebase_interop.installations());
}

class Installations
    extends JsObjectWrapper<installations_interop.InstallationsJsImpl> {
  static final _expando = Expando<Installations>();

  /// Creates a new Installations from a [jsObject].
  static Installations getInstance(
      installations_interop.InstallationsJsImpl jsObject) {
    return _expando[jsObject] ??= Installations._fromJsObject(jsObject);
  }

  Installations._fromJsObject(
      installations_interop.InstallationsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Future<void> delete() => handleThenable(jsObject.delete());

  Future<String> getId() => handleThenable(jsObject.getId());

  Future<String> getToken([bool forceRefresh = false]) =>
      handleThenable(jsObject.getToken(forceRefresh));

  Func0? _onIdChangedUnsubscribe;

  StreamController<String>? _idChangeController;

  Stream<String> get onIdChange {
    if (_idChangeController == null) {
      final wrapper = allowInterop((String id) {
        _idChangeController!.add(id);
      });

      void startListen() {
        assert(_onIdChangedUnsubscribe == null);
        _onIdChangedUnsubscribe = jsObject.onIdChange(wrapper);
      }

      void stopListen() {
        _onIdChangedUnsubscribe!();
        _onIdChangedUnsubscribe = null;
      }

      _idChangeController = StreamController<String>.broadcast(
        onListen: startListen,
        onCancel: stopListen,
        sync: true,
      );
    }

    return _idChangeController!.stream;
  }
}
