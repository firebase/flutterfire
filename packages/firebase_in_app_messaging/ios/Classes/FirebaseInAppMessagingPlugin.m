// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseInAppMessagingPlugin.h"
#import <Firebase/Firebase.h>

static NSMutableDictionary *getDictionaryFromInAppMessaging(
    FIRInAppMessagingDisplayMessage *inAppMessage, FIRInAppMessagingAction *action) {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  dictionary[@"messageID"] = inAppMessage.campaignInfo.messageID;
  dictionary[@"campaignName"] = inAppMessage.campaignInfo.campaignName;
  NSMutableDictionary *actionData = [[NSMutableDictionary alloc] init];
  if (action) {
    actionData[@"actionText"] = action.actionText;
    actionData[@"actionURL"] = action.actionURL.absoluteString;
  }
  dictionary[@"action"] = actionData;
  return dictionary;
}

static NSDictionary *getDictionaryFromError(NSError *error) {
  if (error == nil) {
    return nil;
  }

  return @{
    @"code" : @(error.code),
    @"message" : error.domain ?: [NSNull null],
    @"details" : error.localizedDescription ?: [NSNull null],
  };
}

@implementation FirebaseInAppMessagingPlugin {
  FlutterMethodChannel *_channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_in_app_messaging"
                                  binaryMessenger:[registrar messenger]];
  FirebaseInAppMessagingPlugin *instance =
      [[FirebaseInAppMessagingPlugin alloc] initWithChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }
    [FIRInAppMessaging inAppMessaging].delegate = self;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"triggerEvent" isEqualToString:call.method]) {
    NSString *eventName = call.arguments[@"eventName"];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    [fiam triggerEvent:eventName];
    result(nil);
  } else if ([@"setMessagesSuppressed" isEqualToString:call.method]) {
    NSNumber *suppress = [NSNumber numberWithBool:call.arguments];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    fiam.messageDisplaySuppressed = [suppress boolValue];
    result(nil);
  } else if ([@"setAutomaticDataCollectionEnabled" isEqualToString:call.method]) {
    NSNumber *enabled = [NSNumber numberWithBool:call.arguments];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    fiam.automaticDataCollectionEnabled = [enabled boolValue];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)displayErrorForMessage:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage
                         error:(nonnull NSError *)error {
  [_channel invokeMethod:@"onError" arguments:getDictionaryFromError(error)];
}

- (void)impressionDetectedForMessage:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage {
  [_channel invokeMethod:@"onImpression"
               arguments:getDictionaryFromInAppMessaging(inAppMessage, nil)];
}

- (void)messageClicked:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage
            withAction:(nonnull FIRInAppMessagingAction *)action {
  [_channel invokeMethod:@"onClicked"
               arguments:getDictionaryFromInAppMessaging(inAppMessage, action)];
}

@end
