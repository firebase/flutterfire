//
//  FLTSnapshotsInSyncStreamHandler.m
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FLTSnapshotsInSyncStreamHandler.h"

@implementation FLTSnapshotsInSyncStreamHandler {
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
  FIRFirestore *firestore = arguments[@"firestore"];

  id listener = ^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      events(@{@"handle" : handle});
    });
  };

  id<FIRListenerRegistration> listenerRegistration =
      [firestore addSnapshotsInSyncListener:listener];

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
