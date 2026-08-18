// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@import FirebaseAuth;
#import "include/Private/FLTIdTokenChannelStreamHandler.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import "include/Private/PigeonParser.h"
#import "include/Public/FLTFirebaseAuthPlugin.h"

@implementation FLTIdTokenChannelStreamHandler {
  FIRAuth *_auth;
  FIRIDTokenDidChangeListenerHandle _listener;
}

- (instancetype)initWithAuth:(FIRAuth *)auth {
  self = [super init];
  if (self) {
    _auth = auth;
  }
  return self;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  bool __block initialAuthState = YES;

  _listener = [_auth addIDTokenDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                   FIRUser *_Nullable user) {
    if (initialAuthState) {
      initialAuthState = NO;
      return;
    }

    if (user) {
      events(@{
        @"user" : [PigeonParser getManualList:[PigeonParser getPigeonDetails:[auth currentUser]]]
      });
    } else {
      events(@{@"user" : [NSNull null]});
    }
  }];

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  if (_listener) {
    [_auth removeIDTokenDidChangeListener:_listener];
  }
  _listener = nil;

  return nil;
}

@end
