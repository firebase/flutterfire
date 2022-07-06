// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

import 'installations_interop.dart' as installations_interop;

export 'installations_interop.dart';

Installations getInstallationsInstance([App? app]) {
  return Installations.getInstance(app != null
      ? installations_interop.getInstallations(app.jsObject)
      : installations_interop.getInstallations());
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

  Future<void> delete() =>
      handleThenable(installations_interop.deleteInstallations(jsObject));

  Future<String> getId() =>
      handleThenable(installations_interop.getId(jsObject));

  Future<String> getToken([bool forceRefresh = false]) =>
      handleThenable(installations_interop.getToken(jsObject, forceRefresh));

  Func0? _onIdChangedUnsubscribe;

  StreamController<String>? _idChangeController;

  Stream<String> get onIdChange {
    if (_idChangeController == null) {
      final wrapper = allowInterop((String id) {
        _idChangeController!.add(id);
      });

      void startListen() {
        assert(_onIdChangedUnsubscribe == null);
        _onIdChangedUnsubscribe =
            installations_interop.onIdChange(jsObject, wrapper);
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
