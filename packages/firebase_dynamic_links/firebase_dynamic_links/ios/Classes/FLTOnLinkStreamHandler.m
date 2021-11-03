// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Private/FLTOnLinkStreamHandler.h"
#import "Public/FLTFirebaseDynamicLinksPlugin.h"

@implementation FLTOnLinkStreamHandler {
  FlutterEventSink events;
}

- (instancetype)init {
  self = [super init];
  
  return self;
}

- (void) sinkEvent {
  
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventHandler {
  events = eventHandler;
//  bool __block initialAuthState = YES;
//
//  _listener =
//      [_auth addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
//        if (initialAuthState) {
//          initialAuthState = NO;
//          return;
//        }
//
//        if (user) {
//          events(@{@"user" : [FLTFirebaseAuthPlugin getNSDictionaryFromUser:user]});
//        } else {
//          events(@{
//            @"user" : [NSNull null],
//          });
//        }
//      }];

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
//  if (_listener) {
//    [_auth removeAuthStateDidChangeListener:_listener];
//  }
//  _listener = nil;
//
  return nil;
}

@end
