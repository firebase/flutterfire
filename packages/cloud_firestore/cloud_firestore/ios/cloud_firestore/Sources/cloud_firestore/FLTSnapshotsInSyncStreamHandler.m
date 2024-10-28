// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseFirestore;

#import "include/cloud_firestore/Private/FLTSnapshotsInSyncStreamHandler.h"
#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"

@interface FLTSnapshotsInSyncStreamHandler ()
@property(readwrite, strong) id<FIRListenerRegistration> listenerRegistration;
@end

@implementation FLTSnapshotsInSyncStreamHandler

- (nonnull instancetype)initWithFirestore:(nonnull FIRFirestore *)firestore {
  self = [super init];
  if (self) {
    _firestore = firestore;
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  id listener = ^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      events(nil);
    });
  };

  self.listenerRegistration = [_firestore addSnapshotsInSyncListener:listener];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.listenerRegistration remove];
  self.listenerRegistration = nil;

  return nil;
}

@end
