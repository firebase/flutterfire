// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseFunctionsPlugin.h"

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

NSString *const kFLTFirebaseFunctionsChannelName = @"plugins.flutter.io/firebase_functions";

@interface FLTFirebaseFunctionsPlugin ()
@end

@implementation FLTFirebaseFunctionsPlugin

#pragma mark - FlutterPlugin

// Returns a singleton instance of the Firebase Functions plugin.
+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseFunctionsPlugin *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseFunctionsPlugin alloc] init];
    // Register with the Flutter Firebase plugin registry.
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  });

  return instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseFunctionsChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseFunctionsPlugin *instance = [FLTFirebaseFunctionsPlugin sharedInstance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  if (![@"FirebaseFunctions#call" isEqualToString:call.method]) {
    flutterResult(FlutterMethodNotImplemented);
    return;
  }

  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        NSMutableDictionary *httpsErrorDetails = [NSMutableDictionary dictionary];
        NSString *httpsErrorCode = [NSString stringWithFormat:@"%ld", error.code];
        NSString *httpsErrorMessage = error.localizedDescription;
        // FIRFunctionsErrorDomain has been removed and replaced with Swift implementation
        // https://github.com/firebase/firebase-ios-sdk/blob/master/FirebaseFunctions/Sources/FunctionsError.swift#L18
        NSString *errorDomain = @"com.firebase.functions";
        // FIRFunctionsErrorDetailsKey has been deprecated and replaced with Swift implementation
        // https://github.com/firebase/firebase-ios-sdk/blob/master/FirebaseFunctions/Sources/FunctionsError.swift#L21
        NSString *detailsKey = @"details";
        // See also https://github.com/firebase/firebase-ios-sdk/pull/9569
        if ([error.domain isEqualToString:errorDomain]) {
          httpsErrorCode = [self mapFunctionsErrorCodes:error.code];
          if (error.userInfo[detailsKey] != nil) {
            httpsErrorDetails[@"additionalData"] = error.userInfo[detailsKey];
          }
        }
        httpsErrorDetails[@"code"] = httpsErrorCode;
        httpsErrorDetails[@"message"] = httpsErrorMessage;
        flutterResult([FlutterError errorWithCode:httpsErrorCode
                                          message:httpsErrorMessage
                                          details:httpsErrorDetails]);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  [self httpsFunctionCall:call.arguments withMethodCallResult:methodCallResult];
}

#pragma mark - Firebase Functions API

- (void)httpsFunctionCall:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *appName = arguments[@"appName"];
  NSString *functionName = arguments[@"functionName"];
  NSString *origin = arguments[@"origin"];
  NSString *region = arguments[@"region"];
  NSNumber *timeout = arguments[@"timeout"];
  NSObject *parameters = arguments[@"parameters"];

  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appName];
  FIRFunctions *functions = [FIRFunctions functionsForApp:app region:region];
  if (origin != nil && origin != (id)[NSNull null]) {
    NSURL *url = [NSURL URLWithString:origin];
    [functions useEmulatorWithHost:[url host] port:[[url port] intValue]];
  }

  FIRHTTPSCallable *function = [functions HTTPSCallableWithName:functionName];
  if (timeout != nil && ![timeout isEqual:[NSNull null]]) {
    function.timeoutInterval = timeout.doubleValue / 1000;
  }

  [function callWithObject:parameters
                completion:^(FIRHTTPSCallableResult *callableResult, NSError *error) {
                  if (error) {
                    result.error(nil, nil, nil, error);
                  } else {
                    result.success(callableResult.data);
                  }
                }];
}

#pragma mark - Utilities

// Map function error code objects to Strings that match error names on Android.
- (NSString *)mapFunctionsErrorCodes:(FIRFunctionsErrorCode)code {
  if (code == FIRFunctionsErrorCodeAborted) {
    return @"aborted";
  } else if (code == FIRFunctionsErrorCodeAlreadyExists) {
    return @"already-exists";
  } else if (code == FIRFunctionsErrorCodeCancelled) {
    return @"cancelled";
  } else if (code == FIRFunctionsErrorCodeDataLoss) {
    return @"data-loss";
  } else if (code == FIRFunctionsErrorCodeDeadlineExceeded) {
    return @"deadline-exceeded";
  } else if (code == FIRFunctionsErrorCodeFailedPrecondition) {
    return @"failed-precondition";
  } else if (code == FIRFunctionsErrorCodeInternal) {
    return @"internal";
  } else if (code == FIRFunctionsErrorCodeInvalidArgument) {
    return @"invalid-argument";
  } else if (code == FIRFunctionsErrorCodeNotFound) {
    return @"not-found";
  } else if (code == FIRFunctionsErrorCodeOK) {
    return @"ok";
  } else if (code == FIRFunctionsErrorCodeOutOfRange) {
    return @"out-of-range";
  } else if (code == FIRFunctionsErrorCodePermissionDenied) {
    return @"permission-denied";
  } else if (code == FIRFunctionsErrorCodeResourceExhausted) {
    return @"resource-exhausted";
  } else if (code == FIRFunctionsErrorCodeUnauthenticated) {
    return @"unauthenticated";
  } else if (code == FIRFunctionsErrorCodeUnavailable) {
    return @"unavailable";
  } else if (code == FIRFunctionsErrorCodeUnimplemented) {
    return @"unimplemented";
  } else {
    return @"unknown";
  }
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  completion();
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{};
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseFunctionsChannelName;
}

@end
