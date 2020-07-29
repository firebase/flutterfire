// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseMLCustomPlugin.h"

static FlutterError* getFlutterError(NSError* error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

@implementation FLTFirebaseMLCustomPlugin

+ (void)handleError:(NSError*)error result:(FlutterResult)result {
  result(getFlutterError(error));
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_ml_custom"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMLCustomPlugin* instance = [[FLTFirebaseMLCustomPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];

  SEL sel = NSSelectorFromString(@"registerLibrary:withVersion:");
  if ([FIRApp respondsToSelector:sel]) {
    [FIRApp performSelector:sel withObject:LIBRARY_NAME withObject:LIBRARY_VERSION];
  }
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* callHandler = [[call.method componentsSeparatedByString:@"#"] objectAtIndex:0];

  if ([@"FirebaseModelManager" isEqualToString:callHandler]) {
    [FLTModelManager handleMethodCall:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
