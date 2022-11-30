// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseAnalyticsPlugin.h"

#import <Firebase/Firebase.h>

#import <firebase_core/FLTFirebasePluginRegistry.h>

NSString *const kFLTFirebaseAnalyticsName = @"name";
NSString *const kFLTFirebaseAnalyticsValue = @"value";
NSString *const kFLTFirebaseAnalyticsEnabled = @"enabled";
NSString *const kFLTFirebaseAnalyticsEventName = @"eventName";
NSString *const kFLTFirebaseAnalyticsParameters = @"parameters";
NSString *const kFLTFirebaseAnalyticsAdStorageConsentGranted = @"adStorageConsentGranted";
NSString *const kFLTFirebaseAnalyticsStorageConsentGranted = @"analyticsStorageConsentGranted";
NSString *const kFLTFirebaseAnalyticsUserId = @"userId";

NSString *const FLTFirebaseAnalyticsChannelName = @"plugins.flutter.io/firebase_analytics";

@implementation FLTFirebaseAnalyticsPlugin

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseAnalyticsPlugin *instance;
  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseAnalyticsPlugin alloc] init];
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  });
  return instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:FLTFirebaseAnalyticsChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAnalyticsPlugin *instance = [FLTFirebaseAnalyticsPlugin sharedInstance];
  [registrar addMethodCallDelegate:instance channel:channel];
#if !TARGET_OS_OSX
  [registrar publish:instance];
#endif
  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        result(nil);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:result andErrorBlock:errorBlock];

  if ([@"Analytics#logEvent" isEqualToString:call.method]) {
    [self logEvent:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setUserId" isEqualToString:call.method]) {
    [self setUserId:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setUserProperty" isEqualToString:call.method]) {
    [self setUserProperty:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setAnalyticsCollectionEnabled" isEqualToString:call.method]) {
    [self setAnalyticsCollectionEnabled:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#resetAnalyticsData" isEqualToString:call.method]) {
    [self resetAnalyticsDataWithMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setConsent" isEqualToString:call.method]) {
    [self setConsent:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setDefaultEventParameters" isEqualToString:call.method]) {
    [self setDefaultEventParameters:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#getAppInstanceId" isEqualToString:call.method]) {
    [self getAppInstanceIdWithMethodCallResult:methodCallResult];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase Analytics API

- (void)logEvent:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *eventName = arguments[kFLTFirebaseAnalyticsEventName];
  id parameterMap = arguments[kFLTFirebaseAnalyticsParameters];

  if (parameterMap != [NSNull null]) {
    [FIRAnalytics logEventWithName:eventName parameters:parameterMap];
  } else {
    [FIRAnalytics logEventWithName:eventName parameters:nil];
  }

  result.success(nil);
}

- (void)setUserId:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *userId = arguments[kFLTFirebaseAnalyticsUserId];
  [FIRAnalytics setUserID:[userId isKindOfClass:[NSNull class]] ? nil : userId];

  result.success(nil);
}

- (void)setUserProperty:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *name = arguments[kFLTFirebaseAnalyticsName];
  NSString *value = arguments[kFLTFirebaseAnalyticsValue];
  [FIRAnalytics setUserPropertyString:[value isKindOfClass:[NSNull class]] ? nil : value
                              forName:name];
  result.success(nil);
}

- (void)setAnalyticsCollectionEnabled:(id)arguments
                 withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSNumber *enabled = arguments[kFLTFirebaseAnalyticsEnabled];
  [FIRAnalytics setAnalyticsCollectionEnabled:[enabled boolValue]];
  result.success(nil);
}

- (void)resetAnalyticsDataWithMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [FIRAnalytics resetAnalyticsData];
  result.success(nil);
}

- (void)setConsent:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSNumber *adStorageGranted = arguments[kFLTFirebaseAnalyticsAdStorageConsentGranted];
  NSNumber *analyticsStorageGranted = arguments[kFLTFirebaseAnalyticsStorageConsentGranted];
  NSMutableDictionary<FIRConsentType, FIRConsentStatus> *parameters =
      [[NSMutableDictionary alloc] init];

  if (adStorageGranted != nil) {
    parameters[FIRConsentTypeAdStorage] =
        [adStorageGranted boolValue] ? FIRConsentStatusGranted : FIRConsentStatusDenied;
  }
  if (analyticsStorageGranted != nil) {
    parameters[FIRConsentTypeAnalyticsStorage] =
        [analyticsStorageGranted boolValue] ? FIRConsentStatusGranted : FIRConsentStatusDenied;
  }

  [FIRAnalytics setConsent:parameters];
  result.success(nil);
}

- (void)setDefaultEventParameters:(id)arguments
             withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [FIRAnalytics setDefaultEventParameters:arguments];
  result.success(nil);
}

- (void)getAppInstanceIdWithMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *appInstanceID = [FIRAnalytics appInstanceID];
  result.success(appInstanceID);
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^_Nonnull)(void))completion {
  completion();
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return FLTFirebaseAnalyticsChannelName;
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *_Nonnull)firebaseApp {
  return @{};
}

@end
