/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import <Foundation/Foundation.h>
#import "../Public/firebase_auth_messages.g.h"

@class FIRAuthDataResult;
@class FIRUser;
@class FIRActionCodeSettings;
@class FIRAuthTokenResult;
@class FIRTOTPSecret;
@class FIRAuthCredential;

@interface PigeonParser : NSObject

+ (NSArray *_Nonnull)getManualList:(nonnull InternalUserDetails *)userDetails;
+ (InternalUserCredential *_Nullable)
    getPigeonUserCredentialFromAuthResult:(nonnull FIRAuthDataResult *)authResult
                        authorizationCode:(nullable NSString *)authorizationCode;
+ (InternalUserDetails *_Nullable)getPigeonDetails:(nonnull FIRUser *)user;
+ (InternalUserInfo *_Nullable)getPigeonUserInfo:(nonnull FIRUser *)user;
+ (FIRActionCodeSettings *_Nullable)parseActionCodeSettings:
    (nullable InternalActionCodeSettings *)settings;
+ (InternalUserCredential *_Nullable)getPigeonUserCredentialFromFIRUser:(nonnull FIRUser *)user;
+ (InternalIdTokenResult *_Nonnull)parseIdTokenResult:(nonnull FIRAuthTokenResult *)tokenResult;
+ (InternalTotpSecret *_Nonnull)getPigeonTotpSecret:(nonnull FIRTOTPSecret *)secret;
+ (InternalAuthCredential *_Nullable)getPigeonAuthCredential:
                                         (FIRAuthCredential *_Nullable)authCredentialToken
                                                       token:(NSNumber *_Nullable)token;
@end
