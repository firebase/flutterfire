// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS('firebase_installations')
library firebase_interop.installations;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS()
external InstallationsJsImpl getInstallations([AppJsImpl? app]);

@JS()
external PromiseJsImpl<String> getId(InstallationsJsImpl installations);

@JS()
external PromiseJsImpl<String> getToken(InstallationsJsImpl installations,
    [bool? forceRefresh]);

@JS()
external PromiseJsImpl<void> deleteInstallations(
    InstallationsJsImpl installations);

@JS()
external Func0 onIdChange(
    InstallationsJsImpl installations, Func1<String, void> forceRefresh);

@JS('Installations')
abstract class InstallationsJsImpl {
  external AppJsImpl get app;
}
