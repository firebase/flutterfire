// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "FirestorePigeonParser.h"
#import <Foundation/Foundation.h>

@implementation FirestorePigeonParser

+ (FIRFilter *_Nonnull)filterFromJson:(NSDictionary<NSString *, id> *_Nullable)map {
  if (map[@"fieldPath"]) {
    // Deserialize a FilterQuery
    NSString *op = map[@"op"];
    FIRFieldPath *fieldPath = map[@"fieldPath"];
    id value = map[@"value"];

    // All the operators from Firebase
    if ([op isEqualToString:@"=="]) {
      return [FIRFilter filterWhereFieldPath:fieldPath isEqualTo:value];
    } else if ([op isEqualToString:@"!="]) {
      return [FIRFilter filterWhereFieldPath:fieldPath isNotEqualTo:value];
    } else if ([op isEqualToString:@"<"]) {
      return [FIRFilter filterWhereFieldPath:fieldPath isLessThan:value];
    } else if ([op isEqualToString:@"<="]) {
      return [FIRFilter filterWhereFieldPath:fieldPath isLessThanOrEqualTo:value];
    } else if ([op isEqualToString:@">"]) {
      return [FIRFilter filterWhereFieldPath:fieldPath isGreaterThan:value];
    } else if ([op isEqualToString:@">="]) {
      return [FIRFilter filterWhereFieldPath:fieldPath isGreaterThanOrEqualTo:value];
    } else if ([op isEqualToString:@"array-contains"]) {
      return [FIRFilter filterWhereFieldPath:fieldPath arrayContains:value];
    } else if ([op isEqualToString:@"array-contains-any"]) {
      return [FIRFilter filterWhereFieldPath:fieldPath arrayContainsAny:value];
    } else if ([op isEqualToString:@"in"]) {
      return [FIRFilter filterWhereFieldPath:fieldPath in:value];
    } else if ([op isEqualToString:@"not-in"]) {
      return [FIRFilter filterWhereFieldPath:fieldPath notIn:value];
    } else {
      @throw [NSException exceptionWithName:@"InvalidOperator"
                                     reason:@"Invalid operator"
                                   userInfo:nil];
    }
  }
  // Deserialize a FilterOperator
  NSString *op = map[@"op"];
  NSArray<NSDictionary<NSString *, id> *> *queries = map[@"queries"];

  // Map queries recursively
  NSMutableArray<FIRFilter *> *parsedFilters = [NSMutableArray array];
  for (NSDictionary<NSString *, id> *query in queries) {
    [parsedFilters addObject:[self filterFromJson:query]];
  }

  if ([op isEqualToString:@"OR"]) {
    return [FIRFilter orFilterWithFilters:parsedFilters];
  } else if ([op isEqualToString:@"AND"]) {
    return [FIRFilter andFilterWithFilters:parsedFilters];
  }

  @throw [NSException exceptionWithName:@"InvalidOperator" reason:@"Invalid operator" userInfo:nil];
}

+ (FIRQuery *_Nonnull)parseQueryWithParameters:(nonnull PigeonQueryParameters *)parameters
                                     firestore:(nonnull FIRFirestore *)firestore
                                          path:(nonnull NSString *)path
                             isCollectionGroup:(Boolean)isCollectionGroup {
  @try {
    FIRQuery *query;

    NSArray *whereConditions = parameters.where;

    if (isCollectionGroup) {
      query = [firestore collectionGroupWithID:path];
    } else {
      query = (FIRQuery *)[firestore collectionWithPath:path];
    }

    BOOL isFilterQuery = parameters.filters != nil;
    if (isFilterQuery) {
      FIRFilter *filter = [FirestorePigeonParser filterFromJson:parameters.filters];
      query = [query queryWhereFilter:filter];
    }

    // Filters
    for (id item in whereConditions) {
      NSArray *condition = item;
      FIRFieldPath *fieldPath = (FIRFieldPath *)condition[0];
      NSString *operator= condition[1];
      id value = condition[2];
          if ([operator isEqualToString:@"=="]) {
            query = [query queryWhereFieldPath:fieldPath isEqualTo:value];
          } else if ([operator isEqualToString:@"!="]) {
            query = [query queryWhereFieldPath:fieldPath isNotEqualTo:value];
          } else if ([operator isEqualToString:@"<"]) {
            query = [query queryWhereFieldPath:fieldPath isLessThan:value];
          } else if ([operator isEqualToString:@"<="]) {
            query = [query queryWhereFieldPath:fieldPath isLessThanOrEqualTo:value];
          } else if ([operator isEqualToString:@">"]) {
            query = [query queryWhereFieldPath:fieldPath isGreaterThan:value];
          } else if ([operator isEqualToString:@">="]) {
            query = [query queryWhereFieldPath:fieldPath isGreaterThanOrEqualTo:value];
          } else if ([operator isEqualToString:@"array-contains"]) {
            query = [query queryWhereFieldPath:fieldPath arrayContains:value];
          } else if ([operator isEqualToString:@"array-contains-any"]) {
            query = [query queryWhereFieldPath:fieldPath arrayContainsAny:value];
          } else if ([operator isEqualToString:@"in"]) {
            query = [query queryWhereFieldPath:fieldPath in:value];
          } else if ([operator isEqualToString:@"not-in"]) {
            query = [query queryWhereFieldPath:fieldPath notIn:value];
          } else {
            NSLog(
                @"FLTFirebaseFirestore: An invalid query operator %@ was received but not handled.",
                operator);
          }
    }

    // Limit
    id limit = parameters.limit;
    if (limit) {
      query = [query queryLimitedTo:((NSNumber *)limit).intValue];
    }

    // Limit To Last
    id limitToLast = parameters.limitToLast;
    if (limitToLast) {
      query = [query queryLimitedToLast:((NSNumber *)limitToLast).intValue];
    }

    // Ordering
    NSArray *orderBy = parameters.orderBy;
    if (!orderBy) {
      // We return early if no ordering set as cursor queries below require at least one orderBy
      // set
      return query;
    }

    for (NSArray *orderByParameters in orderBy) {
      FIRFieldPath *fieldPath = (FIRFieldPath *)orderByParameters[0];
      NSNumber *descending = orderByParameters[1];
      query = [query queryOrderedByFieldPath:fieldPath descending:[descending boolValue]];
    }

    // Start At
    id startAt = parameters.startAt;
    if (startAt) query = [query queryStartingAtValues:(NSArray *)startAt];
    // Start After
    id startAfter = parameters.startAfter;
    if (startAfter) query = [query queryStartingAfterValues:(NSArray *)startAfter];
    // End At
    id endAt = parameters.endAt;
    if (endAt) query = [query queryEndingAtValues:(NSArray *)endAt];
    // End Before
    id endBefore = parameters.endBefore;
    if (endBefore) query = [query queryEndingBeforeValues:(NSArray *)endBefore];

    return query;
  } @catch (NSException *exception) {
    NSLog(@"An error occurred while parsing query arguments, this is most likely an error with "
          @"this SDK. %@",
          [exception callStackSymbols]);
    return nil;
  }
}

+ (FIRFirestoreSource)parseSource:(Source)source {
  switch (source) {
    case SourceServerAndCache:
      return FIRFirestoreSourceDefault;
    case SourceServer:
      return FIRFirestoreSourceServer;
    case SourceCache:
      return FIRFirestoreSourceCache;
    default:
      @throw [NSException exceptionWithName:@"Invalid Source"
                                     reason:@"This source is not supported by the SDK"
                                   userInfo:nil];
  }
}

+ (NSArray<FIRFieldPath *> *_Nonnull)parseFieldPath:
    (NSArray<NSArray<NSString *> *> *_Nonnull)fieldPaths {
  NSMutableArray<FIRFieldPath *> *paths = [NSMutableArray arrayWithCapacity:[fieldPaths count]];
  for (NSArray<NSString *> *fieldPath in fieldPaths) {
    FIRFieldPath *parsed = [[FIRFieldPath alloc] initWithFields:fieldPath];
    [paths addObject:parsed];
  }
  return [NSArray arrayWithArray:paths];
}

+ (FIRServerTimestampBehavior)parseServerTimestampBehavior:
    (ServerTimestampBehavior)serverTimestampBehavior {
  switch (serverTimestampBehavior) {
    case ServerTimestampBehaviorNone:
      return FIRServerTimestampBehaviorNone;
    case ServerTimestampBehaviorEstimate:
      return FIRServerTimestampBehaviorEstimate;
    case ServerTimestampBehaviorPrevious:
      return FIRServerTimestampBehaviorPrevious;
    default:
      @throw [NSException
          exceptionWithName:@"Invalid Server Timestamp Behavior"
                     reason:@"This Server Timestamp Behavior is not supported by the SDK"
                   userInfo:nil];
  }
}

+ (FIRListenSource)parseListenSource:(ListenSource)source {
  switch (source) {
    case ListenSourceDefaultSource:
      return FIRListenSourceDefault;
    case ListenSourceCache:
      return FIRListenSourceCache;
    default:
      @throw
          [NSException exceptionWithName:@"Invalid ListenSource"
                                  reason:@"This ListenSource Behavior is not supported by the SDK"
                                userInfo:nil];
  }
}

+ (PigeonSnapshotMetadata *_Nonnull)toPigeonSnapshotMetadata:
    (FIRSnapshotMetadata *_Nonnull)snapshotMetadata {
  return [PigeonSnapshotMetadata
      makeWithHasPendingWrites:[NSNumber numberWithBool:snapshotMetadata.hasPendingWrites]
                   isFromCache:[NSNumber numberWithBool:snapshotMetadata.isFromCache]];
}

+ (PigeonDocumentSnapshot *_Nonnull)
    toPigeonDocumentSnapshot:(FIRDocumentSnapshot *_Nonnull)documentSnapshot
     serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior {
  return [PigeonDocumentSnapshot
      makeWithPath:documentSnapshot.reference.path
              data:[documentSnapshot dataWithServerTimestampBehavior:serverTimestampBehavior]
          metadata:[FirestorePigeonParser toPigeonSnapshotMetadata:documentSnapshot.metadata]];
}

+ (DocumentChangeType)toPigeonDocumentChangeType:(FIRDocumentChangeType)documentChangeType {
  switch (documentChangeType) {
    case FIRDocumentChangeTypeAdded:
      return DocumentChangeTypeAdded;
    case FIRDocumentChangeTypeModified:
      return DocumentChangeTypeModified;
    case FIRDocumentChangeTypeRemoved:
      return DocumentChangeTypeRemoved;
    default:
      @throw [NSException exceptionWithName:@"InvalidDocumentChangeType"
                                     reason:@"Invalid document change type"
                                   userInfo:nil];
  }
}

+ (PigeonDocumentChange *_Nonnull)toPigeonDocumentChange:(FIRDocumentChange *_Nonnull)documentChange
                                 serverTimestampBehavior:
                                     (FIRServerTimestampBehavior)serverTimestampBehavior {
  NSNumber *oldIndex;
  NSNumber *newIndex;

  // Note the Firestore C++ SDK here returns a maxed UInt that is != NSUIntegerMax, so we make one
  // ourselves so we can convert to -1 for Dart.
  NSUInteger MAX_VAL = (NSUInteger)[@(-1) integerValue];

  if (documentChange.newIndex == NSNotFound || documentChange.newIndex == 4294967295 ||
      documentChange.newIndex == MAX_VAL) {
    newIndex = @([@(-1) intValue]);
  } else {
    newIndex = @([@(documentChange.newIndex) intValue]);
  }

  if (documentChange.oldIndex == NSNotFound || documentChange.oldIndex == 4294967295 ||
      documentChange.oldIndex == MAX_VAL) {
    oldIndex = @([@(-1) intValue]);
  } else {
    oldIndex = @([@(documentChange.oldIndex) intValue]);
  }

  return [PigeonDocumentChange
      makeWithType:[FirestorePigeonParser toPigeonDocumentChangeType:documentChange.type]
          document:[FirestorePigeonParser toPigeonDocumentSnapshot:documentChange.document
                                           serverTimestampBehavior:serverTimestampBehavior]
          oldIndex:oldIndex
          newIndex:newIndex];
}

+ (NSArray<PigeonDocumentChange *> *_Nonnull)
    toPigeonDocumentChanges:(NSArray<FIRDocumentChange *> *_Nonnull)documentChanges
    serverTimestampBehavior:(FIRServerTimestampBehavior)serverTimestampBehavior {
  NSMutableArray *pigeonDocumentChanges = [NSMutableArray array];
  for (FIRDocumentChange *documentChange in documentChanges) {
    [pigeonDocumentChanges
        addObject:[FirestorePigeonParser toPigeonDocumentChange:documentChange
                                        serverTimestampBehavior:serverTimestampBehavior]];
  }
  return pigeonDocumentChanges;
}

+ (PigeonQuerySnapshot *_Nonnull)toPigeonQuerySnapshot:(FIRQuerySnapshot *_Nonnull)querySnaphot
                               serverTimestampBehavior:
                                   (FIRServerTimestampBehavior)serverTimestampBehavior {
  NSMutableArray *documentSnapshots = [NSMutableArray array];
  for (FIRDocumentSnapshot *documentSnapshot in querySnaphot.documents) {
    [documentSnapshots
        addObject:[FirestorePigeonParser toPigeonDocumentSnapshot:documentSnapshot
                                          serverTimestampBehavior:serverTimestampBehavior]];
  }
  return [PigeonQuerySnapshot
      makeWithDocuments:documentSnapshots
        documentChanges:[FirestorePigeonParser toPigeonDocumentChanges:querySnaphot.documentChanges
                                               serverTimestampBehavior:serverTimestampBehavior]
               metadata:[FirestorePigeonParser toPigeonSnapshotMetadata:querySnaphot.metadata]];
}

@end
