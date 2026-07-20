// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';

export 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    show
        FirebaseAuthException,
        MultiFactorInfo,
        MultiFactorSession,
        PhoneMultiFactorInfo,
        TotpMultiFactorInfo,
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
        AuthProvider,
        AppleAuthProvider,
        AppleFullPersonName,
        AppleAuthCredential,
        EmailAuthProvider,
        EmailAuthCredential,
        FacebookAuthProvider,
        FacebookAuthCredential,
        GameCenterAuthProvider,
        GameCenterAuthCredential,
        PlayGamesAuthProvider,
        PlayGamesAuthCredential,
        GithubAuthProvider,
        GithubAuthCredential,
        GoogleAuthProvider,
        GoogleAuthCredential,
        YahooAuthProvider,
        YahooAuthCredential,
        MicrosoftAuthProvider,
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
        RecaptchaVerifierTheme,
        PasswordValidationStatus;
export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/confirmation_result.dart';
part 'src/firebase_auth.dart';
part 'src/multi_factor.dart';
part 'src/recaptcha_verifier.dart';
part 'src/user.dart';
part 'src/user_credential.dart';
