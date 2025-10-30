// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS('firebase_installations')
library firebase_interop.installations;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external InstallationsJsImpl getInstallations([AppJsImpl? app]);

@JS()
@staticInterop
external JSPromise<JSString> getId(InstallationsJsImpl installations);

@JS()
@staticInterop
external JSPromise<JSString> getToken(InstallationsJsImpl installations,
    [JSBoolean? forceRefresh]);

@JS()
@staticInterop
external JSPromise /* void */ deleteInstallations(
    InstallationsJsImpl installations);

@JS()
@staticInterop
external JSFunction onIdChange(JSObject installations, JSFunction forceRefresh);

extension type InstallationsJsImplExtension._(JSObject _) implements JSObject {
  external AppJsImpl get app;
}

extension type InstallationsJsImpl._(JSObject _) implements JSObject {
  external JSPromise<JSString> getId();
  external JSPromise<JSString> getToken([JSBoolean? forceRefresh]);
  external JSPromise deleteInstallations();
  external JSFunction onIdChange(JSFunction forceRefresh);
}
