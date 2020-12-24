// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <firebase_core/FLTFirebasePluginRegistry.h>
#import <Firebase/Firebase.h>

#import "FirebaseRemoteConfigPlugin.h"

NSString *const kFirebaseRemoteConfigChannelName = @"plugins.flutter.io/firebase_remote_config";

@interface FirebaseRemoteConfigPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseRemoteConfigPlugin

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FirebaseRemoteConfigPlugin *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FirebaseRemoteConfigPlugin alloc] init];
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  });

  return instance;
}

- (instancetype)init {
  self = [super init];
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFirebaseRemoteConfigChannelName
                                  binaryMessenger:[registrar messenger]];
  FirebaseRemoteConfigPlugin *instance = [FirebaseRemoteConfigPlugin sharedInstance];

  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (void)detachFromEngineForRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
  self.channel = nil;
}

- (FIRRemoteConfig *_Nullable)getFIRRemoteConfigFromArguments:(NSDictionary *)arguments {
  NSString *appName = arguments[@"appName"];
  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appName];
  return [FIRRemoteConfig remoteConfigWithApp:app];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:call.arguments];
  if ([@"RemoteConfig#ensureInitialized" isEqualToString:call.method]) {
    [remoteConfig ensureInitializedWithCompletionHandler:^(NSError * _Nullable initializationError) {
      result(nil);
    }];
  } else if([@"RemoteConfig#activate" isEqualToString:call.method]) {
    [remoteConfig activateWithCompletion:^(BOOL configActivated, NSError *_Nullable activateError) {
      result(@(configActivated));
    }];
  } else if ([@"RemoteConfig#getAll" isEqualToString:call.method]) {
    NSDictionary *parameters = [self getAllParametersForInstance:remoteConfig];
    result(parameters);
  } else if ([@"RemoteConfig#fetch" isEqualToString:call.method] ) {
    [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
      result(nil);
    }];
  } else if ([@"RemoteConfig#fetchAndActivate" isEqualToString:call.method]) {
    [remoteConfig fetchAndActivateWithCompletionHandler:^(FIRRemoteConfigFetchAndActivateStatus status, NSError *error) {
      if (status == FIRRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote) {
        result([NSNumber numberWithBool:TRUE]);
      } else {
        result([NSNumber numberWithBool:FALSE]);
      }
    }];
  } else if ([@"RemoteConfig#setConfigSettings" isEqualToString:call.method]) {
    NSNumber *fetchTimeout = call.arguments[@"fetchTimeout"];
    NSNumber *minimumFetchInterval = call.arguments[@"minimumFetchInterval"];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
    remoteConfigSettings.fetchTimeout = [fetchTimeout intValue];
    remoteConfigSettings.minimumFetchInterval = [minimumFetchInterval intValue];
    [remoteConfig setConfigSettings:remoteConfigSettings];
    result(nil);
  } else if ([@"RemoteConfig#setDefaults" isEqualToString:call.method]) {
    NSDictionary *defaults = call.arguments[@"defaults"];
    [remoteConfig setDefaults:defaults];
    result(nil);
  } else if ([@"RemoteConfig#getProperties" isEqualToString:call.method]) {
    NSDictionary *configProperties = [self configPropertiesForInstance:remoteConfig];
    result(configProperties);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *)getAllParametersForInstance:(FIRRemoteConfig *)remoteConfig {
  NSMutableSet *keySet = [[NSMutableSet alloc] init];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceStatic]];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceDefault]];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote]];

  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  for (NSString *key in keySet) {
    parameters[key] = [self createRemoteConfigValueDict: [remoteConfig configValueForKey:key]];
  }
  return parameters;
}

- (NSMutableDictionary *)createRemoteConfigValueDict:(FIRRemoteConfigValue *)remoteConfigValue {
  NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
  valueDict[@"value"] = [FlutterStandardTypedData typedDataWithBytes:[remoteConfigValue dataValue]];
  valueDict[@"source"] = [self mapValueSource:[remoteConfigValue source]];
  return valueDict;
}

- (NSString *)mapLastFetchStatus:(FIRRemoteConfigFetchStatus)status {
  if (status == FIRRemoteConfigFetchStatusSuccess) {
    return @"success";
  } else if (status == FIRRemoteConfigFetchStatusFailure) {
    return @"failure";
  } else if (status == FIRRemoteConfigFetchStatusThrottled) {
    return @"throttled";
  } else if (status == FIRRemoteConfigFetchStatusNoFetchYet) {
    return @"noFetchYet";
  } else {
    return @"failure";
  }
}

- (NSString *)mapValueSource:(FIRRemoteConfigSource)source {
  if (source == FIRRemoteConfigSourceStatic) {
    return @"static";
  } else if (source == FIRRemoteConfigSourceDefault) {
    return @"default";
  } else if (source == FIRRemoteConfigSourceRemote) {
    return @"remote";
  } else {
    return @"static";
  }
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  completion();
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  FIRRemoteConfig  *firebaseRemoteConfig = [FIRRemoteConfig remoteConfigWithApp:firebase_app];
  NSDictionary *configProperties = [self configPropertiesForInstance:firebaseRemoteConfig];

  NSMutableDictionary *configValues = [[NSMutableDictionary alloc] init];
  [configValues addEntriesFromDictionary:configProperties];
  [configValues setValue:[self getAllParametersForInstance:firebaseRemoteConfig] forKey:@"parameters"];
  return configValues;
}

- (NSDictionary *_Nonnull)configPropertiesForInstance:(FIRRemoteConfig *)remoteConfig {
  NSNumber *fetchTimeout = @([[remoteConfig configSettings] fetchTimeout]);
  NSNumber *minimumFetchInterval = @([[remoteConfig configSettings] minimumFetchInterval]);
  int lastFetchMillis = (int) ([[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000);

  NSMutableDictionary *configProperties = [[NSMutableDictionary alloc] init];
  [configProperties setValue:@([fetchTimeout intValue]) forKey:@"fetchTimeout"];
  [configProperties setValue:@([minimumFetchInterval intValue]) forKey:@"minimumFetchInterval"];
  [configProperties setValue:@(lastFetchMillis) forKey:@"lastFetchTime"];
  [configProperties setValue:[self mapLastFetchStatus:[remoteConfig lastFetchStatus]] forKey:@"lastFetchStatus"];
  return configProperties;
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFirebaseRemoteConfigChannelName;
}

@end
