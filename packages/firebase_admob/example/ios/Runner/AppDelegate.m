// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "FLTFirebaseAdMobPlugin.h"

@interface NativeAdFactoryExample : NSObject<FLTNativeAdFactory>
@end

@implementation NativeAdFactoryExample
- (GADUnifiedNativeAdView *)createNativeAd:(GADUnifiedNativeAd *)nativeAd customOptions:(NSDictionary *)customOptions {
  return [[GADUnifiedNativeAdView alloc] init];
}
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  
  NativeAdFactoryExample *nativeAdFactory = [[NativeAdFactoryExample alloc] init];
  [FLTFirebaseAdMobPlugin registerNativeAdFactory:self
                                         factoryId:@"adFactoryExample"
                                   nativeAdFactory:nativeAdFactory];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
