// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebasePerformancePlugin+Internal.h"

@interface FLTHttpMetric ()
@property FIRHTTPMetric *metric;
@end

@implementation FLTHttpMetric
- (instancetype _Nonnull)initWithHTTPMetric:(FIRHTTPMetric *)metric {
  self = [self init];
  if (self) {
    _metric = metric;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"HttpMetric#start" isEqualToString:call.method]) {
    [self start:result];
  } else if ([@"HttpMetric#stop" isEqualToString:call.method]) {
    [self stop:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)start:(FlutterResult)result {
  [_metric start];
  result(nil);
}

- (void)stop:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *attributes = call.arguments[@"attributes"];
  NSNumber *httpResponseCode = call.arguments[@"httpResponseCode"];
  NSNumber *requestPayloadSize = call.arguments[@"requestPayloadSize"];
  NSString *responseContentType = call.arguments[@"responseContentType"];
  NSNumber *responsePayloadSize = call.arguments[@"responsePayloadSize"];

  [attributes
      enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSString *value, BOOL *stop) {
        [_metric setValue:value forAttribute:attributeName];
      }];

  if (httpResponseCode != nil) {
    _metric.responseCode = [httpResponseCode integerValue];
  }
  if (responseContentType != nil) {
    _metric.responseContentType = responseContentType;
  }
  if (requestPayloadSize != nil) {
    _metric.requestPayloadSize = [requestPayloadSize longValue];
  }
  if (responsePayloadSize != nil) {
    _metric.responsePayloadSize = [responsePayloadSize longValue];
  }

  [_metric stop];

  NSNumber *handle = call.arguments[@"handle"];
  [FLTFirebasePerformancePlugin removeMethodHandler:handle];

  result(nil);
}

@end
