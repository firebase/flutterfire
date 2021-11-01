// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseAnalyticsPlugin.h"

#import <Firebase/Firebase.h>

#import <firebase_core/FLTFirebasePluginRegistry.h>

NSString *const kConsentGranted = @"granted";
NSString *const kConsentDenied = @"denied";
// kName, kEnabled & kValue clashes with FLTFirebaseCorePlugin constants
NSString *const kNameAnalytics = @"name";
NSString *const kValueAnalytics = @"value";
NSString *const kEnabledAnalytics = @"enabled";
NSString *const kEventName = @"eventName";
NSString *const kParameters = @"parameters";
NSString *const kScreenName = @"screenName";
NSString *const kScreenClassOverride = @"screenClassOverride";
NSString *const kAdStorage = @"adStorage";
NSString *const kAnalyticsStorage = @"analyticsStorage";
NSString *const kUserId = @"userId";

NSString *const kFLTFirebaseCrashlyticsChannelName = @"plugins.flutter.io/firebase_analytics";

@implementation FLTFirebaseAnalyticsPlugin {
}

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseAnalyticsPlugin *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseAnalyticsPlugin alloc] init];
    // Register with the Flutter Firebase plugin registry.
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  });

  return instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseCrashlyticsChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAnalyticsPlugin *instance = [FLTFirebaseAnalyticsPlugin sharedInstance];
  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        // `result.error` is not called in this plugin so this block does nothing.
        result(nil);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:result andErrorBlock:errorBlock];

  if ([@"Analytics#logEvent" isEqualToString:call.method]) {
    [self logEvent:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setUserId" isEqualToString:call.method]) {
    [self setUserId:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setCurrentScreen" isEqualToString:call.method]) {
    [self setCurrentScreen:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setUserProperty" isEqualToString:call.method]) {
    [self setUserProperty:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setAnalyticsCollectionEnabled" isEqualToString:call.method]) {
    [self setAnalyticsCollectionEnabled:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#resetAnalyticsData" isEqualToString:call.method]) {
    [self resetAnalyticsData:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setConsent" isEqualToString:call.method]) {
    [self setConsent:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Analytics#setDefaultEventParameters" isEqualToString:call.method]) {
    [self setDefaultEventParameters:call.arguments withMethodCallResult:methodCallResult];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase Analytics API

- (void)logEvent:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *eventName = arguments[kEventName];
  id parameterMap = arguments[kParameters];

  if (parameterMap != [NSNull null]) {
    [FIRAnalytics logEventWithName:eventName parameters:parameterMap];
  } else {
    [FIRAnalytics logEventWithName:eventName parameters:nil];
  }

  result.success(nil);
}

- (void)setUserId:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *userId = arguments[kUserId];
  [FIRAnalytics setUserID:userId];

  result.success(nil);
}

- (void)setCurrentScreen:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *screenName = arguments[kScreenName];
  NSString *screenClassOverride = arguments[kScreenClassOverride];
  [FIRAnalytics logEventWithName:@"screen_view"
                      parameters:@{
                        @"screen_name" : screenName,
                        @"screen_class" : screenClassOverride,
                      }];
  result.success(nil);
}

- (void)setUserProperty:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *name = arguments[kNameAnalytics];
  NSString *value = arguments[kValueAnalytics];
  [FIRAnalytics setUserPropertyString:value forName:name];
  result.success(nil);
}

- (void)setAnalyticsCollectionEnabled:(id)arguments
                 withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSNumber *enabled = arguments[kEnabledAnalytics];
  [FIRAnalytics setAnalyticsCollectionEnabled:[enabled boolValue]];
  result.success(nil);
}

- (void)resetAnalyticsData:(id)arguments
      withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [FIRAnalytics resetAnalyticsData];
  result.success(nil);
}

- (void)setConsent:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *adStorage = arguments[kAdStorage];
  NSString *analyticsStorage = arguments[kAnalyticsStorage];
  NSMutableDictionary<FIRConsentType, FIRConsentStatus> *parameters =
      [[NSMutableDictionary alloc] init];
  ;

  if (adStorage != NULL) {
    FIRConsentStatus adStorageConsent = [adStorage isEqualToString:kConsentDenied]
                                            ? FIRConsentStatusDenied
                                            : FIRConsentStatusGranted;
    [parameters setObject:adStorageConsent forKey:FIRConsentTypeAdStorage];
  }

  if (analyticsStorage != NULL) {
    FIRConsentStatus analyticsStorageConsent = [analyticsStorage isEqualToString:kConsentDenied]
                                                   ? FIRConsentStatusDenied
                                                   : FIRConsentStatusGranted;
    [parameters setObject:analyticsStorageConsent forKey:FIRConsentTypeAnalyticsStorage];
  }

  [FIRAnalytics setConsent:parameters];
  result.success(nil);
}

- (void)setDefaultEventParameters:(id)arguments
             withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  id parameters = arguments[kParameters];
  [FIRAnalytics setDefaultEventParameters:parameters];
  result.success(nil);
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
  return kFLTFirebaseCrashlyticsChannelName;
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *_Nonnull)firebaseApp {
  return @{};
}

@end
