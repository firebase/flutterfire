//
//  FLTLoadBundleStreamHandler.m
//  cloud_firestore
//
//  Created by Russell Wheatley on 05/05/2021.
//

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FLTLoadBundleStreamHandler.h"

@interface FLTLoadBundleStreamHandler ()
@property(readwrite, strong) FIRLoadBundleTask *task;
@end

@implementation FLTLoadBundleStreamHandler

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  FlutterStandardTypedData *bundle = arguments[@"bundle"];
  FIRFirestore *firestore = arguments[@"firestore"];

  self.task = [firestore loadBundle:bundle.data];

  [self.task addObserver:^(FIRLoadBundleTaskProgress *_Nullable progress) {
    dispatch_async(dispatch_get_main_queue(), ^{
      events(progress);
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
