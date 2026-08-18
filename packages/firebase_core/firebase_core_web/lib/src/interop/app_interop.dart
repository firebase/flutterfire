// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_core')
library;

import 'dart:js_interop';

import 'core_interop.dart';

extension type AppJsImpl._(JSObject _) implements JSObject {
  external JSString get name;
  external FirebaseOptions get options;
}
