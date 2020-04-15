// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseAdMobPlugin.h"

@interface FLTAdInstanceManager : NSObject<FLTAdListenerCallbackHandler>
@end

@implementation FLTAdInstanceManager {
  NSLock *dictionaryLock;
  NSMutableDictionary<NSNumber *, id<FLTAd>> *referenceIdToAd;
  FlutterMethodChannel *callbackChannel;
  __weak UIViewController *rootViewController;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    dictionaryLock = [[NSLock alloc] init];
    referenceIdToAd = [NSMutableDictionary dictionary];
    callbackChannel = channel;
    rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  }
  return self;
}

- (void)loadAdWithRefernceId:(NSNumber *)referenceId
                   className:(NSString *)className
                  parameters:(NSArray<id> *)parameters {
  id<FLTAd> ad = [self createAd:className parameters:parameters];
  [dictionaryLock lock];
  [referenceIdToAd setObject:ad forKey:referenceId];
  [dictionaryLock unlock];
  [ad load];
}

- (void)sendMethodCall:(id<FLTAd>)ad methodName:(NSString *)methodName arguments:(NSArray<id> *)arguments {
  [callbackChannel invokeMethod:methodName arguments:@[[self referenceIdForAd:ad], arguments]];
}

- (void)receiveMethodCall:(NSNumber *)referenceId
               methodName:(NSString *)methodName
                arguments:(NSArray<id> *)arguments {
  // TODO: implement
}

- (void)disposeAdWithReferenceId:(NSNumber *)referenceId {
  id<FLTAd> ad = [self adForReferenceId:referenceId];
  [ad dispose];
  
  [dictionaryLock lock];
  [referenceIdToAd removeObjectForKey:referenceId];
  [dictionaryLock unlock];
}

- (id<FLTAd>)adForReferenceId:(NSNumber *)referenceId {
  [dictionaryLock lock];
  id<FLTAd> ad = [referenceIdToAd objectForKey:referenceId];
  [dictionaryLock unlock];
  return ad;
}

- (NSNumber *)referenceIdForAd:(id<FLTAd>)ad {
  [dictionaryLock lock];
  NSNumber *referenceId = [referenceIdToAd allKeysForObject:ad][0];
  [dictionaryLock unlock];
  return referenceId;
}

- (id<FLTAd>)createAd:(NSString *)className parameters:(NSArray<id> *)parameters {
  if ([className isEqual:@"BannerAd"]) {
    return [[FLTBannerAd alloc] initWithAdUnitId:parameters[0]
                                         request:parameters[1]
                                          adSize:parameters[2]
                              rootViewController:rootViewController
                                 callbackHandler:self];
  }
  return nil;
}

- (void)onAdLoaded:(id<FLTAd>)ad {
  [self sendMethodCall:ad methodName:@"AdListener#onAdLoaded" arguments:@[]];
}
@end

@implementation FLTFirebaseAdMobPlugin {
  FLTAdInstanceManager *instanceManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseAdMobReaderWriter *readerWriter = [[FLTFirebaseAdMobReaderWriter alloc] init];
  FlutterMethodChannel*channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_admob"
                                  binaryMessenger:[registrar messenger]
                                            codec:[FlutterStandardMethodCodec codecWithReaderWriter:readerWriter]];
  
  FLTAdInstanceManager *referenceManager = [[FLTAdInstanceManager alloc] initWithChannel:channel];
  
  FLTFirebaseAdMobPlugin *plugin = [[FLTFirebaseAdMobPlugin alloc] initWithInstanceManager:referenceManager];
  [registrar addMethodCallDelegate:plugin channel:channel];
  [registrar publish:plugin];

//  FLTFirebaseAdMobViewFactory *viewFactory = [[FLTFirebaseAdMobViewFactory alloc] init];
//  [registrar registerViewFactory:viewFactory withId:@"plugins.flutter.io/firebase_admob/ad_widget"];
}

- (instancetype)initWithInstanceManager:(FLTAdInstanceManager *)instanceManager {
  self = [super init];
  if (self && ![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
    NSLog(@"Configuring the default Firebase app...");
    [FIRApp configure];
    NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    self->instanceManager = instanceManager;
  }
  
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqual:@"INITIALIZE"]) {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    result(nil);
  } else if ([call.method isEqual:@"LOAD"]) {
    [instanceManager loadAdWithRefernceId:call.arguments[0]
                                 className:call.arguments[1]
                                parameters:call.arguments[2]];
    result(nil);
  } else if ([call.method isEqual:@"METHOD"]) {
    [instanceManager receiveMethodCall:call.arguments[0]
                             methodName:call.arguments[1]
                              arguments:call.arguments[2]];
    result(nil);
  } else if ([call.method isEqual:@"DISPOSE"]) {
    [instanceManager disposeAdWithReferenceId:call.arguments];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
