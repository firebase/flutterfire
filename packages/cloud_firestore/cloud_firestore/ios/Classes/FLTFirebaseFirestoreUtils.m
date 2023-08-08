// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Firebase/Firebase.h>

#import "Private/FLTFirebaseFirestoreExtension.h"
#import "Private/FLTFirebaseFirestoreReader.h"
#import "Private/FLTFirebaseFirestoreUtils.h"
#import "Private/FLTFirebaseFirestoreWriter.h"

@implementation FLTFirebaseFirestoreReaderWriter
- (FlutterStandardWriter *_Nonnull)writerWithData:(NSMutableData *)data {
  return [[FLTFirebaseFirestoreWriter alloc] initWithData:data];
}
- (FlutterStandardReader *_Nonnull)readerWithData:(NSData *)data {
  return [[FLTFirebaseFirestoreReader alloc] initWithData:data];
}
@end

NSMutableDictionary<NSString *, FLTFirebaseFirestoreExtension *> *firestoreInstanceCache;

@implementation FLTFirebaseFirestoreUtils

+ (NSString *)generateKeyForAppName:(NSString *)appName andDatabaseURL:(NSString *)databaseURL {
  return [NSString stringWithFormat:@"%@|%@", appName, databaseURL];
}

+ (FLTFirebaseFirestoreExtension *_Nullable)
    getCachedFIRFirestoreInstanceForAppName:(NSString *_Nonnull)appName
                                databaseURL:(NSString *_Nonnull)url {
  @synchronized(firestoreInstanceCache) {
    if (firestoreInstanceCache == nil) {
      firestoreInstanceCache = [NSMutableDictionary dictionary];
      return nil;
    } else {
      NSString *key = [self generateKeyForAppName:appName andDatabaseURL:url];
      return firestoreInstanceCache[key];
    }
  }
}

+ (void)setCachedFIRFirestoreInstance:(FIRFirestore *_Nonnull)firestore
                           forAppName:(NSString *_Nonnull)appName
                          databaseURL:(NSString *_Nonnull)url {
  @synchronized(firestoreInstanceCache) {
    if (firestoreInstanceCache == nil) {
      firestoreInstanceCache = [NSMutableDictionary dictionary];
    }
    NSString *key = [self generateKeyForAppName:appName andDatabaseURL:url];
    firestoreInstanceCache[key] =
        [[FLTFirebaseFirestoreExtension alloc] initWithFirestoreInstance:firestore databaseURL:url];
  }
}

+ (void)destroyCachedInstanceForFirestore:(NSString *_Nonnull)appName
                              databaseURL:(NSString *_Nonnull)databaseURL {
  @synchronized(firestoreInstanceCache) {
    if (firestoreInstanceCache != nil) {
      NSString *key = [self generateKeyForAppName:appName andDatabaseURL:databaseURL];
      FLTFirebaseFirestoreExtension *extension = firestoreInstanceCache[key];

      if (extension != nil) {
        [firestoreInstanceCache removeObjectForKey:key];
      }
    }
  }
}

+ (FIRFirestore *)getFirestoreInstanceByName:(NSString *)appName
                                 databaseURL:(NSString *)databaseURL {
  @synchronized(firestoreInstanceCache) {
    if (firestoreInstanceCache == nil) {
      firestoreInstanceCache = [NSMutableDictionary dictionary];
    }
    NSString *key = [self generateKeyForAppName:appName andDatabaseURL:databaseURL];
    FLTFirebaseFirestoreExtension *extension = firestoreInstanceCache[key];

    if (extension != nil) {
      return extension.instance;
    }

    return nil;
  }
}

+ (NSUInteger)count {
  return [firestoreInstanceCache count];
}

// Require this method when we don't have access to the "databaseURL"
+ (FLTFirebaseFirestoreExtension *_Nullable)getCachedInstanceForFirestore:
    (FIRFirestore *_Nonnull)firestore {
  @synchronized(firestoreInstanceCache) {
    if (firestoreInstanceCache != nil) {
      NSEnumerator *enumerator = [firestoreInstanceCache keyEnumerator];
      NSString *key;

      while ((key = [enumerator nextObject])) {
        FLTFirebaseFirestoreExtension *value = firestoreInstanceCache[key];

        if (value.instance == firestore) {
          return value;
        }
      }
    }
    @throw [NSException exceptionWithName:@"NoCachedInstance"
                                   reason:@"No cached instance of Firestore"
                                 userInfo:nil];
  }
}

+ (void)cleanupFirestoreInstances:(void (^)(void))completion {
  __block int instancesTerminated = 0;
  NSUInteger numberOfInstances = [firestoreInstanceCache count];
  void (^firestoreTerminateInstanceCompletion)(NSError *) = ^void(NSError *error) {
    instancesTerminated++;
    if (instancesTerminated == numberOfInstances && completion != nil) {
      completion();
    }
  };

  if (numberOfInstances > 0) {
    for (NSString *key in firestoreInstanceCache) {
      FLTFirebaseFirestoreExtension *firestoreExtension = firestoreInstanceCache[key];
      FIRFirestore *firestore = firestoreExtension.instance;

      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [firestore terminateWithCompletion:^(NSError *error) {
          [FLTFirebaseFirestoreUtils
              destroyCachedInstanceForFirestore:firestore.app.name
                                    databaseURL:firestoreExtension.databaseURL];
          firestoreTerminateInstanceCompletion(error);
        }];
      });
    }
  }
}

+ (FIRFirestoreSource)FIRFirestoreSourceFromArguments:(NSDictionary *)arguments {
  NSString *source = arguments[@"source"];
  if ([@"server" isEqualToString:source]) {
    return FIRFirestoreSourceServer;
  }

  if ([@"cache" isEqualToString:source]) {
    return FIRFirestoreSourceCache;
  }

  return FIRFirestoreSourceDefault;
}

+ (NSArray *)ErrorCodeAndMessageFromNSError:(NSError *)error {
  NSString *code = @"unknown";

  if (error == nil) {
    return @[ code, @"An unknown error has occurred." ];
  }

  NSString *message;

  switch (error.code) {
    case FIRFirestoreErrorCodeAborted:
      code = @"aborted";
      message = @"The operation was aborted, typically due to a concurrency issue like transaction "
                @"aborts, etc.";
      break;
    case FIRFirestoreErrorCodeAlreadyExists:
      code = @"already-exists";
      message = @"Some document that we attempted to create already exists.";
      break;
    case FIRFirestoreErrorCodeCancelled:
      code = @"cancelled";
      message = @"The operation was cancelled (typically by the caller).";
      break;
    case FIRFirestoreErrorCodeDataLoss:
      code = @"data-loss";
      message = @"Unrecoverable data loss or corruption.";
      break;
    case FIRFirestoreErrorCodeDeadlineExceeded:
      code = @"deadline-exceeded";
      message = @"Deadline expired before operation could complete. For operations that change the "
                @"state of the system, this error may be returned even if the operation has "
                @"completed successfully. For example, a successful response from a server could "
                @"have been delayed long enough for the deadline to expire.";
      break;
    case FIRFirestoreErrorCodeFailedPrecondition:
      code = @"failed-precondition";
      if ([error.localizedDescription containsString:@"index"]) {
        message = error.localizedDescription;
      } else {
        message = @"Operation was rejected because the system is not in a state required for the "
                  @"operation's execution. If performing a query, ensure it has been indexed via "
                  @"the Firebase console.";
      }
      break;
    case FIRFirestoreErrorCodeInternal:
      code = @"internal";
      message = @"Internal errors. Means some invariants expected by underlying system has been "
                @"broken. If you see one of these errors, something is very broken.";
      break;
    case FIRFirestoreErrorCodeInvalidArgument:
      code = @"invalid-argument";
      message = @"Client specified an invalid argument. Note that this differs from "
                @"failed-precondition. invalid-argument indicates arguments that are problematic "
                @"regardless of the state of the system (e.g., an invalid field name).";
      break;
    case FIRFirestoreErrorCodeNotFound:
      code = @"not-found";
      message = @"Some requested document was not found.";
      break;
    case FIRFirestoreErrorCodeOutOfRange:
      code = @"out-of-range";
      message = @"Operation was attempted past the valid range.";
      break;
    case FIRFirestoreErrorCodePermissionDenied:
      code = @"permission-denied";
      message = @"The caller does not have permission to execute the specified operation.";
      break;
    case FIRFirestoreErrorCodeResourceExhausted:
      code = @"resource-exhausted";
      message = @"Some resource has been exhausted, perhaps a per-user quota, or perhaps the "
                @"entire file system is out of space.";
      break;
    case FIRFirestoreErrorCodeUnauthenticated:
      code = @"unauthenticated";
      message = @"The request does not have valid authentication credentials for the operation.";
      break;
    case FIRFirestoreErrorCodeUnavailable:
      code = @"unavailable";
      message = @"The service is currently unavailable. This is a most likely a transient "
                @"condition and may be corrected by retrying with a backoff.";
      break;
    case FIRFirestoreErrorCodeUnimplemented:
      code = @"unimplemented";
      message = @"Operation is not implemented or not supported/enabled.";
      break;
    case FIRFirestoreErrorCodeUnknown:
      code = @"unknown";
      message = @"Unknown error or an error from a different error domain.";
      break;
    default:
      code = @"unknown";
      message = @"An unknown error occurred.";
      break;
  }

  return @[ code, message ];
}

@end
