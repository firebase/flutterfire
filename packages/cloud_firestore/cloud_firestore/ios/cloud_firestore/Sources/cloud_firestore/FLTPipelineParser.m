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

  // Map Dart names to iOS SDK names where they differ
  NSString *sdkName = name;
  if ([name isEqualToString:@"bit_xor"]) sdkName = @"xor";

  // -------------------------------------------------------------------------
  // Binary expressions (left + right): comparisons, arithmetic, xor
  // -------------------------------------------------------------------------
  static NSArray *binaryNames = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    binaryNames = @[
      @"equal", @"not_equal", @"greater_than", @"greater_than_or_equal", @"less_than",
      @"less_than_or_equal", @"add", @"subtract", @"multiply", @"divide", @"modulo", @"xor"
    ];
  });
  if ([binaryNames containsObject:sdkName] || [name isEqualToString:@"bit_xor"]) {
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
    return [[FIRFunctionExprBridge alloc] initWithName:sdkName Args:@[ left, right ]];
  }

  // -------------------------------------------------------------------------
  // Unary expressions (single expression): exists, is_error, is_absent, not
  // -------------------------------------------------------------------------
  NSArray *unaryNames = @[ @"exists", @"is_error", @"is_absent", @"not" ];
  if ([unaryNames containsObject:name]) {
    id exprMap = args[@"expression"];
    if (![exprMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires expression", name]);
      return nil;
    }
    FIRExprBridge *expr = [name isEqualToString:@"not"]
                              ? [self parseBooleanExpression:exprMap error:error]
                              : [self parseExpression:exprMap error:error];
    if (!expr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ expr ]];
  }

  // -------------------------------------------------------------------------
  // N-ary logical (expressions array): and, or
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"and"] || [name isEqualToString:@"or"]) {
    NSArray *exprMaps = args[@"expressions"];
    if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    NSMutableArray<FIRExprBridge *> *all = [NSMutableArray array];
    for (id em in exprMaps) {
      if (![em isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *e = [self parseBooleanExpression:em error:error];
      if (!e) return nil;
      [all addObject:e];
    }
    if (all.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires at least one expression", name]);
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:all];
  }

  // -------------------------------------------------------------------------
  // value + values[]: equal_any, not_equal_any
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"equal_any"] || [name isEqualToString:@"not_equal_any"]) {
    id valueMap = args[@"value"];
    NSArray *valuesMaps = args[@"values"];
    if (![valueMap isKindOfClass:[NSDictionary class]] ||
        ![valuesMaps isKindOfClass:[NSArray class]] || valuesMaps.count == 0) {
      if (error)
        *error =
            parseError([NSString stringWithFormat:@"%@ requires value and non-empty values", name]);
      return nil;
    }
    FIRExprBridge *valueExpr = [self parseExpression:valueMap error:error];
    if (!valueExpr) return nil;
    NSMutableArray<FIRExprBridge *> *valueExprs = [NSMutableArray array];
    for (id vm in valuesMaps) {
      if (![vm isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *ve = [self parseExpression:vm error:error];
      if (!ve) return nil;
      [valueExprs addObject:ve];
    }
    if (valueExprs.count == 0) {
      if (error)
        *error = parseError([NSString stringWithFormat:@"%@ requires at least one value", name]);
      return nil;
    }
    NSMutableArray *argsArray = [NSMutableArray arrayWithObject:valueExpr];
    [argsArray addObjectsFromArray:valueExprs];
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:argsArray];
  }

  // -------------------------------------------------------------------------
  // array + element: array_contains
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_contains"]) {
    id arrayMap = args[@"array"];
    id elementMap = args[@"element"];
    if (![arrayMap isKindOfClass:[NSDictionary class]] ||
        ![elementMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"array_contains requires array and element");
      return nil;
    }
    FIRExprBridge *arrayExpr = [self parseExpression:arrayMap error:error];
    FIRExprBridge *elementExpr = [self parseExpression:elementMap error:error];
    if (!arrayExpr || !elementExpr) return nil;
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:@[ arrayExpr, elementExpr ]];
  }

  // -------------------------------------------------------------------------
  // array + values[]: array_contains_all, array_contains_any
  // -------------------------------------------------------------------------
  if ([name isEqualToString:@"array_contains_all"] ||
      [name isEqualToString:@"array_contains_any"]) {
    id arrayMap = args[@"array"];
    NSArray *valuesMaps = args[@"values"];
    if (![valuesMaps isKindOfClass:[NSArray class]]) valuesMaps = args[@"elements"];
    if (![arrayMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError([NSString stringWithFormat:@"%@ requires array", name]);
      return nil;
    }
    FIRExprBridge *arrayExpr = [self parseExpression:arrayMap error:error];
    if (!arrayExpr) return nil;
    NSMutableArray<FIRExprBridge *> *argsArray = [NSMutableArray arrayWithObject:arrayExpr];
    if ([valuesMaps isKindOfClass:[NSArray class]]) {
      for (id vm in valuesMaps) {
        if (![vm isKindOfClass:[NSDictionary class]]) continue;
        FIRExprBridge *ve = [self parseExpression:vm error:error];
        if (!ve) return nil;
        [argsArray addObject:ve];
      }
    }
    if (argsArray.count < 2) {
      if (error)
        *error = parseError(
            [NSString stringWithFormat:@"%@ requires array and at least one value", name]);
      return nil;
    }
    return [[FIRFunctionExprBridge alloc] initWithName:name Args:argsArray];
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

+ (NSArray<FIRStageBridge *> *)
    parseStagesWithFirestore:(FIRFirestore *)firestore
                      stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                       error:(NSError **)error {
  FLTPipelineExpressionParser *exprParser = [[FLTPipelineExpressionParser alloc] init];
  NSMutableArray<FIRStageBridge *> *stageBridges = [NSMutableArray array];
  NSError *parseErr = nil;

  for (NSUInteger i = 0; i < stages.count; i++) {
    NSDictionary *stageMap = stages[i];
    if (![stageMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Stage must be a map");
      return nil;
    }
    NSString *stageName = stageMap[@"stage"];
    if (![stageName isKindOfClass:[NSString class]]) {
      if (error) *error = parseError(@"Stage must have a 'stage' field");
      return nil;
    }
    id argsObj = stageMap[@"args"];
    NSDictionary *args = [argsObj isKindOfClass:[NSDictionary class]] ? argsObj : @{};
    NSArray *argsArray = [argsObj isKindOfClass:[NSArray class]] ? argsObj : nil;

    FIRStageBridge *stage = nil;

    if (i == 0) {
      if ([stageName isEqualToString:@"collection"]) {
        NSString *path = args[@"path"];
        if (!path) {
          if (error) *error = parseError(@"collection requires 'path'");
          return nil;
        }
        FIRCollectionReference *ref = [firestore collectionWithPath:path];
        stage = [[FIRCollectionSourceStageBridge alloc] initWithRef:ref firestore:firestore];
      } else if ([stageName isEqualToString:@"collection_group"]) {
        NSString *path = args[@"path"];
        if (!path) {
          if (error) *error = parseError(@"collection_group requires 'path'");
          return nil;
        }
        stage = [[FIRCollectionGroupSourceStageBridge alloc] initWithCollectionId:path];
      } else if ([stageName isEqualToString:@"database"]) {
        stage = [[FIRDatabaseSourceStageBridge alloc] init];
      } else if ([stageName isEqualToString:@"documents"]) {
        NSArray *docMaps = argsArray;
        if (!docMaps || docMaps.count == 0) {
          if (error) *error = parseError(@"documents requires array of document refs");
          return nil;
        }
        NSMutableArray<FIRDocumentReference *> *refs = [NSMutableArray array];
        for (id docMap in docMaps) {
          if (![docMap isKindOfClass:[NSDictionary class]]) continue;
          NSString *path = ((NSDictionary *)docMap)[@"path"];
          if (path) [refs addObject:[firestore documentWithPath:path]];
        }
        stage = [[FIRDocumentsSourceStageBridge alloc] initWithDocuments:refs firestore:firestore];
      } else {
        if (error)
          *error = parseError(
              [NSString stringWithFormat:@"First stage must be collection, collection_group, "
                                         @"documents, or database. Got: %@",
                                         stageName]);
        return nil;
      }
    } else {
      if ([stageName isEqualToString:@"where"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"where requires expression");
          return nil;
        }
        FIRExprBridge *expr = [exprParser parseBooleanExpression:exprMap error:&parseErr];
        if (!expr) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[FIRWhereStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"limit"]) {
        NSNumber *limit = args[@"limit"];
        if (![limit isKindOfClass:[NSNumber class]]) {
          if (error) *error = parseError(@"limit requires numeric limit");
          return nil;
        }
        stage = [[FIRLimitStageBridge alloc] initWithLimit:limit.intValue];
      } else if ([stageName isEqualToString:@"offset"]) {
        NSNumber *offset = args[@"offset"];
        if (![offset isKindOfClass:[NSNumber class]]) {
          if (error) *error = parseError(@"offset requires numeric offset");
          return nil;
        }
        stage = [[FIROffsetStageBridge alloc] initWithOffset:offset.intValue];
      } else if ([stageName isEqualToString:@"sort"]) {
        NSArray *orderingMaps = args[@"orderings"];
        if (![orderingMaps isKindOfClass:[NSArray class]] || orderingMaps.count == 0) {
          if (error) *error = parseError(@"sort requires at least one ordering");
          return nil;
        }
        NSMutableArray<FIROrderingBridge *> *orderings = [NSMutableArray array];
        for (id om in orderingMaps) {
          if (![om isKindOfClass:[NSDictionary class]]) continue;
          id exprMap = ((NSDictionary *)om)[@"expression"];
          NSString *dir = ((NSDictionary *)om)[@"order_direction"];
          if (![exprMap isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *direction = [dir isEqualToString:@"asc"] ? @"ascending" : @"descending";
          FIROrderingBridge *ordering = [[FIROrderingBridge alloc] initWithExpr:expr
                                                                      Direction:direction];
          [orderings addObject:ordering];
        }
        if (orderings.count == 0) {
          if (error) *error = parseError(@"sort requires at least one ordering");
          return nil;
        }
        stage = [[FIRSorStageBridge alloc] initWithOrderings:orderings];
      } else if ([stageName isEqualToString:@"select"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"select requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
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
          if (error) *error = parseError(@"add_fields requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (id em in exprMaps) {
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          NSString *alias = [em valueForKeyPath:@"args.alias"];
          if (!alias) {
            if (error) *error = parseError(@"add_fields expressions must have alias");
            return nil;
          }
          fields[alias] = expr;
        }
        stage = [[FIRAddFieldsStageBridge alloc] initWithFields:fields];
      } else if ([stageName isEqualToString:@"remove_fields"]) {
        NSArray *paths = args[@"field_paths"];
        if (![paths isKindOfClass:[NSArray class]] || paths.count == 0) {
          if (error) *error = parseError(@"remove_fields requires field_paths");
          return nil;
        }
        stage = [[FIRRemoveFieldsStageBridge alloc] initWithFields:paths];
      } else if ([stageName isEqualToString:@"distinct"]) {
        NSArray *exprMaps = args[@"expressions"];
        if (![exprMaps isKindOfClass:[NSArray class]] || exprMaps.count == 0) {
          if (error) *error = parseError(@"distinct requires at least one expression");
          return nil;
        }
        NSMutableDictionary<NSString *, FIRExprBridge *> *fields = [NSMutableDictionary dictionary];
        for (NSUInteger j = 0; j < exprMaps.count; j++) {
          id em = exprMaps[j];
          if (![em isKindOfClass:[NSDictionary class]]) continue;
          FIRExprBridge *expr = [exprParser parseExpression:em error:&parseErr];
          if (!expr) {
            if (error) *error = parseErr;
            return nil;
          }
          fields[[NSString stringWithFormat:@"_%lu", (unsigned long)j]] = expr;
        }
        stage = [[FIRDistinctStageBridge alloc] initWithGroups:fields];
      } else if ([stageName isEqualToString:@"replace_with"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"replace_with requires expression");
          return nil;
        }
        FIRExprBridge *expr = [exprParser parseExpression:exprMap error:&parseErr];
        if (!expr) {
          if (error) *error = parseErr;
          return nil;
        }
        stage = [[FIRReplaceWithStageBridge alloc] initWithExpr:expr];
      } else if ([stageName isEqualToString:@"union"]) {
        NSArray *nestedStages = args[@"pipeline"];
        if (![nestedStages isKindOfClass:[NSArray class]] || nestedStages.count == 0) {
          if (error) *error = parseError(@"union requires non-empty pipeline");
          return nil;
        }
        id otherPipeline = [self buildPipelineWithFirestore:firestore
                                                     stages:nestedStages
                                                      error:&parseErr];
        if (!otherPipeline) {
          if (error) *error = parseErr;
          return nil;
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
      } else if ([stageName isEqualToString:@"aggregate"]) {
        stage = [self parseAggregateStageWithArgs:args exprParser:exprParser error:error];
      } else if ([stageName isEqualToString:@"unnest"]) {
        id exprMap = args[@"expression"];
        if (![exprMap isKindOfClass:[NSDictionary class]]) {
          if (error) *error = parseError(@"unnest requires expression");
          return nil;
        }
        FIRExprBridge *fieldExpr = nil;
        FIRExprBridge *aliasExpr = nil;
        NSDictionary *exprDict = (NSDictionary *)exprMap;
        NSString *aliasStr = nil;
        if ([exprDict[@"name"] isEqualToString:@"alias"]) {
          NSDictionary *aliasArgs = exprDict[@"args"];
          if ([aliasArgs isKindOfClass:[NSDictionary class]] && aliasArgs[@"expression"]) {
            fieldExpr = [exprParser parseExpression:aliasArgs[@"expression"] error:&parseErr];
            if (!fieldExpr) {
              if (error) *error = parseErr;
              return nil;
            }
            aliasStr =
                [aliasArgs[@"alias"] isKindOfClass:[NSString class]] ? aliasArgs[@"alias"] : nil;
          }
        }
        if (!fieldExpr) {
          fieldExpr = [exprParser parseExpression:exprMap error:&parseErr];
          if (!fieldExpr) {
            if (error) *error = parseErr;
            return nil;
          }
          if (!aliasStr && [exprDict[@"name"] isEqualToString:@"field"]) {
            NSDictionary *fieldArgs = exprDict[@"args"];
            aliasStr =
                [fieldArgs[@"field"] isKindOfClass:[NSString class]] ? fieldArgs[@"field"] : @"_";
          }
        }
        if (!aliasStr) aliasStr = @"_";
        aliasExpr = [[FIRFieldBridge alloc] initWithName:aliasStr];
        NSString *indexFieldStr =
            [args[@"index_field"] isKindOfClass:[NSString class]] ? args[@"index_field"] : nil;
        FIRExprBridge *indexFieldExpr =
            (indexFieldStr.length > 0) ? [[FIRFieldBridge alloc] initWithName:indexFieldStr] : nil;
        stage = [[FIRUnnestStageBridge alloc] initWithField:fieldExpr
                                                      alias:aliasExpr
                                                 indexField:indexFieldExpr];
      } else {
        if (error)
          *error = parseError([NSString stringWithFormat:@"Unknown pipeline stage: %@", stageName]);
        return nil;
      }
    }

    if (stage) [stageBridges addObject:stage];
  }

  if (stageBridges.count == 0) {
    if (error && !*error) *error = parseError(@"No valid stages");
    return nil;
  }

  return stageBridges;
}

+ (FIRAggregateFunctionBridge *)aggregateFunctionFromMap:(NSDictionary *)funcMap
                                              exprParser:(FLTPipelineExpressionParser *)exprParser
                                                   error:(NSError **)error {
  NSString *name = funcMap[@"name"];
  if (![name isKindOfClass:[NSString class]]) {
    if (error) *error = parseError(@"Aggregate function must have a 'name'");
    return nil;
  }
  // Map Dart aggregate function names to iOS SDK names (count_all -> count with no args; minimum ->
  // min; maximum -> max)
  NSString *iosName = name;
  if ([name isEqualToString:@"count_all"]) {
    iosName = @"count";
  } else if ([name isEqualToString:@"minimum"]) {
    iosName = @"min";
  } else if ([name isEqualToString:@"maximum"]) {
    iosName = @"max";
  }
  NSDictionary *argsDict = funcMap[@"args"];
  NSMutableArray<FIRExprBridge *> *argsArray = [NSMutableArray array];
  if ([argsDict isKindOfClass:[NSDictionary class]]) {
    id exprMap = argsDict[@"expression"];
    if ([exprMap isKindOfClass:[NSDictionary class]]) {
      FIRExprBridge *expr = [exprParser parseExpression:exprMap error:error];
      if (!expr) return nil;
      [argsArray addObject:expr];
    }
  }
  return [[FIRAggregateFunctionBridge alloc] initWithName:iosName Args:argsArray];
}

+ (FIRStageBridge *)parseAggregateStageWithArgs:(NSDictionary *)args
                                     exprParser:(FLTPipelineExpressionParser *)exprParser
                                          error:(NSError **)error {
  NSError *parseErr = nil;
  NSArray *accumulatorMaps = nil;
  NSArray *groupMaps = nil;

  if (args[@"aggregate_stage"]) {
    NSDictionary *stageMap = args[@"aggregate_stage"];
    if (![stageMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"aggregate_stage must be a map");
      return nil;
    }
    accumulatorMaps = stageMap[@"accumulators"];
    groupMaps = stageMap[@"groups"];
  }
  if (!accumulatorMaps || ![accumulatorMaps isKindOfClass:[NSArray class]]) {
    accumulatorMaps = args[@"aggregate_functions"];
  }
  if (![accumulatorMaps isKindOfClass:[NSArray class]] || accumulatorMaps.count == 0) {
    if (error) *error = parseError(@"aggregate requires accumulators or aggregate_functions");
    return nil;
  }

  NSMutableDictionary<NSString *, FIRAggregateFunctionBridge *> *accumulators =
      [NSMutableDictionary dictionary];
  for (id accMap in accumulatorMaps) {
    if (![accMap isKindOfClass:[NSDictionary class]]) continue;
    NSString *alias = nil;
    NSDictionary *funcMap = nil;
    if ([accMap[@"name"] isEqualToString:@"alias"]) {
      NSDictionary *accArgs = accMap[@"args"];
      if (![accArgs isKindOfClass:[NSDictionary class]]) continue;
      alias = accArgs[@"alias"];
      funcMap = accArgs[@"aggregate_function"];
    }
    if (![alias isKindOfClass:[NSString class]] || ![funcMap isKindOfClass:[NSDictionary class]]) {
      if (error) *error = parseError(@"Each accumulator must have alias and aggregate_function");
      return nil;
    }
    FIRAggregateFunctionBridge *func = [self aggregateFunctionFromMap:funcMap
                                                           exprParser:exprParser
                                                                error:&parseErr];
    if (!func) {
      if (error) *error = parseErr;
      return nil;
    }
    accumulators[alias] = func;
  }
  if (accumulators.count == 0) {
    if (error) *error = parseError(@"aggregate requires at least one valid accumulator");
    return nil;
  }

  NSMutableDictionary<NSString *, FIRExprBridge *> *groups = [NSMutableDictionary dictionary];
  if ([groupMaps isKindOfClass:[NSArray class]] && groupMaps.count > 0) {
    for (NSUInteger g = 0; g < groupMaps.count; g++) {
      id gm = groupMaps[g];
      if (![gm isKindOfClass:[NSDictionary class]]) continue;
      FIRExprBridge *expr = [exprParser parseExpression:gm error:&parseErr];
      if (!expr) continue;
      groups[[NSString stringWithFormat:@"_%lu", (unsigned long)g]] = expr;
    }
  }

  return [[FIRAggregateStageBridge alloc] initWithAccumulators:accumulators groups:groups];
}

+ (void)executePipelineWithFirestore:(FIRFirestore *)firestore
                              stages:(NSArray<NSDictionary<NSString *, id> *> *)stages
                             options:(nullable NSDictionary<NSString *, id> *)options
                          completion:(void (^)(id _Nullable snapshot,
                                               NSError *_Nullable error))completion {
  if (!stages || stages.count == 0) {
    completion(nil, parseError(@"Pipeline requires at least one stage"));
    return;
  }

  NSError *parseErr = nil;
  NSArray<FIRStageBridge *> *stageBridges = [self parseStagesWithFirestore:firestore
                                                                    stages:stages
                                                                     error:&parseErr];
  if (!stageBridges) {
    completion(nil, parseErr);
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
  NSArray<FIRStageBridge *> *stageBridges = [self parseStagesWithFirestore:firestore
                                                                    stages:stages
                                                                     error:error];
  if (!stageBridges) return nil;
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
