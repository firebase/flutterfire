// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseRemoteConfig;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "FLTFirebaseRemoteConfigPlugin.h"
#import "FLTFirebaseRemoteConfigUtils.h"
// Import generated Pigeon header
#import "messages.g.h"

// Remove channel name constant as it's no longer used for method calls
// NSString *const kFirebaseRemoteConfigChannelName = @"plugins.flutter.io/firebase_remote_config";
NSString *const kFirebaseRemoteConfigUpdateChannelName =
    @"plugins.flutter.io/firebase_remote_config_updated";

@interface FLTFirebaseRemoteConfigPlugin ()
// Remove channel property
@property(nonatomic, strong)
    NSMutableDictionary<NSString *, FIRConfigUpdateListenerRegistration *> *listenersMap;
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
  if (!self) return self;
  _listenersMap = [NSMutableDictionary dictionary];
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseRemoteConfigPlugin *instance = [FLTFirebaseRemoteConfigPlugin sharedInstance];

  // Setup Pigeon Host API instead of MethodChannel
  FirebaseRemoteConfigHostApiSetup([registrar messenger], instance);

  // Keep EventChannel for config updates
  FlutterEventChannel *eventChannel =
      [FlutterEventChannel eventChannelWithName:kFirebaseRemoteConfigUpdateChannelName
                                binaryMessenger:[registrar messenger]];
  [eventChannel setStreamHandler:instance];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:@LIBRARY_NAME withObject:@LIBRARY_VERSION];
  }
}

// Remove detachFromEngineForRegistrar as it's MethodChannel specific
// - (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
//   self.channel = nil;
// }

// Remove handleMethodCall and related types/methods
// - (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult { ... }
// - (void)setCustomSignals:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)ensureInitialized:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)activate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)getAll:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)fetch:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)getProperties:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)setDefaults:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)setConfigSettings:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }
// - (void)fetchAndActivate:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result { ... }


#pragma mark - FirebaseRemoteConfigHostApi implementation

- (void)activateAppName:(NSString *)appName
             completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  [remoteConfig activateWithCompletion:^(BOOL changed, NSError *error) {
    if (error != nil) {
      completion(nil, [FLTFirebaseRemoteConfigUtils flutterErrorFromNSError:error]);
    } else {
      completion(@(changed), nil);
    }
  }];
}

- (void)ensureInitializedAppName:(NSString *)appName
                      completion:(void (^)(FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  [remoteConfig ensureInitializedWithCompletionHandler:^(NSError *initializationError) {
    if (initializationError != nil) {
      completion([FLTFirebaseRemoteConfigUtils flutterErrorFromNSError:initializationError]);
    } else {
      completion(nil);
    }
  }];
}

- (void)fetchAndActivateAppName:(NSString *)appName
                     completion:
                         (void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  [remoteConfig fetchAndActivateWithCompletionHandler:^(
                    FIRRemoteConfigFetchAndActivateStatus status, NSError *error) {
    if (error != nil) {
      // Note: Retry logic removed as it was based on specific error code handling
      // which might differ or be handled differently by the native SDK now.
      // If issues arise, this might need revisiting.
      completion(nil, [FLTFirebaseRemoteConfigUtils flutterErrorFromNSError:error]);
    } else {
      // Pigeon expects a boolean indicating if activation happened.
      // FIRRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote implies activation.
      // FIRRemoteConfigFetchAndActivateStatusSuccessUsingPreFetchedData means already activated.
      // We return YES if fetched from remote, NO otherwise (matching old logic).
      BOOL activated = (status == FIRRemoteConfigFetchAndActivateStatusSuccessFetchedFromRemote);
      completion(@(activated), nil);
    }
  }];
}

- (void)fetchAppName:(NSString *)appName completion:(void (^)(FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
    if (error != nil) {
      completion([FLTFirebaseRemoteConfigUtils flutterErrorFromNSError:error]);
    } else {
      // Fetch doesn't return data, just status. Pigeon method expects void/error.
      completion(nil);
    }
  }];
}

- (void)getAllAppName:(NSString *)appName
           completion:(void (^)(NSDictionary<NSString *, PigeonFirebaseRemoteConfigValue *> *_Nullable,
                                FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  NSDictionary<NSString *, PigeonFirebaseRemoteConfigValue *> *parameters =
      [self getAllParametersForInstance:remoteConfig];
  completion(parameters, nil);
}

- (void)getPropertiesAppName:(NSString *)appName
                  completion:
                      (void (^)(PigeonConfigSettings *_Nullable, FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  PigeonConfigSettings *settings = [self configPropertiesForInstance:remoteConfig];
  completion(settings, nil);
}

- (void)setConfigSettingsAppName:(NSString *)appName
                        settings:(PigeonFirebaseSettings *)settings
                      completion:(void (^)(FlutterError *_Nullable))completion {
  FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
  // Pigeon uses int seconds, SDK uses double seconds.
  remoteConfigSettings.fetchTimeout = [settings.fetchTimeout doubleValue];
  remoteConfigSettings.minimumFetchInterval = [settings.minimumFetchInterval doubleValue];
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  [remoteConfig setConfigSettings:remoteConfigSettings];
  completion(nil);
}

- (void)setDefaultsAppName:(NSString *)appName
                  defaults:(NSDictionary<NSString *, id> *)defaults
                completion:(void (^)(FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  [remoteConfig setDefaults:defaults];
  completion(nil);
}

- (void)setCustomSignalsAppName:(NSString *)appName
                  customSignals:(NSDictionary<NSString *, id> *)customSignals
                     completion:(void (^)(FlutterError *_Nullable))completion {
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];

  [remoteConfig setCustomSignals:customSignals
                  withCompletion:^(NSError *_Nullable error) {
                    if (error != nil) {
                      completion([FLTFirebaseRemoteConfigUtils flutterErrorFromNSError:error]);
                    } else {
                      completion(nil);
                    }
                  }];
}


#pragma mark - Helper Methods (Adapting for Pigeon)

// Renamed from getFIRRemoteConfigFromArguments and takes appName directly
- (FIRRemoteConfig *_Nullable)getFIRRemoteConfigForAppName:(NSString *)appName {
  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appName];
  return [FIRRemoteConfig remoteConfigWithApp:app];
}

// Updated return type to use PigeonFirebaseRemoteConfigValue
- (NSDictionary<NSString *, PigeonFirebaseRemoteConfigValue *> *)getAllParametersForInstance:
    (FIRRemoteConfig *)remoteConfig {
  NSMutableSet *keySet = [[NSMutableSet alloc] init];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceStatic]];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceDefault]];
  [keySet addObjectsFromArray:[remoteConfig allKeysFromSource:FIRRemoteConfigSourceRemote]];

  NSMutableDictionary<NSString *, PigeonFirebaseRemoteConfigValue *> *parameters =
      [[NSMutableDictionary alloc] init];
  for (NSString *key in keySet) {
    parameters[key] = [self createPigeonRemoteConfigValue:[remoteConfig configValueForKey:key]];
  }
  return parameters;
}

// Renamed from createRemoteConfigValueDict and returns Pigeon type
- (PigeonFirebaseRemoteConfigValue *)createPigeonRemoteConfigValue:(FIRRemoteConfigValue *)remoteConfigValue {
  PigeonFirebaseRemoteConfigValue *value = [[PigeonFirebaseRemoteConfigValue alloc] init];
  value.value = [FlutterStandardTypedData typedDataWithBytes:[remoteConfigValue dataValue]];
  value.source = [self mapValueSource:[remoteConfigValue source]];
  return value;
}

// Updated return type to Pigeon enum Box
- (PigeonRemoteConfigFetchStatusBox *)mapLastFetchStatus:(FIRRemoteConfigFetchStatus)status {
  PigeonRemoteConfigFetchStatus pigeonStatus;
  switch (status) {
    case FIRRemoteConfigFetchStatusSuccess:
      pigeonStatus = PigeonRemoteConfigFetchStatusSuccess;
      break;
    case FIRRemoteConfigFetchStatusFailure:
      pigeonStatus = PigeonRemoteConfigFetchStatusFailure;
      break;
    case FIRRemoteConfigFetchStatusThrottled:
      pigeonStatus = PigeonRemoteConfigFetchStatusThrottle; // Corrected enum name
      break;
    case FIRRemoteConfigFetchStatusNoFetchYet:
      pigeonStatus = PigeonRemoteConfigFetchStatusNoFetchYet;
      break;
    default:
      // Map unexpected status to failure as a fallback
      pigeonStatus = PigeonRemoteConfigFetchStatusFailure;
      break;
  }
  return [PigeonRemoteConfigFetchStatusBox numberWithValue:pigeonStatus];
}

// Updated return type to Pigeon enum Box
- (PigeonValueSourceBox *)mapValueSource:(FIRRemoteConfigSource)source {
  PigeonValueSource pigeonSource;
  switch (source) {
    case FIRRemoteConfigSourceStatic:
      pigeonSource = PigeonValueSourceStatic;
      break;
    case FIRRemoteConfigSourceDefault:
      pigeonSource = PigeonValueSourceDefault;
      break;
    case FIRRemoteConfigSourceRemote:
      pigeonSource = PigeonValueSourceRemote;
      break;
    default:
      // Map unexpected source to static as a fallback
      pigeonSource = PigeonValueSourceStatic;
      break;
  }
  return [PigeonValueSourceBox numberWithValue:pigeonSource];
}

#pragma mark - FLTFirebasePlugin Methods (Keep as is)

- (void)cleanupWithCompletion {
  for (FIRConfigUpdateListenerRegistration *listener in self.listenersMap.allValues) {
    [listener remove];
  }
  [self.listenersMap removeAllObjects];
}

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  _fetchAndActivateRetry = false;
  [self cleanupWithCompletion];
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

// Updated return type to PigeonConfigSettings
- (PigeonConfigSettings *)configPropertiesForInstance:(FIRRemoteConfig *)remoteConfig {
  PigeonConfigSettings *settings = [[PigeonConfigSettings alloc] init];
  // Pigeon expects int seconds, SDK provides double seconds. Cast to long long for safety.
  settings.fetchTimeout = @((long long)[[remoteConfig configSettings] fetchTimeout]);
  settings.minimumFetchInterval = @((long long)[[remoteConfig configSettings] minimumFetchInterval]);
  settings.lastFetchTimeMillis =
      @((long long)([[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000)); // Needs ms
  settings.lastFetchStatus = [self mapLastFetchStatus:[remoteConfig lastFetchStatus]];
  return settings;
}

- (NSString *_Nonnull)firebaseLibraryName {
  return @LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return @LIBRARY_VERSION;
}

// Remove flutterChannelName as it's MethodChannel specific
// - (NSString *_Nonnull)flutterChannelName {
//  return kFirebaseRemoteConfigChannelName;
// }

#pragma mark - FlutterStreamHandler Methods (Keep as is for EventChannel)

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  NSString *appName = (NSString *)arguments[@"appName"];
  // arguments will be null on hot restart, so we will clean up listeners in
  // didReinitializeFirebaseCore()
  if (!appName) return nil;
  [self.listenersMap[appName] remove];
  [self.listenersMap removeObjectForKey:appName];
  return nil;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  // Note: Arguments might be structured differently if Pigeon handled streams.
  // Assuming the event channel setup remains the same for now.
  // Arguments should be a dictionary containing 'appName'.
  NSString *appName = nil;
   if ([arguments isKindOfClass:[NSDictionary class]]) {
      appName = arguments[@"appName"];
  }

  if (!appName) {
      // Handle error: appName is required.
      return [FlutterError errorWithCode:@"invalid-argument" message:@"appName is required" details:nil];
  }

  // Use the updated helper method
  FIRRemoteConfig *remoteConfig = [self getFIRRemoteConfigForAppName:appName];
  if (!remoteConfig) {
      // Handle error: Could not get Remote Config instance for appName
      return [FlutterError errorWithCode:@"instance-not-found" message:@"Remote Config instance not found for the provided app name." details:nil];
  }

  // Check if a listener already exists for this appName
  if (self.listenersMap[appName]) {
    // Optional: Cancel existing listener or return an error, depending on desired behavior.
    // For now, we'll assume replacing the listener is okay.
    [self.listenersMap[appName] remove];
  }

  FIRConfigUpdateListenerRegistration *listener =
      [remoteConfig addOnConfigUpdateListener:^(FIRRemoteConfigUpdate *_Nullable configUpdate,
                                                NSError *_Nullable error) {
        if (error) {
          // Handle the error
          NSLog(@"Error while receiving remote config update: %@", error.localizedDescription);
          return;
        }
        if (configUpdate) {
          events([configUpdate.updatedKeys allObjects]);
        }
      }];
  return nil;
}

@end
