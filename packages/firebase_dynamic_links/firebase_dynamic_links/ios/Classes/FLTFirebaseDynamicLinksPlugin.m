// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <Firebase/Firebase.h>
#import <TargetConditionals.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "FLTFirebaseDynamicLinksPlugin.h"

NSString *const kFLTFirebaseDynamicLinksChannelName = @"plugins.flutter.io/firebase_dynamic_links";
NSString *const kDLAppName = @"appName";
NSString *const kUrl = @"url";
NSString *const kCode = @"code";
NSString *const kMessage = @"message";
NSString *const kDynamicLinkParametersOptions = @"dynamicLinkParametersOptions";
NSString *const kDefaultAppName = @"[DEFAULT]";

static NSMutableDictionary *getDictionaryFromDynamicLink(FIRDynamicLink *dynamicLink) {
  if (dynamicLink != nil) {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"link"] = dynamicLink.url.absoluteString;

    NSMutableDictionary *iosData = [[NSMutableDictionary alloc] init];
    if (dynamicLink.minimumAppVersion) {
      iosData[@"minimumVersion"] = dynamicLink.minimumAppVersion;
    }

    if (dynamicLink.matchType == FIRDLMatchTypeNone) {
      iosData[@"matchType"] = [NSNumber numberWithInt:0];
    }

    if (dynamicLink.matchType == FIRDLMatchTypeWeak) {
      iosData[@"matchType"] = [NSNumber numberWithInt:1];
    }

    if (dynamicLink.matchType == FIRDLMatchTypeDefault) {
      iosData[@"matchType"] = [NSNumber numberWithInt:2];
    }

    if (dynamicLink.matchType == FIRDLMatchTypeUnique) {
      iosData[@"matchType"] = [NSNumber numberWithInt:3];
    }

    dictionary[@"utmParameters"] = dynamicLink.utmParametersDictionary;
    dictionary[@"ios"] = iosData;
    return dictionary;
  } else {
    return nil;
  }
}

static NSDictionary *getDictionaryFromNSError(NSError *error) {
  NSString *code = @"unknown";
  NSString *message = @"An unknown error has occurred.";
  if (error == nil) {
    return @{
      kCode : code,
      kMessage : message,
      @"additionalData" : @{},
    };
  }

  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  dictionary[kCode] = [NSString stringWithFormat:@"%d", (int)error.code];
  dictionary[kMessage] = [error localizedDescription];
  id additionalData = [NSMutableDictionary dictionary];

  if ([error userInfo] != nil) {
    additionalData = [error userInfo];
  }

  return @{
    kCode : code,
    kMessage : message,
    @"additionalData" : additionalData,
  };
}

@implementation FLTFirebaseDynamicLinksPlugin {
  NSObject<FlutterBinaryMessenger> *_binaryMessenger;
}

#pragma mark - FlutterPlugin

- (instancetype)init:(NSObject<FlutterBinaryMessenger> *)messenger
         withChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:self];
    _binaryMessenger = messenger;
    _channel = channel;
    _initiated = NO;
  }
  return self;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseDynamicLinksChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseDynamicLinksPlugin *instance =
      [[FLTFirebaseDynamicLinksPlugin alloc] init:registrar.messenger withChannel:channel];

  [registrar addMethodCallDelegate:instance channel:channel];

#if TARGET_OS_OSX
  // Publish does not exist on MacOS version of FlutterPluginRegistrar.
  // FlutterPluginRegistrar. (https://github.com/flutter/flutter/issues/41471)
#else
  [registrar publish:instance];
  [registrar addApplicationDelegate:instance];
#endif
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
  if (completion != nil) completion();
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self cleanupWithCompletion:nil];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  FLTFirebaseMethodCallErrorBlock errorBlock = ^(
      NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
      NSError *_Nullable error) {
    NSMutableDictionary *temp;
    if (code == nil) {
      NSDictionary *errorDetails = getDictionaryFromNSError(error);
      code = errorDetails[kCode];
      message = errorDetails[kMessage];

      if (errorDetails[@"additionalData"] != nil) {
        temp = [errorDetails[@"additionalData"] mutableCopy];
      } else {
        temp = [errorDetails mutableCopy];
      }

      // "NSErrorFailingURLStringKey" key does not work for removing this object. So we use our own
      // String to retrieve
      if (temp[@"NSErrorFailingURLKey"] != nil) {
        [temp removeObjectForKey:@"NSErrorFailingURLKey"];
      }
      if (temp[NSUnderlyingErrorKey] != nil) {
        [temp removeObjectForKey:NSUnderlyingErrorKey];
      }

      if ([errorDetails[kMessage] containsString:@"An unknown error has occurred"] &&
          [temp[NSLocalizedDescriptionKey] containsString:@"The request timed out"]) {
        message = temp[NSLocalizedDescriptionKey];
      }

      if (errorDetails[@"additionalData"][NSLocalizedFailureReasonErrorKey] != nil) {
        // This stops an uncaught type cast exception in dart
        [temp removeObjectForKey:NSLocalizedFailureReasonErrorKey];
        // provides a useful message to the user. e.g. "Universal link URL could not be parsed".
        if ([message containsString:@"unknown error"]) {
          message = errorDetails[@"additionalData"][NSLocalizedFailureReasonErrorKey];
        }
      }

      details = temp;
    } else {
      details = @{
        kCode : code,
        kMessage : message,
        @"additionalData" : @{},
      };
    }

    if ([@"unknown" isEqualToString:code]) {
      NSLog(@"FLTFirebaseDynamicLinks: An error occurred while calling method %@, errorOrNil => %@",
            call.method, [error userInfo]);
    }

    result([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                 message:message
                                         optionalDetails:details
                                      andOptionalNSError:error]);
  };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:result andErrorBlock:errorBlock];

  NSString *appName = call.arguments[kDLAppName];
  if (appName != nil && ![appName isEqualToString:kDefaultAppName]) {
    // TODO - document iOS default app only
    NSLog(@"FLTFirebaseDynamicLinks: iOS plugin only supports the Firebase default app");
  }

  if ([@"FirebaseDynamicLinks#buildLink" isEqualToString:call.method]) {
    [self buildLink:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseDynamicLinks#buildShortLink" isEqualToString:call.method]) {
    [self buildShortLink:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebaseDynamicLinks#getInitialLink" isEqualToString:call.method]) {
    [self getInitialLink:methodCallResult];
  } else if ([@"FirebaseDynamicLinks#getDynamicLink" isEqualToString:call.method]) {
    [self getDynamicLink:call.arguments withMethodCallResult:methodCallResult];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase Dynamic Links API

- (void)buildLink:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDynamicLinkComponents *components = [self setupParameters:arguments];
  result.success([components.url absoluteString]);
}

- (void)buildShortLink:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRDynamicLinkComponentsOptions *options = [self setupOptions:arguments];
  NSString *longDynamicLink = arguments[@"longDynamicLink"];

  if (longDynamicLink != nil) {
    NSURL *url = [NSURL URLWithString:longDynamicLink];
    [FIRDynamicLinkComponents
        shortenURL:url
           options:options
        completion:^(NSURL *_Nullable shortURL, NSArray<NSString *> *_Nullable warnings,
                     NSError *_Nullable error) {
          if (error != nil) {
            result.error(nil, nil, nil, error);
          } else {
            if (warnings == nil) {
              warnings = [NSMutableArray array];
            }

            result.success(@{
              kUrl : [shortURL absoluteString],
              @"warnings" : warnings,
            });
          }
        }];
  } else {
    FIRDynamicLinkComponents *components = [self setupParameters:arguments];
    components.options = options;
    [components
        shortenWithCompletion:^(NSURL *_Nullable shortURL, NSArray<NSString *> *_Nullable warnings,
                                NSError *_Nullable error) {
          if (error != nil) {
            result.error(nil, nil, nil, error);
          } else {
            if (warnings == nil) {
              warnings = [NSMutableArray array];
            }

            result.success(@{
              kUrl : [shortURL absoluteString],
              @"warnings" : warnings,
            });
          }
        }];
  }
}

- (void)getInitialLink:(FLTFirebaseMethodCallResult *)result {
  if (_initiated == YES) {
    result.success(nil);
    return;
  }

  NSMutableDictionary *dict = getDictionaryFromDynamicLink(_initialLink);
  if (dict == nil && self.initialError != nil) {
    result.error(nil, nil, nil, self.initialError);
  } else {
    result.success(dict);
  }
  _initiated = YES;
}

- (void)getDynamicLink:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSURL *shortLink = [NSURL URLWithString:arguments[kUrl]];
  FIRDynamicLinkUniversalLinkHandler completion =
      ^(FIRDynamicLink *_Nullable dynamicLink, NSError *_Nullable error) {
        if (error) {
          result.error(nil, nil, nil, error);
        } else {
          result.success(getDictionaryFromDynamicLink(dynamicLink));
        }
      };
  [[FIRDynamicLinks dynamicLinks] handleUniversalLink:shortLink completion:completion];
}

#pragma mark - AppDelegate
// Handle links received through your app's custom URL scheme. Called when your
// app receives a link and your app is opened for the first time after installation.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  [self checkForDynamicLink:url];
  // Results of this are ORed and NO doesn't affect other delegate interceptors' result.
  return NO;
}

// Handle links received as Universal Links when the app is already installed (on iOS 9 and newer).
- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(nonnull void (^)(NSArray *_Nullable))restorationHandler {
  __block BOOL retried = NO;
  void (^completionBlock)(FIRDynamicLink *_Nullable dynamicLink, NSError *_Nullable error);

  void (^__block __weak weakCompletionBlock)(FIRDynamicLink *_Nullable dynamicLink,
                                             NSError *_Nullable error);
  weakCompletionBlock = completionBlock =
      ^(FIRDynamicLink *_Nullable dynamicLink, NSError *_Nullable error) {
        if (!error && dynamicLink && dynamicLink.url) {
          [self onDeepLinkResult:dynamicLink error:nil];
        }

        if (!error && dynamicLink && !dynamicLink.url) {
          NSLog(@"FLTFirebaseDynamicLinks: The url has not been supplied with the dynamic link."
                @"Please try opening your app with the long dynamic link to see if that works");
        }
        // Per Apple Tech Support, a network failure could occur when returning from background on
        // iOS 12. https://github.com/AFNetworking/AFNetworking/issues/4279#issuecomment-447108981
        // So we'll retry the request once
        if (error && !retried && [NSPOSIXErrorDomain isEqualToString:error.domain] &&
            error.code == 53) {
          retried = YES;
          [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                   completion:weakCompletionBlock];
        }

        if (error && retried) {
          // Need to update any event channel the universal link failed
          [self onDeepLinkResult:nil error:error];
        }
      };

  return [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                  completion:completionBlock];
}

#pragma mark - Utilities

- (void)checkForDynamicLink:(NSURL *)url {
  FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
  if (dynamicLink) {
    [self onDeepLinkResult:dynamicLink error:nil];
  }
}

// Used to action events from firebase-ios-sdk custom & universal dynamic link event listeners
- (void)onDeepLinkResult:(FIRDynamicLink *_Nullable)dynamicLink error:(NSError *_Nullable)error {
  if (error) {
    if (_initialLink == nil) {
      // store initial error to pass back to user if getInitialLink is called
      _initialError = error;
    }

    NSDictionary *errorDetails = getDictionaryFromNSError(error);

    FlutterError *flutterError =
        [FLTFirebasePlugin createFlutterErrorFromCode:errorDetails[kCode]
                                              message:errorDetails[kMessage]
                                      optionalDetails:errorDetails
                                   andOptionalNSError:error];

    NSLog(@"FLTFirebaseDynamicLinks: Unknown error occurred when attempting to handle a dynamic "
          @"link: %@",
          flutterError);

    [_channel invokeMethod:@"FirebaseDynamicLink#onLinkError" arguments:flutterError];
  } else {
    NSMutableDictionary *dictionary = getDictionaryFromDynamicLink(dynamicLink);
    if (dictionary != nil) {
      [_channel invokeMethod:@"FirebaseDynamicLink#onLinkSuccess" arguments:dictionary];
    }
  }

  if (_initialLink == nil && _initiated == NO && dynamicLink.url != nil) {
    _initialLink = dynamicLink;
  }

  if (dynamicLink.url != nil) {
    _latestLink = dynamicLink;
  }
}

- (FIRDynamicLinkComponentsOptions *)setupOptions:(NSDictionary *)arguments {
  FIRDynamicLinkComponentsOptions *options = [FIRDynamicLinkComponentsOptions options];

  NSNumber *shortDynamicLinkPathLength = arguments[@"shortLinkType"];
  if (![shortDynamicLinkPathLength isEqual:[NSNull null]]) {
    switch (shortDynamicLinkPathLength.intValue) {
      case 0:
        options.pathLength = FIRShortDynamicLinkPathLengthUnguessable;
        break;
      case 1:
        options.pathLength = FIRShortDynamicLinkPathLengthShort;
        break;
      default:
        break;
    }
  }

  return options;
}

- (FIRDynamicLinkComponents *)setupParameters:(NSDictionary *)arguments {
  NSURL *link = [NSURL URLWithString:arguments[@"link"]];
  NSString *uriPrefix = arguments[@"uriPrefix"];

  FIRDynamicLinkComponents *components = [FIRDynamicLinkComponents componentsWithLink:link
                                                                      domainURIPrefix:uriPrefix];

  if (![arguments[@"androidParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"androidParameters"];

    FIRDynamicLinkAndroidParameters *androidParams =
        [FIRDynamicLinkAndroidParameters parametersWithPackageName:params[@"packageName"]];

    NSString *fallbackUrl = params[@"fallbackUrl"];
    NSNumber *minimumVersion = params[@"minimumVersion"];

    if (![fallbackUrl isEqual:[NSNull null]])
      androidParams.fallbackURL = [NSURL URLWithString:fallbackUrl];
    if (![minimumVersion isEqual:[NSNull null]])
      androidParams.minimumVersion = ((NSNumber *)minimumVersion).integerValue;

    components.androidParameters = androidParams;
  }

  components.options = [self setupOptions:arguments];

  if (![arguments[@"googleAnalyticsParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"googleAnalyticsParameters"];

    FIRDynamicLinkGoogleAnalyticsParameters *googleAnalyticsParameters =
        [FIRDynamicLinkGoogleAnalyticsParameters parameters];

    NSString *campaign = params[@"campaign"];
    NSString *content = params[@"content"];
    NSString *medium = params[@"medium"];
    NSString *source = params[@"source"];
    NSString *term = params[@"term"];

    if (![campaign isEqual:[NSNull null]]) googleAnalyticsParameters.campaign = campaign;
    if (![content isEqual:[NSNull null]]) googleAnalyticsParameters.content = content;
    if (![medium isEqual:[NSNull null]]) googleAnalyticsParameters.medium = medium;
    if (![source isEqual:[NSNull null]]) googleAnalyticsParameters.source = source;
    if (![term isEqual:[NSNull null]]) googleAnalyticsParameters.term = term;

    components.analyticsParameters = googleAnalyticsParameters;
  }

  if (![arguments[@"iosParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"iosParameters"];

    FIRDynamicLinkIOSParameters *iosParameters =
        [FIRDynamicLinkIOSParameters parametersWithBundleID:params[@"bundleId"]];

    NSString *appStoreID = params[@"appStoreId"];
    NSString *customScheme = params[@"customScheme"];
    NSString *fallbackURL = params[@"fallbackUrl"];
    NSString *iPadBundleID = params[@"ipadBundleId"];
    NSString *iPadFallbackURL = params[@"ipadFallbackUrl"];
    NSString *minimumAppVersion = params[@"minimumVersion"];

    if (![appStoreID isEqual:[NSNull null]]) iosParameters.appStoreID = appStoreID;
    if (![customScheme isEqual:[NSNull null]]) iosParameters.customScheme = customScheme;
    if (![fallbackURL isEqual:[NSNull null]])
      iosParameters.fallbackURL = [NSURL URLWithString:fallbackURL];
    if (![iPadBundleID isEqual:[NSNull null]]) iosParameters.iPadBundleID = iPadBundleID;
    if (![iPadFallbackURL isEqual:[NSNull null]])
      iosParameters.iPadFallbackURL = [NSURL URLWithString:iPadFallbackURL];
    if (![minimumAppVersion isEqual:[NSNull null]])
      iosParameters.minimumAppVersion = minimumAppVersion;

    components.iOSParameters = iosParameters;
  }

  if (![arguments[@"itunesConnectAnalyticsParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"itunesConnectAnalyticsParameters"];

    FIRDynamicLinkItunesConnectAnalyticsParameters *itunesConnectAnalyticsParameters =
        [FIRDynamicLinkItunesConnectAnalyticsParameters parameters];

    NSString *affiliateToken = params[@"affiliateToken"];
    NSString *campaignToken = params[@"campaignToken"];
    NSString *providerToken = params[@"providerToken"];

    if (![affiliateToken isEqual:[NSNull null]])
      itunesConnectAnalyticsParameters.affiliateToken = affiliateToken;
    if (![campaignToken isEqual:[NSNull null]])
      itunesConnectAnalyticsParameters.campaignToken = campaignToken;
    if (![providerToken isEqual:[NSNull null]])
      itunesConnectAnalyticsParameters.providerToken = providerToken;

    components.iTunesConnectParameters = itunesConnectAnalyticsParameters;
  }

  if (![arguments[@"navigationInfoParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"navigationInfoParameters"];

    FIRDynamicLinkNavigationInfoParameters *navigationInfoParameters =
        [FIRDynamicLinkNavigationInfoParameters parameters];

    NSNumber *forcedRedirectEnabled = params[@"forcedRedirectEnabled"];
    if (![forcedRedirectEnabled isEqual:[NSNull null]])
      navigationInfoParameters.forcedRedirectEnabled = [forcedRedirectEnabled boolValue];

    components.navigationInfoParameters = navigationInfoParameters;
  }

  if (![arguments[@"socialMetaTagParameters"] isEqual:[NSNull null]]) {
    NSDictionary *params = arguments[@"socialMetaTagParameters"];

    FIRDynamicLinkSocialMetaTagParameters *socialMetaTagParameters =
        [FIRDynamicLinkSocialMetaTagParameters parameters];

    NSString *descriptionText = params[@"description"];
    NSString *imageURL = params[@"imageUrl"];
    NSString *title = params[@"title"];

    if (![descriptionText isEqual:[NSNull null]])
      socialMetaTagParameters.descriptionText = descriptionText;
    if (![imageURL isEqual:[NSNull null]])
      socialMetaTagParameters.imageURL = [NSURL URLWithString:imageURL];
    if (![title isEqual:[NSNull null]]) socialMetaTagParameters.title = title;

    components.socialMetaTagParameters = socialMetaTagParameters;
  }

  return components;
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  [self cleanupWithCompletion:completion];
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
  return kFLTFirebaseDynamicLinksChannelName;
}

@end
