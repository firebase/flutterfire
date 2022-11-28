// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseInAppMessagingPlugin.h"

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

NSString *const kFLTFirebaseInAppMessagingChannelName =
    @"plugins.flutter.io/firebase_in_app_messaging";

@implementation FirebaseInAppMessagingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseInAppMessagingChannelName
                                  binaryMessenger:[registrar messenger]];
  FirebaseInAppMessagingPlugin *instance = [[FirebaseInAppMessagingPlugin alloc] init];
  [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"FirebaseInAppMessaging#triggerEvent" isEqualToString:call.method]) {
    NSString *eventName = call.arguments[@"eventName"];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    [fiam triggerEvent:eventName];
    result(nil);
  } else if ([@"FirebaseInAppMessaging#setMessagesSuppressed" isEqualToString:call.method]) {
    BOOL suppress = [[call.arguments objectForKey:@"suppress"] boolValue];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    fiam.messageDisplaySuppressed = suppress;
    result(nil);
  } else if ([@"FirebaseInAppMessaging#setAutomaticDataCollectionEnabled"
                 isEqualToString:call.method]) {
    BOOL enabled = [[call.arguments objectForKey:@"enabled"] boolValue];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    fiam.automaticDataCollectionEnabled = enabled;
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  if (completion != nil) completion();
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
  return kFLTFirebaseInAppMessagingChannelName;
}

@end
