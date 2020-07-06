// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

class PhoneAuthCallbacks {
  const PhoneAuthCallbacks(
    this.verificationCompleted,
    this.verificationFailed,
    this.codeSent,
    this.codeAutoRetrievalTimeout,
  );

  final PhoneVerificationCompleted verificationCompleted;
  final PhoneVerificationFailed verificationFailed;
  final PhoneCodeSent codeSent;
  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;
}
