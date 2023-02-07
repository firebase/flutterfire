// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebasePerformancePlugin.h"

#import <Firebase/Firebase.h>

#import <firebase_core/FLTFirebasePluginRegistry.h>

NSString *const kFLTFirebasePerformanceChannelName = @"plugins.flutter.io/firebase_performance";

@implementation FLTFirebasePerformancePlugin {
  NSMutableDictionary<NSNumber *, FIRHTTPMetric *> *_httpMetrics;
  NSMutableDictionary<NSNumber *, FIRTrace *> *_traces;
  NSNumber *_traceHandle;
  NSNumber *_httpMetricHandle;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:self];
    _httpMetrics = [NSMutableDictionary<NSNumber *, FIRHTTPMetric *> dictionary];
    _traces = [NSMutableDictionary<NSNumber *, FIRTrace *> dictionary];
    _traceHandle = [NSNumber numberWithInt:0];
    _httpMetricHandle = [NSNumber numberWithInt:0];
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebasePerformanceChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTFirebasePerformancePlugin *instance = [[FLTFirebasePerformancePlugin alloc] init];

  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock =
      ^(NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
        NSError *_Nullable error) {
        // `result.error` is not called in this plugin so this block does nothing.
        flutterResult(nil);
      };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"FirebasePerformance#isPerformanceCollectionEnabled" isEqualToString:call.method]) {
    [self isPerformanceCollectionEnabled:methodCallResult];
  } else if ([@"FirebasePerformance#setPerformanceCollectionEnabled" isEqualToString:call.method]) {
    [self setPerformanceCollectionEnabled:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebasePerformance#httpMetricStart" isEqualToString:call.method]) {
    [self httpMetricStart:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebasePerformance#httpMetricStop" isEqualToString:call.method]) {
    [self httpMetricStop:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebasePerformance#traceStart" isEqualToString:call.method]) {
    [self traceStart:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"FirebasePerformance#traceStop" isEqualToString:call.method]) {
    [self traceStop:call.arguments withMethodCallResult:methodCallResult];
  } else {
    methodCallResult.success(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase Performance API

- (void)isPerformanceCollectionEnabled:(FLTFirebaseMethodCallResult *)result {
  result.success(@([[FIRPerformance sharedInstance] isDataCollectionEnabled]));
}

- (void)setPerformanceCollectionEnabled:(id)arguments
                   withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSNumber *enable = arguments[@"enable"];

  [[FIRPerformance sharedInstance] setDataCollectionEnabled:[enable boolValue]];
  result.success(nil);
}

- (void)httpMetricStart:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRHTTPMethod method = [FLTFirebasePerformancePlugin parseHttpMethod:arguments[@"httpMethod"]];
  NSURL *url = [NSURL URLWithString:arguments[@"url"]];
  FIRHTTPMetric *httpMetric = [[FIRHTTPMetric alloc] initWithURL:url HTTPMethod:method];
  if (httpMetric == nil) {
    // Performance collection is disabled
    result.success(nil);
    return;
  }

  [httpMetric start];
  _httpMetricHandle = [NSNumber numberWithInt:[_httpMetricHandle intValue] + 1];

  [_httpMetrics setObject:httpMetric forKey:_httpMetricHandle];
  result.success(_httpMetricHandle);
}

- (void)httpMetricStop:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSDictionary *attributes = arguments[@"attributes"];
  NSNumber *httpResponseCode = arguments[@"httpResponseCode"];
  NSNumber *requestPayloadSize = arguments[@"requestPayloadSize"];
  NSString *responseContentType = arguments[@"responseContentType"];
  NSNumber *responsePayloadSize = arguments[@"responsePayloadSize"];
  NSNumber *handle = arguments[@"handle"];

  FIRHTTPMetric *httpMetric = [_httpMetrics objectForKey:handle];

  [attributes
      enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSString *value, BOOL *stop) {
        [httpMetric setValue:value forAttribute:attributeName];
      }];

  if (httpResponseCode != nil) {
    httpMetric.responseCode = [httpResponseCode integerValue];
  }
  if (responseContentType != nil) {
    httpMetric.responseContentType = responseContentType;
  }
  if (requestPayloadSize != nil) {
    httpMetric.requestPayloadSize = [requestPayloadSize longValue];
  }
  if (responsePayloadSize != nil) {
    httpMetric.responsePayloadSize = [responsePayloadSize longValue];
  }

  [httpMetric stop];
  [_httpMetrics removeObjectForKey:handle];

  result.success(nil);
}

- (void)traceStart:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSString *name = arguments[@"name"];

  FIRTrace *trace = [FIRPerformance startTraceWithName:name];
  if (trace == nil) {
    // Performance collection is disabled
    result.success(nil);
    return;
  }
  _traceHandle = [NSNumber numberWithInt:[_traceHandle intValue] + 1];
  [_traces setObject:trace forKey:_traceHandle];

  result.success(_traceHandle);
}

- (void)traceStop:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  NSDictionary *metrics = arguments[@"metrics"];
  NSDictionary *attributes = arguments[@"attributes"];
  NSNumber *handle = arguments[@"handle"];

  FIRTrace *trace = [_traces objectForKey:handle];

  [metrics enumerateKeysAndObjectsUsingBlock:^(NSString *metricName, NSNumber *value, BOOL *stop) {
    [trace setIntValue:[value longLongValue] forMetric:metricName];
  }];

  [attributes
      enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSString *value, BOOL *stop) {
        [trace setValue:value forAttribute:attributeName];
      }];

  [trace stop];
  [_traces removeObjectForKey:handle];

  result.success(nil);
}

+ (FIRHTTPMethod)parseHttpMethod:(NSString *)method {
  if ([@"HttpMethod.Connect" isEqualToString:method]) {
    return FIRHTTPMethodCONNECT;
  } else if ([@"HttpMethod.Delete" isEqualToString:method]) {
    return FIRHTTPMethodDELETE;
  } else if ([@"HttpMethod.Get" isEqualToString:method]) {
    return FIRHTTPMethodGET;
  } else if ([@"HttpMethod.Head" isEqualToString:method]) {
    return FIRHTTPMethodHEAD;
  } else if ([@"HttpMethod.Options" isEqualToString:method]) {
    return FIRHTTPMethodOPTIONS;
  } else if ([@"HttpMethod.Patch" isEqualToString:method]) {
    return FIRHTTPMethodPATCH;
  } else if ([@"HttpMethod.Post" isEqualToString:method]) {
    return FIRHTTPMethodPOST;
  } else if ([@"HttpMethod.Put" isEqualToString:method]) {
    return FIRHTTPMethodPUT;
  } else if ([@"HttpMethod.Trace" isEqualToString:method]) {
    return FIRHTTPMethodTRACE;
  }

  NSString *reason = [NSString stringWithFormat:@"Invalid HttpMethod: %@", method];
  @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  for (FIRTrace *trace in self->_traces.allValues) {
    [trace stop];
  }
  [self->_traces removeAllObjects];

  for (FIRHTTPMetric *httpMetric in self->_httpMetrics.allValues) {
    [httpMetric stop];
  }
  [self->_httpMetrics removeAllObjects];

  if (completion != nil) {
    completion();
  }
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{};
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebasePerformanceChannelName;
}

@end
