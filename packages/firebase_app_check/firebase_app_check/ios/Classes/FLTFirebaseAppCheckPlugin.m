// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseAppCheckPlugin.h"
#import "FLTTokenRefreshStreamHandler.h"

#import <Firebase/Firebase.h>

#import <firebase_core/FLTFirebasePluginRegistry.h>

NSString *const kFLTFirebaseAppCheckChannelName = @"plugins.flutter.io/firebase_app_check";

@interface FLTFirebaseAppCheckPlugin ()
@end

@implementation FLTFirebaseAppCheckPlugin {
  NSMutableDictionary<NSString *, FlutterEventChannel *> *_eventChannels;
  NSMutableDictionary<NSString *, NSObject<FlutterStreamHandler> *> *_streamHandlers;
  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
}

#pragma mark - FlutterPlugin

- (instancetype)init:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:self];
    _binaryMessenger = messenger;
    _eventChannels = [NSMutableDictionary dictionary];
    _streamHandlers = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseAppCheckChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAppCheckPlugin *instance =
      [[FLTFirebaseAppCheckPlugin alloc] init:registrar.messenger];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
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
  FLTFirebaseMethodCallErrorBlock errorBlock = ^(
      NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
      NSError *_Nullable error) {
    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
    NSString *errorCode;

    switch (error.code) {
      case FIRAppCheckErrorCodeServerUnreachable:
        errorCode = @"server-unreachable";
        break;
      case FIRAppCheckErrorCodeInvalidConfiguration:
        errorCode = @"invalid-configuration";
        break;
      case FIRAppCheckErrorCodeKeychain:
        errorCode = @"code-keychain";
        break;
      case FIRAppCheckErrorCodeUnsupported:
        errorCode = @"code-unsupported";
        break;
      case FIRAppCheckErrorCodeUnknown:
      default:
        errorCode = @"unknown";
    }

    NSString *errorMessage = error.localizedDescription;
    errorDetails[@"code"] = errorCode;
    errorDetails[@"message"] = errorMessage;
    flutterResult([FlutterError errorWithCode:errorCode message:errorMessage details:errorDetails]);
  };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"FirebaseAppCheck#activate" isEqualToString:call.method]) {
    [self activate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseAppCheck#getToken" isEqualToString:call.method]) {
    [self getToken:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseAppCheck#setTokenAutoRefreshEnabled" isEqualToString:call.method]) {
    [self setTokenAutoRefreshEnabled:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseAppCheck#registerTokenListener" isEqualToString:call.method]) {
    [self registerTokenListener:call.arguments withMethodCallResult:methodCallResult];
  } else {
    flutterResult(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase App Check API

- (void)activate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  // TODO the App Check Firebase iOS SDK doesn't allow us to set a provider
  // TODO after Firebase core has been initialized, which means we can't currently
  // TODO support changing providers in FlutterFire. So for now we'll do nothing.

  //  BOOL debug = [arguments[@"debug"] boolValue];
  //  id<FIRAppCheckProviderFactory> provider;
  //  if (debug) {
  //    provider = [FIRAppCheckDebugProviderFactory alloc];
  //  } else {
  //    provider = [FIRDeviceCheckProviderFactory alloc];
  //  }
  //  [FIRAppCheck setAppCheckProviderFactory:provider];
  result.success(nil);
}

- (void)registerTokenListener:(id)arguments
         withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *appName = arguments[@"appName"];
  NSString *name =
      [NSString stringWithFormat:@"%@/token/%@", kFLTFirebaseAppCheckChannelName, appName];

  FlutterEventChannel *channel = [FlutterEventChannel eventChannelWithName:name
                                                           binaryMessenger:_binaryMessenger];

  FLTTokenRefreshStreamHandler *handler = [[FLTTokenRefreshStreamHandler alloc] init];
  [channel setStreamHandler:handler];

  [_eventChannels setObject:channel forKey:name];
  [_streamHandlers setObject:handler forKey:name];
  result.success(name);
}

- (void)getToken:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAppCheck *appCheck = [self getFIRAppCheckFromArguments:arguments];
  bool forceRefresh = arguments[@"forceRefresh"];

  [appCheck tokenForcingRefresh:forceRefresh
                     completion:^(FIRAppCheckToken *_Nullable token, NSError *_Nullable error) {
                       if (error != nil) {
                         result.error(nil, nil, nil, error);
                       }

                       NSMutableDictionary *response = [NSMutableDictionary dictionary];

                       response[@"token"] = token.token;
                       result.success(response);
                     }];
}

- (void)setTokenAutoRefreshEnabled:(id)arguments
              withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRAppCheck *appCheck = [self getFIRAppCheckFromArguments:arguments];
  bool isTokenAutoRefreshEnabled = arguments[@"isTokenAutoRefreshEnabled"];
  appCheck.isTokenAutoRefreshEnabled = isTokenAutoRefreshEnabled;
  result.success(nil);
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  [self cleanupWithCompletion:completion];
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
  return kFLTFirebaseAppCheckChannelName;
}

#pragma mark - Utilities

- (FIRAppCheck *_Nullable)getFIRAppCheckFromArguments:(NSDictionary *)arguments {
  NSString *appNameDart = arguments[@"appName"];
  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appNameDart];
  FIRAppCheck *appCheck = [FIRAppCheck appCheckWithApp:app];

  return appCheck;
}

@end
