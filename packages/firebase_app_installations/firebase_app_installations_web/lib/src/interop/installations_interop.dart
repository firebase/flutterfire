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
external JSPromise /* String */ getId(InstallationsJsImpl installations);

@JS()
@staticInterop
external JSPromise /* String */ getToken(InstallationsJsImpl installations,
    [JSBoolean? forceRefresh]);

@JS()
@staticInterop
external JSPromise /* void */ deleteInstallations(
    InstallationsJsImpl installations);

@JS()
@staticInterop
external JSFunction onIdChange(
    InstallationsJsImpl installations, JSFunction forceRefresh);

@JS('Installations')
@staticInterop
abstract class InstallationsJsImpl {}

extension InstallationsJsImplExtension on InstallationsJsImpl {
  external AppJsImpl get app;
}
