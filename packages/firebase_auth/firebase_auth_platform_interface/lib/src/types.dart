// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/providers/phone_auth_provider.dart';

import 'firebase_auth_exception.dart';

typedef void PhoneVerificationCompleted(
    PhoneAuthCredential phoneAuthCredential);
typedef void PhoneVerificationFailed(FirebaseAuthException error);
typedef void PhoneCodeSent(String verificationId, int forceResendingToken);
typedef void PhoneCodeAutoRetrievalTimeout(String verificationId);

/// An enumeration of the possible persistence mechanism types.
///
/// Setting a persistence type is only available on web based platforms.
enum Persistence {
  /// Indicates that the state will be persisted even when the browser window is
  /// closed.
  LOCAL,

  /// Indicates that the state will only be stored in memory and will be cleared]
  /// when the window or activity is refreshed.
  NONE,

  /// Indicates that the state will only persist in current session/tab, relevant
  /// to web only, and will be cleared when the tab is closed.
  SESSION,
}
