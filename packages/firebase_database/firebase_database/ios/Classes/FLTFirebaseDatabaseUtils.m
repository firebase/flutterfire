// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseDatabaseUtils.h"
#import <firebase_core/FLTFirebasePlugin.h>

@implementation FLTFirebaseDatabaseUtils

+ (dispatch_queue_t)dispatchQueue {
  static dispatch_once_t once;
  __strong static dispatch_queue_t sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance =
        dispatch_queue_create("io.flutter.plugins.firebase.database", DISPATCH_QUEUE_SERIAL);
  });
  return sharedInstance;
}

+ (FIRDatabase *)databaseFromArguments:(id)arguments {
  NSString *appName = arguments[@"appName"] == nil ? @"[DEFAULT]" : arguments[@"appName"];
  NSString *databaseURL = arguments[@"databaseURL"] == nil ? @"" : arguments[@"databaseURL"];
  NSString *instanceKey = [appName stringByAppendingString:databaseURL];

  // TODO check instance already exists and return;

  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appName];
  FIRDatabase *database;

  if (databaseURL.length == 0) {
    database = [FIRDatabase databaseForApp:app];
  } else {
    database = [FIRDatabase databaseForApp:app URL:databaseURL];
  }

  [database setCallbackQueue:[self dispatchQueue]];

  // TODO persistence
  // TODO logging enabled
  // TODO cache size

  NSString *emulatorHost = arguments[@"emulatorHost"];
  NSNumber *emulatorPort = arguments[@"emulatorPort"];
  if (emulatorHost != nil && emulatorPort != nil) {
    [database useEmulatorWithHost:emulatorHost port:[emulatorPort integerValue]];
  }

  // TODO cache by instance key

  return database;
}

+ (FIRDatabaseReference *)databaseReferenceFromArguments:(id)arguments {
  FIRDatabase *database = [FLTFirebaseDatabaseUtils databaseFromArguments:arguments];
  return [database referenceWithPath:arguments[@"path"]];
}

+ (FIRDatabaseQuery *)databaseQueryFromArguments:(id)arguments {
  // TODO this is now wrong, modifiers is now an Array
  FIRDatabaseQuery *query = [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  NSDictionary *parameters = arguments[@"parameters"];

  NSString *orderBy = parameters[@"orderBy"];
  if ([orderBy isEqualToString:@"child"]) {
    query = [query queryOrderedByChild:parameters[@"orderByChildKey"]];
  } else if ([orderBy isEqualToString:@"key"]) {
    query = [query queryOrderedByKey];
  } else if ([orderBy isEqualToString:@"value"]) {
    query = [query queryOrderedByValue];
  } else if ([orderBy isEqualToString:@"priority"]) {
    query = [query queryOrderedByPriority];
  }

  id startAt = parameters[@"startAt"];
  if (startAt != nil) {
    id startAtKey = parameters[@"startAtKey"];
    if (startAtKey != nil) {
      query = [query queryStartingAtValue:startAt childKey:startAtKey];
    } else {
      query = [query queryStartingAtValue:startAt];
    }
  }

  id startAfter = parameters[@"startAfter"];
  if (startAfter != nil) {
    id startAfterKey = parameters[@"startAfterKey"];
    if (startAfterKey != nil) {
      query = [query queryStartingAfterValue:startAfter childKey:startAfterKey];
    } else {
      query = [query queryStartingAfterValue:startAfter];
    }
  }

  id endAt = parameters[@"endAt"];
  if (endAt != nil) {
    id endAtKey = parameters[@"endAtKey"];
    if (endAtKey != nil) {
      query = [query queryEndingAtValue:endAt childKey:endAtKey];
    } else {
      query = [query queryEndingAtValue:endAt];
    }
  }

  id endBefore = parameters[@"endBefore"];
  if (endBefore != nil) {
    id endBeforeKey = parameters[@"endBeforeKey"];
    if (endBeforeKey != nil) {
      query = [query queryEndingBeforeValue:endBefore childKey:endBeforeKey];
    } else {
      query = [query queryEndingBeforeValue:endBefore];
    }
  }

  id equalTo = parameters[@"equalTo"];
  if (equalTo != nil) {
    id equalToKey = parameters[@"equalToKey"];
    if (equalToKey != nil) {
      query = [query queryEqualToValue:equalTo childKey:equalToKey];
    } else {
      query = [query queryEqualToValue:equalTo];
    }
  }

  NSNumber *limitToFirst = parameters[@"limitToFirst"];
  if (limitToFirst != nil) {
    query = [query queryLimitedToFirst:limitToFirst.unsignedIntValue];
  }

  NSNumber *limitToLast = parameters[@"limitToLast"];
  if (limitToLast != nil) {
    query = [query queryLimitedToLast:limitToLast.unsignedIntValue];
  }

  return query;
}

+ (NSDictionary *)dictionaryFromSnapshot:(FIRDataSnapshot *)snapshot
                    withPreviousChildKey:(NSString *)previousChildKey {
  return @{
    @"snapshot" : [self dictionaryFromSnapshot:snapshot],
    @"previousChildKey" : previousChildKey,
  };
}

+ (NSDictionary *)dictionaryFromSnapshot:(FIRDataSnapshot *)snapshot {
  NSMutableArray *childKeys = [NSMutableArray array];
  if (snapshot.childrenCount > 0) {
    NSEnumerator *children = [snapshot children];
    FIRDataSnapshot *child;
    child = [children nextObject];
    while (child) {
      [childKeys addObject:child.key];
      child = [children nextObject];
    }
  }

  return @{
    @"key" : snapshot.key,
    @"value" : snapshot.value,
    @"priority" : snapshot.priority,
    @"childKeys" : childKeys,
  };
}

+ (NSArray *)codeAndMessageFromNSError:(NSError *)error {
  NSString *code = @"unknown";

  if (error == nil) {
    return @[ code, @"An unknown error has occurred." ];
  }

  NSString *message;

  switch (error.code) {
    case 1:
      code = @"permission-denied";
      message = @"Client doesn't have permission to access the desired data.";
      break;
    case 2:
      code = @"unavailable";
      message = @"The service is unavailable.";
      break;
    case 3:
      code = @"write-cancelled";
      message = @"The write was cancelled by the user.";
      break;
    case -1:
      code = @"data-stale";
      message = @"The transaction needs to be run again with current data.";
      break;
    case -2:
      code = @"failure";
      message = @"The server indicated that this operation failed.";
      break;
    case -4:
      code = @"disconnected";
      message = @"The operation had to be aborted due to a network disconnect.";
      break;
    case -6:
      code = @"expired-token";
      message = @"The supplied auth token has expired.";
      break;
    case -7:
      code = @"invalid-token";
      message = @"The supplied auth token was invalid.";
      break;
    case -8:
      code = @"max-retries";
      message = @"The transaction had too many retries.";
      break;
    case -9:
      code = @"overridden-by-set";
      message = @"The transaction was overridden by a subsequent set";
      break;
    case -11:
      code = @"user-code-exception";
      message = @"User code called from the Firebase Database runloop threw an exception.";
      break;
    case -24:
      code = @"network-error";
      message = @"The operation could not be performed due to a network error.";
      break;
    default:
      code = @"unknown";
      message = [error localizedDescription];
  }

  return @[ code, message ];
}

+ (FIRDataEventType)eventTypeFromArguments:(id)arguments {
  NSString *eventTypeName = arguments[@"eventType"];
  if ([eventTypeName isEqualToString:@"value"]) {
    return FIRDataEventTypeValue;
  } else if ([eventTypeName isEqualToString:@"childAdded"]) {
    return FIRDataEventTypeChildAdded;
  } else if ([eventTypeName isEqualToString:@"childChanged"]) {
    return FIRDataEventTypeChildChanged;
  } else if ([eventTypeName isEqualToString:@"childRemoved"]) {
    return FIRDataEventTypeChildRemoved;
  } else if ([eventTypeName isEqualToString:@"childMoved"]) {
    return FIRDataEventTypeChildMoved;
  }
  return FIRDataEventTypeValue;
}

@end