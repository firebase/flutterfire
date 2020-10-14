// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <FirebaseMessaging/NSError+FIRMessaging.h>
#import <GoogleUtilities/GULAppDelegateSwizzler.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>
#import <objc/message.h>

#import "FLTFirebaseMessagingPlugin.h"
#import "Runner/GeneratedPluginRegistrant.h"

NSString *const kFLTFirebaseMessagingChannelName = @"plugins.flutter.io/firebase_messaging";
NSString *const kFLTFirebaseMessagingBackgroundChannelName =
    @"plugins.flutter.io/firebase_messaging_background";

NSString *const kMessagingArgumentCode = @"code";
NSString *const kMessagingArgumentMessage = @"message";
NSString *const kMessagingArgumentAdditionalData = @"additionalData";

NSString *const kMessagingBackgroundSetupCallback = @"firebase_messaging_background_setup_callback";
NSString *const kMessagingBackgroundCallback = @"firebase_messaging_background_callback";

@implementation FLTFirebaseMessagingPlugin {
  FlutterMethodChannel *_channel;
  NSObject<FlutterPluginRegistrar> *_registrar;

  FlutterMethodChannel *_backgroundChannel;
  // TODO use me
  NSMutableArray<NSArray *> *_backgroundEventQueue;

  NSDictionary *_initialNotification;
  BOOL _backgroundFlutterEngineRunning;
  FlutterEngine *_backgroundFlutterEngine;

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
  __weak id<UNUserNotificationCenterDelegate> _originalNotificationCenterDelegate;
  struct {
    unsigned int willPresentNotification : 1;
    unsigned int didReceiveNotificationResponse : 1;
    unsigned int openSettingsForNotification : 1;
  } _originalNotificationCenterDelegateRespondsTo;
#endif
}

#pragma mark - FlutterPlugin

- (instancetype)initWithFlutterMethodChannel:(FlutterMethodChannel *)channel
                   andFlutterPluginRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _channel = channel;
    _registrar = registrar;

    // Application
    // Dart -> `getInitialNotification`
    // ObjC -> Initialize other delegates & observers
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(application_onDidFinishLaunchingNotification:)
               name:UIApplicationDidFinishLaunchingNotification
             object:nil];

    // Setup background event handling.
    _backgroundFlutterEngineRunning = NO;
    _backgroundEventQueue = [[NSMutableArray alloc] init];
    _backgroundFlutterEngine = [[FlutterEngine alloc] initWithName:@"firebase_messaging_background"
                                                           project:nil
                                            allowHeadlessExecution:YES];

    _backgroundFlutterEngine.isGpuDisabled = YES;
    _backgroundChannel =
        [FlutterMethodChannel methodChannelWithName:kFLTFirebaseMessagingBackgroundChannelName
                                    binaryMessenger:[_backgroundFlutterEngine binaryMessenger]];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseMessagingChannelName
                                  binaryMessenger:[registrar messenger]];
  id instance = [[FLTFirebaseMessagingPlugin alloc] initWithFlutterMethodChannel:channel
                                                       andFlutterPluginRegistrar:registrar];
  // Register with internal FlutterFire plugin registry.
  [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];

  [registrar addMethodCallDelegate:instance channel:channel];
#if !TARGET_OS_OSX
  [registrar publish:instance];  // iOS only supported
#endif
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock = ^(
      NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
      NSError *_Nullable error) {
    if (code == nil) {
      NSDictionary *errorDetails = [self NSDictionaryForNSError:error];
      code = errorDetails[kMessagingArgumentCode];
      message = errorDetails[kMessagingArgumentMessage];
      details = errorDetails;
    } else {
      details = @{
        kMessagingArgumentCode : code,
        kMessagingArgumentMessage : message,
        kMessagingArgumentAdditionalData : @{},
      };
    }

    if ([@"unknown" isEqualToString:code]) {
      NSLog(@"FLTFirebaseMessaging: An error occurred while calling method %@, errorOrNil => %@",
            call.method, [error userInfo]);
    }

    flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                        message:message
                                                optionalDetails:details
                                             andOptionalNSError:error]);
  };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"Messaging#getInitialNotification" isEqualToString:call.method]) {
    methodCallResult.success([self copyInitialNotification]);
  } else if ([@"Messaging#deleteToken" isEqualToString:call.method]) {
    [self messagingDeleteToken:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#getAPNSToken" isEqualToString:call.method]) {
    [self messagingGetAPNSToken:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#getToken" isEqualToString:call.method]) {
    [self messagingGetToken:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#getNotificationSettings" isEqualToString:call.method]) {
    [self messagingGetNotificationSettings:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#requestPermission" isEqualToString:call.method]) {
    [self messagingRequestPermission:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#setAutoInitEnabled" isEqualToString:call.method]) {
    [self messagingSetAutoInitEnabled:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#subscribeToTopic" isEqualToString:call.method]) {
    [self messagingSubscribeToTopic:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Messaging#unsubscribeFromTopic" isEqualToString:call.method]) {
    [self messagingUnsubscribeFromTopic:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FcmDartService#start" isEqualToString:call.method]) {
    [self dartServiceStart:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FcmDartService#initialized" isEqualToString:call.method]) {
    [self dartServiceInitialized:call.arguments withMethodCallResult:methodCallResult];
  } else {
    methodCallResult.success(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase Messaging Delegate

- (void)messaging:(nonnull FIRMessaging *)messaging
    didReceiveRegistrationToken:(nonnull NSString *)fcmToken {
  // Don't crash if the token is reset.
  if (fcmToken == nil) {
    return;
  }

  // Send to Dart.
  [_channel invokeMethod:@"Messaging#onTokenRefresh" arguments:fcmToken];

  // If the users AppDelegate implements messaging:didReceiveRegistrationToken: then call it as well
  // so we don't break other libraries.
  SEL messaging_didReceiveRegistrationTokenSelector =
      NSSelectorFromString(@"messaging:didReceiveRegistrationToken:");
  if ([[GULAppDelegateSwizzler sharedApplication].delegate
          respondsToSelector:messaging_didReceiveRegistrationTokenSelector]) {
    void (*usersDidReceiveRegistrationTokenIMP)(id, SEL, FIRMessaging *, NSString *) =
        (typeof(usersDidReceiveRegistrationTokenIMP)) & objc_msgSend;
    usersDidReceiveRegistrationTokenIMP([GULAppDelegateSwizzler sharedApplication].delegate,
                                        messaging_didReceiveRegistrationTokenSelector, messaging,
                                        fcmToken);
  }
}

#pragma mark - NSNotificationCenter Observers

- (void)application_onDidFinishLaunchingNotification:(nonnull NSNotification *)notification {
  // Setup UIApplicationDelegate.
#if TARGET_OS_OSX
  // For macOS we use swizzling to intercept as addApplicationDelegate does not exist on the macOS
  // registrar Flutter implementation.
  [GULAppDelegateSwizzler registerAppDelegateInterceptor:self];
  [GULAppDelegateSwizzler proxyOriginalDelegateIncludingAPNSMethods];

  SEL didReceiveRemoteNotificationWithCompletionSEL =
      NSSelectorFromString(@"application:didReceiveRemoteNotification:fetchCompletionHandler:");
  if ([[GULAppDelegateSwizzler sharedApplication].delegate
          respondsToSelector:didReceiveRemoteNotificationWithCompletionSEL]) {
    // noop - user has own implementation of this method in their AppDelegate, this
    // means GULAppDelegateSwizzler will have already replaced it with a donor method
  } else {
    // add our own donor implementation of
    // application:didReceiveRemoteNotification:fetchCompletionHandler:
    Method donorMethod = class_getInstanceMethod(object_getClass(self),
                                                 didReceiveRemoteNotificationWithCompletionSEL);
    class_addMethod(object_getClass([GULAppDelegateSwizzler sharedApplication].delegate),
                    didReceiveRemoteNotificationWithCompletionSEL,
                    method_getImplementation(donorMethod), method_getTypeEncoding(donorMethod));
  }
#else
  [_registrar addApplicationDelegate:self];
#endif

  // Set UNUserNotificationCenter but preserve original delegate if necessary.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
  if (@available(iOS 10.0, *)) {
    UNUserNotificationCenter *notificationCenter =
        [UNUserNotificationCenter currentNotificationCenter];
    if (notificationCenter.delegate != nil) {
      _originalNotificationCenterDelegate = notificationCenter.delegate;
      _originalNotificationCenterDelegateRespondsTo.openSettingsForNotification =
          (unsigned int)[_originalNotificationCenterDelegate
              respondsToSelector:@selector(userNotificationCenter:openSettingsForNotification:)];
      _originalNotificationCenterDelegateRespondsTo.willPresentNotification =
          (unsigned int)[_originalNotificationCenterDelegate
              respondsToSelector:@selector(userNotificationCenter:
                                          willPresentNotification:withCompletionHandler:)];
      _originalNotificationCenterDelegateRespondsTo.didReceiveNotificationResponse =
          (unsigned int)[_originalNotificationCenterDelegate
              respondsToSelector:@selector(userNotificationCenter:
                                     didReceiveNotificationResponse:withCompletionHandler:)];
    }
    notificationCenter.delegate = self;
  }
#endif

  // We automatically register for remote notifications as
  // application:didReceiveRemoteNotification:fetchCompletionHandler: will not get called unless
  // registerForRemoteNotifications is called early on during app initialization, calling this from
  // Dart would be too late.
  [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - UNUserNotificationCenter Delegate Methods

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Called when a notification is received whilst the app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:
             (void (^)(UNNotificationPresentationOptions options))completionHandler {
  // We only want to handle FCM notifications.
  if (notification.request.content.userInfo[@"gcm.message_id"]) {
    NSDictionary *notificationDict =
        [FLTFirebaseMessagingPlugin NSDictionaryFromUNNotification:notification];

    // Don't send an event if contentAvailable is true - application:didReceiveRemoteNotification
    // will send the event for us, we don't want to duplicate them.
    if (!notificationDict[@"contentAvailable"]) {
      [_channel invokeMethod:@"Messaging#onMessage" arguments:notificationDict];
    }

    // TODO in a later version possibly allow customising completion options in Dart code.
    completionHandler(UNNotificationPresentationOptionNone);
  }

  // Forward on to any other delegates.
  if (_originalNotificationCenterDelegate != nil &&
      _originalNotificationCenterDelegateRespondsTo.willPresentNotification) {
    [_originalNotificationCenterDelegate userNotificationCenter:center
                                        willPresentNotification:notification
                                          withCompletionHandler:completionHandler];
  } else {
    completionHandler(UNNotificationPresentationOptionNone);
  }
}

// Called when a use interacts with a notification.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {
  NSDictionary *remoteNotification = response.notification.request.content.userInfo;
  // We only want to handle FCM notifications.
  if (remoteNotification[@"gcm.message_id"]) {
    NSDictionary *notificationDict =
        [FLTFirebaseMessagingPlugin remoteMessageUserInfoToDict:remoteNotification];
    [_channel invokeMethod:@"Messaging#onNotificationOpenedApp" arguments:notificationDict];
    @synchronized(self) {
      _initialNotification = notificationDict;
    }
  }

  // Forward on to any other delegates.
  if (_originalNotificationCenterDelegate != nil &&
      _originalNotificationCenterDelegateRespondsTo.didReceiveNotificationResponse) {
    [_originalNotificationCenterDelegate userNotificationCenter:center
                                 didReceiveNotificationResponse:response
                                          withCompletionHandler:completionHandler];
  } else {
    completionHandler();
  }
}

// We don't use this for FlutterFire, but for the purpose of forwarding to any original delegates we
// implement this.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    openSettingsForNotification:(nullable UNNotification *)notification {
  // Forward on to any other delegates.
  if (_originalNotificationCenterDelegate != nil &&
      _originalNotificationCenterDelegateRespondsTo.openSettingsForNotification) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    [_originalNotificationCenterDelegate userNotificationCenter:center
                                    openSettingsForNotification:notification];
#pragma clang diagnostic pop
  }
}

#endif

#pragma mark - AppDelegate Methods

// Called when `registerForRemoteNotifications` completes successfully.
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#ifdef DEBUG
  [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeSandbox];
#else
  [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeProd];
#endif
}

// Called when `registerForRemoteNotifications` fails to complete.
- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  // TODO log an error? Not sending this anywhere
  // TODO log an error? Not sending this anywhere
  // TODO log an error? Not sending this anywhere
  // TODO log an error? Not sending this anywhere
  // TODO log an error? Not sending this anywhere
}

// Called when a remote notification is received via APNs.
#if TARGET_OS_OSX
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
#else
- (BOOL)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
#endif
#if __has_include(<FirebaseAuth/FirebaseAuth.h>)
  if ([[FIRAuth auth] canHandleNotification:userInfo]) {
    completionHandler(UIBackgroundFetchResultNoData);
#if TARGET_OS_OSX
    return;
#else
    return YES;
#endif
  }
#endif

  // Only handle notifications from FCM.
  if (userInfo[@"gcm.message_id"]) {
    NSDictionary *notificationDict =
        [FLTFirebaseMessagingPlugin remoteMessageUserInfoToDict:userInfo];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
      // If app is in background state, register background task to guarantee async queues aren't
      // frozen.
      UIBackgroundTaskIdentifier __block backgroundTaskId =
          [application beginBackgroundTaskWithExpirationHandler:^{
            if (backgroundTaskId != UIBackgroundTaskInvalid) {
              [application endBackgroundTask:backgroundTaskId];
              backgroundTaskId = UIBackgroundTaskInvalid;
            }
          }];

      // TODO call completion handler directly from Dart when user Dart code complete
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25 * NSEC_PER_SEC)),
                     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                       completionHandler(UIBackgroundFetchResultNewData);

                       // Stop background task after the longest timeout, async queue is okay to
                       // freeze again after handling period.
                       if (backgroundTaskId != UIBackgroundTaskInvalid) {
                         [application endBackgroundTask:backgroundTaskId];
                         backgroundTaskId = UIBackgroundTaskInvalid;
                       }
                     });

      // TODO queue event
      // TODO queue event
      // TODO queue event
      // TODO queue event
      // TODO queue event

      @synchronized(self) {
        if (!_backgroundFlutterEngineRunning && ![_backgroundFlutterEngine run]) {
          [self runBackgroundFlutterEngine];
        }
      }

      // TODO send notificationDict to background channel
      // TODO send notificationDict to background channel
      // TODO send notificationDict to background channel
      // TODO send notificationDict to background channel
      // TODO send notificationDict to background channel
      // TODO send notificationDict to background channel
    } else {
      // TODO check if this also needs queuing
      [_channel invokeMethod:@"Messaging#onMessage" arguments:notificationDict];
      completionHandler(UIBackgroundFetchResultNoData);
    }

#if TARGET_OS_OSX
    return;
#else
    return YES;
#endif
  }  // if (userInfo[@"gcm.message_id"])

  // Nothing to handle in FlutterFire messaging.
#if TARGET_OS_OSX
  return;
#else
  return NO;
#endif
}  // didReceiveRemoteNotification

#pragma mark - Firebase Messaging API

- (void)dartServiceInitialized:(id)arguments
          withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  // TODO implement
  // TODO implement
  // TODO implement
  // TODO implement
}

- (void)dartServiceStart:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  // TODO implement
  // TODO implement
  // TODO implement
  // TODO implement
}

- (void)messagingUnsubscribeFromTopic:(id)arguments
                 withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRMessaging *messaging = [FIRMessaging messaging];
  NSString *topic = arguments[@"topic"];
  [messaging unsubscribeFromTopic:topic
                       completion:^(NSError *error) {
                         if (error != nil) {
                           result.error(nil, nil, nil, error);
                         } else {
                           result.success(nil);
                         }
                       }];
}

- (void)messagingSubscribeToTopic:(id)arguments
             withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRMessaging *messaging = [FIRMessaging messaging];
  NSString *topic = arguments[@"topic"];
  [messaging subscribeToTopic:topic
                   completion:^(NSError *error) {
                     if (error != nil) {
                       result.error(nil, nil, nil, error);
                     } else {
                       result.success(nil);
                     }
                   }];
}

- (void)messagingSetAutoInitEnabled:(id)arguments
               withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRMessaging *messaging = [FIRMessaging messaging];
  messaging.autoInitEnabled = [arguments[@"enabled"] boolValue];
  result.success(@{
    @"isAutoInitEnabled" : @(messaging.isAutoInitEnabled),
  });
}

- (void)messagingRequestPermission:(id)arguments
              withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSDictionary *permissions = arguments[@"permissions"];
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

  UNAuthorizationOptions options = UNAuthorizationOptionNone;

  if ([permissions[@"alert"] isEqual:@(YES)]) {
    options |= UNAuthorizationOptionAlert;
  }

  if ([permissions[@"badge"] isEqual:@(YES)]) {
    options |= UNAuthorizationOptionBadge;
  }

  if ([permissions[@"sound"] isEqual:@(YES)]) {
    options |= UNAuthorizationOptionSound;
  }

  if ([permissions[@"provisional"] isEqual:@(YES)]) {
    if (@available(iOS 12.0, *)) {
      options |= UNAuthorizationOptionProvisional;
    }
  }

  if ([permissions[@"announcement"] isEqual:@(YES)]) {
    if (@available(iOS 13.0, *)) {
      // TODO not available in iOS9 deployment target - enable once iOS10+ deployment target
      // specified in podspec. options |= UNAuthorizationOptionAnnouncement;
    }
  }

  if ([permissions[@"carPlay"] isEqual:@(YES)]) {
    options |= UNAuthorizationOptionCarPlay;
  }

  if ([permissions[@"criticalAlert"] isEqual:@(YES)]) {
    if (@available(iOS 12.0, *)) {
      options |= UNAuthorizationOptionCriticalAlert;
    }
  }

  id handler = ^(BOOL granted, NSError *_Nullable error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      [center getNotificationSettingsWithCompletionHandler:^(
                  UNNotificationSettings *_Nonnull settings) {
        result.success(
            [FLTFirebaseMessagingPlugin NSDictionaryFromUNNotificationSettings:settings]);
      }];
    }
  };

  [center requestAuthorizationWithOptions:options completionHandler:handler];
}

- (void)messagingGetNotificationSettings:(id)arguments
                    withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  [center getNotificationSettingsWithCompletionHandler:^(
              UNNotificationSettings *_Nonnull settings) {
    result.success([FLTFirebaseMessagingPlugin NSDictionaryFromUNNotificationSettings:settings]);
  }];
}

- (void)messagingGetToken:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRMessaging *messaging = [FIRMessaging messaging];
  [messaging tokenWithCompletion:^(NSString *token, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(token);
    }
  }];
}

- (void)messagingGetAPNSToken:(id)arguments
         withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSData *apnsToken = [FIRMessaging messaging].APNSToken;
  if (apnsToken) {
    result.success([FLTFirebaseMessagingPlugin APNSTokenFromNSData:apnsToken]);
  } else {
    result.success([NSNull null]);
  }
}

- (void)messagingDeleteToken:(id)arguments
        withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRMessaging *messaging = [FIRMessaging messaging];
  [messaging deleteTokenWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  completion();
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{
    @"AUTO_INIT_ENABLED" : @([FIRMessaging messaging].isAutoInitEnabled),
  };
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseMessagingChannelName;
}

#pragma mark - Utilities

+ (NSDictionary *)NSDictionaryFromUNNotificationSettings:
    (UNNotificationSettings *_Nonnull)settings {
  NSMutableDictionary *settingsDictionary = [NSMutableDictionary dictionary];

  // authorizedStatus
  NSNumber *authorizedStatus = @-1;
  if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
    authorizedStatus = @-1;
  } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
    authorizedStatus = @0;
  } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
    authorizedStatus = @1;
  }

  if (@available(iOS 12.0, *)) {
    if (settings.authorizationStatus == UNAuthorizationStatusProvisional) {
      authorizedStatus = @2;
    }
  }

  NSNumber *showPreviews = @-1;
  if (@available(iOS 11.0, *)) {
    if (settings.showPreviewsSetting == UNShowPreviewsSettingNever) {
      showPreviews = @0;
    } else if (settings.showPreviewsSetting == UNShowPreviewsSettingAlways) {
      showPreviews = @1;
    } else if (settings.showPreviewsSetting == UNShowPreviewsSettingWhenAuthenticated) {
      showPreviews = @2;
    }
  }

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCSimplifyInspectionLegacy"
  if (@available(iOS 13.0, *)) {
    // TODO not available in iOS9 deployment target - enable once iOS10+ deployment target specified
    // in podspec. settingsDictionary[@"announcement"] =
    //   [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.announcementSetting];
    settingsDictionary[@"announcement"] = @-1;
  } else {
    settingsDictionary[@"announcement"] = @-1;
  }
#pragma clang diagnostic pop

  if (@available(iOS 12.0, *)) {
    settingsDictionary[@"criticalAlert"] =
        [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.criticalAlertSetting];
  } else {
    settingsDictionary[@"criticalAlert"] = @-1;
  }

  settingsDictionary[@"showPreviews"] = showPreviews;
  settingsDictionary[@"authorizationStatus"] = authorizedStatus;
  settingsDictionary[@"alert"] =
      [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.alertSetting];
  settingsDictionary[@"badge"] =
      [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.badgeSetting];
  settingsDictionary[@"sound"] =
      [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.soundSetting];
  settingsDictionary[@"carPlay"] =
      [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.carPlaySetting];
  settingsDictionary[@"lockScreen"] =
      [FLTFirebaseMessagingPlugin NSNumberForUNNotificationSetting:settings.lockScreenSetting];
  settingsDictionary[@"notificationCenter"] = [FLTFirebaseMessagingPlugin
      NSNumberForUNNotificationSetting:settings.notificationCenterSetting];
  return settingsDictionary;
}

+ (NSNumber *)NSNumberForUNNotificationSetting:(UNNotificationSetting)setting {
  NSNumber *asNumber = @-1;
  if (setting == UNNotificationSettingNotSupported) {
    asNumber = @-1;
  } else if (setting == UNNotificationSettingDisabled) {
    asNumber = @0;
  } else if (setting == UNNotificationSettingEnabled) {
    asNumber = @1;
  }
  return asNumber;
}

+ (NSString *)APNSTokenFromNSData:(NSData *)tokenData {
  const char *data = [tokenData bytes];

  NSMutableString *token = [NSMutableString string];
  for (NSInteger i = 0; i < tokenData.length; i++) {
    [token appendFormat:@"%02.2hhX", data[i]];
  }

  return [token copy];
}

+ (NSDictionary *)NSDictionaryFromUNNotification:(UNNotification *)notification {
  return [self remoteMessageUserInfoToDict:notification.request.content.userInfo];
}

+ (NSDictionary *)remoteMessageUserInfoToDict:(NSDictionary *)userInfo {
  NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *notificationIOS = [[NSMutableDictionary alloc] init];

  // message.data
  for (id key in userInfo) {
    // message.messageId
    if ([key isEqualToString:@"gcm.message_id"] || [key isEqualToString:@"google.message_id"] ||
        [key isEqualToString:@"message_id"]) {
      message[@"messageId"] = userInfo[key];
      continue;
    }

    // message.messageType
    if ([key isEqualToString:@"message_type"]) {
      message[@"messageType"] = userInfo[key];
      continue;
    }

    // message.collapseKey
    if ([key isEqualToString:@"collapse_key"]) {
      message[@"collapseKey"] = userInfo[key];
      continue;
    }

    // message.from
    if ([key isEqualToString:@"from"]) {
      message[@"from"] = userInfo[key];
      continue;
    }

    // message.sentTime
    if ([key isEqualToString:@"google.c.a.ts"]) {
      message[@"sentTime"] = userInfo[key];
      continue;
    }

    // message.to
    if ([key isEqualToString:@"to"] || [key isEqualToString:@"google.to"]) {
      message[@"to"] = userInfo[key];
      continue;
    }

    // build data dict from remaining keys but skip keys that shouldn't be included in data
    if ([key isEqualToString:@"aps"] || [key hasPrefix:@"gcm."] || [key hasPrefix:@"google."]) {
      continue;
    }
    data[key] = userInfo[key];
  }
  message[@"data"] = data;

  if (userInfo[@"aps"] != nil) {
    NSDictionary *apsDict = userInfo[@"aps"];
    // message.category
    if (apsDict[@"category"] != nil) {
      message[@"category"] = apsDict[@"category"];
    }

    // message.threadId
    if (apsDict[@"thread-id"] != nil) {
      message[@"threadId"] = apsDict[@"thread-id"];
    }

    // message.contentAvailable
    if (apsDict[@"content-available"] != nil) {
      message[@"contentAvailable"] = @([apsDict[@"content-available"] boolValue]);
    }

    // message.mutableContent
    if (apsDict[@"mutable-content"] != nil && [apsDict[@"mutable-content"] intValue] == 1) {
      message[@"mutableContent"] = @([apsDict[@"mutable-content"] boolValue]);
    }

    // message.notification.*
    if (apsDict[@"alert"] != nil) {
      // can be a string or dictionary
      if ([apsDict[@"alert"] isKindOfClass:[NSString class]]) {
        // message.notification.title
        notification[@"title"] = apsDict[@"alert"];
      } else if ([apsDict[@"alert"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *apsAlertDict = apsDict[@"alert"];

        // message.notification.title
        if (apsAlertDict[@"title"] != nil) {
          notification[@"title"] = apsAlertDict[@"title"];
        }

        // message.notification.titleLocKey
        if (apsAlertDict[@"title-loc-key"] != nil) {
          notification[@"titleLocKey"] = apsAlertDict[@"title-loc-key"];
        }

        // message.notification.titleLocArgs
        if (apsAlertDict[@"title-loc-args"] != nil) {
          notification[@"titleLocArgs"] = apsAlertDict[@"title-loc-args"];
        }

        // message.notification.body
        if (apsAlertDict[@"body"] != nil) {
          notification[@"body"] = apsAlertDict[@"body"];
        }

        // message.notification.bodyLocKey
        if (apsAlertDict[@"loc-key"] != nil) {
          notification[@"bodyLocKey"] = apsAlertDict[@"loc-key"];
        }

        // message.notification.bodyLocArgs
        if (apsAlertDict[@"loc-args"] != nil) {
          notification[@"bodyLocArgs"] = apsAlertDict[@"loc-args"];
        }

        // iOS only
        // message.notification.ios.subtitle
        if (apsAlertDict[@"subtitle"] != nil) {
          notificationIOS[@"subtitle"] = apsAlertDict[@"subtitle"];
        }

        // iOS only
        // message.notification.ios.subtitleLocKey
        if (apsAlertDict[@"subtitle-loc-key"] != nil) {
          notificationIOS[@"subtitleLocKey"] = apsAlertDict[@"subtitle-loc-key"];
        }

        // iOS only
        // message.notification.ios.subtitleLocArgs
        if (apsAlertDict[@"subtitle-loc-args"] != nil) {
          notificationIOS[@"subtitleLocArgs"] = apsAlertDict[@"subtitle-loc-args"];
        }

        // iOS only
        // message.notification.ios.badge
        if (apsAlertDict[@"badge"] != nil) {
          notificationIOS[@"badge"] = apsAlertDict[@"badge"];
        }
      }

      notification[@"ios"] = notificationIOS;
      message[@"notification"] = notification;
    }

    // message.notification.ios.sound
    if (apsDict[@"sound"] != nil) {
      if ([apsDict[@"sound"] isKindOfClass:[NSString class]]) {
        // message.notification.ios.sound
        notification[@"sound"] = apsDict[@"sound"];
      } else if ([apsDict[@"sound"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *apsSoundDict = apsDict[@"sound"];
        NSMutableDictionary *notificationIOSSound = [[NSMutableDictionary alloc] init];

        // message.notification.ios.sound.name String
        if (apsSoundDict[@"name"] != nil) {
          notificationIOSSound[@"name"] = apsSoundDict[@"name"];
        }

        // message.notification.ios.sound.critical Boolean
        if (apsSoundDict[@"critical"] != nil) {
          notificationIOSSound[@"critical"] = @([apsSoundDict[@"critical"] boolValue]);
        }

        // message.notification.ios.sound.volume Number
        if (apsSoundDict[@"volume"] != nil) {
          notificationIOSSound[@"volume"] = apsSoundDict[@"volume"];
        }

        // message.notification.ios.sound
        notificationIOS[@"sound"] = notificationIOSSound;
      }

      notification[@"ios"] = notificationIOS;
      message[@"notification"] = notification;
    }
  }

  return message;
}

- (int64_t)getCallbackHandle:(NSString *)key {
  NSLog(@"FLTFirebaseMessaging: Getting callback handle for key %@", key);
  id handle = [[NSUserDefaults standardUserDefaults] objectForKey:key];
  if (handle == nil) {
    return 0;
  }
  return [handle longLongValue];
}

- (void)runBackgroundFlutterEngine {
  NSLog(@"FLTFirebaseMessaging: Starting background flutter engine...");

  int64_t handle = [self getCallbackHandle:kMessagingBackgroundSetupCallback];
  FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
  NSAssert(info != nil, @"FLTFirebaseMessaging: Failed to find callback.");

  NSString *entrypoint = info.callbackName;
  NSString *uri = info.callbackLibraryPath;

  [_backgroundFlutterEngine runWithEntrypoint:entrypoint libraryURI:uri];
  [_registrar addMethodCallDelegate:self channel:_backgroundChannel];

  // Once our headless runner has been started, we need to register the application's plugins
  // with the runner in order for them to work on the background isolate.
  [GeneratedPluginRegistrant registerWithRegistry:_backgroundFlutterEngine];
}

- (nullable NSDictionary *)copyInitialNotification {
  @synchronized(self) {
    if (_initialNotification != nil) {
      NSDictionary *initialNotificationCopy = [_initialNotification copy];
      _initialNotification = nil;
      return initialNotificationCopy;
    }
  }

  return nil;
}

- (NSDictionary *)NSDictionaryForNSError:(NSError *)error {
  NSString *code = @"unknown";
  NSString *message = @"An unknown error has occurred.";

  if (error == nil) {
    return @{
      kMessagingArgumentCode : code,
      kMessagingArgumentMessage : message,
      kMessagingArgumentAdditionalData : @{},
    };
  }

  // code
  if (error.code == kFIRMessagingErrorCodeNetwork) {
    code = @"unavailable";
  } else if (error.code == kFIRMessagingErrorCodeInvalidRequest) {
    code = @"invalid-request";
  } else if (error.code == kFIRMessagingErrorCodeInvalidTopicName) {
    code = @"invalid-argument";
  } else if (error.code == kFIRMessagingErrorCodeMissingDeviceID) {
    code = @"missing-device-id";
  } else if (error.code == kFIRMessagingErrorCodeServiceNotAvailable) {
    code = @"unavailable";
  } else if (error.code == kFIRMessagingErrorCodeMissingTo) {
    code = @"invalid-argument";
  } else if (error.code == kFIRMessagingErrorCodeSave) {
    code = @"save-failed";
  } else if (error.code == kFIRMessagingErrorCodeSizeExceeded) {
    code = @"invalid-argument";
  } else if (error.code == kFIRMessagingErrorCodeAlreadyConnected) {
    code = @"already-connected";
  } else if (error.code == kFIRMessagingErrorCodePubSubOperationIsCancelled) {
    code = @"pubsub-operation-cancelled";
  }

  // message
  if ([error userInfo][NSLocalizedDescriptionKey] != nil) {
    message = [error userInfo][NSLocalizedDescriptionKey];
  }

  return @{
    kMessagingArgumentCode : code,
    kMessagingArgumentMessage : message,
    kMessagingArgumentAdditionalData : @{},
  };
}

@end
