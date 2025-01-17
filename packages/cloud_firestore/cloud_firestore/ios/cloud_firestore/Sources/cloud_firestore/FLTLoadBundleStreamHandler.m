// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//
//  FLTLoadBundleStreamHandler.m
//  cloud_firestore
//
//  Created by Russell Wheatley on 05/05/2021.
//

@import FirebaseFirestore;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"
#import "include/cloud_firestore/Private/FLTLoadBundleStreamHandler.h"

@interface FLTLoadBundleStreamHandler ()
@property(readwrite, strong) FIRLoadBundleTask *task;
@end

@implementation FLTLoadBundleStreamHandler

- (nonnull instancetype)initWithFirestore:(nonnull FIRFirestore *)firestore
                                   bundle:(FlutterStandardTypedData *)bundle {
  self = [super init];
  if (self) {
    _firestore = firestore;
    _bundle = bundle;
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  // use completion handler to inform user of platform error.
  self.task = [_firestore
      loadBundle:_bundle.data
      completion:^(FIRLoadBundleTaskProgress *_Nullable snapshot, NSError *_Nullable error) {
        if (error != nil) {
          NSArray *codeAndMessage =
              [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];
          NSString *code = codeAndMessage[0];
          NSString *message = codeAndMessage[1];
          NSDictionary *details = @{
            @"code" : code,
            @"message" : message,
          };

          dispatch_async(dispatch_get_main_queue(), ^{
            events([FLTFirebasePlugin createFlutterErrorFromCode:code
                                                         message:message
                                                 optionalDetails:details
                                              andOptionalNSError:error]);
          });
        }
      }];
  // use addObserver to update user with snapshot progress
  [self.task addObserver:^(FIRLoadBundleTaskProgress *_Nullable progress) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (progress.state != FIRLoadBundleTaskStateError) {
        events(progress);
      }
    });
  }];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.task removeAllObservers];
  self.task = nil;

  return nil;
}
@end
