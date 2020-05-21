// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseCrashlyticsPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseCrashlyticsPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseCrashlyticsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_crashlytics"
                                  binaryMessenger:[registrar messenger]];
  FirebaseCrashlyticsPlugin *instance = [[FirebaseCrashlyticsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"Crashlytics#onError" isEqualToString:call.method]) {
    // Add logs.
    NSArray *logs = call.arguments[@"logs"];
    for (NSString *log in logs) {
      [[FIRCrashlytics crashlytics] logWithFormat:@"%@", log];
    }

    // Set keys.
    NSDictionary *keys = call.arguments[@"keys"];
    for (NSString *key in keys) {
      [[FIRCrashlytics crashlytics] setCustomValue:keys[key] forKey:key];
    }

    // Add additional information from the Flutter framework to the exception reported in
    // Crashlytics.
    NSString *information = call.arguments[@"information"];
    if ([information length] != 0) {
      [[FIRCrashlytics crashlytics] logWithFormat:@"%@", information];
    }

    // Report crash.
    NSArray *errorElements = call.arguments[@"stackTraceElements"];
    NSMutableArray *frames = [NSMutableArray array];
    for (NSDictionary *errorElement in errorElements) {
      [frames addObject:[self generateFrame:errorElement]];
    }

    NSString *context = call.arguments[@"context"];
    NSString *reason;
    if (context != nil) {
      reason = [NSString stringWithFormat:@"thrown %@", context];
    }

    FIRExceptionModel *exception =
        [FIRExceptionModel exceptionModelWithName:call.arguments[@"exception"] reason:reason];

    exception.stackTrace = frames;

    [[FIRCrashlytics crashlytics] recordExceptionModel:exception];
    result(@"Error reported to Crashlytics.");
  } else if ([@"Crashlytics#setUserIdentifier" isEqualToString:call.method]) {
    [[FIRCrashlytics crashlytics] setUserID:call.arguments[@"identifier"]];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FIRStackFrame *)generateFrame:(NSDictionary *)errorElement {
  FIRStackFrame *frame =
      [FIRStackFrame stackFrameWithSymbol:[errorElement valueForKey:@"method"]
                                     file:[errorElement valueForKey:@"file"]
                                     line:[[errorElement valueForKey:@"line"] intValue]];
  return frame;
}

@end
