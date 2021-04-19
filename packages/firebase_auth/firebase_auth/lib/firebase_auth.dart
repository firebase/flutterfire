// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_auth;

import 'dart:async';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

export 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    show
        FirebaseAuthException,
        IdTokenResult,
        UserMetadata,
        UserInfo,
        ActionCodeInfo,
        ActionCodeSettings,
        AdditionalUserInfo,
        ActionCodeInfoOperation,
        Persistence,
        PhoneVerificationCompleted,
        PhoneVerificationFailed,
        PhoneCodeSent,
        PhoneCodeAutoRetrievalTimeout,
        AuthCredential,
        EmailAuthProvider,
        EmailAuthCredential,
        FacebookAuthProvider,
        FacebookAuthCredential,
        GithubAuthProvider,
        GithubAuthCredential,
        GoogleAuthProvider,
        GoogleAuthCredential,
        OAuthProvider,
        OAuthCredential,
        PhoneAuthProvider,
        PhoneAuthCredential,
        SAMLAuthProvider,
        TwitterAuthProvider,
        TwitterAuthCredential,
        RecaptchaVerifierOnSuccess,
        RecaptchaVerifierOnExpired,
        RecaptchaVerifierOnError,
        RecaptchaVerifierSize,
        RecaptchaVerifierTheme;

export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/firebase_auth.dart';
part 'src/user_credential.dart';
part 'src/user.dart';
part 'src/confirmation_result.dart';
part 'src/recaptcha_verifier.dart';
