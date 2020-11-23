// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "FLTFirebaseStoragePlugin.h"

static NSString *const kFLTFirebaseStorageChannelName = @"plugins.flutter.io/firebase_storage";
static NSString *const kFLTFirebaseStorageKeyCacheControl = @"cacheControl";
static NSString *const kFLTFirebaseStorageKeyContentDisposition = @"contentDisposition";
static NSString *const kFLTFirebaseStorageKeyContentEncoding = @"contentEncoding";
static NSString *const kFLTFirebaseStorageKeyContentLanguage = @"contentLanguage";
static NSString *const kFLTFirebaseStorageKeyContentType = @"contentType";
static NSString *const kFLTFirebaseStorageKeyCustomMetadata = @"customMetadata";
static NSString *const kFLTFirebaseStorageKeyName = @"name";
static NSString *const kFLTFirebaseStorageKeyBucket = @"bucket";
static NSString *const kFLTFirebaseStorageKeyGeneration = @"generation";
static NSString *const kFLTFirebaseStorageKeyMetadataGeneration = @"metadataGeneration";
static NSString *const kFLTFirebaseStorageKeyFullPath = @"fullPath";
static NSString *const kFLTFirebaseStorageKeySize = @"size";
static NSString *const kFLTFirebaseStorageKeyCreationTime = @"creationTimeMillis";
static NSString *const kFLTFirebaseStorageKeyUpdatedTime = @"updatedTimeMillis";
static NSString *const kFLTFirebaseStorageKeyMD5Hash = @"md5Hash";
static NSString *const kFLTFirebaseStorageKeyAppName = @"appName";
static NSString *const kFLTFirebaseStorageKeyMaxOperationRetryTime = @"maxOperationRetryTime";
static NSString *const kFLTFirebaseStorageKeyMaxDownloadRetryTime = @"maxDownloadRetryTime";
static NSString *const kFLTFirebaseStorageKeyMaxUploadRetryTime = @"maxUploadRetryTime";
static NSString *const kFLTFirebaseStorageKeyPath = @"path";
static NSString *const kFLTFirebaseStorageKeySnapshot = @"snapshot";
static NSString *const kFLTFirebaseStorageKeyHandle = @"handle";
static NSString *const kFLTFirebaseStorageKeyMetadata = @"metadata";
static NSString *const kFLTFirebaseStorageKeyPageToken = @"pageToken";
static NSString *const kFLTFirebaseStorageKeyOptions = @"options";
static NSString *const kFLTFirebaseStorageKeyMaxResults = @"maxResults";
static NSString *const kFLTFirebaseStorageKeyItems = @"items";
static NSString *const kFLTFirebaseStorageKeyPrefixes = @"prefixes";
static NSString *const kFLTFirebaseStorageKeyNextPageToken = @"nextPageToken";
static NSString *const kFLTFirebaseStorageKeyMaxSize = @"maxSize";

typedef NS_ENUM(NSUInteger, FLTFirebaseStorageTaskState) {
  FLTFirebaseStorageTaskStateCancel = 0,
  FLTFirebaseStorageTaskStatePause = 1,
  FLTFirebaseStorageTaskStateResume = 2,
};

typedef NS_ENUM(NSUInteger, FLTFirebaseStorageTaskType) {
  FLTFirebaseStorageTaskTypeFile = 0,
  FLTFirebaseStorageTaskTypeBytes = 1,
  FLTFirebaseStorageTaskTypeDownload = 2,
  FLTFirebaseStorageTaskTypeString = 3,
};

typedef NS_ENUM(NSUInteger, FLTFirebaseStorageStringType) {
  // FLTFirebaseStorageStringTypeRaw = 0, // unused
  FLTFirebaseStorageStringTypeBase64 = 1,
  FLTFirebaseStorageStringTypeBase64URL = 2,
  // FLTFirebaseStorageStringTypeDataUrl = 3, // unused
};

@interface FLTFirebaseStoragePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTFirebaseStoragePlugin {
  NSMutableDictionary<NSNumber *, FIRStorageObservableTask<FIRStorageTaskManagement> *> *_tasks;
  dispatch_queue_t _callbackQueue;
}

#pragma mark - FlutterPlugin

// Returns a singleton instance of the Firebase Storage plugin.
+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static FLTFirebaseStoragePlugin *instance;

  dispatch_once(&onceToken, ^{
    instance = [[FLTFirebaseStoragePlugin alloc] init];
    // Register with the Flutter Firebase plugin registry.
    [[FLTFirebasePluginRegistry sharedInstance] registerFirebasePlugin:instance];
  });

  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _tasks = [NSMutableDictionary<NSNumber *, FIRStorageObservableTask<FIRStorageTaskManagement> *>
        dictionary];
    _callbackQueue =
        dispatch_queue_create("io.flutter.plugins.firebase.storage", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kFLTFirebaseStorageChannelName
                                  binaryMessenger:[registrar messenger]];

  FLTFirebaseStoragePlugin *instance = [FLTFirebaseStoragePlugin sharedInstance];
  instance.channel = channel;
#if TARGET_OS_OSX
  // TODO(Salakar): Publish does not exist on MacOS version of FlutterPluginRegistrar.
#else
  [registrar publish:instance];
#endif
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)cleanupWithCompletion:(void (^)(void))completion {
  @synchronized(self->_tasks) {
    for (NSNumber *key in [self->_tasks allKeys]) {
      FIRStorageObservableTask<FIRStorageTaskManagement> *task = self->_tasks[key];
      if (task != nil) {
        [task removeAllObservers];
        [task cancel];
      }
    }
    [self->_tasks removeAllObjects];
    if (completion != nil) completion();
  }
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self cleanupWithCompletion:^() {
    self.channel = nil;
  }];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)flutterResult {
  FLTFirebaseMethodCallErrorBlock errorBlock = ^(
      NSString *_Nullable code, NSString *_Nullable message, NSDictionary *_Nullable details,
      NSError *_Nullable error) {
    if (code == nil) {
      NSDictionary *errorDetails = [self NSDictionaryFromNSError:error];
      code = errorDetails[@"code"];
      message = errorDetails[@"message"];
      details = errorDetails;
    }
    if ([@"unknown" isEqualToString:code]) {
      NSLog(@"FLTFirebaseStorage: An unknown error occurred while calling method %@", call.method);
    }
    flutterResult([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                        message:message
                                                optionalDetails:details
                                             andOptionalNSError:error]);
  };

  FLTFirebaseMethodCallResult *methodCallResult =
      [FLTFirebaseMethodCallResult createWithSuccess:flutterResult andErrorBlock:errorBlock];

  if ([@"Reference#delete" isEqualToString:call.method]) {
    [self referenceDelete:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Reference#getDownloadURL" isEqualToString:call.method]) {
    [self referenceGetDownloadUrl:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Reference#getMetadata" isEqualToString:call.method]) {
    [self referenceGetMetadata:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Reference#getData" isEqualToString:call.method]) {
    [self referenceGetData:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Reference#list" isEqualToString:call.method]) {
    [self referenceList:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Reference#listAll" isEqualToString:call.method]) {
    [self referenceListAll:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Reference#updateMetadata" isEqualToString:call.method]) {
    [self referenceUpdateMetadata:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#startPutData" isEqualToString:call.method]) {
    [self taskStartPutData:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#startPutString" isEqualToString:call.method]) {
    [self taskStartPutString:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#startPutFile" isEqualToString:call.method]) {
    [self taskStartPutFile:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#pause" isEqualToString:call.method]) {
    [self taskPause:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#resume" isEqualToString:call.method]) {
    [self taskResume:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#cancel" isEqualToString:call.method]) {
    [self taskCancel:call.arguments withMethodCallResult:methodCallResult];
  } else if ([@"Task#writeToFile" isEqualToString:call.method]) {
    [self taskWriteToFile:call.arguments withMethodCallResult:methodCallResult];
  } else {
    flutterResult(FlutterMethodNotImplemented);
  }
}

#pragma mark - Firebase Storage API

- (void)referenceDelete:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  [reference deleteWithCompletion:^(NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(nil);
    }
  }];
}

- (void)referenceGetDownloadUrl:(id)arguments
           withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  [reference downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success(@{
        @"downloadURL" : URL.absoluteString,
      });
    }
  }];
}

- (void)referenceGetMetadata:(id)arguments
        withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  [reference metadataWithCompletion:^(FIRStorageMetadata *metadata, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success([self NSDictionaryFromFIRStorageMetadata:metadata]);
    }
  }];
}

- (void)referenceGetData:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  NSNumber *maxSize = arguments[kFLTFirebaseStorageKeyMaxSize];
  [reference dataWithMaxSize:[maxSize longLongValue]
                  completion:^(NSData *_Nullable data, NSError *_Nullable error) {
                    if (error != nil) {
                      result.error(nil, nil, nil, error);
                      return;
                    }

                    FlutterStandardTypedData *typedData;
                    if (data == nil) {
                      typedData =
                          [FlutterStandardTypedData typedDataWithBytes:[[NSData alloc] init]];
                    } else {
                      typedData = [FlutterStandardTypedData typedDataWithBytes:data];
                    }

                    result.success(typedData);
                  }];
}

- (void)referenceList:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  NSDictionary *options = arguments[kFLTFirebaseStorageKeyOptions];
  long maxResults = [options[kFLTFirebaseStorageKeyMaxResults] longValue];
  id completion = ^(FIRStorageListResult *listResult, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success([self NSDictionaryFromFIRStorageListResult:listResult]);
    }
  };

  NSString *pageToken = options[kFLTFirebaseStorageKeyPageToken];
  if ([pageToken isEqual:[NSNull null]]) {
    [reference listWithMaxResults:(int64_t)maxResults completion:completion];
  } else {
    [reference listWithMaxResults:(int64_t)maxResults pageToken:pageToken completion:completion];
  }
}

- (void)referenceListAll:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  [reference listAllWithCompletion:^(FIRStorageListResult *listResult, NSError *error) {
    if (error != nil) {
      result.error(nil, nil, nil, error);
    } else {
      result.success([self NSDictionaryFromFIRStorageListResult:listResult]);
    }
  }];
}

- (void)referenceUpdateMetadata:(id)arguments
           withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
  FIRStorageMetadata *metadata =
      [self FIRStorageMetadataFromNSDictionary:arguments[kFLTFirebaseStorageKeyMetadata]];
  [reference updateMetadata:metadata
                 completion:^(FIRStorageMetadata *updatedMetadata, NSError *error) {
                   if (error != nil) {
                     result.error(nil, nil, nil, error);
                   } else {
                     result.success([self NSDictionaryFromFIRStorageMetadata:updatedMetadata]);
                   }
                 }];
}

- (void)taskStartPutData:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [self startFIRStorageObservableTaskForArguments:arguments
                    andFLTFirebaseStorageTaskType:FLTFirebaseStorageTaskTypeBytes];
  result.success(nil);
}

- (void)taskStartPutString:(id)arguments
      withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [self startFIRStorageObservableTaskForArguments:arguments
                    andFLTFirebaseStorageTaskType:FLTFirebaseStorageTaskTypeString];
  result.success(nil);
}

- (void)taskStartPutFile:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [self startFIRStorageObservableTaskForArguments:arguments
                    andFLTFirebaseStorageTaskType:FLTFirebaseStorageTaskTypeFile];
  result.success(nil);
}

- (void)taskWriteToFile:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  [self startFIRStorageObservableTaskForArguments:arguments
                    andFLTFirebaseStorageTaskType:FLTFirebaseStorageTaskTypeDownload];
  result.success(nil);
}

- (void)taskPause:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  dispatch_async(self->_callbackQueue, ^() {
    NSNumber *handle = arguments[kFLTFirebaseStorageKeyHandle];
    FIRStorageObservableTask<FIRStorageTaskManagement> *task;
    @synchronized(self->_tasks) {
      task = self->_tasks[handle];
    }
    if (task != nil) {
      [self setState:FLTFirebaseStorageTaskStatePause
          forFIRStorageObservableTask:task
                       withCompletion:^(BOOL success, NSDictionary *snapshotDict) {
                         result.success(@{
                           @"status" : @(success),
                           @"snapshot" : (id)snapshotDict ?: [NSNull null],
                         });
                       }];
    } else {
      result.success(@{
        @"status" : @(NO),
      });
    }
  });
}

- (void)taskResume:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  dispatch_async(self->_callbackQueue, ^() {
    NSNumber *handle = arguments[kFLTFirebaseStorageKeyHandle];
    FIRStorageObservableTask<FIRStorageTaskManagement> *task;
    @synchronized(self->_tasks) {
      task = self->_tasks[handle];
    }
    if (task != nil) {
      [self setState:FLTFirebaseStorageTaskStateResume
          forFIRStorageObservableTask:task
                       withCompletion:^(BOOL success, NSDictionary *snapshotDict) {
                         result.success(@{
                           @"status" : @(success),
                           @"snapshot" : (id)snapshotDict ?: [NSNull null],
                         });
                       }];
    } else {
      result.success(@{
        @"status" : @(NO),
      });
    }
  });
}

- (void)taskCancel:(id)arguments withMethodCallResult:(FLTFirebaseMethodCallResult *)result {
  dispatch_async(self->_callbackQueue, ^() {
    NSNumber *handle = arguments[kFLTFirebaseStorageKeyHandle];
    FIRStorageObservableTask<FIRStorageTaskManagement> *task;
    @synchronized(self->_tasks) {
      task = self->_tasks[handle];
    }
    if (task != nil) {
      [self setState:FLTFirebaseStorageTaskStateCancel
          forFIRStorageObservableTask:task
                       withCompletion:^(BOOL success, NSDictionary *snapshotDict) {
                         result.success(@{
                           @"status" : @(success),
                           @"snapshot" : (id)snapshotDict ?: [NSNull null],
                         });
                       }];
    } else {
      result.success(@{
        @"status" : @(NO),
      });
    }
  });
}

#pragma mark - Utilities

// To match Web & Android SDKs we need to return a bool of whether a task state change was
// successful.
- (void)setState:(FLTFirebaseStorageTaskState)state
    forFIRStorageObservableTask:(FIRStorageObservableTask<FIRStorageTaskManagement> *)task
                 withCompletion:(void (^)(BOOL, NSDictionary *))completion {
  // Pause
  if (state == FLTFirebaseStorageTaskStatePause) {
    if (task.snapshot.status == FIRStorageTaskStatusResume ||
        task.snapshot.status == FIRStorageTaskStatusProgress ||
        task.snapshot.status == FIRStorageTaskStatusUnknown) {
      __block FIRStorageHandle pauseHandle;
      __block FIRStorageHandle successHandle;
      __block FIRStorageHandle failureHandle;
      pauseHandle =
          [task observeStatus:FIRStorageTaskStatusPause
                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                        [task removeObserverWithHandle:pauseHandle];
                        [task removeObserverWithHandle:successHandle];
                        [task removeObserverWithHandle:failureHandle];
                        completion(YES, [self NSDictionaryFromFIRStorageTaskSnapshot:snapshot]);
                      }];
      successHandle = [task observeStatus:FIRStorageTaskStatusSuccess
                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                    [task removeObserverWithHandle:pauseHandle];
                                    [task removeObserverWithHandle:successHandle];
                                    [task removeObserverWithHandle:failureHandle];
                                    completion(NO, nil);
                                  }];
      failureHandle = [task observeStatus:FIRStorageTaskStatusFailure
                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                    [task removeObserverWithHandle:pauseHandle];
                                    [task removeObserverWithHandle:successHandle];
                                    [task removeObserverWithHandle:failureHandle];
                                    completion(NO, nil);
                                  }];

      [task pause];
    } else {
      completion(NO, nil);
    }
    return;
  }

  // Resume
  if (state == FLTFirebaseStorageTaskStateResume) {
    if (task.snapshot.status == FIRStorageTaskStatusPause) {
      __block FIRStorageHandle resumeHandle;
      __block FIRStorageHandle progressHandle;
      __block FIRStorageHandle successHandle;
      __block FIRStorageHandle failureHandle;
      resumeHandle =
          [task observeStatus:FIRStorageTaskStatusResume
                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                        [task removeObserverWithHandle:resumeHandle];
                        [task removeObserverWithHandle:progressHandle];
                        [task removeObserverWithHandle:successHandle];
                        [task removeObserverWithHandle:failureHandle];
                        completion(YES, [self NSDictionaryFromFIRStorageTaskSnapshot:snapshot]);
                      }];
      progressHandle =
          [task observeStatus:FIRStorageTaskStatusProgress
                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                        [task removeObserverWithHandle:resumeHandle];
                        [task removeObserverWithHandle:progressHandle];
                        [task removeObserverWithHandle:successHandle];
                        [task removeObserverWithHandle:failureHandle];
                        completion(YES, [self NSDictionaryFromFIRStorageTaskSnapshot:snapshot]);
                      }];
      successHandle = [task observeStatus:FIRStorageTaskStatusSuccess
                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                    [task removeObserverWithHandle:resumeHandle];
                                    [task removeObserverWithHandle:progressHandle];
                                    [task removeObserverWithHandle:successHandle];
                                    [task removeObserverWithHandle:failureHandle];
                                    completion(NO, nil);
                                  }];
      failureHandle = [task observeStatus:FIRStorageTaskStatusFailure
                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                    [task removeObserverWithHandle:resumeHandle];
                                    [task removeObserverWithHandle:progressHandle];
                                    [task removeObserverWithHandle:successHandle];
                                    [task removeObserverWithHandle:failureHandle];
                                    completion(NO, nil);
                                  }];
      [task resume];
    } else {
      completion(NO, nil);
    }
    return;
  }

  // Cancel
  if (state == FLTFirebaseStorageTaskStateCancel) {
    if (task.snapshot.status == FIRStorageTaskStatusPause ||
        task.snapshot.status == FIRStorageTaskStatusResume ||
        task.snapshot.status == FIRStorageTaskStatusProgress ||
        task.snapshot.status == FIRStorageTaskStatusUnknown) {
      __block FIRStorageHandle successHandle;
      __block FIRStorageHandle failureHandle;
      successHandle = [task observeStatus:FIRStorageTaskStatusSuccess
                                  handler:^(FIRStorageTaskSnapshot *snapshot) {
                                    [task removeObserverWithHandle:successHandle];
                                    [task removeObserverWithHandle:failureHandle];
                                    completion(NO, nil);
                                  }];
      failureHandle =
          [task observeStatus:FIRStorageTaskStatusFailure
                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                        [task removeObserverWithHandle:successHandle];
                        [task removeObserverWithHandle:failureHandle];
                        if (snapshot.error && snapshot.error.code == FIRStorageErrorCodeCancelled) {
                          completion(YES, [self NSDictionaryFromFIRStorageTaskSnapshot:snapshot]);
                        } else {
                          completion(NO, nil);
                        }
                      }];
      [task cancel];
    } else {
      completion(NO, nil);
    }
    return;
  }

  completion(NO, nil);
}

- (void)startFIRStorageObservableTaskForArguments:(id)arguments
                    andFLTFirebaseStorageTaskType:(FLTFirebaseStorageTaskType)type {
  dispatch_async(self->_callbackQueue, ^() {
    FIRStorageObservableTask<FIRStorageTaskManagement> *task;
    FIRStorageReference *reference = [self FIRStorageReferenceForArguments:arguments];
    FIRStorageMetadata *metadata =
        [self FIRStorageMetadataFromNSDictionary:arguments[kFLTFirebaseStorageKeyMetadata]];

    if (type == FLTFirebaseStorageTaskTypeFile) {
      NSURL *fileUrl = [NSURL fileURLWithPath:arguments[@"filePath"]];
      task = [reference putFile:fileUrl metadata:metadata];
    } else if (type == FLTFirebaseStorageTaskTypeBytes) {
      NSData *data = [(FlutterStandardTypedData *)arguments[@"data"] data];
      task = [reference putData:data metadata:metadata];
    } else if (type == FLTFirebaseStorageTaskTypeDownload) {
      NSURL *fileUrl = [NSURL fileURLWithPath:arguments[@"filePath"]];
      task = [reference writeToFile:fileUrl];
    } else if (type == FLTFirebaseStorageTaskTypeString) {
      NSData *data = [self
          NSDataFromUploadString:arguments[@"data"]
                          format:(FLTFirebaseStorageStringType)[arguments[@"format"] intValue]];
      task = [reference putData:data metadata:metadata];
    }

    NSNumber *handle = arguments[kFLTFirebaseStorageKeyHandle];
    __weak FLTFirebaseStoragePlugin *weakSelf = self;

    @synchronized(self->_tasks) {
      self->_tasks[handle] = task;
    }

    // upload paused
    [task observeStatus:FIRStorageTaskStatusPause
                handler:^(FIRStorageTaskSnapshot *snapshot) {
                  dispatch_async(self->_callbackQueue, ^() {
                    [weakSelf.channel invokeMethod:@"Task#onPaused"
                                         arguments:[weakSelf NSDictionaryFromHandle:handle
                                                          andFIRStorageTaskSnapshot:snapshot]];
                  });
                }];

    // upload reported progress
    [task observeStatus:FIRStorageTaskStatusProgress
                handler:^(FIRStorageTaskSnapshot *snapshot) {
                  dispatch_async(self->_callbackQueue, ^() {
                    [weakSelf.channel invokeMethod:@"Task#onProgress"
                                         arguments:[weakSelf NSDictionaryFromHandle:handle
                                                          andFIRStorageTaskSnapshot:snapshot]];
                  });
                }];

    // upload completed successfully
    [task observeStatus:FIRStorageTaskStatusSuccess
                handler:^(FIRStorageTaskSnapshot *snapshot) {
                  dispatch_async(self->_callbackQueue, ^() {
                    @synchronized(self->_tasks) {
                      [self->_tasks removeObjectForKey:handle];
                    }
                    [weakSelf.channel invokeMethod:@"Task#onSuccess"
                                         arguments:[weakSelf NSDictionaryFromHandle:handle
                                                          andFIRStorageTaskSnapshot:snapshot]];
                  });
                }];

    [task observeStatus:FIRStorageTaskStatusFailure
                handler:^(FIRStorageTaskSnapshot *snapshot) {
                  dispatch_async(self->_callbackQueue, ^() {
                    @synchronized(self->_tasks) {
                      [self->_tasks removeObjectForKey:handle];
                    }
                    if (snapshot.error.code == FIRStorageErrorCodeCancelled) {
                      [weakSelf.channel invokeMethod:@"Task#onCanceled"
                                           arguments:[weakSelf NSDictionaryFromHandle:handle
                                                            andFIRStorageTaskSnapshot:snapshot]];
                    } else {
                      [weakSelf.channel invokeMethod:@"Task#onFailure"
                                           arguments:[weakSelf NSDictionaryFromHandle:handle
                                                            andFIRStorageTaskSnapshot:snapshot]];
                    }
                  });
                }];
  });
}

- (NSDictionary *)NSDictionaryFromNSError:(NSError *)error {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  NSString *code = @"unknown";
  NSString *message = [error localizedDescription];

  if (error.code == FIRStorageErrorCodeUnknown) {
    code = @"unknown";
  } else if (error.code == FIRStorageErrorCodeObjectNotFound) {
    code = @"object-not-found";
    message = @"No object exists at the desired reference.";
  } else if (error.code == FIRStorageErrorCodeBucketNotFound) {
    code = @"bucket-not-found";
    message = @"No bucket is configured for Firebase Storage.";
  } else if (error.code == FIRStorageErrorCodeProjectNotFound) {
    code = @"project-not-found";
    message = @"No project is configured for Firebase Storage.";
  } else if (error.code == FIRStorageErrorCodeQuotaExceeded) {
    code = @"quota-exceeded";
    message = @"Quota on your Firebase Storage bucket has been exceeded.";
  } else if (error.code == FIRStorageErrorCodeUnauthenticated) {
    code = @"unauthenticated";
    message = @"User is unauthenticated. Authenticate and try again.";
  } else if (error.code == FIRStorageErrorCodeUnauthorized) {
    code = @"unauthorized";
    message = @"User is not authorized to perform the desired action.";
  } else if (error.code == FIRStorageErrorCodeRetryLimitExceeded) {
    code = @"retry-limit-exceeded";
    message = @"The maximum time limit on an operation (upload, download, delete, etc.) has been "
              @"exceeded.";
  } else if (error.code == FIRStorageErrorCodeNonMatchingChecksum) {
    code = @"invalid-checksum";
    message = @"File on the client does not match the checksum of the file received by the server.";
  } else if (error.code == FIRStorageErrorCodeDownloadSizeExceeded) {
    code = @"download-size-exceeded";
    message =
        @"Size of the downloaded file exceeds the amount of memory allocated for the download.";
  } else if (error.code == FIRStorageErrorCodeCancelled) {
    code = @"canceled";
    message = @"User cancelled the operation.";
  } else if (error.code == FIRStorageErrorCodeInvalidArgument) {
    code = @"invalid-argument";
  }

  dictionary[@"code"] = code;
  dictionary[@"message"] = message;

  return dictionary;
}

- (NSDictionary *)NSDictionaryFromHandle:(NSNumber *)handle
               andFIRStorageTaskSnapshot:(FIRStorageTaskSnapshot *)snapshot {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  dictionary[kFLTFirebaseStorageKeyHandle] = handle;
  dictionary[kFLTFirebaseStorageKeyAppName] =
      [FLTFirebasePlugin firebaseAppNameFromIosName:snapshot.reference.storage.app.name];
  dictionary[kFLTFirebaseStorageKeyBucket] = snapshot.reference.bucket;
  if (snapshot.error != nil) {
    dictionary[@"error"] = [self NSDictionaryFromNSError:snapshot.error];
  } else {
    dictionary[kFLTFirebaseStorageKeySnapshot] =
        [self NSDictionaryFromFIRStorageTaskSnapshot:snapshot];
  }
  return dictionary;
}

- (NSDictionary *)NSDictionaryFromFIRStorageTaskSnapshot:(FIRStorageTaskSnapshot *)snapshot {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

  dictionary[kFLTFirebaseStorageKeyPath] = snapshot.reference.fullPath;

  if (snapshot.metadata != nil) {
    dictionary[@"metadata"] = [self NSDictionaryFromFIRStorageMetadata:snapshot.metadata];
  }

  if (snapshot.progress != nil) {
    dictionary[@"bytesTransferred"] = @(snapshot.progress.completedUnitCount);
    dictionary[@"totalBytes"] = @(snapshot.progress.totalUnitCount);
  } else {
    dictionary[@"bytesTransferred"] = @(0);
    dictionary[@"totalBytes"] = @(0);
  }

  return dictionary;
}

- (NSData *)NSDataFromUploadString:(NSString *)string format:(FLTFirebaseStorageStringType)format {
  // Dart: PutStringFormat.base64
  if (format == FLTFirebaseStorageStringTypeBase64) {
    return [[NSData alloc] initWithBase64EncodedString:string options:0];
  }

  // Dart: PutStringFormat.base64Url
  if (format == FLTFirebaseStorageStringTypeBase64URL) {
    // Convert to base64 from base64url.
    NSString *base64Encoded = string;
    base64Encoded = [base64Encoded stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64Encoded = [base64Encoded stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    // Add mandatory base64 encoding padding.
    while (base64Encoded.length % 4 != 0) {
      base64Encoded = [base64Encoded stringByAppendingString:@"="];
    }

    return [[NSData alloc] initWithBase64EncodedString:base64Encoded options:0];
  }

  return nil;
}

- (NSDictionary *)NSDictionaryFromFIRStorageListResult:(FIRStorageListResult *)listResult {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

  NSMutableArray<NSString *> *items = [[NSMutableArray alloc] init];
  for (FIRStorageReference *reference in listResult.items) {
    [items addObject:reference.fullPath];
  }
  dictionary[kFLTFirebaseStorageKeyItems] = items;

  NSMutableArray<NSString *> *prefixes = [[NSMutableArray alloc] init];
  for (FIRStorageReference *reference in listResult.prefixes) {
    [prefixes addObject:reference.fullPath];
  }
  dictionary[kFLTFirebaseStorageKeyPrefixes] = prefixes;

  if (listResult.pageToken != nil) {
    dictionary[kFLTFirebaseStorageKeyNextPageToken] = listResult.pageToken;
  }

  return dictionary;
}

- (FIRStorageMetadata *)FIRStorageMetadataFromNSDictionary:(NSDictionary *)dictionary {
  if (dictionary == nil || [dictionary isEqual:[NSNull null]]) return nil;
  FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
  if (dictionary[kFLTFirebaseStorageKeyCacheControl] != [NSNull null]) {
    metadata.cacheControl = dictionary[kFLTFirebaseStorageKeyCacheControl];
  }
  if (dictionary[kFLTFirebaseStorageKeyContentDisposition] != [NSNull null]) {
    metadata.contentDisposition = dictionary[kFLTFirebaseStorageKeyContentDisposition];
  }
  if (dictionary[kFLTFirebaseStorageKeyContentEncoding] != [NSNull null]) {
    metadata.contentEncoding = dictionary[kFLTFirebaseStorageKeyContentEncoding];
  }
  if (dictionary[kFLTFirebaseStorageKeyContentLanguage] != [NSNull null]) {
    metadata.contentLanguage = dictionary[kFLTFirebaseStorageKeyContentLanguage];
  }
  if (dictionary[kFLTFirebaseStorageKeyContentType] != [NSNull null]) {
    metadata.contentType = dictionary[kFLTFirebaseStorageKeyContentType];
  }
  if (dictionary[kFLTFirebaseStorageKeyCustomMetadata] != [NSNull null]) {
    metadata.customMetadata = dictionary[kFLTFirebaseStorageKeyCustomMetadata];
  }
  return metadata;
}

- (NSDictionary *)NSDictionaryFromFIRStorageMetadata:(FIRStorageMetadata *)metadata {
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

  [dictionary setValue:[metadata name] forKey:kFLTFirebaseStorageKeyName];
  [dictionary setValue:[metadata bucket] forKey:kFLTFirebaseStorageKeyBucket];

  [dictionary setValue:[NSString stringWithFormat:@"%lld", [metadata generation]]
                forKey:kFLTFirebaseStorageKeyGeneration];

  [dictionary setValue:[NSString stringWithFormat:@"%lld", [metadata metageneration]]
                forKey:kFLTFirebaseStorageKeyMetadataGeneration];

  [dictionary setValue:[metadata path] forKey:kFLTFirebaseStorageKeyFullPath];

  [dictionary setValue:@([metadata size]) forKey:kFLTFirebaseStorageKeySize];

  [dictionary setValue:@((long)([[metadata timeCreated] timeIntervalSince1970] * 1000.0))
                forKey:kFLTFirebaseStorageKeyCreationTime];

  [dictionary setValue:@((long)([[metadata updated] timeIntervalSince1970] * 1000.0))
                forKey:kFLTFirebaseStorageKeyUpdatedTime];

  if ([metadata md5Hash] != nil) {
    [dictionary setValue:[metadata md5Hash] forKey:kFLTFirebaseStorageKeyMD5Hash];
  }

  if ([metadata cacheControl] != nil) {
    [dictionary setValue:[metadata cacheControl] forKey:kFLTFirebaseStorageKeyCacheControl];
  }

  if ([metadata contentDisposition] != nil) {
    [dictionary setValue:[metadata contentDisposition]
                  forKey:kFLTFirebaseStorageKeyContentDisposition];
  }

  if ([metadata contentEncoding] != nil) {
    [dictionary setValue:[metadata contentEncoding] forKey:kFLTFirebaseStorageKeyContentEncoding];
  }

  if ([metadata contentLanguage] != nil) {
    [dictionary setValue:[metadata contentLanguage] forKey:kFLTFirebaseStorageKeyContentLanguage];
  }

  if ([metadata contentType] != nil) {
    [dictionary setValue:[metadata contentType] forKey:kFLTFirebaseStorageKeyContentType];
  }

  if ([metadata customMetadata] != nil) {
    [dictionary setValue:[metadata customMetadata] forKey:kFLTFirebaseStorageKeyCustomMetadata];
  } else {
    [dictionary setValue:@{} forKey:kFLTFirebaseStorageKeyCustomMetadata];
  }

  return dictionary;
}

- (FIRStorage *)FIRStorageForArguments:(id)arguments {
  FIRStorage *storage;
  NSString *appName = arguments[kFLTFirebaseStorageKeyAppName];
  NSString *bucket = arguments[kFLTFirebaseStorageKeyBucket];
  FIRApp *firebaseApp = [FLTFirebasePlugin firebaseAppNamed:appName];

  if (![bucket isEqual:[NSNull null]]) {
    NSString *url = [@"gs://" stringByAppendingString:bucket];
    storage = [FIRStorage storageForApp:firebaseApp URL:url];
  } else {
    storage = [FIRStorage storageForApp:firebaseApp];
  }

  NSNumber *maxOperationRetryTime = arguments[kFLTFirebaseStorageKeyMaxOperationRetryTime];
  if (![maxOperationRetryTime isEqual:[NSNull null]]) {
    storage.maxOperationRetryTime = [maxOperationRetryTime longLongValue] / 1000.0;
  }

  NSNumber *maxDownloadRetryTime = arguments[kFLTFirebaseStorageKeyMaxDownloadRetryTime];
  if (![maxDownloadRetryTime isEqual:[NSNull null]]) {
    storage.maxDownloadRetryTime = [maxDownloadRetryTime longLongValue] / 1000.0;
  }

  NSNumber *maxUploadRetryTime = arguments[kFLTFirebaseStorageKeyMaxUploadRetryTime];
  if (![maxUploadRetryTime isEqual:[NSNull null]]) {
    storage.maxUploadRetryTime = [maxUploadRetryTime longLongValue] / 1000.0;
  }

  storage.callbackQueue = _callbackQueue;

  return storage;
}

- (FIRStorageReference *)FIRStorageReferenceForArguments:(id)arguments {
  NSString *path = arguments[kFLTFirebaseStorageKeyPath];
  FIRStorage *storage = [self FIRStorageForArguments:arguments];
  return [storage referenceWithPath:path];
}

#pragma mark - FLTFirebasePlugin

- (void)didReinitializeFirebaseCore:(void (^)(void))completion {
  [self cleanupWithCompletion:completion];
}

- (NSDictionary *_Nonnull)pluginConstantsForFIRApp:(FIRApp *)firebase_app {
  return @{};
}

- (NSString *_Nonnull)firebaseLibraryName {
  return LIBRARY_NAME;
}

- (NSString *_Nonnull)firebaseLibraryVersion {
  return LIBRARY_VERSION;
}

- (NSString *_Nonnull)flutterChannelName {
  return kFLTFirebaseStorageChannelName;
}

@end
