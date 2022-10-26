// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../oauth_providers.dart';

mixin SignOutMixin on OAuthProvider {
  @override
  Future<void> signOut() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await logOutProvider();
    }
    return super.signOut();
  }
}
