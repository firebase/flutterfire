// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseAuth;
#import <FirebaseAuth/FirebaseAuth.h>
#import <TargetConditionals.h>
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "include/Private/FLTAuthStateChannelStreamHandler.h"
#import "include/Private/FLTIdTokenChannelStreamHandler.h"
#import "include/Private/FLTPhoneNumberVerificationStreamHandler.h"
#import "include/Private/PigeonParser.h"

#import "include/Public/CustomPigeonHeader.h"
#import "include/Public/FLTFirebaseAuthPlugin.h"
@import CommonCrypto;
#import <AuthenticationServices/AuthenticationServices.h>

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
#import <FLTFirebaseCorePlugin.h>
#endif

NSString *const kFLTFirebaseAuthChannelName = @"plugins.flutter.io/firebase_auth";

// Argument Keys
NSString *const kAppName = @"appName";

// Provider type keys.
NSString *const kSignInMethodPassword = @"password";
NSString *const kSignInMethodEmailLink = @"emailLink";
NSString *const kSignInMethodFacebook = @"facebook.com";
NSString *const kSignInMethodGoogle = @"google.com";
NSString *const kSignInMethodGameCenter = @"gc.apple.com";
NSString *const kSignInMethodTwitter = @"twitter.com";
NSString *const kSignInMethodGithub = @"github.com";
NSString *const kSignInMethodApple = @"apple.com";
NSString *const kSignInMethodPhone = @"phone";
NSString *const kSignInMethodOAuth = @"oauth";

// Credential argument keys.
NSString *const kArgumentCredential = @"credential";
NSString *const kArgumentProviderId = @"providerId";
NSString *const kArgumentProviderScope = @"scopes";
NSString *const kArgumentProviderCustomParameters = @"customParameters";
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
NSString *const kArgumentFamilyName = @"familyName";
NSString *const kArgumentGivenName = @"givenName";
NSString *const kArgumentMiddleName = @"middleName";
NSString *const kArgumentNickname = @"nickname";
NSString *const kArgumentNamePrefix = @"namePrefix";
NSString *const kArgumentNameSuffix = @"nameSuffix";

// MultiFactor
NSString *const kArgumentMultiFactorHints = @"multiFactorHints";
NSString *const kArgumentMultiFactorSessionId = @"multiFactorSessionId";
NSString *const kArgumentMultiFactorResolverId = @"multiFactorResolverId";
NSString *const kArgumentMultiFactorInfo = @"multiFactorInfo";

// Manual error codes & messages.
NSString *const kErrCodeNoCurrentUser = @"no-current-user";
NSString *const kErrMsgNoCurrentUser = @"No user currently signed in.";
NSString *const kErrCodeInvalidCredential = @"invalid-credential";
NSString *const kErrMsgInvalidCredential =
    @"The supplied auth credential is malformed, has expired or is not "
    @"currently supported.";

// Used for caching credentials between Method Channel method calls.
static NSMutableDictionary<NSNumber *, FIRAuthCredential *> *credentialsMap;

@interface FLTFirebaseAuthPlugin ()
@property(nonatomic, retain) NSObject<FlutterBinaryMessenger> *messenger;
@property(strong, nonatomic) FIROAuthProvider *authProvider;
// Used to keep the user who wants to link with Apple Sign In
@property(strong, nonatomic) FIRUser *linkWithAppleUser;
@property(strong, nonatomic) FIRAuth *signInWithAppleAuth;
@property BOOL isReauthenticatingWithApple;
@property(strong, nonatomic) NSString *currentNonce;
@property(strong, nonatomic) void (^appleCompletion)
    (PigeonUserCredential *_Nullable, FlutterError *_Nullable);
@property(strong, nonatomic) AuthPigeonFirebaseApp *appleArguments;

@end

@implementation FLTFirebaseAuthPlugin {
  // Map an id to a MultiFactorSession object.
  NSMutableDictionary<NSString *, FIRMultiFactorSession *> *_multiFactorSessionMap;

  // Map an id to a MultiFactorResolver object.
  NSMutableDictionary<NSString *, FIRMultiFactorResolver *> *_multiFactorResolverMap;

  // Map an id to a MultiFactorResolver object.
  NSMutableDictionary<NSString *, FIRMultiFactorAssertion *> *_multiFactorAssertionMap;

  // Map an id to a MultiFactorResolver object.
  NSMutableDictionary<NSString *, FIRTOTPSecret *> *_multiFactorTotpSecretMap;

  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
  NSMutableDictionary<NSString *, FlutterEventChannel *> *_eventChannels;
  NSMutableDictionary<NSString *, NSObject<FlutterStreamHandler> *> *_streamHandlers;
  NSData *_apnsToken;
}

#pragma mark - FlutterPlugin

- (instancetype)init:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:self];
    credentialsMap = [NSMutableDictionary<NSNumber *, FIRAuthCredential *> dictionary];
    _binaryMessenger = messenger;
    _eventChannels = [NSMutableDictionary dictionary];
    _streamHandlers = [NSMutableDictionary dictionary];

    _multiFactorSessionMap = [NSMutableDictionary dictionary];
    _multiFactorResolverMap = [NSMutableDictionary dictionary];
    _multiFactorAssertionMap = [NSMutableDictionary dictionary];
    _multiFactorTotpSecretMap = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseAuthChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAuthPlugin *instance = [[FLTFirebaseAuthPlugin alloc] init:registrar.messenger];

  [registrar addMethodCallDelegate:instance channel:channel];

  [registrar publish:instance];
  [registrar addApplicationDelegate:instance];
  SetUpFirebaseAuthHostApi(registrar.messenger, instance);
  SetUpFirebaseAuthUserHostApi(registrar.messenger, instance);
  SetUpMultiFactorUserHostApi(registrar.messenger, instance);
  SetUpMultiFactoResolverHostApi(registrar.messenger, instance);
  SetUpMultiFactorTotpHostApi(registrar.messenger, instance);
  SetUpMultiFactorTotpSecretHostApi(registrar.messenger, instance);
}

+ (FlutterError *)convertToFlutterError:(NSError *)error {
  NSString *code = @"unknown";
  NSString *message = @"An unknown error has occurred.";

  if (error == nil) {
    return [FlutterError errorWithCode:code message:message details:@{}];
  }

  // code
  if ([error userInfo][FIRAuthErrorUserInfoNameKey] != nil) {
    // See [FIRAuthErrorCodeString] for list of codes.
    // Codes are in the format "ERROR_SOME_NAME", converting below to the format
    // required in Dart. ERROR_SOME_NAME -> SOME_NAME
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
  // We want to store the credential if present for future sign in if the exception contains a
  // credential, we pass a token back to Flutter to allow retrieval of the credential.
  NSNumber *token = [FLTFirebaseAuthPlugin storeAuthCredentialIfPresent:error];

  // additionalData.authCredential
  if ([error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey] != nil) {
    FIRAuthCredential *authCredential = [error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey];
    additionalData[@"authCredential"] = [PigeonParser getPigeonAuthCredential:authCredential
                                                                        token:token];
  }

  // Manual message overrides to ensure messages/codes matches other platforms.
  if ([message isEqual:@"The password must be 6 characters long or more."]) {
    message = @"Password should be at least 6 characters";
  }

  return [FlutterError errorWithCode:code message:message details:additionalData];
}

+ (id)getNSDictionaryFromAuthCredential:(FIRAuthCredential *)authCredential {
  if (authCredential == nil) {
    return [NSNull null];
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

  return @{
    kArgumentProviderId : authCredential.provider,
    // Note: "signInMethod" does not exist on iOS SDK, so using provider
    // instead.
    kArgumentSignInMethod : authCredential.provider,
    kArgumentToken : @([authCredential hash]),
    kArgumentAccessToken : accessToken ?: [NSNull null],
  };
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
  // Cleanup credentials.
  [credentialsMap removeAllObjects];

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
  _apnsToken = deviceToken;
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
  return @LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return @LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseAuthChannelName;
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *_Nonnull)firebaseApp {
  FIRAuth *auth = [FIRAuth authWithApp:firebaseApp];
  return @{
    @"APP_LANGUAGE_CODE" : (id)[auth languageCode] ?: [NSNull null],
    @"APP_CURRENT_USER" : [auth currentUser]
        ? [PigeonParser getManualList:[PigeonParser getPigeonDetails:[auth currentUser]]]
        : [NSNull null],
  };
}

#pragma mark - Firebase Auth API

// Adapted from
// https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce Used
// for Apple Sign In
- (NSString *)randomNonce:(NSInteger)length {
  NSAssert(length > 0, @"Expected nonce to have positive length");
  NSString *characterSet = @"0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._";
  NSMutableString *result = [NSMutableString string];
  NSInteger remainingLength = length;

  while (remainingLength > 0) {
    NSMutableArray *randoms = [NSMutableArray arrayWithCapacity:16];
    for (NSInteger i = 0; i < 16; i++) {
      uint8_t random = 0;
      int errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random);
      NSAssert(errorCode == errSecSuccess, @"Unable to generate nonce: OSStatus %i", errorCode);

      [randoms addObject:@(random)];
    }

    for (NSNumber *random in randoms) {
      if (remainingLength == 0) {
        break;
      }

      if (random.unsignedIntValue < characterSet.length) {
        unichar character = [characterSet characterAtIndex:random.unsignedIntValue];
        [result appendFormat:@"%C", character];
        remainingLength--;
      }
    }
  }

  return [result copy];
}

- (NSString *)stringBySha256HashingString:(NSString *)input {
  const char *string = [input UTF8String];
  unsigned char result[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(string, (CC_LONG)strlen(string), result);

  NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (NSInteger i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [hashed appendFormat:@"%02x", result[i]];
  }
  return hashed;
}

static void handleSignInWithApple(FLTFirebaseAuthPlugin *object, FIRAuthDataResult *authResult,
                                  NSString *authorizationCode, NSError *error) {
  void (^completion)(PigeonUserCredential *_Nullable, FlutterError *_Nullable) =
      object.appleCompletion;
  if (completion == nil) return;

  if (error != nil) {
    if (error.code == FIRAuthErrorCodeSecondFactorRequired) {
      [object handleMultiFactorError:object.appleArguments completion:completion withError:error];
    } else {
      completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
    }
    return;
  }
  completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                               authorizationCode:authorizationCode],
             nil);
}

- (void)authorizationController:(ASAuthorizationController *)controller
    didCompleteWithAuthorization:(ASAuthorization *)authorization
    API_AVAILABLE(macos(10.15), ios(13.0)) {
  if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
    ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
    NSString *rawNonce = self.currentNonce;
    NSAssert(rawNonce != nil,
             @"Invalid state: A login callback was received, but no login request was sent.");

    if (appleIDCredential.identityToken == nil) {
      NSLog(@"Unable to fetch identity token.");
      return;
    }

    NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken
                                              encoding:NSUTF8StringEncoding];
    if (idToken == nil) {
      NSLog(@"Unable to serialize id token from data: %@", appleIDCredential.identityToken);
    }

    NSString *authorizationCode = nil;
    if (appleIDCredential.authorizationCode != nil) {
      authorizationCode = [[NSString alloc] initWithData:appleIDCredential.authorizationCode
                                                encoding:NSUTF8StringEncoding];
    }

    FIROAuthCredential *credential =
        [FIROAuthProvider appleCredentialWithIDToken:idToken
                                            rawNonce:rawNonce
                                            fullName:appleIDCredential.fullName];

    if (self.isReauthenticatingWithApple == YES) {
      self.isReauthenticatingWithApple = NO;
      void (^capturedCompletion)(PigeonUserCredential *_Nullable, FlutterError *_Nullable) =
          self.appleCompletion;
      [[FIRAuth.auth currentUser]
          reauthenticateWithCredential:credential
                            completion:^(FIRAuthDataResult *_Nullable authResult,
                                         NSError *_Nullable error) {
                              handleSignInWithApple(self, authResult, authorizationCode, error);
                            }];

    } else if (self.linkWithAppleUser != nil) {
      FIRUser *userToLink = self.linkWithAppleUser;
      void (^capturedCompletion)(PigeonUserCredential *_Nullable, FlutterError *_Nullable) =
          self.appleCompletion;
      [userToLink linkWithCredential:credential
                          completion:^(FIRAuthDataResult *authResult, NSError *error) {
                            self.linkWithAppleUser = nil;
                            handleSignInWithApple(self, authResult, authorizationCode, error);
                          }];

    } else {
      FIRAuth *signInAuth =
          self.signInWithAppleAuth != nil ? self.signInWithAppleAuth : FIRAuth.auth;
      void (^capturedCompletion)(PigeonUserCredential *_Nullable, FlutterError *_Nullable) =
          self.appleCompletion;
      [signInAuth signInWithCredential:credential
                            completion:^(FIRAuthDataResult *_Nullable authResult,
                                         NSError *_Nullable error) {
                              self.signInWithAppleAuth = nil;
                              handleSignInWithApple(self, authResult, authorizationCode, error);
                            }];
    }
  }
}

- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error API_AVAILABLE(macos(10.15), ios(13.0)) {
  NSLog(@"Sign in with Apple errored: %@", error);
  switch (error.code) {
    case ASAuthorizationErrorCanceled:
      self.appleCompletion(
          nil, [FlutterError errorWithCode:@"canceled"
                                   message:@"The user canceled the authorization attempt."
                                   details:nil]);
      break;

    case ASAuthorizationErrorInvalidResponse:
      self.appleCompletion(
          nil,
          [FlutterError errorWithCode:@"invalid-response"
                              message:@"The authorization request received an invalid response."
                              details:nil]);
      break;

    case ASAuthorizationErrorNotHandled:
      self.appleCompletion(nil,
                           [FlutterError errorWithCode:@"not-handled"
                                               message:@"The authorization request wasn’t handled."
                                               details:nil]);
      break;

    case ASAuthorizationErrorFailed:
      self.appleCompletion(nil, [FlutterError errorWithCode:@"failed"
                                                    message:@"The authorization attempt failed."
                                                    details:nil]);
      break;

    case ASAuthorizationErrorUnknown:
    default:
      self.appleCompletion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
      break;
  }
  self.appleCompletion = nil;
}

- (void)handleInternalError:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                              FlutterError *_Nullable))completion
                  withError:(NSError *)error {
  const NSError *underlyingError = error.userInfo[@"NSUnderlyingError"];
  if (underlyingError != nil) {
    const NSDictionary *details =
        underlyingError.userInfo[@"FIRAuthErrorUserInfoDeserializedResponseKey"];
    completion(nil, [FlutterError errorWithCode:@"internal-error"
                                        message:error.description
                                        details:details]);
    return;
  }
  completion(nil, [FlutterError errorWithCode:@"internal-error"
                                      message:error.description
                                      details:nil]);
}

- (void)handleMultiFactorError:(AuthPigeonFirebaseApp *)app
                    completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                 FlutterError *_Nullable))completion
                     withError:(NSError *_Nullable)error {
  FIRMultiFactorResolver *resolver =
      (FIRMultiFactorResolver *)error.userInfo[FIRAuthErrorUserInfoMultiFactorResolverKey];

  NSArray<FIRMultiFactorInfo *> *hints = resolver.hints;
  FIRMultiFactorSession *session = resolver.session;

  NSString *sessionId = [[NSUUID UUID] UUIDString];
  self->_multiFactorSessionMap[sessionId] = session;

  NSString *resolverId = [[NSUUID UUID] UUIDString];
  self->_multiFactorResolverMap[resolverId] = resolver;

  NSMutableArray<NSDictionary *> *pigeonHints = [NSMutableArray array];

  for (FIRMultiFactorInfo *multiFactorInfo in hints) {
    NSString *phoneNumber;
    if ([multiFactorInfo class] == [FIRPhoneMultiFactorInfo class]) {
      FIRPhoneMultiFactorInfo *phoneFactorInfo = (FIRPhoneMultiFactorInfo *)multiFactorInfo;
      phoneNumber = phoneFactorInfo.phoneNumber;
    }

    PigeonMultiFactorInfo *object = [PigeonMultiFactorInfo
        makeWithDisplayName:multiFactorInfo.displayName
        enrollmentTimestamp:multiFactorInfo.enrollmentDate.timeIntervalSince1970
                   factorId:multiFactorInfo.factorID
                        uid:multiFactorInfo.UID
                phoneNumber:phoneNumber];

    [pigeonHints addObject:object.toList];
  }

  NSDictionary *output = @{
    kAppName : app.appName,
    kArgumentMultiFactorHints : pigeonHints,
    kArgumentMultiFactorSessionId : sessionId,
    kArgumentMultiFactorResolverId : resolverId,
  };
  completion(nil, [FlutterError errorWithCode:@"second-factor-required"
                                      message:error.description
                                      details:output]);
}

static void launchAppleSignInRequest(FLTFirebaseAuthPlugin *object, AuthPigeonFirebaseApp *app,
                                     PigeonSignInProvider *signInProvider,
                                     void (^_Nonnull completion)(PigeonUserCredential *_Nullable,
                                                                 FlutterError *_Nullable)) {
  if (@available(iOS 13.0, macOS 10.15, *)) {
    NSString *nonce = [object randomNonce:32];
    object.currentNonce = nonce;
    object.appleCompletion = completion;
    object.appleArguments = app;

    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];

    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    NSMutableArray *requestedScopes = [NSMutableArray arrayWithCapacity:2];
    if ([signInProvider.scopes containsObject:@"name"]) {
      [requestedScopes addObject:ASAuthorizationScopeFullName];
    }
    if ([signInProvider.scopes containsObject:@"email"]) {
      [requestedScopes addObject:ASAuthorizationScopeEmail];
    }
    request.requestedScopes = [requestedScopes copy];
    request.nonce = [object stringBySha256HashingString:nonce];

    ASAuthorizationController *authorizationController =
        [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[ request ]];
    authorizationController.delegate = object;
    authorizationController.presentationContextProvider = object;
    [authorizationController performRequests];
  } else {
    NSLog(@"Sign in with Apple was introduced in iOS 13, update your Podfile with platform :ios, "
          @"'13.0'");
  }
}

static void handleAppleAuthResult(FLTFirebaseAuthPlugin *object, AuthPigeonFirebaseApp *app,
                                  FIRAuth *auth, FIRAuthCredential *credentials, NSError *error,
                                  void (^_Nonnull completion)(PigeonUserCredential *_Nullable,
                                                              FlutterError *_Nullable)) {
  if (error) {
    if (error.code == FIRAuthErrorCodeSecondFactorRequired) {
      [object handleMultiFactorError:app completion:completion withError:error];
    } else {
      completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
    }
    return;
  }
  if (credentials) {
    [auth
        signInWithCredential:credentials
                  completion:^(FIRAuthDataResult *authResult, NSError *error) {
                    if (error != nil) {
                      NSDictionary *userInfo = [error userInfo];
                      NSError *underlyingError = [userInfo objectForKey:NSUnderlyingErrorKey];

                      NSDictionary *firebaseDictionary =
                          underlyingError.userInfo[@"FIRAuthErrorUserInfoDes"
                                                   @"erializedResponseKey"];

                      NSString *errorCode = userInfo[@"FIRAuthErrorUserInfoNameKey"];

                      if (firebaseDictionary == nil && errorCode != nil) {
                        if ([errorCode isEqual:@"ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL"]) {
                          completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                          return;
                        }

                        // Removing since it's not parsed and causing issue when sending back the
                        // object to Flutter
                        NSMutableDictionary *mutableUserInfo = [userInfo mutableCopy];
                        [mutableUserInfo
                            removeObjectForKey:@"FIRAuthErrorUserInfoUpdatedCredentialKey"];
                        NSError *modifiedError = [NSError errorWithDomain:error.domain
                                                                     code:error.code
                                                                 userInfo:mutableUserInfo];

                        completion(nil,
                                   [FlutterError errorWithCode:@"sign-in-failed"
                                                       message:userInfo[@"NSLocalizedDescription"]
                                                       details:modifiedError.userInfo]);

                      } else if (firebaseDictionary != nil &&
                                 firebaseDictionary[@"message"] != nil) {
                        // error from firebase-ios-sdk is
                        // buried in underlying error.
                        completion(nil,
                                   [FlutterError errorWithCode:@"sign-in-failed"
                                                       message:error.localizedDescription
                                                       details:firebaseDictionary[@"message"]]);
                      } else {
                        completion(nil, [FlutterError errorWithCode:@"sign-in-failed"
                                                            message:error.localizedDescription
                                                            details:error.userInfo]);
                      }
                    } else {
                      completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                                   authorizationCode:nil],
                                 nil);
                    }
                  }];
  }
}

#pragma mark - Utilities

+ (NSNumber *_Nullable)storeAuthCredentialIfPresent:(NSError *)error {
  if ([error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey] != nil) {
    FIRAuthCredential *authCredential = [error userInfo][FIRAuthErrorUserInfoUpdatedCredentialKey];
    // We temporarily store the non-serializable credential so the
    // Dart API can consume these at a later time.
    NSNumber *authCredentialHash = @([authCredential hash]);
    credentialsMap[authCredentialHash] = authCredential;
    return authCredentialHash;
  }
  return nil;
}

- (FIRAuth *_Nullable)getFIRAuthFromAppNameFromPigeon:(AuthPigeonFirebaseApp *)pigeonApp {
  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:pigeonApp.appName];
  FIRAuth *auth = [FIRAuth authWithApp:app];

  auth.tenantID = pigeonApp.tenantId;
  auth.customAuthDomain = [FLTFirebaseCorePlugin getCustomDomain:app.name];
  // Auth's `customAuthDomain` supersedes value from `getCustomDomain` set by `initializeApp`
  if (pigeonApp.customAuthDomain != nil) {
    auth.customAuthDomain = pigeonApp.customAuthDomain;
  }

  return auth;
}

- (void)getFIRAuthCredentialFromArguments:(NSDictionary *)arguments
                                      app:(AuthPigeonFirebaseApp *)app
                               completion:(void (^)(FIRAuthCredential *credential,
                                                    NSError *error))completion {
  // If the credential dictionary contains a token, it means a native one has
  // been stored for later usage, so we'll attempt to retrieve it here.
  if (arguments[kArgumentToken] != nil && ![arguments[kArgumentToken] isEqual:[NSNull null]]) {
    NSNumber *credentialHashCode = arguments[kArgumentToken];
    if (credentialsMap[credentialHashCode] != nil) {
      completion(credentialsMap[credentialHashCode], nil);
      return;
    }
  }

  NSString *signInMethod = arguments[kArgumentSignInMethod];

  if ([signInMethod isEqualToString:kSignInMethodGameCenter]) {
    // Game Center Games is different to other providers, it requires below callback to get a
    // credential. This is why getFIRAuthCredentialFromArguments now requires a completion()
    // callback
    [FIRGameCenterAuthProvider
        getCredentialWithCompletion:^(FIRAuthCredential *credential, NSError *error) {
          if (error) {
            completion(nil, error);
          } else {
            completion(credential, nil);
          }
        }];
    return;
  }

  NSString *secret = arguments[kArgumentSecret] == [NSNull null] ? nil : arguments[kArgumentSecret];
  NSString *idToken =
      arguments[kArgumentIdToken] == [NSNull null] ? nil : arguments[kArgumentIdToken];
  NSString *accessToken =
      arguments[kArgumentAccessToken] == [NSNull null] ? nil : arguments[kArgumentAccessToken];
  NSString *rawNonce =
      arguments[kArgumentRawNonce] == [NSNull null] ? nil : arguments[kArgumentRawNonce];

  // Password Auth
  if ([signInMethod isEqualToString:kSignInMethodPassword]) {
    NSString *email = arguments[kArgumentEmail];
    completion([FIREmailAuthProvider credentialWithEmail:email password:secret], nil);
    return;
  }

  // Email Link Auth
  if ([signInMethod isEqualToString:kSignInMethodEmailLink]) {
    NSString *email = arguments[kArgumentEmail];
    NSString *emailLink = arguments[kArgumentEmailLink];
    completion([FIREmailAuthProvider credentialWithEmail:email link:emailLink], nil);
    return;
  }

  // Facebook Auth
  if ([signInMethod isEqualToString:kSignInMethodFacebook]) {
    completion([FIRFacebookAuthProvider credentialWithAccessToken:accessToken], nil);
    return;
  }

  // Google Auth
  if ([signInMethod isEqualToString:kSignInMethodGoogle]) {
    completion([FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:accessToken], nil);
    return;
  }

  // Twitter Auth
  if ([signInMethod isEqualToString:kSignInMethodTwitter]) {
    completion([FIRTwitterAuthProvider credentialWithToken:accessToken secret:secret], nil);
    return;
  }

  // GitHub Auth
  if ([signInMethod isEqualToString:kSignInMethodGithub]) {
    completion([FIRGitHubAuthProvider credentialWithToken:accessToken], nil);
    return;
  }

  // Phone Auth - Only supported on iOS
  if ([signInMethod isEqualToString:kSignInMethodPhone]) {
#if TARGET_OS_IPHONE
    NSString *verificationId = arguments[kArgumentVerificationId];
    NSString *smsCode = arguments[kArgumentSmsCode];
    completion([[FIRPhoneAuthProvider providerWithAuth:[self getFIRAuthFromAppNameFromPigeon:app]]
                   credentialWithVerificationID:verificationId
                               verificationCode:smsCode],
               nil);
    return;
#else
    NSLog(@"The Firebase Phone Authentication provider is not supported on the "
          @"MacOS platform.");
    completion(nil, nil);
    return;
#endif
  }
  // Apple Auth
  if ([signInMethod isEqualToString:kSignInMethodApple]) {
    if (idToken && rawNonce) {
      // Credential with idToken, rawNonce and fullName
      NSPersonNameComponents *fullName = [[NSPersonNameComponents alloc] init];
      fullName.givenName =
          arguments[kArgumentGivenName] == [NSNull null] ? nil : arguments[kArgumentGivenName];
      fullName.familyName =
          arguments[kArgumentFamilyName] == [NSNull null] ? nil : arguments[kArgumentFamilyName];
      fullName.nickname =
          arguments[kArgumentNickname] == [NSNull null] ? nil : arguments[kArgumentNickname];
      fullName.namePrefix =
          arguments[kArgumentNamePrefix] == [NSNull null] ? nil : arguments[kArgumentNamePrefix];
      fullName.nameSuffix =
          arguments[kArgumentNameSuffix] == [NSNull null] ? nil : arguments[kArgumentNameSuffix];
      fullName.middleName =
          arguments[kArgumentMiddleName] == [NSNull null] ? nil : arguments[kArgumentMiddleName];

      completion([FIROAuthProvider appleCredentialWithIDToken:idToken
                                                     rawNonce:rawNonce
                                                     fullName:fullName],
                 nil);
      return;
    }
  }
  // OAuth
  if ([signInMethod isEqualToString:kSignInMethodOAuth]) {
    NSString *providerId = arguments[kArgumentProviderId];
    completion([FIROAuthProvider credentialWithProviderID:providerId
                                                  IDToken:idToken
                                                 rawNonce:rawNonce
                                              accessToken:accessToken],
               nil);
    return;
  }

  NSLog(@"Support for an auth provider with identifier '%@' is not implemented.", signInMethod);
  completion(nil, nil);
  return;
}

- (void)ensureAPNSTokenSetting {
#if !TARGET_OS_OSX
  FIRApp *defaultApp = [FIRApp defaultApp];
  if (defaultApp) {
    if ([FIRAuth auth].APNSToken == nil && _apnsToken != nil) {
      [[FIRAuth auth] setAPNSToken:_apnsToken type:FIRAuthAPNSTokenTypeUnknown];
      _apnsToken = nil;
    }
  }
#endif
}

- (FIRMultiFactor *)getAppMultiFactorFromPigeon:(nonnull AuthPigeonFirebaseApp *)app {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  return currentUser.multiFactor;
}

- (nonnull ASPresentationAnchor)presentationAnchorForAuthorizationController:
    (nonnull ASAuthorizationController *)controller API_AVAILABLE(macos(10.15), ios(13.0)) {
#if TARGET_OS_OSX
  return [[NSApplication sharedApplication] keyWindow];
#else
  return [[UIApplication sharedApplication] keyWindow];
#endif
}

- (void)enrollPhoneApp:(nonnull AuthPigeonFirebaseApp *)app
             assertion:(nonnull PigeonPhoneMultiFactorAssertion *)assertion
           displayName:(nullable NSString *)displayName
            completion:(nonnull void (^)(FlutterError *_Nullable))completion {
#if TARGET_OS_OSX
  completion([FlutterError errorWithCode:@"unsupported-platform"
                                 message:@"Phone authentication is not supported on macOS"
                                 details:nil]);
#else

  FIRMultiFactor *multiFactor = [self getAppMultiFactorFromPigeon:app];

  FIRPhoneAuthCredential *credential =
      [[FIRPhoneAuthProvider providerWithAuth:[self getFIRAuthFromAppNameFromPigeon:app]]
          credentialWithVerificationID:[assertion verificationId]
                      verificationCode:[assertion verificationCode]];

  FIRMultiFactorAssertion *multiFactorAssertion =
      [FIRPhoneMultiFactorGenerator assertionWithCredential:credential];

  [multiFactor enrollWithAssertion:multiFactorAssertion
                       displayName:displayName
                        completion:^(NSError *_Nullable error) {
                          if (error == nil) {
                            completion(nil);
                          } else {
                            completion([FlutterError errorWithCode:@"enroll-failed"
                                                           message:error.localizedDescription
                                                           details:nil]);
                          }
                        }];
#endif
}

- (void)getEnrolledFactorsApp:(nonnull AuthPigeonFirebaseApp *)app
                   completion:(nonnull void (^)(NSArray<PigeonMultiFactorInfo *> *_Nullable,
                                                FlutterError *_Nullable))completion {
  FIRMultiFactor *multiFactor = [self getAppMultiFactorFromPigeon:app];

  NSArray<FIRMultiFactorInfo *> *enrolledFactors = [multiFactor enrolledFactors];

  NSMutableArray<PigeonMultiFactorInfo *> *results = [NSMutableArray array];

  for (FIRMultiFactorInfo *multiFactorInfo in enrolledFactors) {
    NSString *phoneNumber;
    if ([multiFactorInfo class] == [FIRPhoneMultiFactorInfo class]) {
      FIRPhoneMultiFactorInfo *phoneFactorInfo = (FIRPhoneMultiFactorInfo *)multiFactorInfo;
      phoneNumber = phoneFactorInfo.phoneNumber;
    }

    [results addObject:[PigeonMultiFactorInfo
                           makeWithDisplayName:multiFactorInfo.displayName
                           enrollmentTimestamp:multiFactorInfo.enrollmentDate.timeIntervalSince1970
                                      factorId:multiFactorInfo.factorID
                                           uid:multiFactorInfo.UID
                                   phoneNumber:phoneNumber]];
  }

  completion(results, nil);
}

- (void)getSessionApp:(nonnull AuthPigeonFirebaseApp *)app
           completion:(nonnull void (^)(PigeonMultiFactorSession *_Nullable,
                                        FlutterError *_Nullable))completion {
  FIRMultiFactor *multiFactor = [self getAppMultiFactorFromPigeon:app];
  [multiFactor getSessionWithCompletion:^(FIRMultiFactorSession *_Nullable session,
                                          NSError *_Nullable error) {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    self->_multiFactorSessionMap[UUID] = session;

    PigeonMultiFactorSession *pigeonSession = [PigeonMultiFactorSession makeWithId:UUID];
    completion(pigeonSession, nil);
  }];
}

- (void)unenrollApp:(nonnull AuthPigeonFirebaseApp *)app
          factorUid:(nonnull NSString *)factorUid
         completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRMultiFactor *multiFactor = [self getAppMultiFactorFromPigeon:app];
  [multiFactor unenrollWithFactorUID:factorUid
                          completion:^(NSError *_Nullable error) {
                            if (error == nil) {
                              completion(nil);
                            } else {
                              completion([FlutterError errorWithCode:@"unenroll-failed"
                                                             message:error.localizedDescription
                                                             details:nil]);
                            }
                          }];
}

- (void)enrollTotpApp:(nonnull AuthPigeonFirebaseApp *)app
          assertionId:(nonnull NSString *)assertionId
          displayName:(nullable NSString *)displayName
           completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRMultiFactor *multiFactor = [self getAppMultiFactorFromPigeon:app];

  FIRMultiFactorAssertion *assertion = _multiFactorAssertionMap[assertionId];

  [multiFactor enrollWithAssertion:assertion
                       displayName:displayName
                        completion:^(NSError *_Nullable error) {
                          if (error == nil) {
                            completion(nil);
                          } else {
                            completion([FlutterError errorWithCode:@"enroll-failed"
                                                           message:error.localizedDescription
                                                           details:nil]);
                          }
                        }];
}

- (void)resolveSignInResolverId:(nonnull NSString *)resolverId
                      assertion:(nullable PigeonPhoneMultiFactorAssertion *)assertion
                totpAssertionId:(nullable NSString *)totpAssertionId
                     completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                  FlutterError *_Nullable))completion {
  FIRMultiFactorResolver *resolver = _multiFactorResolverMap[resolverId];

  FIRMultiFactorAssertion *multiFactorAssertion;

  if (assertion != nil) {
#if TARGET_OS_IPHONE
    FIRPhoneAuthCredential *credential =
        [[FIRPhoneAuthProvider provider] credentialWithVerificationID:[assertion verificationId]
                                                     verificationCode:[assertion verificationCode]];
    multiFactorAssertion = [FIRPhoneMultiFactorGenerator assertionWithCredential:credential];
#endif
  } else if (totpAssertionId != nil) {
    multiFactorAssertion = _multiFactorAssertionMap[totpAssertionId];
  } else {
    completion(nil,
               [FlutterError errorWithCode:@"resolve-signin-failed"
                                   message:@"Neither assertion nor totpAssertionId were provided"
                                   details:nil]);
    return;
  }

  [resolver
      resolveSignInWithAssertion:multiFactorAssertion
                      completion:^(FIRAuthDataResult *_Nullable authResult,
                                   NSError *_Nullable error) {
                        if (error == nil) {
                          completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                                       authorizationCode:nil],
                                     nil);
                        } else {
                          completion(nil, [FlutterError errorWithCode:@"resolve-signin-failed"
                                                              message:error.localizedDescription
                                                              details:nil]);
                        }
                      }];
}

- (void)generateSecretSessionId:(nonnull NSString *)sessionId
                     completion:(nonnull void (^)(PigeonTotpSecret *_Nullable,
                                                  FlutterError *_Nullable))completion {
  FIRMultiFactorSession *multiFactorSession = _multiFactorSessionMap[sessionId];

  [FIRTOTPMultiFactorGenerator
      generateSecretWithMultiFactorSession:multiFactorSession
                                completion:^(FIRTOTPSecret *_Nullable secret,
                                             NSError *_Nullable error) {
                                  if (error == nil) {
                                    self->_multiFactorTotpSecretMap[secret.sharedSecretKey] =
                                        secret;
                                    completion([PigeonParser getPigeonTotpSecret:secret], nil);
                                  } else {
                                    completion(
                                        nil, [FlutterError errorWithCode:@"generate-secret-failed"
                                                                 message:error.localizedDescription
                                                                 details:nil]);
                                  }
                                }];
}

- (void)getAssertionForEnrollmentSecretKey:(nonnull NSString *)secretKey
                           oneTimePassword:(nonnull NSString *)oneTimePassword
                                completion:(nonnull void (^)(NSString *_Nullable,
                                                             FlutterError *_Nullable))completion {
  FIRTOTPSecret *totpSecret = _multiFactorTotpSecretMap[secretKey];

  FIRTOTPMultiFactorAssertion *assertion =
      [FIRTOTPMultiFactorGenerator assertionForEnrollmentWithSecret:totpSecret
                                                    oneTimePassword:oneTimePassword];

  NSString *UUID = [[NSUUID UUID] UUIDString];
  self->_multiFactorAssertionMap[UUID] = assertion;
  completion(UUID, nil);
}

- (void)getAssertionForSignInEnrollmentId:(nonnull NSString *)enrollmentId
                          oneTimePassword:(nonnull NSString *)oneTimePassword
                               completion:(nonnull void (^)(NSString *_Nullable,
                                                            FlutterError *_Nullable))completion {
  FIRTOTPMultiFactorAssertion *assertion =
      [FIRTOTPMultiFactorGenerator assertionForSignInWithEnrollmentID:enrollmentId
                                                      oneTimePassword:oneTimePassword];
  NSString *UUID = [[NSUUID UUID] UUIDString];
  self->_multiFactorAssertionMap[UUID] = assertion;
  completion(UUID, nil);
}

- (void)generateQrCodeUrlSecretKey:(nonnull NSString *)secretKey
                       accountName:(nullable NSString *)accountName
                            issuer:(nullable NSString *)issuer
                        completion:(nonnull void (^)(NSString *_Nullable,
                                                     FlutterError *_Nullable))completion {
  FIRTOTPSecret *totpSecret = _multiFactorTotpSecretMap[secretKey];
  completion([totpSecret generateQRCodeURLWithAccountName:accountName issuer:issuer], nil);
}

- (void)openInOtpAppSecretKey:(nonnull NSString *)secretKey
                    qrCodeUrl:(nonnull NSString *)qrCodeUrl
                   completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRTOTPSecret *totpSecret = _multiFactorTotpSecretMap[secretKey];
  [totpSecret openInOTPAppWithQRCodeURL:qrCodeUrl];
  completion(nil);
}

- (void)applyActionCodeApp:(nonnull AuthPigeonFirebaseApp *)app
                      code:(nonnull NSString *)code
                completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth applyActionCode:code
             completion:^(NSError *_Nullable error) {
               if (error != nil) {
                 completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
               } else {
                 completion(nil);
               }
             }];
}

- (void)revokeTokenWithAuthorizationCodeApp:(nonnull AuthPigeonFirebaseApp *)app
                          authorizationCode:(nonnull NSString *)authorizationCode
                                 completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth revokeTokenWithAuthorizationCode:authorizationCode
                              completion:^(NSError *_Nullable error) {
                                if (error != nil) {
                                  completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
                                } else {
                                  completion(nil);
                                }
                              }];
}

- (void)checkActionCodeApp:(nonnull AuthPigeonFirebaseApp *)app
                      code:(nonnull NSString *)code
                completion:(nonnull void (^)(PigeonActionCodeInfo *_Nullable,
                                             FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth checkActionCode:code
             completion:^(FIRActionCodeInfo *_Nullable info, NSError *_Nullable error) {
               if (error != nil) {
                 completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
               } else {
                 completion([self parseActionCode:info], nil);
               }
             }];
}

- (PigeonActionCodeInfo *_Nullable)parseActionCode:(nonnull FIRActionCodeInfo *)info {
  PigeonActionCodeInfoData *data = [PigeonActionCodeInfoData makeWithEmail:info.email
                                                             previousEmail:info.previousEmail];

  ActionCodeInfoOperation operation;

  if (info.operation == FIRActionCodeOperationPasswordReset) {
    operation = ActionCodeInfoOperationPasswordReset;
  } else if (info.operation == FIRActionCodeOperationVerifyEmail) {
    operation = ActionCodeInfoOperationVerifyEmail;
  } else if (info.operation == FIRActionCodeOperationRecoverEmail) {
    operation = ActionCodeInfoOperationRecoverEmail;
  } else if (info.operation == FIRActionCodeOperationEmailLink) {
    operation = ActionCodeInfoOperationEmailSignIn;
  } else if (info.operation == FIRActionCodeOperationVerifyAndChangeEmail) {
    operation = ActionCodeInfoOperationVerifyAndChangeEmail;
  } else if (info.operation == FIRActionCodeOperationRevertSecondFactorAddition) {
    operation = ActionCodeInfoOperationRevertSecondFactorAddition;
  } else {
    operation = ActionCodeInfoOperationUnknown;
  }

  return [PigeonActionCodeInfo makeWithOperation:operation data:data];
}

- (void)confirmPasswordResetApp:(nonnull AuthPigeonFirebaseApp *)app
                           code:(nonnull NSString *)code
                    newPassword:(nonnull NSString *)newPassword
                     completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth confirmPasswordResetWithCode:code
                         newPassword:newPassword
                          completion:^(NSError *_Nullable error) {
                            if (error != nil) {
                              completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
                            } else {
                              completion(nil);
                            }
                          }];
}

- (void)createUserWithEmailAndPasswordApp:(nonnull AuthPigeonFirebaseApp *)app
                                    email:(nonnull NSString *)email
                                 password:(nonnull NSString *)password
                               completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                            FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth createUserWithEmail:email
                   password:password
                 completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
                   if (error != nil) {
                     completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                   } else {
                     completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                                  authorizationCode:nil],
                                nil);
                   }
                 }];
}

- (void)fetchSignInMethodsForEmailApp:(nonnull AuthPigeonFirebaseApp *)app
                                email:(nonnull NSString *)email
                           completion:(nonnull void (^)(NSArray<NSString *> *_Nullable,
                                                        FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth fetchSignInMethodsForEmail:email
                        completion:^(NSArray<NSString *> *_Nullable providers,
                                     NSError *_Nullable error) {
                          if (error != nil) {
                            completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                          } else {
                            if (providers == nil) {
                              completion(@[], nil);
                            } else {
                              completion(providers, nil);
                            }
                          }
                        }];
}

- (void)registerAuthStateListenerApp:(nonnull AuthPigeonFirebaseApp *)app
                          completion:(nonnull void (^)(NSString *_Nullable,
                                                       FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  NSString *name =
      [NSString stringWithFormat:@"%@/auth-state/%@", kFLTFirebaseAuthChannelName, auth.app.name];
  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  FLTAuthStateChannelStreamHandler *handler =
      [[FLTAuthStateChannelStreamHandler alloc] initWithAuth:auth];
  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];

  completion(name, nil);
}

- (void)registerIdTokenListenerApp:(nonnull AuthPigeonFirebaseApp *)app
                        completion:(nonnull void (^)(NSString *_Nullable,
                                                     FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  NSString *name =
      [NSString stringWithFormat:@"%@/id-token/%@", kFLTFirebaseAuthChannelName, auth.app.name];

  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  FLTIdTokenChannelStreamHandler *handler =
      [[FLTIdTokenChannelStreamHandler alloc] initWithAuth:auth];
  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];

  completion(name, nil);
}

- (void)sendPasswordResetEmailApp:(nonnull AuthPigeonFirebaseApp *)app
                            email:(nonnull NSString *)email
               actionCodeSettings:(nullable PigeonActionCodeSettings *)actionCodeSettings
                       completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  if (actionCodeSettings != nil) {
    FIRActionCodeSettings *settings = [PigeonParser parseActionCodeSettings:actionCodeSettings];
    [auth sendPasswordResetWithEmail:email
                  actionCodeSettings:settings
                          completion:^(NSError *_Nullable error) {
                            if (error != nil) {
                              completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
                            } else {
                              completion(nil);
                            }
                          }];
  } else {
    [auth sendPasswordResetWithEmail:email
                          completion:^(NSError *_Nullable error) {
                            if (error != nil) {
                              completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
                            } else {
                              completion(nil);
                            }
                          }];
  }
}

- (void)sendSignInLinkToEmailApp:(nonnull AuthPigeonFirebaseApp *)app
                           email:(nonnull NSString *)email
              actionCodeSettings:(nonnull PigeonActionCodeSettings *)actionCodeSettings
                      completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth sendSignInLinkToEmail:email
           actionCodeSettings:[PigeonParser parseActionCodeSettings:actionCodeSettings]
                   completion:^(NSError *_Nullable error) {
                     if (error != nil) {
                       if (error.code == FIRAuthErrorCodeInternalError) {
                         [self
                             handleInternalError:^(PigeonUserCredential *_Nullable creds,
                                                   FlutterError *_Nullable internalError) {
                               completion(internalError);
                             }
                                       withError:error];
                       } else {
                         completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
                       }
                     } else {
                       completion(nil);
                     }
                   }];
}

- (void)setLanguageCodeApp:(nonnull AuthPigeonFirebaseApp *)app
              languageCode:(nullable NSString *)languageCode
                completion:
                    (nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  if (languageCode != nil && ![languageCode isEqual:[NSNull null]]) {
    auth.languageCode = languageCode;
  } else {
    [auth useAppLanguage];
  }

  completion(auth.languageCode, nil);
}

- (void)setSettingsApp:(nonnull AuthPigeonFirebaseApp *)app
              settings:(nonnull PigeonFirebaseAuthSettings *)settings
            completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  if (settings.userAccessGroup != nil) {
    BOOL useUserAccessGroupSuccessful;
    NSError *useUserAccessGroupErrorPtr;
    useUserAccessGroupSuccessful = [auth useUserAccessGroup:settings.userAccessGroup
                                                      error:&useUserAccessGroupErrorPtr];
    if (!useUserAccessGroupSuccessful) {
      completion([FLTFirebaseAuthPlugin convertToFlutterError:useUserAccessGroupErrorPtr]);
      return;
    }
  }

#if TARGET_OS_IPHONE
  if (settings.appVerificationDisabledForTesting) {
    auth.settings.appVerificationDisabledForTesting = settings.appVerificationDisabledForTesting;
  }
#else
  NSLog(@"FIRAuthSettings.appVerificationDisabledForTesting is not supported "
        @"on MacOS.");
#endif

  completion(nil);
}

- (void)signInAnonymouslyApp:(nonnull AuthPigeonFirebaseApp *)app
                  completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                               FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult *authResult, NSError *error) {
    if (error != nil) {
      completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
    } else {
      completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                   authorizationCode:nil],
                 nil);
    }
  }];
}

- (void)signInWithCredentialApp:(nonnull AuthPigeonFirebaseApp *)app
                          input:(nonnull NSDictionary<NSString *, id> *)input
                     completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                  FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [self
      getFIRAuthCredentialFromArguments:input
                                    app:app
                             completion:^(FIRAuthCredential *credential, NSError *error) {
                               if (credential == nil) {
                                 completion(nil,
                                            [FlutterError errorWithCode:kErrCodeInvalidCredential
                                                                message:kErrMsgInvalidCredential
                                                                details:nil]);
                                 return;
                               }

                               if (error) {
                                 completion(nil,
                                            [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                               }

                               [auth
                                   signInWithCredential:credential
                                             completion:^(FIRAuthDataResult *authResult,
                                                          NSError *error) {
                                               if (error != nil) {
                                                 NSDictionary *userInfo = [error userInfo];
                                                 NSError *underlyingError =
                                                     [userInfo objectForKey:NSUnderlyingErrorKey];

                                                 NSDictionary *firebaseDictionary =
                                                     underlyingError
                                                         .userInfo[@"FIRAuthErrorUserInfoDeserializ"
                                                                   @"edResponseKey"];

                                                 if (firebaseDictionary != nil &&
                                                     firebaseDictionary[@"message"] != nil) {
                                                   // error from firebase-ios-sdk is buried in
                                                   // underlying error.
                                                   if ([firebaseDictionary[@"code"]
                                                           isKindOfClass:[NSNumber class]]) {
                                                     [self handleInternalError:completion
                                                                     withError:error];
                                                   } else {
                                                     completion(nil,
                                                                [FlutterError
                                                                    errorWithCode:firebaseDictionary
                                                                                      [@"code"]
                                                                          message:firebaseDictionary
                                                                                      [@"message"]
                                                                          details:nil]);
                                                   }
                                                 } else {
                                                   if (error.code ==
                                                       FIRAuthErrorCodeSecondFactorRequired) {
                                                     [self handleMultiFactorError:app
                                                                       completion:completion
                                                                        withError:error];
                                                   } else if (error.code ==
                                                              FIRAuthErrorCodeInternalError) {
                                                     [self handleInternalError:completion
                                                                     withError:error];
                                                   } else {
                                                     completion(nil,
                                                                [FLTFirebaseAuthPlugin
                                                                    convertToFlutterError:error]);
                                                   }
                                                 }
                                               } else {
                                                 completion(
                                                     [PigeonParser
                                                         getPigeonUserCredentialFromAuthResult:
                                                             authResult
                                                                             authorizationCode:nil],
                                                     nil);
                                               }
                                             }];
                             }];
}

- (void)signInWithCustomTokenApp:(nonnull AuthPigeonFirebaseApp *)app
                           token:(nonnull NSString *)token
                      completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                   FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  [auth signInWithCustomToken:token
                   completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
                     if (error != nil) {
                       if (error.code == FIRAuthErrorCodeSecondFactorRequired) {
                         [self handleMultiFactorError:app completion:completion withError:error];
                       } else if (error.code == FIRAuthErrorCodeInternalError) {
                         [self handleInternalError:completion withError:error];
                       } else {
                         completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                       }
                     } else {
                       completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                                    authorizationCode:nil],
                                  nil);
                     }
                   }];
}

- (void)signInWithEmailAndPasswordApp:(nonnull AuthPigeonFirebaseApp *)app
                                email:(nonnull NSString *)email
                             password:(nonnull NSString *)password
                           completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                        FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth signInWithEmail:email
               password:password
             completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
               if (error != nil) {
                 if (error.code == FIRAuthErrorCodeSecondFactorRequired) {
                   [self handleMultiFactorError:app completion:completion withError:error];
                 } else if (error.code == FIRAuthErrorCodeInternalError) {
                   [self handleInternalError:completion withError:error];
                 } else {
                   completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                 }
               } else {
                 completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                              authorizationCode:nil],
                            nil);
               }
             }];
}

- (void)signInWithEmailLinkApp:(nonnull AuthPigeonFirebaseApp *)app
                         email:(nonnull NSString *)email
                     emailLink:(nonnull NSString *)emailLink
                    completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                 FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth signInWithEmail:email
                   link:emailLink
             completion:^(FIRAuthDataResult *_Nullable authResult, NSError *_Nullable error) {
               if (error != nil) {
                 if (error.code == FIRAuthErrorCodeSecondFactorRequired) {
                   [self handleMultiFactorError:app completion:completion withError:error];
                 } else if (error.code == FIRAuthErrorCodeInternalError) {
                   [self handleInternalError:completion withError:error];
                 } else {
                   completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                 }
               } else {
                 completion([PigeonParser getPigeonUserCredentialFromAuthResult:authResult
                                                              authorizationCode:nil],
                            nil);
               }
             }];
}

- (void)signInWithProviderApp:(nonnull AuthPigeonFirebaseApp *)app
               signInProvider:(nonnull PigeonSignInProvider *)signInProvider
                   completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  if ([signInProvider.providerId isEqualToString:kSignInMethodGameCenter]) {
    completion(
        nil,
        [FlutterError
            errorWithCode:@"sign-in-failure"
                  message:
                      @"Game Center sign-in requires signing in with 'signInWithCredential()' API."
                  details:@{}]);
    return;
  }

  if ([signInProvider.providerId isEqualToString:kSignInMethodApple]) {
    self.signInWithAppleAuth = auth;
    launchAppleSignInRequest(self, app, signInProvider, completion);
    return;
  }
#if TARGET_OS_OSX
  NSLog(@"signInWithProvider is not supported on the "
        @"MacOS platform.");
  completion(nil, nil);
#else
  self.authProvider = [FIROAuthProvider providerWithProviderID:signInProvider.providerId auth:auth];
  NSArray *scopes = signInProvider.scopes;
  if (scopes != nil) {
    [self.authProvider setScopes:scopes];
  }
  NSDictionary *customParameters = signInProvider.customParameters;
  if (customParameters != nil) {
    [self.authProvider setCustomParameters:customParameters];
  }

  [self.authProvider
      getCredentialWithUIDelegate:nil
                       completion:^(FIRAuthCredential *_Nullable credential,
                                    NSError *_Nullable error) {
                         handleAppleAuthResult(self, app, auth, credential, error, completion);
                       }];
#endif
}

- (void)signOutApp:(nonnull AuthPigeonFirebaseApp *)app
        completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  if (auth.currentUser == nil) {
    completion(nil);
    return;
  }

  NSError *signOutErrorPtr;
  BOOL signOutSuccessful = [auth signOut:&signOutErrorPtr];

  if (!signOutSuccessful) {
    completion([FLTFirebaseAuthPlugin convertToFlutterError:signOutErrorPtr]);
  } else {
    completion(nil);
  }
}

- (void)useEmulatorApp:(nonnull AuthPigeonFirebaseApp *)app
                  host:(nonnull NSString *)host
                  port:(long)port
            completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth useEmulatorWithHost:host port:port];
  completion(nil);
}

- (void)verifyPasswordResetCodeApp:(nonnull AuthPigeonFirebaseApp *)app
                              code:(nonnull NSString *)code
                        completion:(nonnull void (^)(NSString *_Nullable,
                                                     FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  [auth verifyPasswordResetCode:code
                     completion:^(NSString *_Nullable email, NSError *_Nullable error) {
                       if (error != nil) {
                         completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                       } else {
                         completion(email, nil);
                       }
                     }];
}

- (void)verifyPhoneNumberApp:(nonnull AuthPigeonFirebaseApp *)app
                     request:(nonnull PigeonVerifyPhoneNumberRequest *)request
                  completion:
                      (nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
#if TARGET_OS_OSX
  NSLog(@"The Firebase Phone Authentication provider is not supported on the "
        @"MacOS platform.");
  completion(nil, nil);
#else
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];

  NSString *name = [NSString
      stringWithFormat:@"%@/phone/%@", kFLTFirebaseAuthChannelName, [NSUUID UUID].UUIDString];
  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  NSString *multiFactorSessionId = request.multiFactorSessionId;
  FIRMultiFactorSession *multiFactorSession = nil;

  if (multiFactorSessionId != nil) {
    multiFactorSession = _multiFactorSessionMap[multiFactorSessionId];
  }

  NSString *multiFactorInfoId = request.multiFactorInfoId;

  FIRPhoneMultiFactorInfo *multiFactorInfo = nil;
  if (multiFactorInfoId != nil) {
    for (NSString *resolverId in _multiFactorResolverMap) {
      for (FIRMultiFactorInfo *info in _multiFactorResolverMap[resolverId].hints) {
        if ([info.UID isEqualToString:multiFactorInfoId] &&
            [info class] == [FIRPhoneMultiFactorInfo class]) {
          multiFactorInfo = (FIRPhoneMultiFactorInfo *)info;
          break;
        }
      }
    }
  }

#if TARGET_OS_OSX
  FLTPhoneNumberVerificationStreamHandler *handler =
      [[FLTPhoneNumberVerificationStreamHandler alloc] initWithAuth:auth];
#else
  FLTPhoneNumberVerificationStreamHandler *handler =
      [[FLTPhoneNumberVerificationStreamHandler alloc] initWithAuth:auth
                                                            request:request
                                                            session:multiFactorSession
                                                         factorInfo:multiFactorInfo];
#endif

  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];

  completion(name, nil);
#endif
}

- (void)deleteApp:(nonnull AuthPigeonFirebaseApp *)app
       completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion([FlutterError errorWithCode:kErrCodeNoCurrentUser
                                   message:kErrMsgNoCurrentUser
                                   details:nil]);
    return;
  }

  [currentUser deleteWithCompletion:^(NSError *_Nullable error) {
    if (error != nil) {
      completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
}

- (void)getIdTokenApp:(nonnull AuthPigeonFirebaseApp *)app
         forceRefresh:(BOOL)forceRefresh
           completion:(nonnull void (^)(PigeonIdTokenResult *_Nullable,
                                        FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [currentUser
      getIDTokenResultForcingRefresh:forceRefresh
                          completion:^(FIRAuthTokenResult *tokenResult, NSError *error) {
                            if (error != nil) {
                              completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                              return;
                            }

                            completion([PigeonParser parseIdTokenResult:tokenResult], nil);
                          }];
}

- (void)linkWithCredentialApp:(nonnull AuthPigeonFirebaseApp *)app
                        input:(nonnull NSDictionary<NSString *, id> *)input
                   completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [self
      getFIRAuthCredentialFromArguments:input
                                    app:app
                             completion:^(FIRAuthCredential *credential, NSError *error) {
                               if (credential == nil) {
                                 completion(nil,
                                            [FlutterError errorWithCode:kErrCodeInvalidCredential
                                                                message:kErrMsgInvalidCredential
                                                                details:nil]);
                                 return;
                               }

                               if (error) {
                                 completion(nil,
                                            [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                               }

                               [currentUser
                                   linkWithCredential:credential
                                           completion:^(FIRAuthDataResult *authResult,
                                                        NSError *error) {
                                             if (error != nil) {
                                               if (error.code ==
                                                   FIRAuthErrorCodeSecondFactorRequired) {
                                                 [self handleMultiFactorError:app
                                                                   completion:completion
                                                                    withError:error];
                                               } else {
                                                 completion(nil, [FLTFirebaseAuthPlugin
                                                                     convertToFlutterError:error]);
                                               }
                                             } else {
                                               completion(
                                                   [PigeonParser
                                                       getPigeonUserCredentialFromAuthResult:
                                                           authResult
                                                                           authorizationCode:nil],
                                                   nil);
                                             }
                                           }];
                             }];
}

- (void)linkWithProviderApp:(nonnull AuthPigeonFirebaseApp *)app
             signInProvider:(nonnull PigeonSignInProvider *)signInProvider
                 completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                              FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if ([signInProvider.providerId isEqualToString:kSignInMethodGameCenter]) {
    completion(
        nil,
        [FlutterError
            errorWithCode:@"provider-link-failure"
                  message:@"Game Center provider requires linking with 'linkWithCredential()' API."
                  details:@{}]);
    return;
  }

  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  if ([signInProvider.providerId isEqualToString:kSignInMethodApple]) {
    self.linkWithAppleUser = currentUser;
    launchAppleSignInRequest(self, app, signInProvider, completion);
    return;
  }
#if TARGET_OS_OSX
  NSLog(@"linkWithProvider is not supported on the "
        @"MacOS platform.");
  completion(nil, nil);
#else
  self.authProvider = [FIROAuthProvider providerWithProviderID:signInProvider.providerId];
  NSArray *scopes = signInProvider.scopes;
  if (scopes != nil) {
    [self.authProvider setScopes:scopes];
  }
  NSDictionary *customParameters = signInProvider.customParameters;
  if (customParameters != nil) {
    [self.authProvider setCustomParameters:customParameters];
  }

  [currentUser
      linkWithProvider:self.authProvider
            UIDelegate:nil
            completion:^(FIRAuthDataResult *authResult, NSError *error) {
              handleAppleAuthResult(self, app, auth, authResult.credential, error, completion);
            }];
#endif
}

- (void)reauthenticateWithCredentialApp:(nonnull AuthPigeonFirebaseApp *)app
                                  input:(nonnull NSDictionary<NSString *, id> *)input
                             completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                          FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [self
      getFIRAuthCredentialFromArguments:input
                                    app:app
                             completion:^(FIRAuthCredential *credential, NSError *error) {
                               if (credential == nil) {
                                 completion(nil,
                                            [FlutterError errorWithCode:kErrCodeInvalidCredential
                                                                message:kErrMsgInvalidCredential
                                                                details:nil]);
                                 return;
                               }

                               if (error) {
                                 completion(nil,
                                            [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                               }

                               [currentUser
                                   reauthenticateWithCredential:credential
                                                     completion:^(FIRAuthDataResult *authResult,
                                                                  NSError *error) {
                                                       if (error != nil) {
                                                         if (error.code ==
                                                             FIRAuthErrorCodeSecondFactorRequired) {
                                                           [self handleMultiFactorError:app
                                                                             completion:completion
                                                                              withError:error];
                                                         } else {
                                                           completion(
                                                               nil,
                                                               [FLTFirebaseAuthPlugin
                                                                   convertToFlutterError:error]);
                                                         }
                                                       } else {
                                                         completion(
                                                             [PigeonParser
                                                                 getPigeonUserCredentialFromAuthResult:
                                                                     authResult
                                                                                     authorizationCode:
                                                                                         nil],
                                                             nil);
                                                       }
                                                     }];
                             }];
}

- (void)reauthenticateWithProviderApp:(nonnull AuthPigeonFirebaseApp *)app
                       signInProvider:(nonnull PigeonSignInProvider *)signInProvider
                           completion:(nonnull void (^)(PigeonUserCredential *_Nullable,
                                                        FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  if ([signInProvider.providerId isEqualToString:kSignInMethodApple]) {
    self.isReauthenticatingWithApple = YES;
    launchAppleSignInRequest(self, app, signInProvider, completion);
    return;
  }
#if TARGET_OS_OSX
  NSLog(@"reauthenticateWithProvider is not supported on the "
        @"MacOS platform.");
  completion(nil, nil);
#else
  self.authProvider = [FIROAuthProvider providerWithProviderID:signInProvider.providerId];
  NSArray *scopes = signInProvider.scopes;
  if (scopes != nil) {
    [self.authProvider setScopes:scopes];
  }
  NSDictionary *customParameters = signInProvider.customParameters;
  if (customParameters != nil) {
    [self.authProvider setCustomParameters:customParameters];
  }

  [currentUser reauthenticateWithProvider:self.authProvider
                               UIDelegate:nil
                               completion:^(FIRAuthDataResult *authResult, NSError *error) {
                                 handleAppleAuthResult(self, app, auth, authResult.credential,
                                                       error, completion);
                               }];
#endif
}

- (void)reloadApp:(nonnull AuthPigeonFirebaseApp *)app
       completion:
           (nonnull void (^)(PigeonUserDetails *_Nullable, FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [currentUser reloadWithCompletion:^(NSError *_Nullable error) {
    if (error != nil) {
      completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
    } else {
      completion([PigeonParser getPigeonDetails:auth.currentUser], nil);
    }
  }];
}

- (void)sendEmailVerificationApp:(nonnull AuthPigeonFirebaseApp *)app
              actionCodeSettings:(nullable PigeonActionCodeSettings *)actionCodeSettings
                      completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion([FlutterError errorWithCode:kErrCodeNoCurrentUser
                                   message:kErrMsgNoCurrentUser
                                   details:nil]);
    return;
  }

  [currentUser
      sendEmailVerificationWithActionCodeSettings:[PigeonParser
                                                      parseActionCodeSettings:actionCodeSettings]

                                       completion:^(NSError *_Nullable error) {
                                         if (error != nil) {
                                           completion(
                                               [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                                         } else {
                                           completion(nil);
                                         }
                                       }];
}

- (void)unlinkApp:(nonnull AuthPigeonFirebaseApp *)app
       providerId:(nonnull NSString *)providerId
       completion:
           (nonnull void (^)(PigeonUserCredential *_Nullable, FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [currentUser unlinkFromProvider:providerId
                       completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                         if (error != nil) {
                           completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                         } else {
                           completion([PigeonParser getPigeonUserCredentialFromFIRUser:user], nil);
                         }
                       }];
}

- (void)updateEmailApp:(nonnull AuthPigeonFirebaseApp *)app
              newEmail:(nonnull NSString *)newEmail
            completion:(nonnull void (^)(PigeonUserDetails *_Nullable,
                                         FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [currentUser updateEmail:newEmail
                completion:^(NSError *_Nullable error) {
                  if (error != nil) {
                    completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                  } else {
                    [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
                      if (reloadError != nil) {
                        completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:reloadError]);
                      } else {
                        completion([PigeonParser getPigeonDetails:auth.currentUser], nil);
                      }
                    }];
                  }
                }];
}

- (void)updatePasswordApp:(nonnull AuthPigeonFirebaseApp *)app
              newPassword:(nonnull NSString *)newPassword
               completion:(nonnull void (^)(PigeonUserDetails *_Nullable,
                                            FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [currentUser
      updatePassword:newPassword
          completion:^(NSError *_Nullable error) {
            if (error != nil) {
              completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
            } else {
              [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
                if (reloadError != nil) {
                  completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:reloadError]);
                } else {
                  completion([PigeonParser getPigeonDetails:auth.currentUser], nil);
                }
              }];
            }
          }];
}

- (void)updatePhoneNumberApp:(nonnull AuthPigeonFirebaseApp *)app
                       input:(nonnull NSDictionary<NSString *, id> *)input
                  completion:(nonnull void (^)(PigeonUserDetails *_Nullable,
                                               FlutterError *_Nullable))completion {
#if TARGET_OS_IPHONE
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  [self
      getFIRAuthCredentialFromArguments:input
                                    app:app
                             completion:^(FIRAuthCredential *credential, NSError *error) {
                               if (credential == nil) {
                                 completion(nil,
                                            [FlutterError errorWithCode:kErrCodeInvalidCredential
                                                                message:kErrMsgInvalidCredential
                                                                details:nil]);
                                 return;
                               }

                               if (error) {
                                 completion(nil,
                                            [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                               }

                               [currentUser
                                   updatePhoneNumberCredential:(FIRPhoneAuthCredential *)credential
                                                    completion:^(NSError *_Nullable error) {
                                                      if (error != nil) {
                                                        completion(
                                                            nil, [FLTFirebaseAuthPlugin
                                                                     convertToFlutterError:error]);
                                                      } else {
                                                        [currentUser
                                                            reloadWithCompletion:^(
                                                                NSError *_Nullable reloadError) {
                                                              if (reloadError != nil) {
                                                                completion(
                                                                    nil, [FLTFirebaseAuthPlugin
                                                                             convertToFlutterError:
                                                                                 reloadError]);
                                                              } else {
                                                                completion(
                                                                    [PigeonParser
                                                                        getPigeonDetails:
                                                                            auth.currentUser],
                                                                    nil);
                                                              }
                                                            }];
                                                      }
                                                    }];
                             }];
#else
  NSLog(@"Updating a users phone number via Firebase Authentication is only "
        @"supported on the iOS "
        @"platform.");
  completion(nil, nil);
#endif
}

- (void)updateProfileApp:(nonnull AuthPigeonFirebaseApp *)app
                 profile:(nonnull PigeonUserProfile *)profile
              completion:(nonnull void (^)(PigeonUserDetails *_Nullable,
                                           FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion(nil, [FlutterError errorWithCode:kErrCodeNoCurrentUser
                                        message:kErrMsgNoCurrentUser
                                        details:nil]);
    return;
  }

  FIRUserProfileChangeRequest *changeRequest = [currentUser profileChangeRequest];

  if (profile.displayNameChanged) {
    changeRequest.displayName = profile.displayName;
  }

  if (profile.photoUrlChanged) {
    if (profile.photoUrl == nil) {
      // We apparently cannot set photoURL to nil/NULL to remove it.
      // Instead, setting it to empty string appears to work.
      // When doing so, Dart will properly receive `null` anyway.
      changeRequest.photoURL = [NSURL URLWithString:@""];
    } else {
      changeRequest.photoURL = [NSURL URLWithString:profile.photoUrl];
    }
  }

  [changeRequest commitChangesWithCompletion:^(NSError *error) {
    if (error != nil) {
      completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:error]);
    } else {
      [currentUser reloadWithCompletion:^(NSError *_Nullable reloadError) {
        if (reloadError != nil) {
          completion(nil, [FLTFirebaseAuthPlugin convertToFlutterError:reloadError]);
        } else {
          completion([PigeonParser getPigeonDetails:auth.currentUser], nil);
        }
      }];
    }
  }];
}

- (void)verifyBeforeUpdateEmailApp:(nonnull AuthPigeonFirebaseApp *)app
                          newEmail:(nonnull NSString *)newEmail
                actionCodeSettings:(nullable PigeonActionCodeSettings *)actionCodeSettings
                        completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  FIRUser *currentUser = auth.currentUser;
  if (currentUser == nil) {
    completion([FlutterError errorWithCode:kErrCodeNoCurrentUser
                                   message:kErrMsgNoCurrentUser
                                   details:nil]);
    return;
  }

  [currentUser
      sendEmailVerificationBeforeUpdatingEmail:newEmail
                            actionCodeSettings:[PigeonParser
                                                   parseActionCodeSettings:actionCodeSettings]
                                    completion:^(NSError *error) {
                                      if (error != nil) {
                                        completion(
                                            [FLTFirebaseAuthPlugin convertToFlutterError:error]);
                                      } else {
                                        completion(nil);
                                      }
                                    }];
}

- (void)initializeRecaptchaConfigApp:(AuthPigeonFirebaseApp *)app
                          completion:(void (^)(FlutterError *_Nullable))completion {
#if TARGET_OS_OSX
  NSLog(@"initializeRecaptchaConfigWithCompletion is not supported on the "
        @"MacOS platform.");
  completion(nil);
#else
  FIRAuth *auth = [self getFIRAuthFromAppNameFromPigeon:app];
  [auth initializeRecaptchaConfigWithCompletion:^(NSError *_Nullable error) {
    if (error != nil) {
      completion([FLTFirebaseAuthPlugin convertToFlutterError:error]);
    } else {
      completion(nil);
    }
  }];
#endif
}

@end
