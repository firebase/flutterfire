/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#import "include/cloud_firestore/Private/FLTPipelineParser.h"

#if TARGET_OS_OSX
#import <FirebaseFirestore/FirebaseFirestore.h>
#else
@import FirebaseFirestore;
#import "FIRPipelineBridge.h"
#endif

#import <Foundation/Foundation.h>

static NSString *const kPipelineNotAvailable =
    @"Pipeline API is not available. Firestore Pipelines require Firebase iOS SDK with pipeline "
     "support.";

static NSError *pipelineUnavailableError(void) {
  return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                             code:-1
                         userInfo:@{NSLocalizedDescriptionKey : kPipelineNotAvailable}];
}

#if __has_include("FIRPipelineBridge.h")
#define FLT_PIPELINE_AVAILABLE 1

static NSError *parseError(NSString *message) {
  return [NSError errorWithDomain:@"FLTFirebaseFirestore"
                             code:-1
                         userInfo:@{NSLocalizedDescriptionKey : message}];
}

@interface FLTPipelineExpressionParser : NSObject
- (FIRExprBridge *)parseExpression:(NSDictionary<NSString *, id> *)map error:(NSError **)error;
- (FIRExprBridge *)parseBooleanExpression:(NSDictionary<NSString *, id> *)map
                                    error:(NSError **)error;
@end

@implementation FLTPipelineExpressionParser

- (FIRExprBridge *)parseExpression:(NSDictionary<NSString *, id> *)map error:(NSError **)error {
  NSString *name = map[@"name"];
  if (!name) {
    NSDictionary *args = map[@"args"];
    if ([args isKindOfClass:[NSDictionary class]] && args[@"field"]) {
      return [[FIRFieldBridge alloc] initWithName:args[@"field"]];
    }
    if (error) *error = parseError(@"Expression must have a 'name' field");
    return nil;
  }

  NSDictionary *args = map[@"args"];
  if (![args isKindOfClass:[NSDictionary class]]) args = @{};

  if ([name isEqualToString:@"field"]) {
    NSString *field = args[@"field"];
    if (!field) {
      if (error) *error = parseError(@"Field expression requires 'field' argument");
      return nil;
    }
    return [[FIRFieldBridge alloc] initWithName:field];
  }

  if ([name isEqualToString:@"constant"]) {
    id value = args[@"value"];
    if (value == nil) {
      if (error) *error = parseError(@"Constant requires 'value' argument");
      return nil;
    }
    return [[FIRConstantBridge alloc] init:value];
  }

  if ([name isEqualToString:@"alias"]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Alias requires 'expression'");
      return nil;
    }
    // No explicit AliasedExpression type in ObjC; aliases are dict keys when building stages.
    // Parse and return the inner expression; the caller uses args[@"alias"] as the dict key.
    return [self parseExpression:exprMap error:error];
  }

  NSArray *binaryNames = @[
    @"equal", @"not_equal", @"greater_than", @"greater_than_or_equal", @"less_than",
    @"less_than_or_equal", @"add", @"subtract", @"multiply", @"divide", @"modulo"
  ];
  if ([binaryNames containsObject:name]) {
    id leftMap = args[@"left"];
    id rightMap = args[@"right"];
    if (![leftMap isKindOfClass:[NSDictionary class]] ||
        ![rightMap isKindOfClass:[NSDictionary class]]) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires left and right expressions", name]);
      return nil;
    }
    FIRExprBridge *left = [self parseExpression:leftMap error:error];
    FIRExprBridge *right = [self parseExpression:rightMap error:error];
    if (!left || !right) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ left, right ]];
  }

  if ([name isEqualToString:@"and"] || [name isEqualToString:@"or"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    FIRExprBridge *first = [self parseBooleanExpression:exprMaps[0] error:error];
    if (!first) return nil;
    NSMutableArray *all = [NSMutableArray arrayWithObject:first];
    for (NSUInteger i = 1; i < exprMaps.count; i++) {
      FIRExprBridge *next = [self parseBooleanExpression:exprMaps[i] error:error];
      if (!next) return nil;
      [all addObject:next];
    }
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:all];
  }

  if ([name isEqualToString:@"not"]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"not requires expression");
      return nil;
    }
    FIRExprBridge *expr = [self parseBooleanExpression:exprMap error:error];
    if (!expr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:@"not" Args:@[ expr ]];
  }

  if (error) *error = parseError([NSString stringWithFormat:@"Unsupported expression: %@", name]);
  return nil;
}

- (FIRExprBridge *)parseBooleanExpression:(NSDictionary<NSString *, id> *)map
                                    error:(NSError **)error {
  return [self parseExpression:map error:error];
}

@end

@implementation FLTPipelineParser

+ (void)executePipelineWithFirestore:(FIRFirestore *)firestore
                              stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                             options:(nullable NSDictionary<NSString *, id> *)options
                          completion:(void (^)(id _Nullable snapshot,
                                               NSError *_Nullable error))completion {
  if (!stages || stages.count == 0) {
    completion(nil, parseError(@"Pipeline requires at least one stage"));
    return;
  }

  FLTPipelineExpressionParser *exprParser = [[FLTPipelineExpressionParser alloc] init];
  NSMutableArray<FIRStageBridge *> *stageBridges = [NSMutableArray array];
  NSError *parseErr = nil;

  for (NSUInteger i = 0; i < stages.count; i++) {
    NSDictionary *stageMap = stages[i];
    if (![stageMap isKindOfClass:[NSDictionary class]]) {
      completion(nil, parseError(@"Stage must be a map"));
      return;
    }
    NSString *stageName = stageMap[@"stage"];
    if (![stageName isKindOfClass:[NSString class]]) {
      completion(nil, parseError(@"Stage must have a 'stage' field"));
      return;
    }
    NSDictionary *args = stageMap[@"args"];
    if (![args isKindOfClass:[NSDictionary class]]) args = @{};

    FIRStageBridge *stage = nil;

    if (i == 0) {
      if ([stageName isEqualToString:@"collection"]) {
        NSString *path = args[@"path"];
        if (!path) {
          completion(nil, parseError(@"collection requires 'path'"));
          return;
        }
        FIRCollectionReference *ref = [firestore collectionWithPath:path];
        stage = [[FIRCollectionSourceStageBridge alloc] initWithRef:ref firestore:firestore];
      } else if ([stageName isEqualToString:@"collection_group"]) {
        NSString *path = args[@"path"];
        if (!path) {
          completion(nil, parseError(@"collection_group requires 'path'"));
          return;
        }
        stage = [[FIRCollectionGroupSourceStageBridge alloc] initWithCollectionId:path];
      } else if ([stageName isEqualToString:@"database"]) {
        stage = [[FIRDatabaseSourceStageBridge alloc] init];
      } else if ([stageName isEqualToString:@"documents"]) {
        id argsOrArray = stageMap[@"args"];
        NSArray *docMaps = [argsOrArray isKindOfClass:[NSArray class]] ? argsOrArray : nil;
        if (!docMaps || docMaps.count == 0) {
          completion(nil, parseError(@"documents requires array of document refs"));
          return;
        }
        NSMutableArray<FIRDocumentReference *> *refs = [NSMutableArray array];
        for (id docMap in docMaps) {
          if (![docMap isKindOfClass:[NSDictionary class]]) continue;
          NSString *path = ((NSDictionary *)docMap)[@"path"];
          if (path) [refs addObject:[firestore documentWithPath:path]];
        }
        stage = [[FIRDocumentsSourceStageBridge alloc] initWithDocuments:refs firestore:firestore];
      } else {
        completion(nil, parseError([NSString
                            stringWithFormat:@"First stage must be collection, collection_group, "
                                             @"documents, or database. Got: %@",
                                             stageName]));
        return;
      }
    } else {
      if ([stageName isEqualToString:@"where"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          completion(nil, parseError(@"where requires expression"));
          return;
        }
        FIRExprBridge *expr = [exprParser parseBooleanExpression:exprMap error:&parseErr];
        if (!expr) {
          completion(nil, parseErr);
          return;
        }
        stage = [[FIRWhereStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"limit"]) {
        NSNumber *limit = args[@"limit"];
        if (![limit isKindOfClass:[NSNumber class]]) {
          completion(nil, parseError(@"limit requires numeric limit"));
          return;
        }
        stage = [[FIRLimitStageBridge alloc] initWithLimit:limit.intValue];
      } else if ([stageName isEqualToString:@"offset"]) {
        NSNumber *offset = args[@"offset"];
        if (![offset isKindOfClass:[NSNumber class]]) {
          completion(nil, parseError(@"offset requires numeric offset"));
          return;
        }
        stage = [[FIROffsetStageBridge alloc] initWithOffset:offset.intValue];
      } else if ([stageName isEqualToString:@"sort"]) {
        NSArray *orderingMaps = args[@"orderings"];
        if (![orderingMaps isKindOfClass:[NSArray class]] || orderingMaps.count == 0) {
          completion(nil, parseError(@"sort requires at least one ordering"));
          return;
        }
        NSMutableArray<FIROrderingBridge *> *orderings = [NSMutableArray array];
        for (id om in orderingMaps) {
          if (![om isKindOfClass:[NSDictionary class]]) continue;
          id exprMap = ((NSDictionary *)om)[@"expression"];
          NSString *dir = ((NSDictionary *)om)[@"order_direction"];
          if (![exprMap isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
          if (!expr) {
            completion(nil, parseErr);
            return;
          }
          NSString *direction = [dir isEqualToString:@"asc"] ? @"ascending" : @"descending";
          FIROrderingBridge *ordering = [[FIROrderingBridge alloc] initWithExpr:expr
                                                                      Direction:direction];
          [orderings addObject:ordering];
        }
        if (orderings.count == 0) {
          completion(nil, parseError(@"sort requires at least one ordering"));
          return;
        }
        stage = [[FIRSorStageBridge alloc] initWithOrderings:orderings];
      } else if ([stageName isEqualToString:@"select"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          completion(nil, parseError(@"select requires at least one expression"));
          return;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            completion(nil, parseErr);
            return;
          }
          NSString *alias = [em valueForKeyPath:@"args.alias"];
          if (alias) {
            fields[alias] = expr;
          } else {
            NSString *fn = em[@"name"];
            if ([fn isEqualToString:@"field"]) {
              NSString *field = [em valueForKeyPath:@"args.field"];
              fields[field ?: @"_"] = expr;
            } else {
              fields[[NSString stringWithFormat:@"_%lu", (unsigned long)fields.count]] = expr;
            }
          }
        }
        stage = [[FIRSelectStageBridge alloc] initWithSelections:fields];
      } else if ([stageName isEqualToString:@"add_fields"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          completion(nil, parseError(@"add_fields requires at least one expression"));
          return;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            completion(nil, parseErr);
            return;
          }
          NSString *alias = [em valueForKeyPath:@"args.alias"];
          if (!alias) {
            completion(nil, parseError(@"add_fields expressions must have alias"));
            return;
          }
          fields[alias] = expr;
        }
        stage = [[FIRAddFieldsStageBridge alloc] initWithFields:fields];
      } else if ([stageName isEqualToString:@"remove_fields"]) {
        NSArray *paths = args[@"field_paths"];
        if (![paths isKindOfClass:[NSArray class]] || paths.count == 0) {
          completion(nil, parseError(@"remove_fields requires field_paths"));
          return;
        }
        stage = [[FIRRemoveFieldsStageBridge alloc] initWithFields:paths];
      } else if ([stageName isEqualToString:@"distinct"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          completion(nil, parseError(@"distinct requires at least one expression"));
          return;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (NSUInteger j = 0; j < exprMaps.count; j++) {
          id em = exprMaps[j];
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            completion(nil, parseErr);
            return;
          }
          fields[[NSString stringWithFormat:@"_%lu", (unsigned long)j]] = expr;
        }
        stage = [[FIRDistinctStageBridge alloc] initWithGroups:fields];
      } else if ([stageName isEqualToString:@"replace_with"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          completion(nil, parseError(@"replace_with requires expression"));
          return;
        }
        FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
        if (!expr) {
          completion(nil, parseErr);
          return;
        }
        stage = [[FIRReplaceWithStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"union"]) {
        NSArray *nestedStages = args[@"pipeline"];
        if (![nestedStages isKindOfClass:[NSArray class]] || nestedStages.count == 0) {
          completion(nil, parseError(@"union requires non-empty pipeline"));
          return;
        }
        id otherPipeline = [self buildPipelineWithFirestore:firestore
                                                     stages:nestedStages
                                                      error:&parseErr];
        if (!otherPipeline) {
          completion(nil, parseErr);
          return;
        }
        stage = [[FIRUnionStageBridge alloc] initWithOther:otherPipeline];
      } else if ([stageName isEqualToString:@"sample"]) {
        NSString *type = args[@"type"];
        id val = args[@"value"];
        if ([type isEqualToString:@"percentage"]) {
          double v = [val isKindOfClass:[NSNumber class]] ? [(NSNumber *)val doubleValue] : 0;
          stage = [[FIRSampleStageBridge alloc] initWithPercentage:v];
        } else {
          int v = [val isKindOfClass:[NSNumber class]] ? [(NSNumber *)val intValue] : 0;
          stage = [[FIRSampleStageBridge alloc] initWithCount:v];
        }
      } else {
        completion(
            nil, parseError([NSString stringWithFormat:@"Unknown pipeline stage: %@", stageName]));
        return;
      }
    }

    if (stage) [stageBridges addObject:stage];
  }

  if (stageBridges.count == 0) {
    completion(nil, parseError(@"No valid stages"));
    return;
  }

  FIRPipelineBridge *pipeline = [[FIRPipelineBridge alloc] initWithStages:stageBridges
                                                                       db:firestore];
  [pipeline executeWithCompletion:^(id snapshot, NSError *execError) {
    if (execError) {
      completion(nil, execError);
      return;
    }
    completion(snapshot, nil);
  }];
}

+ (id)buildPipelineWithFirestore:(FIRFirestore *)firestore
                          stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                           error:(NSError **)error {
  FLTPipelineExpressionParser *exprParser = [[FLTPipelineExpressionParser alloc] init];
  NSMutableArray<FIRStageBridge *> *stageBridges = [NSMutableArray array];

  for (NSUInteger i = 0; i < stages.count; i++) {
    NSDictionary *stageMap = stages[i];
    if (![stageMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Stage must be a map");
      return nil;
    }
    NSString *stageName = stageMap[@"stage"];
    id argsObj = stageMap[@"args"];
    NSDictionary *args = [argsObj isKindOfClass:[NSDictionary class]] ? argsObj : @{};
    NSArray *argsArray = [argsObj isKindOfClass:[NSArray class]] ? argsObj : nil;

    FIRStageBridge *stage = nil;

    if (i == 0) {
      if ([stageName isEqualToString:@"collection"]) {
        NSString *path = args[@"path"];
        FIRCollectionReference *ref = [firestore collectionWithPath:path];
        stage = [[FIRCollectionSourceStageBridge alloc] initWithRef:ref firestore:firestore];
      } else if ([stageName isEqualToString:@"collection_group"]) {
        stage = [[FIRCollectionGroupSourceStageBridge alloc] initWithCollectionId:args[@"path"]];
      } else if ([stageName isEqualToString:@"database"]) {
        stage = [[FIRDatabaseSourceStageBridge alloc] init];
      } else if ([stageName isEqualToString:@"documents"]) {
        NSArray *docMaps = argsArray ?: @[];
        NSMutableArray<FIRDocumentReference *> *refs = [NSMutableArray array];
        for (id docMap in docMaps) {
          if ([docMap isKindOfClass:[NSDictionary class]] && ((NSDictionary *)docMap)[@"path"])
            [refs addObject:[firestore documentWithPath:((NSDictionary *)docMap)[@"path"]]];
        }
        stage = [[FIRDocumentsSourceStageBridge alloc] initWithDocuments:refs firestore:firestore];
      }
    } else {
      NSError *parseErr = nil;
      if ([stageName isEqualToString:@"where"]) {
        FIRExprBridge *expr = [exprParser parseBooleanExpression:args[@"expression"]
                                                           error:&parseErr];
        if (expr) stage = [[FIRWhereStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"limit"]) {
        stage = [[FIRLimitStageBridge alloc] initWithLimit:[args[@"limit"] intValue]];
      } else if ([stageName isEqualToString:@"offset"]) {
        stage = [[FIROffsetStageBridge alloc] initWithOffset:[args[@"offset"] intValue]];
      } else if ([stageName isEqualToString:@"sort"]) {
        NSArray *orderingMaps = args[@"orderings"];
        if ([orderingMaps isKindOfClass:[NSArray class]] && orderingMaps.count > 0) {
          NSMutableArray<FIROrderingBridge *> *orderings = [NSMutableArray array];
          for (id om in orderingMaps) {
            if (![om isKindOfClass:[NSDictionary class]]) continue;
            id exprMap = ((NSDictionary *)om)[@"expression"];
            NSString *dir = ((NSDictionary *)om)[@"order_direction"];
            if (![exprMap isKindOfClass:[NSDictionary class]]) continue;
            FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
            if (!expr) break;
            NSString *direction = [dir isEqualToString:@"asc"] ? @"ascending" : @"descending";
            [orderings addObject:[[FIROrderingBridge alloc] initWithExpr:expr Direction:direction]];
          }
          if (orderings.count > 0) {
            stage = [[FIRSorStageBridge alloc] initWithOrderings:orderings];
          }
        }
      } else if ([stageName isEqualToString:@"union"]) {
        id other = [self buildPipelineWithFirestore:firestore
                                             stages:args[@"pipeline"]
                                              error:&parseErr];
        if (other) stage = [[FIRUnionStageBridge alloc] initWithOther:other];
      }
      if (parseErr && error) *error = parseErr;
    }

    if (stage) [stageBridges addObject:stage];
  }

  if (stageBridges.count == 0) {
    if (error && !*error) *error = parseError(@"No valid stages");
    return nil;
  }

  return [[FIRPipelineBridge alloc] initWithStages:stageBridges db:firestore];
}

@end

#else

@implementation FLTPipelineParser

+ (void)executePipelineWithFirestore:(FIRFirestore *)firestore
                              stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                             options:(nullable NSDictionary<NSString *, id> *)options
                          completion:(void (^)(id _Nullable snapshot,
                                               NSError *_Nullable error))completion {
  completion(nil, pipelineUnavailableError());
}

@end

#endif
