// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <TargetConditionals.h>

#import <Firebase/Firebase.h>
#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <AuthenticationServices/AuthenticationServices.h>
#import <Foundation/Foundation.h>
#import <firebase_core/FLTFirebasePlugin.h>
#import "firebase_auth_messages.g.h"

@interface FLTFirebaseAuthPlugin
    : FLTFirebasePlugin <FlutterPlugin,
                         FirebaseAuthHostApi,
                         FirebaseAuthUserHostApi,
                         MultiFactorUserHostApi,
                         MultiFactoResolverHostApi,
                         MultiFactorTotpHostApi,
                         MultiFactorTotpSecretHostApi,
                         ASAuthorizationControllerDelegate,
                         ASAuthorizationControllerPresentationContextProviding>

+ (FlutterError *)convertToFlutterError:(NSError *)error;
@end
