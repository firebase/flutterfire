// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTTokenRefreshStreamHandler.h"
#import "FLTFirebaseAppCheckPlugin.h"

const NSNotificationName FIRAppCheckAppCheckTokenDidChangeNotification =
    @"FIRAppCheckAppCheckTokenDidChangeNotification";

NSString *const kFIRAppCheckTokenNotificationKey = @"FIRAppCheckTokenNotificationKey";
NSString *const kFIRAppCheckAppNameNotificationKey = @"FIRAppCheckAppNameNotificationKey";

@implementation FLTTokenRefreshStreamHandler {
  id _observer;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  _observer = [NSNotificationCenter.defaultCenter
      addObserverForName:FIRAppCheckAppCheckTokenDidChangeNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *_Nonnull note) {
                NSString *token = note.userInfo[kFIRAppCheckTokenNotificationKey];
                NSString *appName = note.userInfo[kFIRAppCheckAppNameNotificationKey];

                events(@{@"token" : token, @"appName" : appName});
              }];

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  [NSNotificationCenter.defaultCenter removeObserver:_observer];
  return nil;
}

@end
