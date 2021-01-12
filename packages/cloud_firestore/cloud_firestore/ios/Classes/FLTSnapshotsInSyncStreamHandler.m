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

@interface FLTSnapshotsInSyncStreamHandler ()
@property(readwrite, strong) id<FIRListenerRegistration> listenerRegistration;
@end

@implementation FLTSnapshotsInSyncStreamHandler

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  FIRFirestore *firestore = arguments[@"firestore"];

  id listener = ^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      events(nil);
    });
  };

  self.listenerRegistration = [firestore addSnapshotsInSyncListener:listener];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.listenerRegistration remove];
  self.listenerRegistration = nil;

  return nil;
}

@end
