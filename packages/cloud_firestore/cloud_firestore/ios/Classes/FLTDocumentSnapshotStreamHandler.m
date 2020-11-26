//
//  FLTDocumentSnapshotStreamHandler.m
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTDocumentSnapshotStreamHandler.h"
#import "Private/FLTFirebaseFirestoreUtils.h"

@implementation FLTDocumentSnapshotStreamHandler {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _listeners = [NSMutableDictionary dictionary];
  }
  return self;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  NSNumber *handle = arguments[@"handle"];
  NSNumber *includeMetadataChanges = arguments[@"includeMetadataChanges"];

  FIRDocumentReference *document = arguments[@"reference"];

  id listener = ^(FIRDocumentSnapshot *snapshot, NSError *_Nullable error) {
    if (error != nil) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];

      events(@{
        @"handle" : handle,
        @"error" : @{@"code" : codeAndMessage[0], @"message" : codeAndMessage[1]},
      });
    } else if (snapshot != nil) {
      events(@{
        @"handle" : handle,
        @"snapshot" : snapshot,
      });
    }
  };

  id<FIRListenerRegistration> listenerRegistration =
      [document addSnapshotListenerWithIncludeMetadataChanges:includeMetadataChanges.boolValue
                                                     listener:listener];

  @synchronized(_listeners) {
    _listeners[handle] = listenerRegistration;
  }

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  NSNumber *handle = arguments[@"handle"];

  @synchronized(_listeners) {
    [_listeners[handle] remove];
    [_listeners removeObjectForKey:handle];
  }

  return nil;
}

@end
