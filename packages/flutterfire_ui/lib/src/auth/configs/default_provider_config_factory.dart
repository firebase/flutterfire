// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';

ProviderConfiguration createDefaltProviderConfig<T extends AuthController>() {
  switch (T) {
    case EmailFlowController:
      return const EmailProviderConfiguration();
    case OAuthController:
      throw Exception("Can't create default OAuthProviderConfiguration");
    case PhoneAuthController:
      return const PhoneProviderConfiguration();
    default:
      throw Exception("Can't create ProviderConfiguration for $T");
  }
}
