//
//  FLTQuerySnapshotStreamHandler.m
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#import <Firebase/Firebase.h>
#import <firebase_core/FLTFirebasePluginRegistry.h>

#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FLTQuerySnapshotStreamHandler.h"

@implementation FLTQuerySnapshotStreamHandler {
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
  FIRQuery *query = arguments[@"query"];

  if (query == nil) {
    return [FlutterError
        errorWithCode:@"sdk-error"
              message:@"An error occurred while parsing query arguments, see native logs for more "
                      @"information. Please report this issue."
              details:nil];
  }

  NSNumber *handle = arguments[@"handle"];
  NSNumber *includeMetadataChanges = arguments[@"includeMetadataChanges"];

  id listener = ^(FIRQuerySnapshot *_Nullable snapshot, NSError *_Nullable error) {
    if (error) {
      NSArray *codeAndMessage = [FLTFirebaseFirestoreUtils ErrorCodeAndMessageFromNSError:error];

      dispatch_async(dispatch_get_main_queue(), ^{
        events(@{
          @"handle" : handle,
          @"error" : @{@"code" : codeAndMessage[0], @"message" : codeAndMessage[1]},
        });
      });
    } else if (snapshot) {
      dispatch_async(dispatch_get_main_queue(), ^{
        events(@{
          @"handle" : handle,
          @"snapshot" : snapshot,
        });
      });
    }
  };

  id<FIRListenerRegistration> listenerRegistration =
      [query addSnapshotListenerWithIncludeMetadataChanges:includeMetadataChanges.boolValue
                                                  listener:listener];

  @synchronized(_listeners) {
    _listeners[handle] = listenerRegistration;
  }

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  NSNumber *handle = arguments[@"handle"];

  if (handle) {
    @synchronized(_listeners) {
      [_listeners[handle] remove];
      [_listeners removeObjectForKey:handle];
    }
  }

  return nil;
}

@end
