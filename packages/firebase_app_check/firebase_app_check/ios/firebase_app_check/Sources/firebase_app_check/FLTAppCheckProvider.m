// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTAppCheckProvider.h"

@implementation FLTAppCheckProvider

- (id)initWithApp:app {
  self = [super init];
  if (self) {
    self.app = app;
  }
  return self;
}

- (void)configure:(FIRApp *)app
     providerName:(NSString *)providerName
       debugToken:(NSString *)debugToken {
  if ([providerName isEqualToString:@"debug"]) {
    if (debugToken != nil) {
      // We have a debug token, so just need to stuff it in the environment and it will hook up
      char *key = "FIRAAppCheckDebugToken", *value = (char *)[debugToken UTF8String];
      int overwrite = 1;
      setenv(key, value, overwrite);
    }
    FIRAppCheckDebugProvider *provider = [[FIRAppCheckDebugProvider alloc] initWithApp:app];
    if (debugToken == nil) NSLog(@"Firebase App Check Debug Token: %@", [provider localDebugToken]);
    self.delegateProvider = provider;
  }

  if ([providerName isEqualToString:@"deviceCheck"]) {
    self.delegateProvider = [[FIRDeviceCheckProvider alloc] initWithApp:app];
  }

  if ([providerName isEqualToString:@"appAttest"]) {
    if (@available(iOS 14.0, macCatalyst 14.0, tvOS 15.0, watchOS 9.0, *)) {
      self.delegateProvider = [[FIRAppAttestProvider alloc] initWithApp:app];
    } else {
      // This is not a valid environment, setup debug provider.
      self.delegateProvider = [[FIRAppCheckDebugProvider alloc] initWithApp:app];
    }
  }

  if ([providerName isEqualToString:@"appAttestWithDeviceCheckFallback"]) {
    if (@available(iOS 14.0, *)) {
      self.delegateProvider = [[FIRAppAttestProvider alloc] initWithApp:app];
    } else {
      self.delegateProvider = [[FIRDeviceCheckProvider alloc] initWithApp:app];
    }
  }
}

- (void)getTokenWithCompletion:(nonnull void (^)(FIRAppCheckToken *_Nullable,
                                                 NSError *_Nullable))handler {
  // Proxying to delegateProvider
  [self.delegateProvider getTokenWithCompletion:handler];
}

@end
