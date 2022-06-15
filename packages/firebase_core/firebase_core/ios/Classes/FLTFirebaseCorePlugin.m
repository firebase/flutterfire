// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseCorePlugin.h"
#import "FLTFirebasePluginRegistry.h"
#import "messages.g.h"

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
  FLTFirebaseCorePlugin *sharedInstance = [self sharedInstance];
  [registrar publish:sharedInstance];
  FirebaseCoreHostApiSetup(registrar.messenger, sharedInstance);
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

- (PigeonFirebaseOptions *)optionsFromFIROptions:(FIROptions *)options {
    PigeonFirebaseOptions *pigeonOptions = [PigeonFirebaseOptions alloc];
    pigeonOptions.apiKey = (id)options.APIKey ?: [NSNull null];
    pigeonOptions.appId = (id)options.googleAppID ?: [NSNull null];
    pigeonOptions.messagingSenderId = (id)options.GCMSenderID ?: [NSNull null];
    pigeonOptions.projectId = (id)options.projectID ?: [NSNull null];
    pigeonOptions.databaseURL = (id)options.databaseURL ?: [NSNull null];
    pigeonOptions.storageBucket = (id)options.storageBucket ?: [NSNull null];
    pigeonOptions.trackingId = (id)options.trackingID ?: [NSNull null];
    pigeonOptions.deepLinkURLScheme = (id)options.deepLinkURLScheme ?: [NSNull null];
    pigeonOptions.androidClientId = (id)options.androidClientID ?: [NSNull null];
    pigeonOptions.iosBundleId = (id)options.bundleID ?: [NSNull null];
    pigeonOptions.iosClientId = (id)options.clientID ?: [NSNull null];
    pigeonOptions.appGroupId = (id)options.appGroupID ?: [NSNull null];
    return pigeonOptions;
}

- (PigeonInitializeReponse *)initializeResponseFromFIRApp:(FIRApp *)firebaseApp {
  NSString *appNameDart = [FLTFirebasePlugin firebaseAppNameFromIosName:firebaseApp.name];
  PigeonInitializeReponse *response = [PigeonInitializeReponse alloc];
  response.name = appNameDart;
  response.options =[self optionsFromFIROptions:firebaseApp.options];
  response.isAutomaticDataCollectionEnabled = @(firebaseApp.isDataCollectionDefaultEnabled);
  response.pluginConstants = [[FLTFirebasePluginRegistry sharedInstance] pluginConstantsForFIRApp:firebaseApp];

  return response;
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

- (void)initializeAppAppName:(nonnull NSString *)appName initializeAppRequest:(nonnull PigeonFirebaseOptions *)initializeAppRequest completion:(nonnull void (^)(PigeonInitializeReponse * _Nullable, FlutterError * _Nullable))completion {
    NSString *appNameIos = [FLTFirebasePlugin firebaseAppNameFromDartName:appName];

    if ([FLTFirebasePlugin firebaseAppNamed:appNameIos]) {
      completion([self initializeResponseFromFIRApp:[FLTFirebasePlugin firebaseAppNamed:appNameIos]], nil);
      return;
    }

    NSString *appId = initializeAppRequest.appId;
    NSString *messagingSenderId = initializeAppRequest.messagingSenderId;
    FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:appId
                                                      GCMSenderID:messagingSenderId];

    options.APIKey = initializeAppRequest.apiKey;
    options.projectID = initializeAppRequest.projectId;


    // kFirebaseOptionsDatabaseUrl
    if (![initializeAppRequest.databaseURL isEqual:[NSNull null]]) {
      options.databaseURL = initializeAppRequest.databaseURL;
    }

    // kFirebaseOptionsStorageBucket
    if (![options.storageBucket isEqual:[NSNull null]]) {
      options.storageBucket = initializeAppRequest.storageBucket;
    }

    // kFirebaseOptionsTrackingId
    if (![initializeAppRequest.trackingId isEqual:[NSNull null]]) {
      options.trackingID = initializeAppRequest.trackingId;
    }

    // kFirebaseOptionsDeepLinkURLScheme
    if (![initializeAppRequest.deepLinkURLScheme isEqual:[NSNull null]]) {
      options.deepLinkURLScheme = initializeAppRequest.deepLinkURLScheme;
    }

    // kFirebaseOptionsAndroidClientId
    if (![initializeAppRequest.androidClientId isEqual:[NSNull null]]) {
      options.androidClientID = initializeAppRequest.androidClientId;
    }

    // kFirebaseOptionsIosBundleId
    if (![initializeAppRequest.iosBundleId isEqual:[NSNull null]]) {
      options.bundleID = initializeAppRequest.iosBundleId;
    }

    // kFirebaseOptionsIosClientId
    if (![initializeAppRequest.iosClientId isEqual:[NSNull null]]) {
      options.clientID = initializeAppRequest.iosClientId;
    }

    // kFirebaseOptionsAppGroupId
    if (![initializeAppRequest.appGroupId isEqual:[NSNull null]]) {
      options.appGroupID = initializeAppRequest.appGroupId;
    }

    [FIRApp configureWithName:appNameIos options:options];

    completion([self initializeResponseFromFIRApp:[FIRApp appNamed:appNameIos]], nil);
}

- (void)initializeCoreWithCompletion:(nonnull void (^)(NSArray<PigeonInitializeReponse *> * _Nullable, FlutterError * _Nullable))completion {
    NSLog(@"initializeCoreWithCompletion");
}

- (void)optionsFromResourceWithCompletion:(nonnull void (^)(PigeonFirebaseOptions * _Nullable, FlutterError * _Nullable))completion {
    NSLog(@"optionsFromResourceWithCompletion");
}

@end
