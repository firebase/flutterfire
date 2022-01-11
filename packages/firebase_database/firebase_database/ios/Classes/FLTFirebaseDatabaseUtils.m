// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTFirebaseDatabaseUtils.h"
#import <firebase_core/FLTFirebasePlugin.h>

@implementation FLTFirebaseDatabaseUtils
static __strong NSMutableDictionary<NSString *, FIRDatabase *> *cachedDatabaseInstances = nil;

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
  if (cachedDatabaseInstances == nil) {
    cachedDatabaseInstances = [[NSMutableDictionary alloc] init];
  }
  FIRDatabase *cachedInstance = cachedDatabaseInstances[instanceKey];
  if (cachedInstance != nil) {
    return cachedInstance;
  }

  FIRApp *app = [FLTFirebasePlugin firebaseAppNamed:appName];
  FIRDatabase *database;

  if (databaseURL.length == 0) {
    database = [FIRDatabase databaseForApp:app];
  } else {
    database = [FIRDatabase databaseForApp:app URL:databaseURL];
  }

  //  [database setCallbackQueue:[self dispatchQueue]];
  NSNumber *persistenceEnabled = arguments[@"persistenceEnabled"];
  if (persistenceEnabled != nil) {
    database.persistenceEnabled = [persistenceEnabled boolValue];
  }

  NSNumber *cacheSizeBytes = arguments[@"cacheSizeBytes"];
  if (cacheSizeBytes != nil) {
    database.persistenceCacheSizeBytes = [cacheSizeBytes unsignedIntegerValue];
  }

  NSNumber *loggingEnabled = arguments[@"loggingEnabled"];
  if (loggingEnabled != nil) {
    [FIRDatabase setLoggingEnabled:[loggingEnabled boolValue]];
  }

  NSString *emulatorHost = arguments[@"emulatorHost"];
  NSNumber *emulatorPort = arguments[@"emulatorPort"];
  if (emulatorHost != nil && emulatorPort != nil) {
    [database useEmulatorWithHost:emulatorHost port:[emulatorPort integerValue]];
  }

  cachedDatabaseInstances[instanceKey] = database;
  return database;
}

+ (FIRDatabaseReference *)databaseReferenceFromArguments:(id)arguments {
  FIRDatabase *database = [FLTFirebaseDatabaseUtils databaseFromArguments:arguments];
  return [database referenceWithPath:arguments[@"path"]];
}

+ (FIRDatabaseQuery *)databaseQuery:(FIRDatabaseQuery *)query applyLimitModifier:(id)modifier {
  NSString *name = modifier[@"name"];
  NSNumber *limit = modifier[@"limit"];
  if ([name isEqualToString:@"limitToFirst"]) {
    return [query queryLimitedToFirst:limit.unsignedIntValue];
  }
  if ([name isEqualToString:@"limitToLast"]) {
    return [query queryLimitedToLast:limit.unsignedIntValue];
  }
  return query;
}

+ (FIRDatabaseQuery *)databaseQuery:(FIRDatabaseQuery *)query applyOrderModifier:(id)modifier {
  NSString *name = [modifier valueForKey:@"name"];
  if ([name isEqualToString:@"orderByKey"]) {
    return [query queryOrderedByKey];
  }
  if ([name isEqualToString:@"orderByValue"]) {
    return [query queryOrderedByValue];
  }
  if ([name isEqualToString:@"orderByPriority"]) {
    return [query queryOrderedByPriority];
  }
  if ([name isEqualToString:@"orderByChild"]) {
    NSString *path = [modifier valueForKey:@"path"];
    return [query queryOrderedByChild:path];
  }
  return query;
}

+ (FIRDatabaseQuery *)databaseQuery:(FIRDatabaseQuery *)query applyCursorModifier:(id)modifier {
  NSString *name = [modifier valueForKey:@"name"];
  NSString *key = [modifier valueForKey:@"key"];
  id value = [modifier valueForKey:@"value"];
  if ([name isEqualToString:@"startAt"]) {
    if (key != nil) {
      return [query queryStartingAtValue:value childKey:key];
    } else {
      return [query queryStartingAtValue:value];
    }
  }
  if ([name isEqualToString:@"startAfter"]) {
    if (key != nil) {
      return [query queryStartingAfterValue:value childKey:key];
    } else {
      return [query queryStartingAfterValue:value];
    }
  }
  if ([name isEqualToString:@"endAt"]) {
    if (key != nil) {
      return [query queryEndingAtValue:value childKey:key];
    } else {
      return [query queryEndingAtValue:value];
    }
  }
  if ([name isEqualToString:@"endBefore"]) {
    if (key != nil) {
      return [query queryEndingBeforeValue:value childKey:key];
    } else {
      return [query queryEndingBeforeValue:value];
    }
  }
  return query;
}

+ (FIRDatabaseQuery *)databaseQueryFromArguments:(id)arguments {
  FIRDatabaseQuery *query = [FLTFirebaseDatabaseUtils databaseReferenceFromArguments:arguments];
  NSArray<NSDictionary *> *modifiers = arguments[@"modifiers"];
  for (NSDictionary *modifier in modifiers) {
    NSString *type = [modifier valueForKey:@"type"];
    if ([type isEqualToString:@"limit"]) {
      query = [self databaseQuery:query applyLimitModifier:modifier];
    } else if ([type isEqualToString:@"cursor"]) {
      query = [self databaseQuery:query applyCursorModifier:modifier];
    } else if ([type isEqualToString:@"orderBy"]) {
      query = [self databaseQuery:query applyOrderModifier:modifier];
    }
  }
  return query;
}

+ (NSDictionary *)dictionaryFromSnapshot:(FIRDataSnapshot *)snapshot
                    withPreviousChildKey:(NSString *)previousChildKey {
  return @{
    @"snapshot" : [self dictionaryFromSnapshot:snapshot],
    @"previousChildKey" : previousChildKey ?: [NSNull null],
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
    @"key" : snapshot.key ?: [NSNull null],
    @"value" : snapshot.value ?: [NSNull null],
    @"priority" : snapshot.priority ?: [NSNull null],
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

+ (FIRDataEventType)eventTypeFromString:(NSString *)eventTypeString {
  if ([eventTypeString isEqualToString:@"value"]) {
    return FIRDataEventTypeValue;
  } else if ([eventTypeString isEqualToString:@"childAdded"]) {
    return FIRDataEventTypeChildAdded;
  } else if ([eventTypeString isEqualToString:@"childChanged"]) {
    return FIRDataEventTypeChildChanged;
  } else if ([eventTypeString isEqualToString:@"childRemoved"]) {
    return FIRDataEventTypeChildRemoved;
  } else if ([eventTypeString isEqualToString:@"childMoved"]) {
    return FIRDataEventTypeChildMoved;
  }
  return FIRDataEventTypeValue;
}

@end
