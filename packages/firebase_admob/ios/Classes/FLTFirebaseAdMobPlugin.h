// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

#define FLTLogWarning(format, ...) NSLog((@"FirebaseAdMobPlugin <warning> " format), ##__VA_ARGS__)

/**
 * Creates a `GADUnifiedNativeAdView` to be shown in a Flutter app.
 *
 * When a Native Ad is created in Dart, this protocol is responsible for building the
 * `GADUnifiedNativeAdView`. Register a class that implements this with a `FLTFirebaseAdMobPlugin`
 * to use in conjunction with Flutter.
 */
@protocol FLTNativeAdFactory
@required
/**
 * Creates a `GADUnifiedNativeAdView` with a `GADUnifiedNativeAd`.
 *
 * @param nativeAd Ad information used to create a `GADUnifiedNativeAdView`
 * @param customOptions Used to pass additional custom options to create the
 * `GADUnifiedNativeAdView`. Nullable.
 * @return a `GADUnifiedNativeAdView` that is overlaid on top of the FlutterView.
 */
- (GADUnifiedNativeAdView *)createNativeAd:(GADUnifiedNativeAd *)nativeAd
                             customOptions:(NSDictionary *)customOptions;
@end

/**
 * Flutter plugin providing access to the Firebase Admob API.
 */
@interface FLTFirebaseAdMobPlugin : NSObject <FlutterPlugin>
/**
 * Adds a `FLTNativeAdFactory` used to create a `GADUnifiedNativeAdView`s from a Native Ad created
 * in Dart.
 *
 * @param registry maintains access to a `FLTFirebaseAdMobPlugin`` instance.
 * @param factoryId a unique identifier for the ad factory. The Native Ad created in Dart includes
 *     a parameter that refers to this.
 * @param nativeAdFactory creates `GADUnifiedNativeAdView`s when a Native Ad is created in Dart.
 * @return whether the factoryId is unique and the nativeAdFactory was successfully added.
 */
+ (BOOL)registerNativeAdFactory:(NSObject<FlutterPluginRegistry> *)registry
                      factoryId:(NSString *)factoryId
                nativeAdFactory:(NSObject<FLTNativeAdFactory> *)nativeAdFactory;

/**
 * Unregisters a `FLTNativeAdFactory` used to create `GADUnifiedNativeAdView`s from a Native Ad
 * created in Dart.
 *
 * @param registry maintains access to a `FLTFirebaseAdMobPlugin `instance.
 * @param factoryId a unique identifier for the ad factory. The Native Ad created in Dart includes
 *     a parameter that refers to this.
 * @return the previous `FLTNativeAdFactory` associated with this factoryId, or null if there was
 * none for this factoryId.
 */
+ (id<FLTNativeAdFactory>)unregisterNativeAdFactory:(NSObject<FlutterPluginRegistry> *)registry
                                          factoryId:(NSString *)factoryId;
@end
