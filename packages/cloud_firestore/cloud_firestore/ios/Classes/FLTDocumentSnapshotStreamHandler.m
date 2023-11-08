// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTDocumentSnapshotStreamHandler.h"
#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FirestorePigeonParser.h"
#import "Public/CustomPigeonHeaderFirestore.h"

@interface FLTDocumentSnapshotStreamHandler ()
@property(readwrite, strong) id<FIRListenerRegistration> listenerRegistration;
@end

@implementation FLTDocumentSnapshotStreamHandler

- (nonnull instancetype)initWithFirestore:(nonnull FIRFirestore *)firestore
                                reference:(nonnull FIRDocumentReference *)reference
                   includeMetadataChanges:(BOOL)includeMetadataChanges
                  serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior {
  self = [super init];
  if (self) {
    self.firestore = firestore;
    self.reference = reference;
    self.includeMetadataChanges = includeMetadataChanges;
    self.serverTimestampBehavior = serverTimestampBehavior;
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

  self.listenerRegistration =
      [_reference addSnapshotListenerWithIncludeMetadataChanges:_includeMetadataChanges
                                                       listener:listener];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.listenerRegistration remove];
  self.listenerRegistration = nil;

  return nil;
}

@end
