// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@import FirebaseStorage;

#import "FLTTaskStateChannelStreamHandler.h"
#import "FLTFirebaseStoragePlugin.h"

@implementation FLTTaskStateChannelStreamHandler {
  FIRStorageObservableTask *_task;
  FLTFirebaseStoragePlugin *_storagePlugin;
  NSString *_channelName;
  NSNumber *_handle;
  NSString *successHandle;
  NSString *failureHandle;
  NSString *pausedHandle;
  NSString *progressHandle;
}

- (instancetype)initWithTask:(FIRStorageObservableTask *)task
               storagePlugin:(FLTFirebaseStoragePlugin *)storagePlugin
                 channelName:(NSString *)channelName
                      handle:(NSNumber *)handle {
  self = [super init];
  if (self) {
    _task = task;
    _storagePlugin = storagePlugin;
    _channelName = channelName;
    _handle = handle;
  }
  return self;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  // Set up the various status listeners
  successHandle =
      [_task observeStatus:FIRStorageTaskStatusSuccess
                   handler:^(FIRStorageTaskSnapshot *snapshot) {
                     events(@{
                       @"taskState" : @(PigeonStorageTaskStateSuccess),
                       @"appName" : snapshot.reference.storage.app.name,
                       @"snapshot" : [FLTFirebaseStoragePlugin parseTaskSnapshot:snapshot],
                     });
                   }];
  failureHandle =
      [_task observeStatus:FIRStorageTaskStatusFailure
                   handler:^(FIRStorageTaskSnapshot *snapshot) {
                     NSError *error = snapshot.error;
                     // If the snapshot.error is "unknown" and there is an underlying error, use
                     // this. For UploadTasks, the correct error is in the underlying error.
                     if (snapshot.error.code == FIRStorageErrorCodeUnknown &&
                         snapshot.error.userInfo[@"NSUnderlyingError"] != nil) {
                       error = snapshot.error.userInfo[@"NSUnderlyingError"];
                     }
                     events(@{
                       @"taskState" : @(PigeonStorageTaskStateError),
                       @"appName" : snapshot.reference.storage.app.name,
                       @"error" : [FLTFirebaseStoragePlugin NSDictionaryFromNSError:error],
                     });
                   }];
  pausedHandle =
      [_task observeStatus:FIRStorageTaskStatusPause
                   handler:^(FIRStorageTaskSnapshot *snapshot) {
                     events(@{
                       @"taskState" : @(PigeonStorageTaskStatePaused),
                       @"appName" : snapshot.reference.storage.app.name,
                       @"snapshot" : [FLTFirebaseStoragePlugin parseTaskSnapshot:snapshot],
                     });
                   }];
  progressHandle =
      [_task observeStatus:FIRStorageTaskStatusProgress
                   handler:^(FIRStorageTaskSnapshot *snapshot) {
                     events(@{
                       @"taskState" : @(PigeonStorageTaskStateRunning),
                       @"appName" : snapshot.reference.storage.app.name,
                       @"snapshot" : [FLTFirebaseStoragePlugin parseTaskSnapshot:snapshot],
                     });
                   }];

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  if (!_task) {
    return nil;
  }

  if (successHandle) {
    [_task removeObserverWithHandle:successHandle];
  }
  successHandle = nil;

  if (failureHandle) {
    [_task removeObserverWithHandle:failureHandle];
  }
  failureHandle = nil;

  if (pausedHandle) {
    [_task removeObserverWithHandle:pausedHandle];
  }
  pausedHandle = nil;

  if (progressHandle) {
    [_task removeObserverWithHandle:progressHandle];
  }
  progressHandle = nil;

  if (_storagePlugin) {
    [_storagePlugin cleanUpTask:_channelName handle:_handle];
  }

  return nil;
}

@end
