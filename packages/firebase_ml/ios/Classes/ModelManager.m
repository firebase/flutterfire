// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseMLPlugin.h"

@implementation ModelManager

+ (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"FirebaseModelManager#download" isEqualToString:call.method]) {
    [ModelManager download:call result:result];
  } else if ([@"FirebaseModelManager#getLatestModelFile" isEqualToString:call.method]) {
    [ModelManager getLatestModelFile:call result:result];
  } else if ([@"FirebaseModelManager#isModelDownloaded" isEqualToString:call.method]) {
    [ModelManager isModelDownloaded:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)download:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *modelName = call.arguments[@"modelName"];
  NSDictionary *conditionsToMap = call.arguments[@"conditions"];
  BOOL allowsCellularAccess = [conditionsToMap objectForKey:@"allowCellularAccess"];
  BOOL allowBackgroundDownloading = [conditionsToMap objectForKey:@"allowBackgroundDownloading"];

  FIRCustomRemoteModel *remoteModel = [[FIRCustomRemoteModel alloc] initWithName:modelName];
  FIRModelDownloadConditions *downloadConditions =
      [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:allowsCellularAccess
                                           allowsBackgroundDownloading:allowBackgroundDownloading];

  [[FIRModelManager modelManager] downloadModel:remoteModel conditions:downloadConditions];

  __weak typeof(self) weakSelf = self;

  [NSNotificationCenter.defaultCenter
      addObserverForName:FIRModelDownloadDidSucceedNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *_Nonnull note) {
                if (weakSelf == nil | note.userInfo == nil) {
                  return;
                }
                __strong typeof(self) strongSelf = weakSelf;

                FIRRemoteModel *model = note.userInfo[FIRModelDownloadUserInfoKeyRemoteModel];
                if ([model.name isEqualToString:modelName]) {
                  result(@"Model successfully downloaded");
                } else {
                  NSError *error = note.userInfo[FIRModelDownloadUserInfoKeyError];
                  result(error);
                }
              }];

  [NSNotificationCenter.defaultCenter addObserverForName:FIRModelDownloadDidFailNotification
                                                  object:nil
                                                   queue:nil
                                              usingBlock:^(NSNotification *_Nonnull note) {
                                                if (weakSelf == nil | note.userInfo == nil) {
                                                  return;
                                                }
                                                __strong typeof(self) strongSelf = weakSelf;

                                                NSError *error =
                                                    note.userInfo[FIRModelDownloadUserInfoKeyError];
                                                result(error);
                                              }];
}

+ (void)getLatestModelFile:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *modelName = call.arguments[@"modelName"];
  FIRCustomRemoteModel *remoteModel = [[FIRCustomRemoteModel alloc] initWithName:modelName];

  [FIRModelManager.modelManager
      getLatestModelFilePath:remoteModel
                  completion:^(NSString *_Nullable remoteModelPath, NSError *error) {
                    if (remoteModelPath != nil && error == nil) {
                      NSLog(@"-- remoteModelPath: %@", remoteModelPath);
                      result([NSString stringWithString:remoteModelPath]);
                    } else {
                      result(error);
                    }
                  }];
}

+ (void)isModelDownloaded:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *modelName = call.arguments[@"modelName"];
  FIRCustomRemoteModel *remoteModel = [[FIRCustomRemoteModel alloc] initWithName:modelName];

  BOOL isModelDownloaded = [[FIRModelManager modelManager] isModelDownloaded:remoteModel];
  result(@(isModelDownloaded));
}

@end