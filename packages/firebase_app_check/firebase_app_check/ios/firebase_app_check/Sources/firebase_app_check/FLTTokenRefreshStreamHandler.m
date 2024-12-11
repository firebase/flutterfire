// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTTokenRefreshStreamHandler.h"
#import "FLTFirebaseAppCheckPlugin.h"

const NSNotificationName kNotififactionEvent = @"FIRAppCheckAppCheckTokenDidChangeNotification";

NSString *const kTokenKey = @"FIRAppCheckTokenNotificationKey";

@implementation FLTTokenRefreshStreamHandler {
  id _observer;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  _observer =
      [NSNotificationCenter.defaultCenter addObserverForName:kNotififactionEvent
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *_Nonnull note) {
                                                    NSString *token = note.userInfo[kTokenKey];

                                                    events(@{@"token" : token});
                                                  }];

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  [NSNotificationCenter.defaultCenter removeObserver:_observer];
  return nil;
}

@end
