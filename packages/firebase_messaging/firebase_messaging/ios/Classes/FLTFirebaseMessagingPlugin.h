// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <Firebase/Firebase.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <firebase_core/FLTFirebasePlugin.h>

#if TARGET_OS_OSX
@interface FLTFirebaseMessagingPlugin : FLTFirebasePlugin <FlutterPlugin,
                                                           FLTFirebasePlugin,
                                                           FIRMessagingDelegate,
                                                           UIApplicationDelegate>
#else
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
API_AVAILABLE(ios(10.0))
@interface FLTFirebaseMessagingPlugin : FLTFirebasePlugin <FlutterPlugin,
                                                           FLTFirebasePlugin,
                                                           FIRMessagingDelegate,
                                                           UNUserNotificationCenterDelegate>
#else
@interface FLTFirebaseMessagingPlugin
    : FLTFirebasePlugin <FlutterPlugin, FLTFirebasePlugin, FIRMessagingDelegate>
#endif
#endif
@end
