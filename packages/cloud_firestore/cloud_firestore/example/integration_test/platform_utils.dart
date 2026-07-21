// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Whether the tests are running against the desktop implementations backed by
/// the Firebase C++ SDK (Windows and Linux). Both platforms share the same
/// C++ SDK, so they have identical feature limitations in the e2e suites.
///
/// The `!kIsWeb` check matters because web e2e tests run on Linux CI runners,
/// where `defaultTargetPlatform` reports [TargetPlatform.linux].
bool get isDesktopCppSdk =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);
