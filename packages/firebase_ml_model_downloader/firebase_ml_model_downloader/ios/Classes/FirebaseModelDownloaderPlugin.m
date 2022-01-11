// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseModelDownloaderPlugin.h"
#if __has_include(<firebase_ml_model_downloader/firebase_ml_model_downloader-Swift.h>)
#import <firebase_ml_model_downloader/firebase_ml_model_downloader-Swift.h>
#else
#import "firebase_ml_model_downloader-Swift.h"
#endif

@implementation FirebaseModelDownloaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [FirebaseModelDownloaderPluginSwift registerWithRegistrar:registrar];
  [[FLTFirebasePluginRegistry sharedInstance]
      registerFirebasePlugin:[FirebaseModelDownloaderPlugin alloc]];
}

- (void)didReinitializeFirebaseCore:(void (^_Nonnull)(void))completion {
  completion();
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return @"plugins.flutter.io/firebase_ml_model_downloader";
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *_Nonnull)firebaseApp {
  return @{};
}

@end