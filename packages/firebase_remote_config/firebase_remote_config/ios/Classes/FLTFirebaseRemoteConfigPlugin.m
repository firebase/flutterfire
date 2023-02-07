// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "FLTFirebaseRemoteConfigPlugin.h"
#import "FLTFirebaseRemoteConfigUtils.h"

NSString *const kFirebaseRemoteConfigChannelName = @"plugins.flutter.io/firebase_remote_config";

@interface FLTFirebaseRemoteConfigPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTFirebaseRemoteConfigPlugin

BOOL _fetchAndActivateRetry;

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseRemoteConfigPlugin *instance;
  _fetchAndActivateRetry = false;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseRemoteConfigPlugin alloc] init];
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
  FLTFirebaseRemoteConfigPlugin *instance = [FLTFirebaseRemoteConfigPlugin sharedInstance];

  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self.channel = nil;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        if (code == nil) {
          details = [FLTFirebaseRemoteConfigUtils ErrorCodeAndMessageFromNSError:error];
          code = [details valueForKey:@"code"];
          message = [details valueForKey:@"message"];
        }
        if ([@"unknown" isEqualToString:code]) {
          NSLog(@"FLTFirebaseRemoteConfig: An error occurred while calling method %@", call.method);
        }
        flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                            message:message
                                                    optionalDetails:details
                                                 andOptionalNSError:error]);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"RemoteConfig#ensureInitialized" isEqualToString:call.method]) {
    [self ensureInitialized:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#activate" isEqualToString:call.method]) {
    [self activate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#getAll" isEqualToString:call.method]) {
    [self getAll:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#fetch" isEqualToString:call.method]) {
    [self fetch:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#fetchAndActivate" isEqualToString:call.method]) {
    [self fetchAndActivate:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#setConfigSettings" isEqualToString:call.method]) {
    [self setConfigSettings:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#setDefaults" isEqualToString:call.method]) {
    [self setDefaults:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"RemoteConfig#getProperties" isEqualToString:call.method]) {
    [self getProperties:call.arguments withMethodCallResult:methodCallResult];
  } else {
    methodCallResult.success(FlutterMethodNotImplemented);
  }
}

#pragma mark - Remote Config API
- (void)ensureInitialized:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  [remoteConfig ensureInitializedWithCompletionHandler:^(NSError *initializationError) {
    if (initializationError != nil) {
      result.error(nil, nil, nil, initializationError);
    } else {
      result.success(nil);
    }
  }];
}

- (void)activate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  [remoteConfig activateWithCompletion:^(BOOL changed, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(@(changed));
    }
  }];
}

- (void)getAll:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  NSDictionary *parameters = [self getAllParametersForInstance:remoteConfig];
  result.success(parameters);
}

- (void)fetch:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)getProperties:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  NSDictionary *configProperties = [self configPropertiesForInstance:remoteConfig];
  result.success(configProperties);
}

- (void)setDefaults:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  [remoteConfig setDefaults:arguments[@"defaults"]];
  result.success(nil);
}

- (void)setConfigSettings:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSNumber *fetchTimeout = arguments[@"fetchTimeout"];
  NSNumber *minimumFetchInterval = arguments[@"minimumFetchInterval"];
  FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
  remoteConfigSettings.fetchTimeout = [fetchTimeout doubleValue];
  remoteConfigSettings.minimumFetchInterval = [minimumFetchInterval doubleValue];
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  [remoteConfig setConfigSettings:remoteConfigSettings];
  result.success(nil);
}

- (void)fetchAndActivate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigFromArguments:arguments];
  [remoteConfig fetchAndActivateWithCompletionHandler:^(
                    FIRRemoteConfigFetchAndActivateStatus status, NSError *error) {
    if (error != nil) {
      if (error.code == 999 && _fetchAndActivateRetry == false) {
        // Note: see issue for details: https://github.com/firebase/flutterfire/issues/6196
        // Only calling once as the issue noted describes how it works on second retry
        // Issue appears to indicate the error code is: 999
        _fetchAndActivateRetry = true;
        NSLog(@"FLTFirebaseRemoteConfigPlugin: Retrying `fetchAndActivate()` due to a cancelled "
              @"request with the error code: 999.");
        [self fetchAndActivate:arguments withMethodCallResult:result];
      } else {
        result.error(nil, nil, nil, error);
      }
    } else {
      if (status == FIRRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote) {
        result.success(@(YES));
      } else {
        result.success(@(NO));
      }
    }
  }];
}

- (FIRRemoteConfig *_Nullable)getFIRRemoteConfigFromArguments:(NSDictionary *)arguments {
  NSString *appName = arguments[@"appName"];
  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appName];
  return [FIRRemoteConfig remoteConfigWithApp:app];
}

- (NSDictionary *)getAllParametersForInstance:(FIRRemoteConfig *)remoteConfig {
  NSMutableSet *keySet = [[NSMutableSet alloc] init];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceStatic]];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceDefault]];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote]];

  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  for (NSString *key in keySet) {
    parameters[key] = [self createRemoteConfigValueDict:[remoteConfig configValueForKey:key]];
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
  _fetchAndActivateRetry = false;
  completion();
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  FIRRemoteConfig *firebaseRemoteConfig = [FIRRemoteConfig remoteConfigWithApp:firebase_app];
  NSDictionary *configProperties = [self configPropertiesForInstance:firebaseRemoteConfig];

  NSMutableDictionary *configValues = [[NSMutableDictionary alloc] init];
  [configValues addEntriesFromDictionary:configProperties];
  [configValues setValue:[self getAllParametersForInstance:firebaseRemoteConfig]
                  forKey:@"parameters"];
  return configValues;
}

- (NSDictionary *_Nonnull)configPropertiesForInstance:(FIRRemoteConfig *)remoteConfig {
  NSNumber *fetchTimeout = @([[remoteConfig configSettings] fetchTimeout]);
  NSNumber *minimumFetchInterval = @([[remoteConfig configSettings] minimumFetchInterval]);
  NSNumber *lastFetchMillis = @([[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000);

  NSMutableDictionary *configProperties = [[NSMutableDictionary alloc] init];
  [configProperties setValue:@([fetchTimeout longValue]) forKey:@"fetchTimeout"];
  [configProperties setValue:@([minimumFetchInterval longValue]) forKey:@"minimumFetchInterval"];
  [configProperties setValue:@([lastFetchMillis longValue]) forKey:@"lastFetchTime"];
  [configProperties setValue:[self mapLastFetchStatus:[remoteConfig lastFetchStatus]]
                      forKey:@"lastFetchStatus"];
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
