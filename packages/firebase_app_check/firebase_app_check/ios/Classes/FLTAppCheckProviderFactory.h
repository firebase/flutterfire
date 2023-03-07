// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <FirebaseAppCheck/FIRAppCheckProviderFactory.h>

@interface FLTAppCheckProviderFactory : NSObject <FIRAppCheckProviderFactory>

@property NSMutableDictionary *_Nullable providers;

- (void)configure:(FIRApp *_Nonnull)app providerName:(NSString *_Nonnull)providerName;

@end
