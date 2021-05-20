// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'app_check_interop.dart' as app_check_interop;
import 'firebase_interop.dart' as firebase_interop;

export 'app_check_interop.dart';

/// Given an AppJSImp, return the Auth instance.
AppCheck getAppCheckInstance() {
  return AppCheck.getInstance(firebase_interop.appCheck());
}

class AppCheck extends JsObjectWrapper<app_check_interop.AppCheckJsImpl> {
  static final _expando = Expando<AppCheck>();

  /// Creates a new AppCheck from a [jsObject].
  static AppCheck getInstance(app_check_interop.AppCheckJsImpl jsObject) {
    return _expando[jsObject] ??= AppCheck._fromJsObject(jsObject);
  }

  AppCheck._fromJsObject(app_check_interop.AppCheckJsImpl jsObject)
      : super.fromJsObject(jsObject);

  void activate(String? recaptchaKey) => jsObject.activate(recaptchaKey);
}
