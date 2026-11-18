// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Flutter/Flutter.h>

/// Test-only channel used by `integration_test/e2e_test.dart`.
///
/// Opens a URL through the app delegate or the scene delegate the same way iOS
/// does when a sign-in redirect returns to the app, without a browser.
@interface AuthCallbackURLTestChannel : NSObject

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end
