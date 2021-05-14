// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// ignore_for_file: public_member_api_docs

@JS('firebase.appCheck')
library firebase_interop.app_check;

import 'package:js/js.dart';

@JS('AppCheck')
abstract class AppCheckJsImpl {
  external void activate(String? recaptchaKey);
}
