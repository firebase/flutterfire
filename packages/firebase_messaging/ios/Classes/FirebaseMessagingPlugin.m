// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseMessagingPlugin.h"
#import "UserAgent.h"

#import "Firebase/Firebase.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface FLTFirebaseMessagingPlugin () <FIRMessagingDelegate>
@end
#endif

static NSString* backgroundSetupCallback = @"background_setup_callback";
static NSString* backgroundMessageCallback = @"background_message_callback";
static FlutterPluginRegistrantCallback registerPlugins = nil;
typedef void (^FetchCompletionHandler)(UIBackgroundFetchResult result);

static FlutterError *getFlutterError(NSError *error) {
  if (error == nil) return nil;
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

@implementation FLTFirebaseMessagingPlugin {
  FlutterMethodChannel *_channel;
  FlutterMethodChannel *_backgroundChannel;
  NSObject<FlutterPluginRegistrar> *_registrar;
  NSUserDefaults *_userDefaults;
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

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel registrar:(NSObject<FlutterPluginRegistrar> *)registrar  {
  self = [super init];

  if (self) {
    _channel = channel;
    _resumingFromBackground = NO;
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }
    [FIRMessaging messaging].delegate = self;
    
    // Setup background handling
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _eventQueue = [[NSMutableArray alloc] init];
    _registrar = registrar;
    _headlessRunner = [[FlutterEngine alloc] initWithName:@"firebase_messaging_isolate" project:nil allowHeadlessExecution:YES];
    _backgroundChannel = [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_messaging_background" binaryMessenger:[_headlessRunner binaryMessenger]];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *method = call.method;
  if ([@"requestNotificationPermissions" isEqualToString:method]) {
    UIUserNotificationType notificationTypes = 0;
    NSDictionary *arguments = call.arguments;
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

    result(nil);
  /*  Even when the app is not active the `FirebaseMessagingService` extended by
   *  `FlutterFirebaseMessagingService` allows incoming FCM messages to be handled.
   *
   *  `FcmDartService#start` and `FcmDartService#initialized` are the two methods used
   *  to optionally setup handling messages received while the app is not active.
   *
   *  `FcmDartService#start` sets up the plumbing that allows messages received while
   *  the app is not active to be handled by a background isolate.
   *
   *  `FcmDartService#initialized` is called by the Dart side when the plumbing for
   *  background message handling is complete.
   */
  } else if ([@"FcmDartService#start" isEqualToString:method]) {
      
  } else if ([@"FcmDartService#initialized" isEqualToString:method]) {
      /**
       * Acknowledge that background message handling on the Dart side is ready. This is called by the
       * Dart side once all background initialization is complete via `FcmDartService#initialized`.
       */
      @synchronized(self) {
          initialized = YES;
          while ([_eventQueue count] > 0) {
              NSArray* call = _eventQueue[0];
              [_eventQueue removeObjectAtIndex:0];
              
              [self invokeMethod:call[0] callbackHandle:[call[1] longLongValue] arguments:call[2]];
          }
      }
      result(nil);
  } else if ([@"configure" isEqualToString:method]) {
    [FIRMessaging messaging].shouldEstablishDirectChannel = true;
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    if (_launchNotification != nil) {
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
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
  [self didReceiveRemoteNotification:remoteMessage.appData];
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
  // Clears push notifications from the notification center, with the
  // side effect of resetting the badge count. We need to clear notifications
  // because otherwise the user could tap notifications in the notification
  // center while the app is in the foreground, and we wouldn't be able to
  // distinguish that case from the case where a message came in and the
  // user dismissed the notification center without tapping anything.
  // TODO(goderbauer): Revisit this behavior once we provide an API for managing
  // the badge number, or if we add support for running Dart in the background.
  // Setting badgeNumber to 0 is a no-op (= notifications will not be cleared)
  // if it is already 0,
  // therefore the next line is setting it to 1 first before clearing it again
  // to remove all
  // notifications.
  application.applicationIconBadgeNumber = 1;
  application.applicationIconBadgeNumber = 0;
}

- (bool)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (application.applicationState == UIApplicationStateBackground){
        //save this handler for later so it can be completed
        fetchCompletionHandler = completionHandler;
        
        [self queueMethodCall:@"onMessageReceived" callbackName:backgroundMessageCallback arguments:userInfo];
        
        if (!initialized){
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

- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
  NSDictionary *settingsDictionary = @{
    @"sound" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeSound],
    @"badge" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeBadge],
    @"alert" : [NSNumber numberWithBool:notificationSettings.types & UIUserNotificationTypeAlert],
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
    
    [self _saveCallbackHandle:backgroundMessageCallback handle:handle];
    
    NSLog(@"Finished background setup");
}

- (void)startBackgroundRunner {
    NSLog(@"Starting background runner");
    
    int64_t handle = [self getCallbackHandle:backgroundMessageCallback];
    
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

- (int64_t)getCallbackHandle:(NSString *) key {
    NSLog(@"Getting callback handle for key %@", key);
    id handle = [_userDefaults objectForKey:key];
    if (handle == nil) {
        return 0;
    }
    return [handle longLongValue];
}

- (void)_saveCallbackHandle:(NSString *)key handle:(int64_t)handle {
    NSLog(@"Saving callback handle for key %@", key);
    
    [_userDefaults setObject:[NSNumber numberWithLongLong:handle] forKey:key];
}

- (void) queueMethodCall:(NSString *) method callbackName:(NSString*)callback arguments:(NSDictionary*)arguments {
    NSLog(@"Queuing method call: %@", method);
    int64_t handle = [self getCallbackHandle:callback];
    
    @synchronized(self) {
        if (initialized) {
            [self invokeMethod:method callbackHandle:handle arguments:arguments];
        } else {
            NSArray *call = @[method, @(handle), arguments];
            [_eventQueue addObject:call];
        }
    }
}

- (void) invokeMethod:(NSString *) method callbackHandle:(long)handle arguments:(NSDictionary*)arguments {
    NSLog(@"Invoking method: %@", method);
    NSArray* args = @[@(handle), arguments];
    
    [_backgroundChannel invokeMethod:method arguments:args result:^(id  _Nullable result) {
        NSLog(@"%@ method completed", method);
        if (self->fetchCompletionHandler!=nil) {
            self->fetchCompletionHandler(UIBackgroundFetchResultNewData);
            self->fetchCompletionHandler = nil;
        }
    }];
}

@end
