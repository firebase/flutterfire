// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@import FirebaseAuth;

#import "include/Private/PigeonParser.h"
#import <Foundation/Foundation.h>
#import "include/Public/CustomPigeonHeader.h"

@implementation PigeonParser

+ (PigeonUserCredential *)
    getPigeonUserCredentialFromAuthResult:(nonnull FIRAuthDataResult *)authResult
                        authorizationCode:(nullable NSString *)authorizationCode {
  return [PigeonUserCredential
            makeWithUser:[self getPigeonDetails:authResult.user]
      additionalUserInfo:[self getPigeonAdditionalUserInfo:authResult.additionalUserInfo
                                         authorizationCode:authorizationCode]
              credential:[self getPigeonAuthCredential:authResult.credential token:nil]];
}

+ (PigeonUserCredential *)getPigeonUserCredentialFromFIRUser:(nonnull FIRUser *)user {
  return [PigeonUserCredential makeWithUser:[self getPigeonDetails:user]
                         additionalUserInfo:nil
                                 credential:nil];
}

+ (PigeonUserDetails *)getPigeonDetails:(nonnull FIRUser *)user {
  return [PigeonUserDetails makeWithUserInfo:[self getPigeonUserInfo:user]
                                providerData:[self getProviderData:user.providerData]];
}

+ (PigeonUserInfo *)getPigeonUserInfo:(nonnull FIRUser *)user {
  return [PigeonUserInfo
              makeWithUid:user.uid
                    email:user.email
              displayName:user.displayName
                 photoUrl:(user.photoURL.absoluteString.length > 0) ? user.photoURL.absoluteString
                                                                    : nil
              phoneNumber:user.phoneNumber
              isAnonymous:user.isAnonymous
          isEmailVerified:user.emailVerified
               providerId:user.providerID
                 tenantId:user.tenantID
             refreshToken:user.refreshToken
        creationTimestamp:@((long)([user.metadata.creationDate timeIntervalSince1970] * 1000))
      lastSignInTimestamp:@((long)([user.metadata.lastSignInDate timeIntervalSince1970] * 1000))];
}

+ (NSArray<NSDictionary<id, id> *> *)getProviderData:
    (nonnull NSArray<id<FIRUserInfo>> *)providerData {
  NSMutableArray<NSDictionary<id, id> *> *dataArray =
      [NSMutableArray arrayWithCapacity:providerData.count];

  for (id<FIRUserInfo> userInfo in providerData) {
    NSDictionary *dataDict = @{
      @"providerId" : userInfo.providerID,
      // Can be null on emulator
      @"uid" : userInfo.uid ?: @"",
      @"displayName" : userInfo.displayName ?: [NSNull null],
      @"email" : userInfo.email ?: [NSNull null],
      @"phoneNumber" : userInfo.phoneNumber ?: [NSNull null],
      @"photoURL" : userInfo.photoURL.absoluteString ?: [NSNull null],
      // isAnonymous is always false on in a providerData object (the user is not anonymous)
      @"isAnonymous" : @NO,
      // isEmailVerified is always true on in a providerData object (the email is verified by the
      // provider)
      @"isEmailVerified" : @YES,
    };
    [dataArray addObject:dataDict];
  }
  return [dataArray copy];
}

+ (PigeonAdditionalUserInfo *)getPigeonAdditionalUserInfo:(nonnull FIRAdditionalUserInfo *)userInfo
                                        authorizationCode:(nullable NSString *)authorizationCode {
  return [PigeonAdditionalUserInfo makeWithIsNewUser:userInfo.isNewUser
                                          providerId:userInfo.providerID
                                            username:userInfo.username
                                   authorizationCode:authorizationCode
                                             profile:userInfo.profile];
}

+ (PigeonTotpSecret *)getPigeonTotpSecret:(FIRTOTPSecret *)secret {
  return [PigeonTotpSecret makeWithCodeIntervalSeconds:nil
                                            codeLength:nil
                          enrollmentCompletionDeadline:nil
                                      hashingAlgorithm:nil
                                             secretKey:secret.sharedSecretKey];
}

+ (PigeonAuthCredential *)getPigeonAuthCredential:(FIRAuthCredential *)authCredential
                                            token:(NSNumber *_Nullable)token {
  if (authCredential == nil) {
    return nil;
  }

  NSString *accessToken = nil;
  if ([authCredential isKindOfClass:[FIROAuthCredential class]]) {
    if (((FIROAuthCredential *)authCredential).accessToken != nil) {
      accessToken = ((FIROAuthCredential *)authCredential).accessToken;
    } else if (((FIROAuthCredential *)authCredential).IDToken != nil) {
      // For Sign In With Apple, the token is stored in IDToken
      accessToken = ((FIROAuthCredential *)authCredential).IDToken;
    }
  }

  NSUInteger nativeId =
      token != nil ? [token unsignedLongValue] : (NSUInteger)[authCredential hash];

  return [PigeonAuthCredential makeWithProviderId:authCredential.provider
                                     signInMethod:authCredential.provider
                                         nativeId:nativeId
                                      accessToken:accessToken ?: nil];
}

+ (FIRActionCodeSettings *_Nullable)parseActionCodeSettings:
    (nullable PigeonActionCodeSettings *)settings {
  if (settings == nil) {
    return nil;
  }

  FIRActionCodeSettings *codeSettings = [[FIRActionCodeSettings alloc] init];

  if (settings.url != nil) {
    codeSettings.URL = [NSURL URLWithString:settings.url];
  }

  if (settings.linkDomain != nil) {
    codeSettings.linkDomain = settings.linkDomain;
  }

  codeSettings.handleCodeInApp = settings.handleCodeInApp;

  if (settings.iOSBundleId != nil) {
    codeSettings.iOSBundleID = settings.iOSBundleId;
  }

  return codeSettings;
}

+ (PigeonIdTokenResult *)parseIdTokenResult:(FIRAuthTokenResult *)tokenResult {
  long expirationTimestamp = (long)[tokenResult.expirationDate timeIntervalSince1970] * 1000;
  long authTimestamp = (long)[tokenResult.authDate timeIntervalSince1970] * 1000;
  long issuedAtTimestamp = (long)[tokenResult.issuedAtDate timeIntervalSince1970] * 1000;

  return [PigeonIdTokenResult makeWithToken:tokenResult.token
                        expirationTimestamp:@(expirationTimestamp)
                              authTimestamp:@(authTimestamp)
                          issuedAtTimestamp:@(issuedAtTimestamp)
                             signInProvider:tokenResult.signInProvider
                                     claims:tokenResult.claims
                         signInSecondFactor:tokenResult.signInSecondFactor];
}

+ (NSArray *_Nonnull)getManualList:(nonnull PigeonUserDetails *)userDetails {
  NSMutableArray *output = [NSMutableArray array];

  id userInfoList = [[userDetails userInfo] toList];
  [output addObject:userInfoList];

  id providerData = [userDetails providerData];
  [output addObject:providerData];

  return [output copy];
}

@end
