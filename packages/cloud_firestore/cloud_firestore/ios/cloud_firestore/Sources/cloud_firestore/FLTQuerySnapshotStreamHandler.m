// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import FirebaseFirestore;
#if __has_include(<firebase_core/FLTFirebasePluginRegistry.h>)
#import <firebase_core/FLTFirebasePluginRegistry.h>
#else
#import <FLTFirebasePluginRegistry.h>
#endif

#import "include/cloud_firestore/Private/FLTFirebaseFirestoreUtils.h"
#import "include/cloud_firestore/Private/FLTQuerySnapshotStreamHandler.h"
#import "include/cloud_firestore/Private/FirestorePigeonParser.h"
#import "include/cloud_firestore/Public/CustomPigeonHeaderFirestore.h"

@interface FLTQuerySnapshotStreamHandler ()
@property(readwrite, strong) id<FIRListenerRegistration> listenerRegistration;
@end

@implementation FLTQuerySnapshotStreamHandler

- (instancetype)initWithFirestore:(FIRFirestore *)firestore
                            query:(FIRQuery *)query
           includeMetadataChanges:(BOOL)includeMetadataChanges
          serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior
                           source:(FIRListenSource)source {
  self = [super init];
  if (self) {
    _firestore = firestore;
    _query = query;
    _includeMetadataChanges = includeMetadataChanges;
    _serverTimestampBehavior = serverTimestampBehavior;
    _source = source;
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  FIRQuery *query = self.query;

  if (query == nil) {
    return [FlutterError
        errorWithCode:@"sdk-error"
              message:@"An error occurred while parsing query arguments, see native logs for more "
                      @"information. Please report this issue."
              details:nil];
  }

  id listener = ^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
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
        NSMutableArray *toListResult = [[NSMutableArray alloc] initWithCapacity:3];

        NSMutableArray *documents =
            [[NSMutableArray alloc] initWithCapacity:snapshot.documents.count];
        NSMutableArray *documentChanges =
            [[NSMutableArray alloc] initWithCapacity:snapshot.documentChanges.count];

        for (FIRDocumentSnapshot *documentSnapshot in snapshot.documents) {
          [documents addObject:[[FirestorePigeonParser
                                   toPigeonDocumentSnapshot:documentSnapshot
                                    serverTimestampBehavior:self.serverTimestampBehavior] toList]];
        }

        for (FIRDocumentChange *documentChange in snapshot.documentChanges) {
          [documentChanges
              addObject:[[FirestorePigeonParser toPigeonDocumentChange:documentChange
                                               serverTimestampBehavior:self.serverTimestampBehavior]
                            toList]];
        }

        [toListResult addObject:documents];
        [toListResult addObject:documentChanges];
        [toListResult
            addObject:[[FirestorePigeonParser toPigeonSnapshotMetadata:snapshot.metadata] toList]];

        events(toListResult);
      });
    }
  };

  FIRSnapshotListenOptions *options = [[FIRSnapshotListenOptions alloc] init];
  FIRSnapshotListenOptions *optionsWithSourceAndMetadata = [[options
      optionsWithIncludeMetadataChanges:_includeMetadataChanges] optionsWithSource:_source];

  self.listenerRegistration = [query addSnapshotListenerWithOptions:optionsWithSourceAndMetadata
                                                           listener:listener];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.listenerRegistration remove];
  self.listenerRegistration = nil;

  return nil;
}

@end
