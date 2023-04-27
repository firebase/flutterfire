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
#import "messages.g.h"

@interface FLTFirebaseAuthPlugin
    : FLTFirebasePlugin <FlutterPlugin,
                        FirebaseAuthHostApi,
FirebaseAuthUserHostApi,
                         MultiFactorUserHostApi,
                         MultiFactoResolverHostApi,
                         ASAuthorizationControllerDelegate,
                         ASAuthorizationControllerPresentationContextProviding>

+ (id)getNSDictionaryFromAuthCredential:(FIRAuthCredential *)authCredential;
+ (NSDictionary *)getNSDictionaryFromUserInfo:(id<FIRUserInfo>)userInfo;
+ (NSMutableDictionary *)getNSDictionaryFromUser:(FIRUser *)user;
+ (NSDictionary *)getNSDictionaryFromNSError:(NSError *)error;
+ (PigeonUserInfo *_Nonnull)getPigeonUserInfo:(nonnull FIRUser *)user;
+ (PigeonUserDetails *_Nonnull)getPigeonDetails:(nonnull FIRUser *)user;
+ (PigeonUserCredential *_Nonnull)getPigeonUserCredentialFromAuthResult:(nonnull FIRAuthDataResult *)authResult;
+ (NSArray<NSDictionary<id, id> *> *_Nonnull)getProviderData:(nonnull NSArray<id<FIRUserInfo>> *)providerData;
+ (PigeonAuthCredential *_Nullable)getPigeonAuthCredential:(FIRAuthCredential *_Nullable)credential;
@end
