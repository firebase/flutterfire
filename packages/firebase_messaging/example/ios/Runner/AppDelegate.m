// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <firebase_messaging/FirebaseMessagingPlugin.h>

@implementation AppDelegate
    
void callback(NSObject<FlutterPluginRegistry>* registry) {
    [GeneratedPluginRegistrant registerWithRegistry:registry];
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [FLTFirebaseMessagingPlugin setPluginRegistrantCallback:callback];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
