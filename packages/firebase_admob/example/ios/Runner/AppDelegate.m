// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "FLTFirebaseAdMobPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [FLTFirebaseAdMobPlugin registerNativeAdFactory:self factoryId:@"example" nativeAdFactory:nil];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
