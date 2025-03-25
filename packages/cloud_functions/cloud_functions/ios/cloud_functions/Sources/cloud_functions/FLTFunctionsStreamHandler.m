// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//
//  FLTLoadBundleStreamHandler.m
//  cloud_firestore
//
//  Created by Russell Wheatley on 05/05/2021.
//

@import FirebaseFunctions;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "include/FLTFunctionsStreamHandler.h"

@implementation FLTFunctionsStreamHandler

- (nonnull instancetype)initWithFunctions:(nonnull FIRFunctions *)functions {
    self = [super init];
    if (self) {
      _functions = functions;
    }
    return self;
  }
  
  - (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
  eventSink:(nonnull FlutterEventSink)events {
    
    [self httpsStreamCall:arguments eventSink:events];
    return nil;
  }
  
  - (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
  }

- (void)httpsStreamCall:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events{
  NSString *functionName = arguments[@"functionName"];
  NSString *functionUri = arguments[@"functionUri"];
  NSString *origin = arguments[@"origin"];
  NSObject *parameters = arguments[@"parameters"];
  

  if (origin != nil && origin != (id)[NSNull null]) {
    NSURL *url = [NSURL URLWithString:origin];
    [_functions useEmulatorWithHost:[url host] port:[[url port] intValue]];
  }
  
  if (![functionName isEqual:[NSNull null]]) {
    FIRHTTPSCallable *callable = [_functions HTTPSCallableWithName:functionName];
    [callable ];
  } else if (![functionUri isEqual:[NSNull null]]) {
    
  } else {
    NSDictionary *errorDetails = @{
        @"code": @"IllegalArgumentException",
        @"message": @"Either functionName or functionUri must be set",
        @"details": [NSNull null]
    };
    events(errorDetails);
    return;
  }
}
  @end
  
