// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebasePluginRegistry.h"
#import <FirebaseCore/FIRAppInternal.h>

@implementation FLTFirebasePluginRegistry {
  NSMutableDictionary<NSString *, id<FLTFirebasePlugin>> *registeredPlugins;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    registeredPlugins = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebasePluginRegistry *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebasePluginRegistry alloc] init];
  });

  return instance;
}

- (void)registerFirebasePlugin:(id<FLTFirebasePlugin>)firebasePlugin {
  // Register the library with the Firebase backend.
  [FIRApp registerLibrary:[firebasePlugin firebaseLibraryName]
              withVersion:[firebasePlugin firebaseLibraryVersion]];

  // Store the plugin delegate for later usage.
  registeredPlugins[[firebasePlugin flutterChannelName]] = firebasePlugin;
}

- (NSDictionary *)pluginConstantsForFIRApp:(FIRApp *)firebaseApp {
  NSString *pluginFlutterChannelName;
  NSMutableDictionary *pluginConstants = [NSMutableDictionary dictionary];

  for (pluginFlutterChannelName in registeredPlugins) {
    pluginConstants[pluginFlutterChannelName] =
        [registeredPlugins[pluginFlutterChannelName] pluginConstantsForFIRApp:firebaseApp];
  }

  return pluginConstants;
}

- (void)didReinitializeFirebaseCore:(void (^_Nonnull)(void))completion {
  __block int pluginsCompleted = 0;
  NSUInteger pluginsCount = [self->registeredPlugins allKeys].count;
  void (^allPluginsCompletion)(void) = ^void() {
    pluginsCompleted++;
    if (pluginsCompleted == pluginsCount) {
      completion();
    }
  };

  for (NSString *pluginFlutterChannelName in registeredPlugins) {
    [registeredPlugins[pluginFlutterChannelName] didReinitializeFirebaseCore:allPluginsCompletion];
  }
}

@end
