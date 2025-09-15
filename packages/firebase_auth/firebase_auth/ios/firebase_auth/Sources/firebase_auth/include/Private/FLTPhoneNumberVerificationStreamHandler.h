// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import "../Public/firebase_auth_messages.g.h"

#import <Foundation/Foundation.h>

@class FIRAuth;
@class FIRMultiFactorSession;
@class FIRPhoneMultiFactorInfo;

NS_ASSUME_NONNULL_BEGIN

@interface FLTPhoneNumberVerificationStreamHandler : NSObject <FlutterStreamHandler>

#if TARGET_OS_OSX
- (instancetype)initWithAuth:(FIRAuth *)auth arguments:(NSDictionary *)arguments;
#else
- (instancetype)initWithAuth:(FIRAuth *)auth
                     request:(PigeonVerifyPhoneNumberRequest *)request
                     session:(FIRMultiFactorSession *)session
                  factorInfo:(FIRPhoneMultiFactorInfo *)factorInfo;
#endif

@end

NS_ASSUME_NONNULL_END
