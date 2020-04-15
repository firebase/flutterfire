// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseAdMobPlugin.h"

@interface FLTAdReferenceManager : NSObject<FLTAdListenerCallbackHandler>
@end

@interface FLTFirebaseAdMobReaderWriter : FlutterStandardReaderWriter
@end

@interface FLTFirebaseAdMobReader : FlutterStandardReader
@end

typedef NS_ENUM(NSInteger, FirebaseAdMobField) {
  FirebaseAdMobFieldAdRequest = 128,
  FirebaseAdMobFieldAdSize = 129,
};

@implementation FLTFirebaseAdMobReaderWriter
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTFirebaseAdMobReader alloc] initWithData:data];
}
@end

@implementation FLTFirebaseAdMobReader
- (id)readValueOfType:(UInt8)type {
  FirebaseAdMobField field = (FirebaseAdMobField)type;
  switch(field) {
    case FirebaseAdMobFieldAdRequest:
      return [[FLTAdRequest alloc] init];
    case FirebaseAdMobFieldAdSize:
      return [[FLTAdSize alloc] initWithWidth:[self readValueOfType:[self readByte]]
                                       height:[self readValueOfType:[self readByte]]];
  }
  return [super readValueOfType:type];
}
@end

@implementation FLTAdReferenceManager {
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
  FLTAdReferenceManager *referenceManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseAdMobReaderWriter *readerWriter = [[FLTFirebaseAdMobReaderWriter alloc] init];
  FlutterMethodChannel*channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_admob"
                                  binaryMessenger:[registrar messenger]
                                            codec:[FlutterStandardMethodCodec codecWithReaderWriter:readerWriter]];
  
  FLTAdReferenceManager *referenceManager = [[FLTAdReferenceManager alloc] initWithChannel:channel];
  
  FLTFirebaseAdMobPlugin *plugin = [[FLTFirebaseAdMobPlugin alloc] initWithReferenceManager:referenceManager];
  [registrar addMethodCallDelegate:plugin channel:channel];
  [registrar publish:plugin];

//  FLTFirebaseAdMobViewFactory *viewFactory = [[FLTFirebaseAdMobViewFactory alloc] init];
//  [registrar registerViewFactory:viewFactory withId:@"plugins.flutter.io/firebase_admob/ad_widget"];
}

- (instancetype)initWithReferenceManager:(FLTAdReferenceManager *)manager {
  self = [super init];
  if (self && ![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
    NSLog(@"Configuring the default Firebase app...");
    [FIRApp configure];
    NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    referenceManager = manager;
  }
  
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqual:@"INITIALIZE"]) {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    result(nil);
  } else if ([call.method isEqual:@"LOAD"]) {
    [referenceManager loadAdWithRefernceId:call.arguments[0]
                                 className:call.arguments[1]
                                parameters:call.arguments[2]];
    result(nil);
  } else if ([call.method isEqual:@"METHOD"]) {
    [referenceManager receiveMethodCall:call.arguments[0]
                             methodName:call.arguments[1]
                              arguments:call.arguments[2]];
    result(nil);
  } else if ([call.method isEqual:@"DISPOSE"]) {
    [referenceManager disposeAdWithReferenceId:call.arguments];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
