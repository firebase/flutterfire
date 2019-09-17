// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTMobileAd.h"
#import "FLTRequestFactory.h"
#import "FirebaseAdMobPlugin.h"

static NSMutableDictionary *allAds = nil;
static NSDictionary *statusToString = nil;

@implementation FLTMobileAd
NSNumber *_mobileAdId;
FlutterMethodChannel *_channel;
FLTMobileAdStatus _status;
double _anchorOffset;
double _horizontalCenterOffset;
int _anchorType;

+ (void)initialize {
  if (allAds == nil) {
    allAds = [[NSMutableDictionary alloc] init];
  }
  _anchorType = 0;
  _anchorOffset = 0;
  _horizontalCenterOffset = 0;

  if (statusToString == nil) {
    statusToString = @{
      @(CREATED) : @"CREATED",
      @(LOADING) : @"LOADING",
      @(FAILED) : @"FAILED",
      @(PENDING) : @"PENDING",
      @(LOADED) : @"LOADED"
    };
  }
}

+ (void)configureWithAppId:(NSString *)appId {
  [GADMobileAds configureWithApplicationID:appId];
}

+ (FLTMobileAd *)getAdForId:(NSNumber *)mobileAdId {
  return allAds[mobileAdId];
}

+ (UIViewController *)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (instancetype)initWithId:(NSNumber *)mobileAdId channel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _mobileAdId = mobileAdId;
    _channel = channel;
    _status = CREATED;
    _anchorOffset = 0;
    _horizontalCenterOffset = 0;
    _anchorType = 0;
    allAds[mobileAdId] = self;
  }
  return self;
}

- (FLTMobileAdStatus)status {
  return _status;
}

- (void)loadWithAdUnitId:(NSString *)adUnitId targetingInfo:(NSDictionary *)targetingInfo {
  // Implemented by the Banner and Interstitial subclasses
}

- (void)showAtOffset:(double)anchorOffset
       hCenterOffset:(double)horizontalCenterOffset
          fromAnchor:(int)anchorType {
  _anchorType = anchorType;
  _anchorOffset = anchorOffset;
  if (_anchorType == 0) {
    _anchorOffset = -_anchorOffset;
  }
  _horizontalCenterOffset = horizontalCenterOffset;
  [self show];
}

- (void)show {
  // Implemented by the Banner and Interstitial subclasses
}

- (void)dispose {
  [allAds removeObjectForKey:_mobileAdId];
}

- (NSDictionary *)argumentsMap {
  return @{@"id" : _mobileAdId};
}

- (NSString *)description {
  NSString *statusString = (NSString *)statusToString[[NSNumber numberWithInt:_status]];
  return [NSString
      stringWithFormat:@"%@ %@ mobileAdId:%@", super.description, statusString, _mobileAdId];
}
@end

@implementation FLTInterstitialAd
GADInterstitial *_interstitial;

+ (instancetype)withId:(NSNumber *)mobileAdId channel:(FlutterMethodChannel *)channel {
  FLTMobileAd *ad = [FLTMobileAd getAdForId:mobileAdId];
  return ad != nil ? (FLTInterstitialAd *)ad
                   : [[FLTInterstitialAd alloc] initWithId:mobileAdId channel:channel];
}

- (void)loadWithAdUnitId:(NSString *)adUnitId targetingInfo:(NSDictionary *)targetingInfo {
  if (_status != CREATED) return;
  _status = LOADING;

  _interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
  _interstitial.delegate = self;
  FLTRequestFactory *factory = [[FLTRequestFactory alloc] initWithTargetingInfo:targetingInfo];
  [_interstitial loadRequest:[factory createRequest]];
}

- (void)show {
  if (_status == LOADING) {
    _status = PENDING;
    return;
  }
  if (_status != LOADED) return;

  [_interstitial presentFromRootViewController:[FLTMobileAd rootViewController]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  bool statusWasPending = _status == PENDING;
  _status = LOADED;
  [_channel invokeMethod:@"onAdLoaded" arguments:[self argumentsMap]];
  if (statusWasPending) [self show];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
  FLTLogWarning(@"interstitial:didFailToReceiveAdWithError: %@ (MobileAd %@)",
                [error localizedDescription], self);
  [_channel invokeMethod:@"onAdFailedToLoad" arguments:[self argumentsMap]];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdClicked" arguments:[self argumentsMap]];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdImpression" arguments:[self argumentsMap]];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdClosed" arguments:[self argumentsMap]];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdLeftApplication" arguments:[self argumentsMap]];
}

- (void)dispose {
  // It is not possible to hide/remove/destroy an AdMob interstitial Ad.
  _interstitial = nil;
  [super dispose];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ for: %@", super.description, _interstitial];
}
@end
