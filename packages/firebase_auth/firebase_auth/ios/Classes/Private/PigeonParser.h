/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import <Firebase/Firebase.h>
#import <Foundation/Foundation.h>
#import <firebase_auth/messages.g.h>

@interface PigeonParser : NSObject

+ (PigeonUserCredential *_Nullable)getPigeonUserCredentialFromAuthResult:
    (nonnull FIRAuthDataResult *)authResult;
+ (PigeonUserDetails *_Nullable)getPigeonDetails:(nonnull FIRUser *)user;
+ (PigeonUserInfo *_Nullable)getPigeonUserInfo:(nonnull FIRUser *)user;
+ (PigeonActionCodeInfo *_Nullable)parseActionCode:(nonnull FIRActionCodeInfo *)info;
+ (FIRActionCodeSettings *_Nullable)parseActionCodeSettings:
    (nullable PigeonActionCodeSettings *)settings;
+ (PigeonUserCredential *_Nullable)getPigeonUserCredentialFromFIRUser:(nonnull FIRUser *)user;
+ (PigeonIdTokenResult *)parseIdTokenResult:(FIRAuthTokenResult *)tokenResult;

@end
