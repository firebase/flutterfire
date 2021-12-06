// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS('firebase.installations')
library firebase_interop.installations;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS('Installations')
abstract class InstallationsJsImpl {
  external AppJsImpl get app;

  external PromiseJsImpl<void> delete();

  external PromiseJsImpl<String> getId();

  external PromiseJsImpl<String> getToken([bool? forceRefresh]);

  external Func0 onIdChange(Func1<String, void> observer);
}
