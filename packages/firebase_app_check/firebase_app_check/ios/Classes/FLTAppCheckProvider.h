// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <FirebaseAppCheck/FIRAppCheck.h>

@interface FLTAppCheckProvider : NSObject <FIRAppCheckProvider>

@property FIRApp *app;

@property id<FIRAppCheckProvider> delegateProvider;

- (void)configure:(FIRApp *)app providerName:(NSString *)providerName;

- (id)initWithApp:(FIRApp *)app;

@end
