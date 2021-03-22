// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase.app')
library firebase_interop.core.app;

import 'package:js/js.dart';
import 'core_interop.dart';
import 'utils/es6_interop.dart';

@JS('App')
abstract class AppJsImpl {
  external String get name;
  external FirebaseOptions get options;
  external PromiseJsImpl<void> delete();
}
