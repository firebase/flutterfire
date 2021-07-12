// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <firebase_core/FLTFirebasePluginRegistry.h>
#import "Firebase/Firebase.h"

#import "Private/FLTAuthStateChannelStreamHandler.h"
#import "Private/FLTIdTokenChannelStreamHandler.h"
#import "Private/FLTPhoneNumberVerificationStreamHandler.h"

#import "Public/FLTFirebaseAuthPlugin.h"

NSString *const kFLTFirebaseAuthChannelName = @"plugins.flutter.io/firebase_auth";

// Provider type keys.
NSString *const kSignInMethodPassword = @"password";
NSString *const kSignInMethodEmailLink = @"emailLink";
NSString *const kSignInMethodFacebook = @"facebook.com";
NSString *const kSignInMethodGoogle = @"google.com";
NSString *const kSignInMethodTwitter = @"twitter.com";
NSString *const kSignInMethodGithub = @"github.com";
NSString *const kSignInMethodPhone = @"phone";
NSString *const kSignInMethodOAuth = @"oauth";

// Credential argument keys.
NSString *const kArgumentCredential = @"credential";
NSString *const kArgumentProviderId = @"providerId";
NSString *const kArgumentSignInMethod = @"signInMethod";
NSString *const kArgumentSecret = @"secret";
NSString *const kArgumentIdToken = @"idToken";
NSString *const kArgumentAccessToken = @"accessToken";
NSString *const kArgumentRawNonce = @"rawNonce";
NSString *const kArgumentEmail = @"email";
NSString *const kArgumentCode = @"code";
NSString *const kArgumentNewEmail = @"newEmail";
NSString *const kArgumentEmailLink = kSignInMethodEmailLink;
NSString *const kArgumentToken = @"token";
NSString *const kArgumentVerificationId = @"verificationId";
NSString *const kArgumentSmsCode = @"smsCode";
NSString *const kArgumentActionCodeSettings = @"actionCodeSettings";

// Manual error codes & messages.
NSString *const kErrCodeNoCurrentUser = @"no-current-user";
NSString *const kErrMsgNoCurrentUser = @"No user currently signed in.";
NSString *const kErrCodeInvalidCredential = @"invalid-credential";
NSString *const kErrMsgInvalidCredential =
    @"The supplied auth credential is malformed, has expired or is not currently supported.";

@interface FLTFirebaseAuthPlugin ()
@property(nonatomic, retain) NSObject<FlutterBinaryMessenger> *messenger;
@end

@implementation FLTFirebaseAuthPlugin {
  // Used for caching credentials between Method Channel method calls.
  NSMutableDictionary<NSNumber *, FIRAuthCredential *> *_credentials;

  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
  NSMutableDictionary<NSString *, FlutterEventChannel *> *_eventChannels;
  NSMutableDictionary<NSString *, NSObject<FlutterStreamHandler> *> *_streamHandlers;
}

#pragma mark - FlutterPlugin

- (instancetype)init:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:self];
    _credentials = [NSMutableDictionary<NSNumber *, FIRAuthCredential *> dictionary];
    _binaryMessenger = messenger;
    _eventChannels = [NSMutableDictionary dictionary];
    _streamHandlers = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseAuthChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAuthPlugin *instance = [[FLTFirebaseAuthPlugin alloc] init:registrar.messenger];

  [registrar addMethodCallDelegate:instance channel:channel];

#if TARGET_OS_OSX
  // TODO(Salakar): Publish does not exist on MacOS version of FlutterPluginRegistrar.
  // TODO(Salakar): addApplicationDelegate does not exist on MacOS version of
  // FlutterPluginRegistrar. (https://github.com/flutter/flutter/issues/41471)
#else
  [registrar publish:instance];
  [registrar addApplicationDelegate:instance];
#endif
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
  // Cleanup credentials.
  [_credentials removeAllObjects];

  for (FlutterEventChannel *channel in self->_eventChannels.allValues) {
    [channel setStreamHandler:nil];
  }
  [self->_eventChannels removeAllObjects];
  for (NSObject<FlutterStreamHandler> *handler in self->_streamHandlers.allValues) {
    [handler onCancelWithArguments:nil];
  }
  [self->_streamHandlers removeAllObjects];

  if (completion != nil) completion();
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self cleanupWithCompletion:nil];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        if (code == nil) {
          NSDictionary *errorDetails = [FLTFirebaseAuthPlugin getNSDictionaryFromNSError:error];
          [self storeAuthCredentialIfPresent:error];
          code = errorDetails[kArgumentCode];
          message = errorDetails[@"message"];
          details = errorDetails;
        } else {
          details = @{
            kArgumentCode : code,
            @"message" : message,
            @"additionalData" : @{},
          };
        }

        if ([@"unknown" isEqualToString:code]) {
          NSLog(@"FLTFirebaseAuth: An error occurred while calling method %@, errorOrNil => %@",
                call.method, [error userInfo]);
        }

        flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                            message:message
                                                    optionalDetails:details
                                                 andOptionalNSError:error]);
      };

  FLTFirebaseMethodCallSuccessBlock successBlock = ^(id _Nullable result) {
    if ([result isKindOfClass:[FIRAuthDataResult class]]) {
      flutterResult([self getNSDictionaryFromAuthResult:result]);
    } else if ([result isKindOfClass:[FIRUser class]]) {
      flutterResult([FLTFirebaseAuthPlugin getNSDictionaryFromUser:result]);
    } else {
      flutterResult(result);
    }
  };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:successBlock andErrorBlock:errorBlock];

  if ([@"Auth#registerIdTokenListener" isEqualToString:call.method]) {
    [self registerIdTokenListener:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#registerAuthStateListener" isEqualToString:call.method]) {
    [self registerAuthStateListener:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#applyActionCode" isEqualToString:call.method]) {
    [self applyActionCode:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#checkActionCode" isEqualToString:call.method]) {
    [self checkActionCode:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#confirmPasswordReset" isEqualToString:call.method]) {
    [self confirmPasswordReset:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#createUserWithEmailAndPassword" isEqualToString:call.method]) {
    [self createUserWithEmailAndPassword:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#fetchSignInMethodsForEmail" isEqualToString:call.method]) {
    [self fetchSignInMethodsForEmail:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#sendPasswordResetEmail" isEqualToString:call.method]) {
    [self sendPasswordResetEmail:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#sendSignInLinkToEmail" isEqualToString:call.method]) {
    [self sendSignInLinkToEmail:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#signInWithCredential" isEqualToString:call.method]) {
    [self signInWithCredential:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#setLanguageCode" isEqualToString:call.method]) {
    [self setLanguageCode:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#setSettings" isEqualToString:call.method]) {
    [self setSettings:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#signInAnonymously" isEqualToString:call.method]) {
    [self signInAnonymously:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#signInWithCustomToken" isEqualToString:call.method]) {
    [self signInWithCustomToken:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#signInWithEmailAndPassword" isEqualToString:call.method]) {
    [self signInWithEmailAndPassword:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#signInWithEmailLink" isEqualToString:call.method]) {
    [self signInWithEmailLink:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#signOut" isEqualToString:call.method]) {
    [self signOut:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#useEmulator" isEqualToString:call.method]) {
    [self useEmulator:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#verifyPasswordResetCode" isEqualToString:call.method]) {
    [self verifyPasswordResetCode:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Auth#verifyPhoneNumber" isEqualToString:call.method]) {
    [self verifyPhoneNumber:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#delete" isEqualToString:call.method]) {
    [self userDelete:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#getIdToken" isEqualToString:call.method]) {
    [self userGetIdToken:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#linkWithCredential" isEqualToString:call.method]) {
    [self userLinkWithCredential:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#reauthenticateUserWithCredential" isEqualToString:call.method]) {
    [self userReauthenticateUserWithCredential:call.arguments
                          withMethodCallResult:methodCallResult];
  } else if ([@"User#reload" isEqualToString:call.method]) {
    [self userReload:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#sendEmailVerification" isEqualToString:call.method]) {
    [self userSendEmailVerification:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#unlink" isEqualToString:call.method]) {
    [self userUnlink:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#updateEmail" isEqualToString:call.method]) {
    [self userUpdateEmail:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#updatePassword" isEqualToString:call.method]) {
    [self userUpdatePassword:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#updatePhoneNumber" isEqualToString:call.method]) {
    [self userUpdatePhoneNumber:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#updateProfile" isEqualToString:call.method]) {
    [self userUpdateProfile:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"User#verifyBeforeUpdateEmail" isEqualToString:call.method]) {
    [self userVerifyBeforeUpdateEmail:call.arguments withMethodCallResult:methodCallResult];
  } else {
    methodCallResult.success(FlutterMethodNotImplemented);
  }
}

#pragma mark - AppDelegate

#if TARGET_OS_IPHONE
#if !__has_include(<FirebaseMessaging/FirebaseMessaging.h>)
- (BOOL)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)notification
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
  if ([[FIRAuth auth] canHandleNotification:notification]) {
    completionHandler(UIBackgroundFetchResultNoData);
    return YES;
  }
  return NO;
}
#endif

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeUnknown];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
  return [[FIRAuth auth] canHandleURL:url];
}
#endif

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^_Nonnull)(void))completion {
  [self cleanupWithCompletion:completion];
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseAuthChannelName;
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *_Nonnull)firebaseApp {
  FIRAuth *auth = [FIRAuth authWithApp:firebaseApp];
  return @{
    @"APP_LANGUAGE_CODE" : (id)[auth languageCode] ?: [NSNull null],
    @"APP_CURRENT_USER" : [auth currentUser]
        ? (id)[FLTFirebaseAuthPlugin getNSDictionaryFromUser:[auth currentUser]]
        : [NSNull null],
  };
}

#pragma mark - Firebase Auth API

- (void)applyActionCode:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth applyActionCode:arguments[kArgumentCode]
             completion:^(NSError *_Nullable error) {
               if (error != nil) {
                 result.error(nil, nil, nil, error);
               } else {
                 result.success(nil);
               }
             }];
}

- (void)checkActionCode:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth checkActionCode:arguments[kArgumentCode]
             completion:^(FIRActionCodeInfo *_Nullable info, NSError *_Nullable error) {
               if (error != nil) {
                 result.error(nil, nil, nil, error);
               } else {
                 NSMutableDictionary *actionCodeResultDict = [NSMutableDictionary dictionary];
                 NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];

                 if (info.email != nil) {
                   dataDict[@"email"] = info.email;
                 }

                 if (info.previousEmail != nil) {
                   dataDict[@"previousEmail"] = info.previousEmail;
                 }

                 if (info.operation == FIRActionCodeOperationPasswordReset) {
                   actionCodeResultDict[@"operation"] = @1;
                 } else if (info.operation == FIRActionCodeOperationVerifyEmail) {
                   actionCodeResultDict[@"operation"] = @2;
                 } else if (info.operation == FIRActionCodeOperationRecoverEmail) {
                   actionCodeResultDict[@"operation"] = @3;
                 } else if (info.operation == FIRActionCodeOperationEmailLink) {
                   actionCodeResultDict[@"operation"] = @4;
                 } else if (info.operation == FIRActionCodeOperationVerifyAndChangeEmail) {
                   actionCodeResultDict[@"operation"] = @5;
                 } else if (info.operation == FIRActionCodeOperationRevertSecondFactorAddition) {
                   actionCodeResultDict[@"operation"] = @6;
                 } else {
                   // Unknown / Error.
                   actionCodeResultDict[@"operation"] = @0;
                 }

                 actionCodeResultDict[@"data"] = dataDict;

                 result.success(actionCodeResultDict);
               }
             }];
}

- (void)confirmPasswordReset:(id)arguments
        withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth confirmPasswordResetWithCode:arguments[kArgumentCode]
                         newPassword:arguments[@"newPassword"]
                          completion:^(NSError *_Nullable error) {
                            if (error != nil) {
                              result.error(nil, nil, nil, error);
                            } else {
                              result.success(nil);
                            }
                          }];
}

- (void)createUserWithEmailAndPassword:(id)arguments
                  withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth createUserWithEmail:arguments[kArgumentEmail]
                   password:arguments[@"password"]
                 completion:^(FIRAuthDataResult *authResult, NSError *error) {
                   if (error != nil) {
                     result.error(nil, nil, nil, error);
                   } else {
                     result.success(authResult);
                   }
                 }];
}

- (void)fetchSignInMethodsForEmail:(id)arguments
              withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth fetchSignInMethodsForEmail:arguments[kArgumentEmail]
                        completion:^(NSArray<NSString *> *_Nullable providers,
                                     NSError *_Nullable error) {
                          if (error != nil) {
                            result.error(nil, nil, nil, error);
                          } else {
                            result.success(@{
                              @"providers" : (id)providers ?: @[],
                            });
                          }
                        }];
}

- (void)sendPasswordResetEmail:(id)arguments
          withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  NSString *email = arguments[kArgumentEmail];
  FIRActionCodeSettings *actionCodeSettings =
      [self getFIRActionCodeSettingsFromArguments:arguments];
  [auth sendPasswordResetWithEmail:email
                actionCodeSettings:actionCodeSettings
                        completion:^(NSError *_Nullable error) {
                          if (error != nil) {
                            result.error(nil, nil, nil, error);
                          } else {
                            result.success(nil);
                          }
                        }];
}

- (void)sendSignInLinkToEmail:(id)arguments
         withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  NSString *email = arguments[kArgumentEmail];
  FIRActionCodeSettings *actionCodeSettings =
      [self getFIRActionCodeSettingsFromArguments:arguments];
  [auth sendSignInLinkToEmail:email
           actionCodeSettings:actionCodeSettings
                   completion:^(NSError *_Nullable error) {
                     if (error != nil) {
                       result.error(nil, nil, nil, error);
                     } else {
                       result.success(nil);
                     }
                   }];
}

- (void)signInWithCredential:(id)arguments
        withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRAuthCredential *credential = [self getFIRAuthCredentialFromArguments:arguments];

  if (credential == nil) {
    result.error(kErrCodeInvalidCredential, kErrMsgInvalidCredential, nil, nil);
    return;
  }

  [auth signInWithCredential:credential
                  completion:^(FIRAuthDataResult *authResult, NSError *error) {
                    if (error != nil) {
                      result.error(nil, nil, nil, error);
                    } else {
                      result.success(authResult);
                    }
                  }];
}

- (void)setLanguageCode:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  NSString *languageCode = arguments[@"languageCode"];

  if (languageCode != nil && ![languageCode isEqual:[NSNull null]]) {
    auth.languageCode = languageCode;
  } else {
    [auth useAppLanguage];
  }

  result.success(@{@"languageCode" : auth.languageCode});
}

- (void)setSettings:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  if ([[arguments allKeys] containsObject:@"userAccessGroup"] &&
      ![arguments[@"userAccessGroup"] isEqual:[NSNull null]]) {
    BOOL useUserAccessGroupSuccessful;
    NSError *useUserAccessGroupErrorPtr;
    useUserAccessGroupSuccessful = [auth useUserAccessGroup:arguments[@"userAccessGroup"]
                                                      error:&useUserAccessGroupErrorPtr];
    if (!useUserAccessGroupSuccessful) {
      return result.error(nil, nil, nil, useUserAccessGroupErrorPtr);
    }
  }

#if TARGET_OS_IPHONE
  if ([[arguments allKeys] containsObject:@"appVerificationDisabledForTesting"] &&
      ![arguments[@"appVerificationDisabledForTesting"] isEqual:[NSNull null]]) {
    auth.settings.appVerificationDisabledForTesting =
        [arguments[@"appVerificationDisabledForTesting"] boolValue];
  }
#else
  NSLog(@"FIRAuthSettings.appVerificationDisabledForTesting is not supported on MacOS.");
#endif

  result.success(nil);
}

- (void)signInWithCustomToken:(id)arguments
         withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  [auth signInWithCustomToken:arguments[kArgumentToken]
                   completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
                     if (error != nil) {
                       result.error(nil, nil, nil, error);
                     } else {
                       result.success(authResult);
                     }
                   }];
}

- (void)signInWithEmailAndPassword:(id)arguments
              withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth signInWithEmail:arguments[kArgumentEmail]
               password:arguments[@"password"]
             completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
               if (error != nil) {
                 result.error(nil, nil, nil, error);
               } else {
                 result.success(authResult);
               }
             }];
}

- (void)signInWithEmailLink:(id)arguments
       withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth signInWithEmail:arguments[kArgumentEmail]
                   link:arguments[@"emailLink"]
             completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
               if (error != nil) {
                 result.error(nil, nil, nil, error);
               } else {
                 result.success(authResult);
               }
             }];
}

- (void)signOut:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  if (auth.currentUser == nil) {
    result.success(nil);
    return;
  }

  NSError *signOutErrorPtr;
  BOOL signOutSuccessful = [auth signOut:&signOutErrorPtr];

  if (!signOutSuccessful) {
    result.error(nil, nil, nil, signOutErrorPtr);
  } else {
    result.success(nil);
  }
}

- (void)useEmulator:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth useEmulatorWithHost:arguments[@"host"] port:[arguments[@"port"] integerValue]];
  result.success(nil);
}

- (void)verifyPasswordResetCode:(id)arguments
           withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  [auth verifyPasswordResetCode:arguments[kArgumentCode]
                     completion:^(NSString *_Nullable email, NSError *_Nullable error) {
                       if (error != nil) {
                         result.error(nil, nil, nil, error);
                       } else {
                         result.success(@{kArgumentEmail : (id)email ?: [NSNull null]});
                       }
                     }];
}

- (void)userDelete:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  [currentUser deleteWithCompletion:^(NSError *_Nullable error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)userGetIdToken:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  BOOL forceRefresh = [arguments[@"forceRefresh"] boolValue];
  BOOL tokenOnly = [arguments[@"tokenOnly"] boolValue];

  [currentUser
      getIDTokenResultForcingRefresh:forceRefresh
                          completion:^(FIRAuthTokenResult *tokenResult, NSError *error) {
                            if (error != nil) {
                              result.error(nil, nil, nil, error);
                              return;
                            }

                            if (tokenOnly) {
                              result.success(
                                  @{kArgumentToken : (id)tokenResult.token ?: [NSNull null]});
                            } else {
                              long expirationTimestamp =
                                  (long)[tokenResult.expirationDate timeIntervalSince1970] * 1000;
                              long authTimestamp =
                                  (long)[tokenResult.authDate timeIntervalSince1970] * 1000;
                              long issuedAtTimestamp =
                                  (long)[tokenResult.issuedAtDate timeIntervalSince1970] * 1000;

                              NSMutableDictionary *tokenData =
                                  [[NSMutableDictionary alloc] initWithDictionary:@{
                                    @"authTimestamp" : @(authTimestamp),
                                    @"claims" : tokenResult.claims,
                                    @"expirationTimestamp" : @(expirationTimestamp),
                                    @"issuedAtTimestamp" : @(issuedAtTimestamp),
                                    @"signInProvider" : (id)tokenResult.signInProvider
                                        ?: [NSNull null],
                                    @"signInSecondFactor" : (id)tokenResult.signInSecondFactor
                                        ?: [NSNull null],
                                    kArgumentToken : tokenResult.token,
                                  }];

                              result.success(tokenData);
                            }
                          }];
}

- (void)userLinkWithCredential:(id)arguments
          withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  FIRAuthCredential *credential = [self getFIRAuthCredentialFromArguments:arguments];
  if (credential == nil) {
    result.error(kErrCodeInvalidCredential, kErrMsgInvalidCredential, nil, nil);
    return;
  }

  [currentUser linkWithCredential:credential
                       completion:^(FIRAuthDataResult *authResult, NSError *error) {
                         if (error != nil) {
                           result.error(nil, nil, nil, error);
                         } else {
                           result.success(authResult);
                         }
                       }];
}

- (void)userReauthenticateUserWithCredential:(id)arguments
                        withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  FIRAuthCredential *credential = [self getFIRAuthCredentialFromArguments:arguments];
  if (credential == nil) {
    result.error(kErrCodeInvalidCredential, kErrMsgInvalidCredential, nil, nil);
    return;
  }

  [currentUser reauthenticateWithCredential:credential
                                 completion:^(FIRAuthDataResult *authResult, NSError *error) {
                                   if (error != nil) {
                                     result.error(nil, nil, nil, error);
                                   } else {
                                     result.success(authResult);
                                   }
                                 }];
}

- (void)userReload:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  [currentUser reloadWithCompletion:^(NSError *_Nullable error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(auth.currentUser);
    }
  }];
}

- (void)userSendEmailVerification:(id)arguments
             withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  FIRActionCodeSettings *actionCodeSettings =
      [self getFIRActionCodeSettingsFromArguments:arguments];
  [currentUser sendEmailVerificationWithActionCodeSettings:actionCodeSettings
                                                completion:^(NSError *_Nullable error) {
                                                  if (error != nil) {
                                                    result.error(nil, nil, nil, error);
                                                  } else {
                                                    result.success(nil);
                                                  }
                                                }];
}

- (void)userUnlink:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  [currentUser
      unlinkFromProvider:arguments[kArgumentProviderId]
              completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                if (error != nil) {
                  result.error(nil, nil, nil, error);
                } else {
                  [auth.currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
                    if (reloadError != nil) {
                      result.error(nil, nil, nil, reloadError);
                    } else {
                      // Note: On other SDKs `unlinkFromProvider` returns an AuthResult
                      // instance, whereas the iOS SDK currently does not, so we manualy
                      // construct a Dart representation of one here.
                      result.success(@{
                        @"additionalUserInfo" : [NSNull null],
                        @"authCredential" : [NSNull null],
                        @"user" : auth.currentUser
                            ? [FLTFirebaseAuthPlugin getNSDictionaryFromUser:auth.currentUser]
                            : [NSNull null],
                      });
                    }
                  }];
                }
              }];
}

- (void)userUpdateEmail:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  [currentUser updateEmail:arguments[kArgumentNewEmail]
                completion:^(NSError *_Nullable error) {
                  if (error != nil) {
                    result.error(nil, nil, nil, error);
                  } else {
                    [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
                      if (reloadError != nil) {
                        result.error(nil, nil, nil, reloadError);
                      } else {
                        result.success(auth.currentUser);
                      }
                    }];
                  }
                }];
}

- (void)userUpdatePassword:(id)arguments
      withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  [currentUser updatePassword:arguments[@"newPassword"]
                   completion:^(NSError *_Nullable error) {
                     if (error != nil) {
                       result.error(nil, nil, nil, error);
                     } else {
                       [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
                         if (reloadError != nil) {
                           result.error(nil, nil, nil, reloadError);
                         } else {
                           result.success(auth.currentUser);
                         }
                       }];
                     }
                   }];
}

- (void)userUpdatePhoneNumber:(id)arguments
         withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
#if TARGET_OS_IPHONE
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  FIRAuthCredential *credential = [self getFIRAuthCredentialFromArguments:arguments];
  if (credential == nil) {
    result.error(kErrCodeInvalidCredential, kErrMsgInvalidCredential, nil, nil);
    return;
  }

  [currentUser
      updatePhoneNumberCredential:(FIRPhoneAuthCredential *)credential
                       completion:^(NSError *_Nullable error) {
                         if (error != nil) {
                           result.error(nil, nil, nil, error);
                         } else {
                           [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
                             if (reloadError != nil) {
                               result.error(nil, nil, nil, reloadError);
                             } else {
                               result.success(auth.currentUser);
                             }
                           }];
                         }
                       }];
#else
  NSLog(@"Updating a users phone number via Firebase Authentication is only supported on the iOS "
        @"platform.");
  result.success(nil);
#endif
}

- (void)userUpdateProfile:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  NSDictionary *profileUpdates = arguments[@"profile"];
  FIRUserProfileChangeRequest *changeRequest = [currentUser profileChangeRequest];

  if (profileUpdates[@"displayName"] != nil) {
    if ([profileUpdates[@"displayName"] isEqual:[NSNull null]]) {
      changeRequest.displayName = nil;
    } else {
      changeRequest.displayName = profileUpdates[@"displayName"];
    }
  }

  if (profileUpdates[@"photoURL"] != nil) {
    if ([profileUpdates[@"photoURL"] isEqual:[NSNull null]]) {
      // We apparently cannot set photoURL to nil/NULL to remove it.
      // Instead, setting it to empty string appears to work.
      // When doing so, Dart will properly receive `null` anyway.
      changeRequest.photoURL = [NSURL URLWithString:@""];
    } else {
      changeRequest.photoURL = [NSURL URLWithString:profileUpdates[@"photoURL"]];
    }
  }

  [changeRequest commitChangesWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
        if (reloadError != nil) {
          result.error(nil, nil, nil, reloadError);
        } else {
          result.success(auth.currentUser);
        }
      }];
    }
  }];
}

- (void)userVerifyBeforeUpdateEmail:(id)arguments
               withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    result.error(kErrCodeNoCurrentUser, kErrMsgNoCurrentUser, nil, nil);
    return;
  }

  NSString *newEmail = arguments[kArgumentNewEmail];
  FIRActionCodeSettings *actionCodeSettings =
      [self getFIRActionCodeSettingsFromArguments:arguments];
  [currentUser sendEmailVerificationBeforeUpdatingEmail:newEmail
                                     actionCodeSettings:actionCodeSettings
                                             completion:^(NSError *error) {
                                               if (error != nil) {
                                                 result.error(nil, nil, nil, error);
                                               } else {
                                                 result.success(nil);
                                               }
                                             }];
}

- (void)registerIdTokenListener:(id)arguments
           withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  NSString *name =
      [NSString stringWithFormat:@"%@/id-token/%@", kFLTFirebaseAuthChannelName, auth.app.name];

  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  FLTIdTokenChannelStreamHandler *handler =
      [[FLTIdTokenChannelStreamHandler alloc] initWithAuth:auth];
  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];

  result.success(name);
}

- (void)registerAuthStateListener:(id)arguments
             withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  NSString *name =
      [NSString stringWithFormat:@"%@/auth-state/%@", kFLTFirebaseAuthChannelName, auth.app.name];
  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  FLTAuthStateChannelStreamHandler *handler =
      [[FLTAuthStateChannelStreamHandler alloc] initWithAuth:auth];
  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];

  result.success(name);
}

- (void)signInAnonymously:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];
  [auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult *authResult, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(authResult);
    }
  }];
}

- (void)verifyPhoneNumber:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
#if TARGET_OS_OSX
  NSLog(@"The Firebase Phone Authentication provider is not supported on the MacOS platform.");
  result.success(nil);
#else
  FIRAuth *auth = [self getFIRAuthFromArguments:arguments];

  NSString *name = [NSString
      stringWithFormat:@"%@/phone/%@", kFLTFirebaseAuthChannelName, [NSUUID UUID].UUIDString];
  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  FLTPhoneNumberVerificationStreamHandler *handler =
      [[FLTPhoneNumberVerificationStreamHandler alloc] initWithAuth:auth arguments:arguments];
  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];

  result.success(name);
#endif
}

#pragma mark - Utilities

- (void)storeAuthCredentialIfPresent:(NSError *)error {
  if ([error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey] != nil) {
    FIRAuthCredential *authCredential = [error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey];
    // We temporarily store the non-serializable credential so the
    // Dart API can consume these at a later time.
    NSNumber *authCredentialHash = @([authCredential hash]);
    _credentials[authCredentialHash] = authCredential;
  }
}

+ (NSDictionary *)getNSDictionaryFromNSError:(NSError *)error {
  NSString *code = @"unknown";
  NSString *message = @"An unknown error has occurred.";

  if (error == nil) {
    return @{
      kArgumentCode : code,
      @"message" : message,
      @"additionalData" : @{},
    };
  }

  // code
  if ([error userInfo][FIRAuthErrorUserInfoNameKey] != nil) {
    // See [FIRAuthErrorCodeString] for list of codes.
    // Codes are in the format "ERROR_SOME_NAME", converting below to the format required in Dart.
    // ERROR_SOME_NAME -> SOME_NAME
    NSString *firebaseErrorCode = [error userInfo][FIRAuthErrorUserInfoNameKey];
    code = [firebaseErrorCode stringByReplacingOccurrencesOfString:@"ERROR_" withString:@""];
    // SOME_NAME -> SOME-NAME
    code = [code stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    // SOME-NAME -> some-name
    code = [code lowercaseString];
  }

  // message
  if ([error userInfo][NSLocalizedDescriptionKey] != nil) {
    message = [error userInfo][NSLocalizedDescriptionKey];
  }

  NSMutableDictionary *additionalData = [NSMutableDictionary dictionary];
  // additionalData.email
  if ([error userInfo][FIRAuthErrorUserInfoEmailKey] != nil) {
    additionalData[kArgumentEmail] = [error userInfo][FIRAuthErrorUserInfoEmailKey];
  }
  // additionalData.authCredential
  if ([error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey] != nil) {
    FIRAuthCredential *authCredential = [error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey];
    additionalData[@"authCredential"] =
        [FLTFirebaseAuthPlugin getNSDictionaryFromAuthCredential:authCredential];
  }

  // Manual message overrides to ensure messages/codes matche other platforms.
  if ([message isEqual:@"The password must be 6 characters long or more."]) {
    message = @"Password should be at least 6 characters";
  }

  return @{
    kArgumentCode : code,
    @"message" : message,
    @"additionalData" : additionalData,
  };
}

- (FIRAuth *_Nullable)getFIRAuthFromArguments:(NSDictionary *)arguments {
  NSString *appNameDart = arguments[@"appName"];
  NSString *tenantId = arguments[@"tenantId"];
  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appNameDart];
  FIRAuth *auth = [FIRAuth authWithApp:app];

  if (tenantId != nil && ![tenantId isEqual:[NSNull null]]) {
    auth.tenantID = tenantId;
  }

  return auth;
}

- (FIRActionCodeSettings *_Nullable)getFIRActionCodeSettingsFromArguments:
    (NSDictionary *)arguments {
  NSDictionary *actionCodeSettingsDictionary = arguments[kArgumentActionCodeSettings];
  if (actionCodeSettingsDictionary == nil || [actionCodeSettingsDictionary isEqual:[NSNull null]]) {
    return nil;
  }

  FIRActionCodeSettings *actionCodeSettings = [FIRActionCodeSettings new];
  NSDictionary *iOSSettings = actionCodeSettingsDictionary[@"iOS"];
  NSDictionary *androidSettings = actionCodeSettingsDictionary[@"android"];

  // URL - required
  actionCodeSettings.URL = [NSURL URLWithString:actionCodeSettingsDictionary[@"url"]];

  // Dynamic Link Domain - optional
  if (actionCodeSettingsDictionary[@"dynamicLinkDomain"] != nil &&
      ![actionCodeSettingsDictionary[@"dynamicLinkDomain"] isEqual:[NSNull null]]) {
    actionCodeSettings.dynamicLinkDomain = actionCodeSettingsDictionary[@"dynamicLinkDomain"];
  }

  // Handle code in app - optional
  if (actionCodeSettingsDictionary[@"handleCodeInApp"] != nil &&
      ![actionCodeSettingsDictionary[@"handleCodeInApp"] isEqual:[NSNull null]]) {
    actionCodeSettings.handleCodeInApp =
        [actionCodeSettingsDictionary[@"handleCodeInApp"] boolValue];
  }

  // Android settings - optional
  if (androidSettings != nil && ![androidSettings isEqual:[NSNull null]]) {
    BOOL installIfNotAvailable = NO;
    if (androidSettings[@"installApp"] != nil &&
        ![androidSettings[@"installApp"] isEqual:[NSNull null]]) {
      installIfNotAvailable = [androidSettings[@"installApp"] boolValue];
    }
    [actionCodeSettings setAndroidPackageName:androidSettings[@"packageName"]
                        installIfNotAvailable:installIfNotAvailable
                               minimumVersion:androidSettings[@"minimumVersion"]];
  }

  // iOS settings - optional
  if (iOSSettings != nil && ![iOSSettings isEqual:[NSNull null]]) {
    if (iOSSettings[@"bundleId"] != nil && ![iOSSettings[@"bundleId"] isEqual:[NSNull null]]) {
      [actionCodeSettings setIOSBundleID:iOSSettings[@"bundleId"]];
    }
  }

  return actionCodeSettings;
}

- (FIRAuthCredential *_Nullable)getFIRAuthCredentialFromArguments:(NSDictionary *)arguments {
  NSDictionary *credentialDictionary = arguments[kArgumentCredential];

  // If the credential dictionary contains a token, it means a native one has been stored for later
  // usage, so we'll attempt to retrieve it here.
  if (credentialDictionary[kArgumentToken] != nil &&
      ![credentialDictionary[kArgumentToken] isEqual:[NSNull null]]) {
    NSNumber *credentialHashCode = credentialDictionary[kArgumentToken];
    return _credentials[credentialHashCode];
  }

  NSString *signInMethod = credentialDictionary[kArgumentSignInMethod];
  NSString *secret = credentialDictionary[kArgumentSecret] == [NSNull null]
                         ? nil
                         : credentialDictionary[kArgumentSecret];
  NSString *idToken = credentialDictionary[kArgumentIdToken] == [NSNull null]
                          ? nil
                          : credentialDictionary[kArgumentIdToken];
  NSString *accessToken = credentialDictionary[kArgumentAccessToken] == [NSNull null]
                              ? nil
                              : credentialDictionary[kArgumentAccessToken];
  NSString *rawNonce = credentialDictionary[kArgumentRawNonce] == [NSNull null]
                           ? nil
                           : credentialDictionary[kArgumentRawNonce];

  // Password Auth
  if ([signInMethod isEqualToString:kSignInMethodPassword]) {
    NSString *email = credentialDictionary[kArgumentEmail];
    return [FIREmailAuthProvider credentialWithEmail:email password:secret];
  }

  // Email Link Auth
  if ([signInMethod isEqualToString:kSignInMethodEmailLink]) {
    NSString *email = credentialDictionary[kArgumentEmail];
    NSString *emailLink = credentialDictionary[kArgumentEmailLink];
    return [FIREmailAuthProvider credentialWithEmail:email link:emailLink];
  }

  // Facebook Auth
  if ([signInMethod isEqualToString:kSignInMethodFacebook]) {
    return [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
  }

  // Google Auth
  if ([signInMethod isEqualToString:kSignInMethodGoogle]) {
    return [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:accessToken];
  }

  // Twitter Auth
  if ([signInMethod isEqualToString:kSignInMethodTwitter]) {
    return [FIRTwitterAuthProvider credentialWithToken:accessToken secret:secret];
  }

  // GitHub Auth
  if ([signInMethod isEqualToString:kSignInMethodGithub]) {
    return [FIRGitHubAuthProvider credentialWithToken:accessToken];
  }

  // Phone Auth - Only supported on iOS
  if ([signInMethod isEqualToString:kSignInMethodPhone]) {
#if TARGET_OS_IPHONE
    NSString *verificationId = credentialDictionary[kArgumentVerificationId];
    NSString *smsCode = credentialDictionary[kArgumentSmsCode];
    return [[FIRPhoneAuthProvider providerWithAuth:[self getFIRAuthFromArguments:arguments]]
        credentialWithVerificationID:verificationId
                    verificationCode:smsCode];
#else
    NSLog(@"The Firebase Phone Authentication provider is not supported on the MacOS platform.");
    return nil;
#endif
  }

  // OAuth
  if ([signInMethod isEqualToString:kSignInMethodOAuth]) {
    NSString *providerId = credentialDictionary[kArgumentProviderId];
    return [FIROAuthProvider credentialWithProviderID:providerId
                                              IDToken:idToken
                                             rawNonce:rawNonce
                                          accessToken:accessToken];
  }

  NSLog(@"Support for an auth provider with identifier '%@' is not implemented.", signInMethod);
  return nil;
}

- (NSDictionary *)getNSDictionaryFromAuthResult:(FIRAuthDataResult *)authResult {
  return @{
    @"additionalUserInfo" :
        [self getNSDictionaryFromAdditionalUserInfo:authResult.additionalUserInfo],
    @"authCredential" :
        [FLTFirebaseAuthPlugin getNSDictionaryFromAuthCredential:authResult.credential],
    @"user" : [FLTFirebaseAuthPlugin getNSDictionaryFromUser:authResult.user],
  };
}

- (id)getNSDictionaryFromAdditionalUserInfo:(FIRAdditionalUserInfo *)additionalUserInfo {
  if (additionalUserInfo == nil) {
    return [NSNull null];
  }

  return @{
    @"isNewUser" : @(additionalUserInfo.newUser),
    @"profile" : (id)additionalUserInfo.profile ?: [NSNull null],
    kArgumentProviderId : (id)additionalUserInfo.providerID ?: [NSNull null],
    @"username" : (id)additionalUserInfo.username ?: [NSNull null],
  };
}

+ (id)getNSDictionaryFromAuthCredential:(FIRAuthCredential *)authCredential {
  if (authCredential == nil) {
    return [NSNull null];
  }

  return @{
    kArgumentProviderId : authCredential.provider,
    // Note: "signInMethod" does not exist on iOS SDK, so using provider instead.
    kArgumentSignInMethod : authCredential.provider,
    kArgumentToken : @([authCredential hash]),
  };
}

+ (NSDictionary *)getNSDictionaryFromUserInfo:(id<FIRUserInfo>)userInfo {
  NSString *photoURL = nil;
  if (userInfo.photoURL != nil) {
    photoURL = userInfo.photoURL.absoluteString;
    if ([photoURL length] == 0) photoURL = nil;
  }
  return @{
    kArgumentProviderId : userInfo.providerID,
    @"displayName" : (id)userInfo.displayName ?: [NSNull null],
    @"uid" : (id)userInfo.uid ?: [NSNull null],
    @"photoURL" : (id)photoURL ?: [NSNull null],
    kArgumentEmail : (id)userInfo.email ?: [NSNull null],
    @"phoneNumber" : (id)userInfo.phoneNumber ?: [NSNull null],
  };
}

+ (NSMutableDictionary *)getNSDictionaryFromUser:(FIRUser *)user {
  // FIRUser inherits from FIRUserInfo, so we can re-use `getNSDictionaryFromUserInfo` method.
  NSMutableDictionary *userData = [[self getNSDictionaryFromUserInfo:user] mutableCopy];
  NSMutableDictionary *metadata = [NSMutableDictionary dictionary];

  // This code is necessary to avoid an iOS issue where when unlinking the `password` provider
  // the previous email still remains on the currentUser.
  if ([user.providerData count] == 0) {
    userData[@"email"] = [NSNull null];
  }

  // metadata.creationTimestamp as milliseconds
  long creationDate = (long)([user.metadata.creationDate timeIntervalSince1970] * 1000);
  metadata[@"creationTime"] = @(creationDate);

  // metadata.lastSignInTimestamp as milliseconds
  long lastSignInDate = (long)([user.metadata.lastSignInDate timeIntervalSince1970] * 1000);
  metadata[@"lastSignInTime"] = @(lastSignInDate);

  // metadata
  userData[@"metadata"] = metadata;

  // providerData
  NSMutableArray<NSDictionary<NSString *, NSString *> *> *providerData =
      [NSMutableArray arrayWithCapacity:user.providerData.count];
  for (id<FIRUserInfo> userInfo in user.providerData) {
    [providerData addObject:[FLTFirebaseAuthPlugin getNSDictionaryFromUserInfo:userInfo]];
  }
  userData[@"providerData"] = providerData;

  userData[@"isAnonymous"] = @(user.isAnonymous);
  userData[@"emailVerified"] = @(user.isEmailVerified);

  if (user.tenantID != nil) {
    userData[@"tenantId"] = user.tenantID;
  } else {
    userData[@"tenantId"] = [NSNull null];
  }

  // native does not provide refresh tokens
  userData[@"refreshToken"] = @"";
  return userData;
}

@end
