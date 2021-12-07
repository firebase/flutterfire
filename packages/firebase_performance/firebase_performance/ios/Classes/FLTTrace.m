// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebasePerformancePlugin+Internal.h"

@interface FLTTrace ()
@property FIRTrace *trace;
@end

@implementation FLTTrace
- (instancetype _Nonnull)initWithTrace:(FIRTrace *)trace {
  self = [self init];
  if (self) {
    _trace = trace;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"Trace#start" isEqualToString:call.method]) {
    [self start:result];
  } else if ([@"Trace#stop" isEqualToString:call.method]) {
    [self stop:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)start:(FlutterResult)result {
  [_trace start];
  result(nil);
}

- (void)stop:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *metrics = call.arguments[@"metrics"];
  NSDictionary *attributes = call.arguments[@"attributes"];

  [metrics enumerateKeysAndObjectsUsingBlock:^(NSString *metricName, NSNumber *value, BOOL *stop) {
    [_trace setIntValue:[value longLongValue] forMetric:metricName];
  }];

  [attributes
      enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSString *value, BOOL *stop) {
        [_trace setValue:value forAttribute:attributeName];
      }];

  [_trace stop];

  NSNumber *handle = call.arguments[@"handle"];
  [FLTFirebasePerformancePlugin removeMethodHandler:handle];

  result(nil);
}
@end
