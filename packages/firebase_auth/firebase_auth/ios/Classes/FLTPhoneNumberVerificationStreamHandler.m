// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Private/FLTPhoneNumberVerificationStreamHandler.h"
#import "Public/FLTFirebaseAuthPlugin.h"

@implementation FLTPhoneNumberVerificationStreamHandler {
  FIRAuth *_auth;
  NSString *_phoneNumber;
}

- (instancetype)initWithAuth:(id)auth arguments:(NSDictionary *)arguments {
  self = [super init];
  if (self) {
    _auth = auth;
    _phoneNumber = arguments[@"phoneNumber"];
  }
  return self;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
#if TARGET_OS_IPHONE
  id completer = ^(NSString *verificationID, NSError *error) {
    if (error != nil) {
      NSDictionary *errorDetails = [FLTFirebaseAuthPlugin getNSDictionaryFromNSError:error];
      events(@{
        @"name" : @"Auth#phoneVerificationFailed",
        @"error" : @{
          @"message" : errorDetails[@"message"],
          @"details" : errorDetails,
        }
      });
    } else {
      events(@{
        @"name" : @"Auth#phoneCodeSent",
        @"verificationId" : verificationID,
      });
    }
  };

  // Try catch to capture 'missing URL scheme' error.
  @try {
    [[FIRPhoneAuthProvider providerWithAuth:_auth] verifyPhoneNumber:_phoneNumber
                                                          UIDelegate:nil
                                                          completion:completer];
  } @catch (NSException *exception) {
    events(@{
      @"name" : @"Auth#phoneVerificationFailed",
      @"error" : @{
        @"message" : exception.reason,
      }
    });
  }
#endif

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  return nil;
}

@end
