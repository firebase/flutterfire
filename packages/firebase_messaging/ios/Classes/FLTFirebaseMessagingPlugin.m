// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UserNotifications/UserNotifications.h>

#import "FLTFirebaseMessagingPlugin.h"

#import "Firebase/Firebase.h"

NSString *const kGCMMessageIDKey = @"gcm.message_id";

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface FLTFirebaseMessagingPlugin () <FIRMessagingDelegate>
@end
#endif

static NSString *backgroundSetupCallback = @"background_setup_callback";
static NSString *backgroundMessageCallback = @"background_message_callback";
static FlutterPluginRegistrantCallback registerPlugins = nil;
typedef void (^FetchCompletionHandler)(UIBackgroundFetchResult result);

static FlutterError *getFlutterError(NSError *error) {
  if (error == nil) return nil;
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", (long)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

static NSObject<FlutterPluginRegistrar> *_registrar;

@implementation FLTFirebaseMessagingPlugin {
  FlutterMethodChannel *_channel;
  FlutterMethodChannel *_backgroundChannel;
  NSUserDefaults *_userDefaults;
  NSObject<FlutterPluginRegistrar> *_registrar;
  NSDictionary *_launchNotification;
  NSMutableArray *_eventQueue;
  BOOL _resumingFromBackground;
  FlutterEngine *_headlessRunner;
  BOOL initialized;
  FetchCompletionHandler fetchCompletionHandler;
}

+ (void)setPluginRegistrantCallback:(FlutterPluginRegistrantCallback)callback {
  registerPlugins = callback;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSLog(@"registerWithRegistrar");
  _registrar = registrar;
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_messaging"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMessagingPlugin *instance =
      [[FLTFirebaseMessagingPlugin alloc] initWithChannel:channel registrar:registrar];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];

  if (self) {
    _channel = channel;
    _resumingFromBackground = NO;
    [FIRMessaging messaging].delegate = self;

    // Setup background handling
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _eventQueue = [[NSMutableArray alloc] init];
    _registrar = registrar;
    _headlessRunner = [[FlutterEngine alloc] initWithName:@"firebase_messaging_background"
                                                  project:nil
                                   allowHeadlessExecution:YES];
    _backgroundChannel = [FlutterMethodChannel
        methodChannelWithName:@"plugins.flutter.io/firebase_messaging_background"
              binaryMessenger:[_headlessRunner binaryMessenger]];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *method = call.method;
  NSLog(@"handleMethodCall : %@", method);
  if ([@"requestNotificationPermissions" isEqualToString:method]) {
    NSDictionary *arguments = call.arguments;
    if (@available(iOS 10.0, *)) {
      UNAuthorizationOptions authOptions = 0;
      NSNumber *provisional = arguments[@"provisional"];
      if ([arguments[@"sound"] boolValue]) {
        authOptions |= UNAuthorizationOptionSound;
      }
      if ([arguments[@"alert"] boolValue]) {
        authOptions |= UNAuthorizationOptionAlert;
      }
      if ([arguments[@"badge"] boolValue]) {
        authOptions |= UNAuthorizationOptionBadge;
      }

      NSNumber *isAtLeastVersion12;
      if (@available(iOS 12, *)) {
        isAtLeastVersion12 = [NSNumber numberWithBool:YES];
        if ([provisional boolValue]) authOptions |= UNAuthorizationOptionProvisional;
      } else {
        isAtLeastVersion12 = [NSNumber numberWithBool:NO];
      }

      [[UNUserNotificationCenter currentNotificationCenter]
          requestAuthorizationWithOptions:authOptions
                        completionHandler:^(BOOL granted, NSError *_Nullable error) {
                          if (error) {
                            result(getFlutterError(error));
                            return;
                          }
                          // This works for iOS >= 10. See
                          // [UIApplication:didRegisterUserNotificationSettings:notificationSettings]
                          // for ios < 10.
                          [[UNUserNotificationCenter currentNotificationCenter]
                              getNotificationSettingsWithCompletionHandler:^(
                                  UNNotificationSettings *_Nonnull settings) {
                                NSDictionary *settingsDictionary = @{
                                  @"sound" : [NSNumber numberWithBool:settings.soundSetting ==
                                                                      UNNotificationSettingEnabled],
                                  @"badge" : [NSNumber numberWithBool:settings.badgeSetting ==
                                                                      UNNotificationSettingEnabled],
                                  @"alert" : [NSNumber numberWithBool:settings.alertSetting ==
                                                                      UNNotificationSettingEnabled],
                                  @"provisional" :
                                      [NSNumber numberWithBool:granted && [provisional boolValue] &&
                                                               isAtLeastVersion12],
                                };
                                [self->_channel invokeMethod:@"onIosSettingsRegistered"
                                                   arguments:settingsDictionary];
                              }];
                          result([NSNumber numberWithBool:granted]);
                        }];

      [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
      UIUserNotificationType notificationTypes = 0;
      if ([arguments[@"sound"] boolValue]) {
        notificationTypes |= UIUserNotificationTypeSound;
      }
      if ([arguments[@"alert"] boolValue]) {
        notificationTypes |= UIUserNotificationTypeAlert;
      }
      if ([arguments[@"badge"] boolValue]) {
        notificationTypes |= UIUserNotificationTypeBadge;
      }

      UIUserNotificationSettings *settings =
          [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
      [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

      [[UIApplication sharedApplication] registerForRemoteNotifications];
      result([NSNumber numberWithBool:YES]);
    }
  } else if ([@"FcmDartService#start" isEqualToString:method]) {
    NSDictionary *arguments = call.arguments;
    NSLog(@"FcmDartService#start");
    long setupHandle = [arguments[@"setupHandle"] longValue];
    long backgroundHandle = [arguments[@"backgroundHandle"] longValue];
    NSLog(@"FcmDartService#start with handle : %ld", setupHandle);
    [self saveCallbackHandle:backgroundSetupCallback handle:setupHandle];
    [self saveCallbackHandle:backgroundMessageCallback handle:backgroundHandle];
    result(nil);
  } else if ([@"FcmDartService#initialized" isEqualToString:method]) {
    /**
     * Acknowledge that background message handling on the Dart side is ready. This is called by the
     * Dart side once all background initialization is complete via `FcmDartService#initialized`.
     */
    @synchronized(self) {
      initialized = YES;
      while ([_eventQueue count] > 0) {
        NSArray *call = _eventQueue[0];
        [_eventQueue removeObjectAtIndex:0];

        [self invokeMethod:call[0] callbackHandle:[call[1] longLongValue] arguments:call[2]];
      }
    }
    result(nil);
  } else if ([@"configure" isEqualToString:method]) {
    [FIRMessaging messaging].shouldEstablishDirectChannel = true;
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    if (_launchNotification != nil && _launchNotification[kGCMMessageIDKey]) {
      [_channel invokeMethod:@"onLaunch" arguments:_launchNotification];
    }
    result(nil);
  } else if ([@"subscribeToTopic" isEqualToString:method]) {
    NSString *topic = call.arguments;
    [[FIRMessaging messaging] subscribeToTopic:topic
                                    completion:^(NSError *error) {
                                      result(getFlutterError(error));
                                    }];
  } else if ([@"unsubscribeFromTopic" isEqualToString:method]) {
    NSString *topic = call.arguments;
    [[FIRMessaging messaging] unsubscribeFromTopic:topic
                                        completion:^(NSError *error) {
                                          result(getFlutterError(error));
                                        }];
  } else if ([@"getToken" isEqualToString:method]) {
    [[FIRInstanceID instanceID]
        instanceIDWithHandler:^(FIRInstanceIDResult *_Nullable instanceIDResult,
                                NSError *_Nullable error) {
          if (error != nil) {
            NSLog(@"getToken, error fetching instanceID: %@", error);
            result(nil);
          } else {
            result(instanceIDResult.token);
          }
        }];
  } else if ([@"deleteInstanceID" isEqualToString:method]) {
    [[FIRInstanceID instanceID] deleteIDWithHandler:^void(NSError *_Nullable error) {
      if (error.code != 0) {
        NSLog(@"deleteInstanceID, error: %@", error);
        result([NSNumber numberWithBool:NO]);
      } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        result([NSNumber numberWithBool:YES]);
      }
    }];
  } else if ([@"autoInitEnabled" isEqualToString:method]) {
    BOOL value = [[FIRMessaging messaging] isAutoInitEnabled];
    result([NSNumber numberWithBool:value]);
  } else if ([@"setAutoInitEnabled" isEqualToString:method]) {
    NSNumber *value = call.arguments;
    [FIRMessaging messaging].autoInitEnabled = value.boolValue;
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Received data message on iOS 10 devices while app is in the foreground.
// Only invoked if method swizzling is enabled.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
  [self didReceiveRemoteNotification:remoteMessage.appData];
}

// Received data message on iOS 10 devices while app is in the foreground.
// Only invoked if method swizzling is disabled and UNUserNotificationCenterDelegate has been
// registered in AppDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
    NS_AVAILABLE_IOS(10.0) {
  NSDictionary *userInfo = notification.request.content.userInfo;
  // Check to key to ensure we only handle messages from Firebase
  if (userInfo[kGCMMessageIDKey]) {
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    [_channel invokeMethod:@"onMessage" arguments:userInfo];
    completionHandler(UNNotificationPresentationOptionNone);
  }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(10.0) {
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  // Check to key to ensure we only handle messages from Firebase
  if (userInfo[kGCMMessageIDKey]) {
    [_channel invokeMethod:@"onResume" arguments:userInfo];
    completionHandler();
  }
}

#endif

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"didReceiveRemoteNotification");
  if (_resumingFromBackground) {
    [_channel invokeMethod:@"onResume" arguments:userInfo];
  } else {
    [_channel invokeMethod:@"onMessage" arguments:userInfo];
  }
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (launchOptions != nil) {
    _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  }
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  _resumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  _resumingFromBackground = NO;
  // Removes badge number but doesn't clear push notifications,
  // helpful when you have valuable info in your push notification
  application.applicationIconBadgeNumber = 0;
}

- (BOOL)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
  NSLog(@"didReceiveRemoteNotification:completionHandler");
  if (application.applicationState == UIApplicationStateBackground) {
    // save this handler for later so it can be completed
    fetchCompletionHandler = completionHandler;

    [self queueMethodCall:@"handleBackgroundMessage"
             callbackName:backgroundMessageCallback
                arguments:userInfo];

    if (!initialized) {
      [self startBackgroundRunner];
    }

  } else {
    [self didReceiveRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
  }

  return YES;
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#ifdef DEBUG
  [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeSandbox];
#else
  [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeProd];
#endif

  [_channel invokeMethod:@"onToken" arguments:[FIRMessaging messaging].FCMToken];
}

// This will only be called for iOS < 10. For iOS >= 10, we make this call when we request
// permissions.
- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
  NSDictionary *settingsDictionary = @{
    @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
    @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
    @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
    @"provisional" : [NSNumber numberWithBool:NO],
  };
  [_channel invokeMethod:@"onIosSettingsRegistered" arguments:settingsDictionary];
}

- (void)messaging:(nonnull FIRMessaging *)messaging
    didReceiveRegistrationToken:(nonnull NSString *)fcmToken {
  [_channel invokeMethod:@"onToken" arguments:fcmToken];
}

- (void)messaging:(FIRMessaging *)messaging
    didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
  [_channel invokeMethod:@"onMessage" arguments:remoteMessage.appData];
}

- (void)setupBackgroundHandling:(int64_t)handle {
  NSLog(@"Setting up Firebase background handling");

  [self saveCallbackHandle:backgroundSetupCallback handle:handle];

  NSLog(@"Finished background setup");
}

- (void)startBackgroundRunner {
  NSLog(@"Starting background runner");

  int64_t handle = [self getCallbackHandle:backgroundSetupCallback];

  FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
  NSAssert(info != nil, @"failed to find callback");
  NSString *entrypoint = info.callbackName;
  NSString *uri = info.callbackLibraryPath;

  [_headlessRunner runWithEntrypoint:entrypoint libraryURI:uri];
  [_registrar addMethodCallDelegate:self channel:_backgroundChannel];

  // Once our headless runner has been started, we need to register the application's plugins
  // with the runner in order for them to work on the background isolate. `registerPlugins` is
  // a callback set from AppDelegate.m in the main application. This callback should register
  // all relevant plugins (excluding those which require UI).

  NSAssert(registerPlugins != nil, @"failed to set registerPlugins");
  registerPlugins(_headlessRunner);
}

- (int64_t)getCallbackHandle:(NSString *)key {
  NSLog(@"Getting callback handle for key %@", key);
  id handle = [_userDefaults objectForKey:key];
  if (handle == nil) {
    return 0;
  }
  return [handle longLongValue];
}

- (void)saveCallbackHandle:(NSString *)key handle:(int64_t)handle {
  NSLog(@"Saving callback handle for key %@", key);

  [_userDefaults setObject:[NSNumber numberWithLongLong:handle] forKey:key];
}

- (void)queueMethodCall:(NSString *)method
           callbackName:(NSString *)callback
              arguments:(NSDictionary *)arguments {
  NSLog(@"Queuing method call: %@", method);
  int64_t handle = [self getCallbackHandle:callback];

  @synchronized(self) {
    if (initialized) {
      [self invokeMethod:method callbackHandle:handle arguments:arguments];
    } else {
      NSArray *call = @[ method, @(handle), arguments ];
      [_eventQueue addObject:call];
    }
  }
}

- (void)invokeMethod:(NSString *)method
      callbackHandle:(long)handle
           arguments:(NSDictionary *)arguments {
  NSLog(@"Invoking method: %@", method);

  NSDictionary *callbackArguments = @{
    @"handle" : @(handle),
    @"message" : arguments,
  };

  [_backgroundChannel invokeMethod:method
                         arguments:callbackArguments
                            result:^(id _Nullable result) {
                              NSLog(@"%@ method completed", method);
                              if (self->fetchCompletionHandler != nil) {
                                self->fetchCompletionHandler(UIBackgroundFetchResultNewData);
                                self->fetchCompletionHandler = nil;
                              }
                            }];
}

@end
