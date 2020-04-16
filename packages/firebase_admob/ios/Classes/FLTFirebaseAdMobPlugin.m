// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseAdMobPlugin.h"

@interface FLTAdInstanceManager : NSObject <FLTAdListenerCallbackHandler>
@property NSMutableDictionary<NSString *, id<FLTNativeAdFactory>> *nativeAdFactories;
@end

@implementation FLTAdInstanceManager {
  FLTAdCollection *_ads;
  FlutterMethodChannel *_callbackChannel;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _ads = [[FLTAdCollection alloc] init];
    _callbackChannel = channel;
    _nativeAdFactories = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)loadAdWithReferenceId:(NSNumber *)referenceId
                    className:(NSString *)className
                   parameters:(NSArray<id> *)parameters {
  id<FLTAd> ad = [self createAd:className parameters:parameters];
  [_ads addAd:ad forReferenceId:referenceId];
  [ad load];
}

- (void)sendMethodCall:(id<FLTAd>)ad
            methodName:(NSString *)methodName
             arguments:(NSArray<id> *)arguments {
  [_callbackChannel invokeMethod:methodName arguments:@[ [_ads referenceIdForAd:ad], arguments ]];
}

- (void)showAdWithReferenceId:(NSNumber *)referenceId parameters:(NSArray<id> *)parameters {
  id<FLTAd> ad = [_ads adForReferenceId:referenceId];

  if ([ad.class conformsToProtocol:@protocol(FLTPlatformViewAd)]) {
    id<FLTPlatformViewAd> platformViewAd = (id<FLTPlatformViewAd>)ad;
    [platformViewAd show:parameters[0]
        horizontalCenterOffset:parameters[1]
                    anchorType:parameters[2]];
  } else if ([ad.class conformsToProtocol:@protocol(FLTFullscreenAd)]) {
    id<FLTFullscreenAd> fullscreenAd = (id<FLTFullscreenAd>)ad;
    [fullscreenAd show];
  } else {
    NSLog(@"Failed to show ad.");
  }
}

- (void)disposeAdWithReferenceId:(NSNumber *)referenceId {
  id<FLTAd> ad = [_ads adForReferenceId:referenceId];
  if ([ad.class conformsToProtocol:@protocol(FLTPlatformViewAd)]) {
    id<FLTPlatformViewAd> platformViewAd = (id<FLTPlatformViewAd>)ad;
    [platformViewAd dispose];
  }
  [_ads removeAdWithReferenceId:referenceId];
}

- (id<FLTAd>)createAd:(NSString *)className parameters:(NSArray<id> *)parameters {
  if ([className isEqual:@"BannerAd"]) {
    return [[FLTBannerAd alloc] initWithAdUnitId:parameters[0]
                                         request:parameters[1]
                                          adSize:parameters[2]
                                 callbackHandler:self];
  } else if ([className isEqual:@"InterstitialAd"]) {
    return [[FLTInterstitialAd alloc] initWithAdUnitId:parameters[0]
                                               request:parameters[1]
                                       callbackHandler:self];
  } else if ([className isEqual:@"NativeAd"]) {
    return [[FLTNativeAd alloc] initWithAdUnitId:parameters[0]
                                         request:parameters[1]
                                 nativeAdFactory:_nativeAdFactories[parameters[2]]
                                   customOptions:parameters[3]
                                 callbackHandler:self];
  } else if ([className isEqual:@"RewardedAd"]) {
    return [[FLTRewardedAd alloc] initWithAdUnitId:parameters[0]
                                           request:parameters[1]
                                   callbackHandler:self];
  }
  
  NSLog(@"Failed to create ad.");
  return nil;
}

- (void)onAdLoaded:(id<FLTAd>)ad {
  [self sendMethodCall:ad methodName:@"AdListener#onAdLoaded" arguments:@[]];
}
@end

@implementation FLTFirebaseAdMobPlugin {
  FLTAdInstanceManager *_instanceManager;
}

/// Returns the AdMob plugin from the registry or nil if the plugin wasn't registered.
+ (FLTFirebaseAdMobPlugin *)adMobPluginFromRegistry:(NSObject<FlutterPluginRegistry> *)registry {
  NSString *pluginClassName = NSStringFromClass([FLTFirebaseAdMobPlugin class]);
  return (FLTFirebaseAdMobPlugin *)[registry valuePublishedByPlugin:pluginClassName];
}

+ (BOOL)registerNativeAdFactory:(NSObject<FlutterPluginRegistry> *)registry
                      factoryId:(NSString *)factoryId
                nativeAdFactory:(NSObject<FLTNativeAdFactory> *)nativeAdFactory {
  FLTFirebaseAdMobPlugin *adMobPlugin = [self adMobPluginFromRegistry:registry];
  if (!adMobPlugin) {
    NSLog(@"Could not find a %@ instance. The plugin may have not been registered.",
          NSStringFromClass([self class]));
    return NO;
  }

  if (adMobPlugin->_instanceManager.nativeAdFactories[factoryId]) {
    NSLog(@"A NativeAdFactory with the following factoryId already exists: %@", factoryId);
    return NO;
  }

  [adMobPlugin->_instanceManager.nativeAdFactories setObject:nativeAdFactory forKey:factoryId];
  return YES;
}

+ (id<FLTNativeAdFactory>)unregisterNativeAdFactory:(NSObject<FlutterPluginRegistry> *)registry
                                          factoryId:(NSString *)factoryId {
  FLTFirebaseAdMobPlugin *adMobPlugin = [self adMobPluginFromRegistry:registry];

  id<FLTNativeAdFactory> factory = adMobPlugin->_instanceManager.nativeAdFactories[factoryId];
  if (factory) [adMobPlugin->_instanceManager.nativeAdFactories removeObjectForKey:factoryId];
  return factory;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseAdMobReaderWriter *readerWriter = [[FLTFirebaseAdMobReaderWriter alloc] init];
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/firebase_admob"
            binaryMessenger:[registrar messenger]
                      codec:[FlutterStandardMethodCodec codecWithReaderWriter:readerWriter]];

  FLTAdInstanceManager *referenceManager = [[FLTAdInstanceManager alloc] initWithChannel:channel];

  FLTFirebaseAdMobPlugin *plugin =
      [[FLTFirebaseAdMobPlugin alloc] initWithInstanceManager:referenceManager];
  [registrar addMethodCallDelegate:plugin channel:channel];
  [registrar publish:plugin];
}

- (instancetype)initWithInstanceManager:(FLTAdInstanceManager *)instanceManager {
  self = [super init];
  if (self && ![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
    NSLog(@"Configuring the default Firebase app...");
    [FIRApp configure];
    NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
  }

  if (self) {
    _instanceManager = instanceManager;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqual:@"INITIALIZE"]) {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    result(nil);
  } else if ([call.method isEqual:@"LOAD"]) {
    [_instanceManager loadAdWithReferenceId:call.arguments[0]
                                  className:call.arguments[1]
                                 parameters:call.arguments[2]];
    result(nil);
  } else if ([call.method isEqual:@"SHOW"]) {
    [_instanceManager showAdWithReferenceId:call.arguments[0] parameters:call.arguments[1]];
    result(nil);
  } else if ([call.method isEqual:@"DISPOSE"]) {
    [_instanceManager disposeAdWithReferenceId:call.arguments];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
