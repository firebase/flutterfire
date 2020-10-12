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
  } originalNotificationCenterDelegateRespondsTo;
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
    _backgroundFlutterEngine.viewController = nil;
    _backgroundFlutterEngine.isGpuDisabled = YES;
    _backgroundChannel =
        [FlutterMethodChannel methodChannelWithName:kFLTFirebaseMessagingBackgroundChannelName
                                    binaryMessenger:[_backgroundFlutterEngine binaryMessenger]];

    // Register with internal FlutterFire plugin registry.
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:self];

    [registrar addMethodCallDelegate:self channel:channel];
#if !TARGET_OS_OSX
    [registrar publish:self];  // iOS only supported
#endif
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseMessagingChannelName
                                  binaryMessenger:[registrar messenger]];
  [[FLTFirebaseMessagingPlugin alloc] initWithFlutterMethodChannel:channel
                                         andFlutterPluginRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock = ^(
      NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
      NSError *_Nullable error) {
    if (code == nil) {
      NSDictionary *errorDetails = [self getNSDictionaryFromNSError:error];
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

  // TODO implement the following APIS
  // TODO implement the following APIS
  // TODO implement the following APIS
  // Messaging#deleteToken
  // Messaging#getAPNSToken
  // Messaging#getToken
  // Messaging#getNotificationSettings
  // Messaging#requestPermission
  // Messaging#setAutoInitEnabled
  // Messaging#subscribeToTopic
  // Messaging#unsubscribeFromTopic
  // TODO implement the following background APIs
  // FcmDartService#start
  // FcmDartService#initialized
  if ([@"TODO" isEqualToString:call.method]) {
    // TODO
  } else if ([@"TODO" isEqualToString:call.method]) {
    // TODO
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
  // TODO confirm method
  // TODO confirm method
  // TODO confirm method
  // TODO confirm method
  // TODO confirm method
  [_channel invokeMethod:@"onToken" arguments:fcmToken];

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
  UNUserNotificationCenter *notificationCenter =
      [UNUserNotificationCenter currentNotificationCenter];
  if (notificationCenter.delegate != nil) {
    _originalNotificationCenterDelegate = notificationCenter.delegate;
    originalNotificationCenterDelegateRespondsTo.openSettingsForNotification =
        (unsigned int)[_originalNotificationCenterDelegate
            respondsToSelector:@selector(userNotificationCenter:openSettingsForNotification:)];
    originalNotificationCenterDelegateRespondsTo.willPresentNotification =
        (unsigned int)[_originalNotificationCenterDelegate
            respondsToSelector:@selector(userNotificationCenter:
                                        willPresentNotification:withCompletionHandler:)];
    originalNotificationCenterDelegateRespondsTo.didReceiveNotificationResponse =
        (unsigned int)[_originalNotificationCenterDelegate
            respondsToSelector:@selector(userNotificationCenter:
                                   didReceiveNotificationResponse:withCompletionHandler:)];
  }
  notificationCenter.delegate = self;
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
      // TODO send onMessage to foreground channel.
      // TODO send onMessage to foreground channel.
      // TODO send onMessage to foreground channel.
      // TODO send onMessage to foreground channel.
      // TODO send onMessage to foreground channel.
      // TODO send onMessage to foreground channel.
    }

    // TODO in a later version possibly allow customising completion options in Dart code.
    completionHandler(UNNotificationPresentationOptionNone);
  }

  // Forward on to any other delegates.
  if (_originalNotificationCenterDelegate != nil &&
      originalNotificationCenterDelegateRespondsTo.willPresentNotification) {
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
    // TODO send onNotificationOpenedApp to foreground channel.
    // TODO send onNotificationOpenedApp to foreground channel.
    // TODO send onNotificationOpenedApp to foreground channel.
    // TODO send onNotificationOpenedApp to foreground channel.
    // TODO send onNotificationOpenedApp to foreground channel.
    // TODO send onNotificationOpenedApp to foreground channel.
    @synchronized(self) {
      _initialNotification = notificationDict;
    }
  }

  // Forward on to any other delegates.
  if (_originalNotificationCenterDelegate != nil &&
      originalNotificationCenterDelegateRespondsTo.didReceiveNotificationResponse) {
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
      originalNotificationCenterDelegateRespondsTo.openSettingsForNotification) {
    [_originalNotificationCenterDelegate userNotificationCenter:center
                                    openSettingsForNotification:notification];
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
      // TODO send notificationDict to foreground channel
      // TODO send notificationDict to foreground channel
      // TODO send notificationDict to foreground channel
      // TODO send notificationDict to foreground channel
      // TODO send notificationDict to foreground channel
      // TODO send notificationDict to foreground channel
      // TODO send notificationDict to foreground channel
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

// TODO implement messaging APIs
// TODO implement messaging APIs
// TODO implement messaging APIs
// TODO implement messaging APIs
// TODO implement messaging APIs
// TODO implement messaging APIs
// TODO implement messaging APIs
// TODO implement messaging APIs

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  completion();
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  // TODO auto init enabled
  // TODO auto init enabled
  // TODO auto init enabled
  // TODO auto init enabled
  // TODO auto init enabled
  // TODO auto init enabled
  return @{};
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

- (NSDictionary *)getNSDictionaryFromNSError:(NSError *)error {
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
  } else if (error.code == kFIRMessagingErrorCodePubSubClientNotSetup) {
    code = @"pubsub-not-setup";
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
