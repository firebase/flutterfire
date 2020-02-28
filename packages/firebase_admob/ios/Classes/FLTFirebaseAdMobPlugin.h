// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

#define FLTLogWarning(format, ...) NSLog((@"FirebaseAdMobPlugin <warning> " format), ##__VA_ARGS__)

@protocol FLTNativeAdFactory
@required
- (GADUnifiedNativeAdView *)createNativeAd:(GADUnifiedNativeAd *)nativeAd customOptions:(NSDictionary *)customOptions;
@end

@interface FLTFirebaseAdMobPlugin : NSObject <FlutterPlugin>
+ (BOOL)registerNativeAdFactory:(NSObject<FlutterPluginRegistry> *)registry
                      factoryId:(NSString *)factoryId
                nativeAdFactory:(NSObject<FLTNativeAdFactory> *)nativeAdFactory;
@end
