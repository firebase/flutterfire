//
//  FLTQuerySnapshotStreamHandler.m
//  cloud_firestore
//
//  Created by Sebastian Roth on 24/11/2020.
//

#import "Private/FLTQuerySnapshotStreamHandler.h"
#import "Private/FLTFirebaseFirestoreUtils.h"

@implementation FLTQuerySnapshotStreamHandler {
  NSMutableDictionary<NSNumber *, id<FIRListenerRegistration>> *_listeners;
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
      [query addSnapshotListenerWithIncludeMetadataChanges:includeMetadataChanges.boolValue
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
