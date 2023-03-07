// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <FirebaseAppCheck/FIRAppCheck.h>

#import <Firebase/Firebase.h>
#import <FirebaseAppCheck/FIRAppCheck.h>
#import "FLTAppCheckProviderFactory.h"

#import "FLTAppCheckProvider.h"

@implementation FLTAppCheckProviderFactory

- (nullable id<FIRAppCheckProvider>)createProviderWithApp:(FIRApp *)app {
  // The SDK may try to call this before we have been configured,
  // so we will configure ourselves and set the provider up as a default to start
  // pre-configure
  if (self.providers == nil) {
    self.providers = [NSMutableDictionary new];
  }

  if (self.providers[app.name] == nil) {
    self.providers[app.name] = [FLTAppCheckProvider new];
    FLTAppCheckProvider *provider = self.providers[app.name];
    // We set "deviceCheck" as this is currently what is default. Backward compatible.
    [provider configure:app providerName:@"deviceCheck"];
  }

  return self.providers[app.name];
}

- (void)configure:(FIRApp *)app providerName:(NSString *)providerName {
  if (self.providers == nil) {
    self.providers = [NSMutableDictionary new];
  }

  if (self.providers[app.name] == nil) {
    self.providers[app.name] = [FLTAppCheckProvider new];
  }

  FLTAppCheckProvider *provider = self.providers[app.name];
  [provider configure:app providerName:providerName];
}

@end
