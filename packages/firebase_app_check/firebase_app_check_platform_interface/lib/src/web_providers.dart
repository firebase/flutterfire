// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class WebProvider {
  final String siteKey;

  WebProvider(this.siteKey);
}

class ReCaptchaV3Provider extends WebProvider {
  ReCaptchaV3Provider(String siteKey) : super(siteKey);
}

class ReCaptchaEnterpriseProvider extends WebProvider {
  ReCaptchaEnterpriseProvider(String siteKey) : super(siteKey);
}
