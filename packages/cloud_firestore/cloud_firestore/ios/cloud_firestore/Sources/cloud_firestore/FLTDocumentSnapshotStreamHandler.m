// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseFirestore;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "include/cloud_firestore/Private/FLTDocumentSnapshotStreamHandler.h"
#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"
#import "include/cloud_firestore/Private/FirestorePigeonParser.h"
#import "include/cloud_firestore/Public/CustomPigeonHeaderFirestore.h"

@interface FLTDocumentSnapshotStreamHandler ()
@property(readwrite, strong) id<FIRListenerRegistration> listenerRegistration;
@end

@implementation FLTDocumentSnapshotStreamHandler

- (nonnull instancetype)initWithFirestore:(nonnull FIRFirestore *)firestore
                                reference:(nonnull FIRDocumentReference *)reference
                   includeMetadataChanges:(BOOL)includeMetadataChanges
                  serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior
                                   source:(FIRListenSource)source {
  self = [super init];
  if (self) {
    self.firestore = firestore;
    self.reference = reference;
    self.includeMetadataChanges = includeMetadataChanges;
    self.serverTimestampBehavior = serverTimestampBehavior;
    self.source = source;
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  id listener = ^(FIRDocumentSnapshot *snapshot, NSError *_Nullable error) {
    if (error) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];
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
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        events(
            [[FirestorePigeonParser toPigeonDocumentSnapshot:snapshot
                                     serverTimestampBehavior:self.serverTimestampBehavior] toList]);
      });
    }
  };

  FIRSnapshotListenOptions *options = [[FIRSnapshotListenOptions alloc] init];
  FIRSnapshotListenOptions *optionsWithSourceAndMetadata = [[options
      optionsWithIncludeMetadataChanges:_includeMetadataChanges] optionsWithSource:_source];

  self.listenerRegistration =
      [_reference addSnapshotListenerWithOptions:optionsWithSourceAndMetadata listener:listener];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.listenerRegistration remove];
  self.listenerRegistration = nil;

  return nil;
}

@end
