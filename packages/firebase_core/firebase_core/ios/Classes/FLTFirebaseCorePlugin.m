// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseCorePlugin.h"
#import "FLTFirebasePluginRegistry.h"

// Flutter method channel name.
NSString *const kFLTFirebaseCoreChannelName = @"plugins.flutter.io/firebase_core";

// Firebase method names.
NSString *const kMethodCoreInitializeApp = @"Firebase#initializeApp";
NSString *const kMethodCoreInitializeCore = @"Firebase#initializeCore";

// FirebaseApp method names.
NSString *const kMethodAppDelete = @"FirebaseApp#delete";
NSString *const kMethodAppSetAutomaticDataCollectionEnabled =
    @"FirebaseApp#setAutomaticDataCollectionEnabled";
NSString *const kMethodAppSetAutomaticResourceManagementEnabled =
    @"FirebaseApp#setAutomaticResourceManagementEnabled";

// Method call argument keys.
NSString *const kName = @"name";
NSString *const kAppName = @"appName";
NSString *const kOptions = @"options";
NSString *const kEnabled = @"enabled";
NSString *const kPluginConstants = @"pluginConstants";
NSString *const kIsAutomaticDataCollectionEnabled = @"isAutomaticDataCollectionEnabled";
NSString *const kFirebaseOptionsApiKey = @"apiKey";
NSString *const kFirebaseOptionsAppId = @"appId";
NSString *const kFirebaseOptionsMessagingSenderId = @"messagingSenderId";
NSString *const kFirebaseOptionsProjectId = @"projectId";
NSString *const kFirebaseOptionsDatabaseUrl = @"databaseURL";
NSString *const kFirebaseOptionsStorageBucket = @"storageBucket";
NSString *const kFirebaseOptionsTrackingId = @"trackingId";
NSString *const kFirebaseOptionsDeepLinkURLScheme = @"deepLinkURLScheme";
NSString *const kFirebaseOptionsAndroidClientId = @"androidClientId";
NSString *const kFirebaseOptionsIosBundleId = @"iosBundleId";
NSString *const kFirebaseOptionsIosClientId = @"iosClientId";
NSString *const kFirebaseOptionsAppGroupId = @"appGroupId";

@implementation FLTFirebaseCorePlugin {
  BOOL _coreInitialized;
}

#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseCoreChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseCorePlugin *sharedInstance = [self sharedInstance];
  [registrar addMethodCallDelegate:sharedInstance channel:channel];
}

// Returns a singleton instance of the Firebase Core plugin.
+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseCorePlugin *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseCorePlugin alloc] init];
    // Register with the Flutter Firebase plugin registry.
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];

    // Initialize default Firebase app, but only if the plist file options exist.
    //  - If it is missing then there is no default app discovered in Dart and Dart throws an error.
    //  - Without this the iOS/MacOS app would crash immediately on calling [FIRApp configure]
    //  without
    //    providing helpful context about the crash to the user.
    //
    // Default app exists check is for backwards compatibility of legacy FlutterFire plugins that
    // call [FIRApp configure]; themselves internally.
    FIROptions *options = [FIROptions defaultOptions];
    if (options != nil && [FIRApp allApps][@"__FIRAPP_DEFAULT"] == nil) {
      [FIRApp configureWithOptions:options];
    }
  });

  return instance;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nonnull code, NSString *_Nonnull message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                            message:message
                                                    optionalDetails:details
                                                 andOptionalNSError:error]);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([kMethodCoreInitializeApp isEqualToString:call.method]) {
    [self initializeApp:call.arguments withMethodCallResult:methodCallResult];
  } else if ([kMethodCoreInitializeCore isEqualToString:call.method]) {
    [self initializeCoreWithMethodCallResult:methodCallResult];
  } else if ([kMethodAppSetAutomaticDataCollectionEnabled isEqualToString:call.method]) {
    [self setAutomaticDataCollectionEnabled:call.arguments withMethodCallResult:methodCallResult];
  } else if ([kMethodAppSetAutomaticResourceManagementEnabled isEqualToString:call.method]) {
    // Unsupported on iOS/MacOS.
    methodCallResult.success(nil);
  } else if ([kMethodAppDelete isEqualToString:call.method]) {
    [self deleteApp:call.arguments withMethodCallResult:methodCallResult];
  } else {
    methodCallResult.success(FlutterMethodNotImplemented);
  }
}

#pragma mark - API

- (void)initializeApp:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *appNameIos = [FLTFirebasePlugin firebaseAppNameFromDartName:arguments[kAppName]];

  if ([FLTFirebasePlugin firebaseAppNamed:appNameIos]) {
    result.success([self dictionaryFromFIRApp:[FLTFirebasePlugin firebaseAppNamed:appNameIos]]);
    return;
  }

  NSDictionary *optionsDictionary = arguments[kOptions];
  NSString *appId = optionsDictionary[kFirebaseOptionsAppId];
  NSString *messagingSenderId = optionsDictionary[kFirebaseOptionsMessagingSenderId];
  FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:appId
                                                    GCMSenderID:messagingSenderId];

  // kFirebaseOptionsApiKey
  if (![optionsDictionary[kFirebaseOptionsApiKey] isEqual:[NSNull null]]) {
    options.APIKey = optionsDictionary[kFirebaseOptionsApiKey];
  }

  // kFirebaseOptionsProjectId
  if (![optionsDictionary[kFirebaseOptionsProjectId] isEqual:[NSNull null]]) {
    options.projectID = optionsDictionary[kFirebaseOptionsProjectId];
  }

  // kFirebaseOptionsDatabaseUrl
  if (![optionsDictionary[kFirebaseOptionsDatabaseUrl] isEqual:[NSNull null]]) {
    options.databaseURL = optionsDictionary[kFirebaseOptionsDatabaseUrl];
  }

  // kFirebaseOptionsStorageBucket
  if (![optionsDictionary[kFirebaseOptionsStorageBucket] isEqual:[NSNull null]]) {
    options.storageBucket = optionsDictionary[kFirebaseOptionsStorageBucket];
  }

  // kFirebaseOptionsTrackingId
  if (![optionsDictionary[kFirebaseOptionsTrackingId] isEqual:[NSNull null]]) {
    options.trackingID = optionsDictionary[kFirebaseOptionsTrackingId];
  }

  // kFirebaseOptionsDeepLinkURLScheme
  if (![optionsDictionary[kFirebaseOptionsDeepLinkURLScheme] isEqual:[NSNull null]]) {
    options.deepLinkURLScheme = optionsDictionary[kFirebaseOptionsDeepLinkURLScheme];
  }

  // kFirebaseOptionsAndroidClientId
  if (![optionsDictionary[kFirebaseOptionsAndroidClientId] isEqual:[NSNull null]]) {
    options.androidClientID = optionsDictionary[kFirebaseOptionsAndroidClientId];
  }

  // kFirebaseOptionsIosBundleId
  if (![optionsDictionary[kFirebaseOptionsIosBundleId] isEqual:[NSNull null]]) {
    options.bundleID = optionsDictionary[kFirebaseOptionsIosBundleId];
  }

  // kFirebaseOptionsIosClientId
  if (![optionsDictionary[kFirebaseOptionsIosClientId] isEqual:[NSNull null]]) {
    options.clientID = optionsDictionary[kFirebaseOptionsIosClientId];
  }

  // kFirebaseOptionsAppGroupId
  if (![optionsDictionary[kFirebaseOptionsAppGroupId] isEqual:[NSNull null]]) {
    options.appGroupID = optionsDictionary[kFirebaseOptionsAppGroupId];
  }

  [FIRApp configureWithName:appNameIos options:options];

  result.success([self dictionaryFromFIRApp:[FIRApp appNamed:appNameIos]]);
}

- (void)initializeCoreWithMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  void (^initializeCoreBlock)(void) = ^void() {
    NSDictionary<NSString *, FIRApp *> *firebaseApps = [FIRApp allApps];
    NSMutableArray *firebaseAppsArray = [NSMutableArray arrayWithCapacity:firebaseApps.count];

    for (NSString *appName in firebaseApps) {
      FIRApp *firebaseApp = firebaseApps[appName];
      [firebaseAppsArray addObject:[self dictionaryFromFIRApp:firebaseApp]];
    }

    result.success(firebaseAppsArray);
  };

  if (!_coreInitialized) {
    _coreInitialized = YES;
    initializeCoreBlock();
  } else {
    [[FLTFirebasePluginRegistry sharedInstance] didReinitializeFirebaseCore:initializeCoreBlock];
  }
}

- (void)deleteApp:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *appName = arguments[kAppName];
  FIRApp *firebaseApp = [FLTFirebasePlugin firebaseAppNamed:appName];

  if (firebaseApp) {
    [firebaseApp deleteApp:^(BOOL success) {
      if (success) {
        result.success(nil);
      } else {
        result.error(@"delete-failed", @"Failed to delete a Firebase app instance.", nil, nil);
      }
    }];
  } else {
    result.success(nil);
  }
}

- (void)setAutomaticDataCollectionEnabled:(id)arguments
                     withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *appName = arguments[kAppName];
  BOOL dataCollectionEnabled = [arguments[kEnabled] boolValue];

  FIRApp *firebaseApp = [FLTFirebasePlugin firebaseAppNamed:appName];
  if (firebaseApp) {
    [firebaseApp setDataCollectionDefaultEnabled:dataCollectionEnabled];
  }

  result.success(nil);
}

#pragma mark - Helpers

- (NSDictionary *)dictionaryFromFIROptions:(FIROptions *)options {
  return @{
    kFirebaseOptionsApiKey : (id)options.APIKey ?: [NSNull null],
    kFirebaseOptionsAppId : (id)options.googleAppID ?: [NSNull null],
    kFirebaseOptionsMessagingSenderId : (id)options.GCMSenderID ?: [NSNull null],
    kFirebaseOptionsProjectId : (id)options.projectID ?: [NSNull null],
    kFirebaseOptionsDatabaseUrl : (id)options.databaseURL ?: [NSNull null],
    kFirebaseOptionsStorageBucket : (id)options.storageBucket ?: [NSNull null],
    kFirebaseOptionsTrackingId : (id)options.trackingID ?: [NSNull null],
    kFirebaseOptionsDeepLinkURLScheme : (id)options.deepLinkURLScheme ?: [NSNull null],
    kFirebaseOptionsAndroidClientId : (id)options.androidClientID ?: [NSNull null],
    kFirebaseOptionsIosBundleId : (id)options.bundleID ?: [NSNull null],
    kFirebaseOptionsIosClientId : (id)options.clientID ?: [NSNull null],
    kFirebaseOptionsAppGroupId : (id)options.appGroupID ?: [NSNull null],
  };
}

- (NSDictionary *)dictionaryFromFIRApp:(FIRApp *)firebaseApp {
  NSString *appNameDart = [FLTFirebasePlugin firebaseAppNameFromIosName:firebaseApp.name];

  return @{
    kName : appNameDart,
    kOptions : [self dictionaryFromFIROptions:firebaseApp.options],
    kIsAutomaticDataCollectionEnabled : @(firebaseApp.isDataCollectionDefaultEnabled),
    kPluginConstants :
        [[FLTFirebasePluginRegistry sharedInstance] pluginConstantsForFIRApp:firebaseApp]
  };
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  completion();
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{};
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseCoreChannelName;
}

@end
