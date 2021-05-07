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
@property(readwrite, strong) id<FIRListenerRegistration> listenerRegistration;
@end

@implementation FLTLoadBundleStreamHandler

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  FlutterStandardTypedData *bundle = arguments[@"bundle"];
  FIRFirestore *firestore = arguments[@"firestore"];

  id listener = ^(FIRLoadBundleTaskProgress *_Nullable progress, NSError *_Nullable error) {
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
        events(progress);
      });
    }
  };

  self.listenerRegistration = [firestore loadBundle:bundle.data completion:listener];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  [self.listenerRegistration remove];
  self.listenerRegistration = nil;

  return nil;
}

@end
