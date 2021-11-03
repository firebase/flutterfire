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

- (void)sinkEvent:(id)event {
  // Can be data or error
  events(event);
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventHandler {
  events = eventHandler;

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  // Do nothing
  return nil;
}

@end
